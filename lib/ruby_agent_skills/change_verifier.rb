# frozen_string_literal: true

require "json"
require "open3"
require "shellwords"
require "time"
require_relative "runtime_profile"

module RubyAgentSkills
  # Verifies a change in a downstream Ruby/Rails project and emits an evidence
  # report. It runs the project's own tools (RuboCop, tests, Brakeman,
  # bundler-audit, zeitwerk:check) plus deterministic structural checks, and it
  # never reports "pass" for a check it could not run.
  #
  # Statuses per check:
  #   pass            ran and succeeded
  #   fail            ran and failed (or timed out)
  #   warn            advisory finding; never changes the overall status
  #   skipped         applicable but could not run (tool missing, not detected)
  #   not_applicable  nothing in the change requires this check
  #
  # Overall status is `fail` if any check failed, `incomplete` if any applicable
  # check was skipped, and `pass` otherwise.
  class ChangeVerifier
    SCHEMA_VERSION = 1
    CHECK_IDS = %w[
      runtime_profile dependency_lock_sync migration_integrity test_presence
      rubocop tests brakeman bundler_audit zeitwerk
    ].freeze
    OUTPUT_TAIL_BYTES = 4_000
    OUTPUT_CAP_BYTES = 10_000_000
    DEFAULT_TIMEOUT = 900
    LEAKING_ENV_KEYS = %w[BUNDLE_GEMFILE BUNDLE_BIN_PATH BUNDLER_SETUP BUNDLER_VERSION
                          RUBYLIB].freeze

    # Routing hints only: which owning skill's change contract applies to a
    # changed path. The verifier does not judge contract adherence.
    CONTRACT_POINTERS = [
      [%r{\Adb/migrate/|\Adb/(schema\.rb|structure\.sql)\z}, "rails-database-engineering"],
      [%r{\Aapp/models/}, "rails-active-record"],
      [%r{\Aapp/controllers/}, "rails-action-controller"],
      [%r{\Aapp/views/}, "rails-action-view"],
      [%r{\Aapp/jobs/}, "rails-active-job"],
      [%r{\Aapp/mailers/}, "rails-action-mailer"],
      [%r{\Aapp/channels/}, "rails-action-cable"],
      [%r{\Aconfig/routes\.rb\z}, "rails-routing"],
      [%r{\Aconfig/(initializers/|environments/|application\.rb\z)},
       "rails-initialization-configuration-engineering"],
      [%r{\A(spec|test)/}, "rails-test-engineering"],
      [/\A(Gemfile|Gemfile\.lock)\z/, "ruby-runtime-compatibility"],
      [%r{\A\.github/workflows/}, "rails-release-engineering"]
    ].freeze

    RUBY_EXTENSIONS = %w[.rb .rake .gemspec].freeze
    RUBY_BASENAMES = %w[Gemfile Rakefile config.ru].freeze
    FRONTEND_EXTENSIONS = %w[.ts .tsx .js .jsx .mjs .cjs .css .scss].freeze

    Result = Struct.new(:status, :exit_code, :stdout, :stderr, :duration, :timed_out,
                        keyword_init: true)

    # Runs one argv (no shell) with a timeout, killing the whole process group
    # on expiry. Replaceable in tests through `runner:`.
    class CommandRunner
      def call(argv, chdir:, timeout:)
        started = monotonic_now
        stdout = +""
        stderr = +""
        timed_out = false
        status = nil

        Open3.popen3(sanitized_env, *argv, chdir: chdir, pgroup: true) do |stdin, out, err, wait|
          stdin.close
          readers = [drain(out, stdout), drain(err, stderr)]
          timed_out = wait.join(timeout).nil?
          terminate(wait) if timed_out
          readers.each { |reader| reader.join(5) }
          status = wait.value
        end

        Result.new(status: :ran, exit_code: status.exitstatus, stdout: stdout, stderr: stderr,
                   duration: monotonic_now - started, timed_out: timed_out)
      rescue Errno::ENOENT, Errno::EACCES => e
        Result.new(status: :not_found, exit_code: nil, stdout: "", stderr: e.message,
                   duration: monotonic_now - started, timed_out: false)
      end

      private

      def sanitized_env
        LEAKING_ENV_KEYS.to_h { |key| [key, nil] }
      end

      def drain(io, buffer)
        Thread.new do # rubocop:disable ThreadSafety/NewThread -- per-call readers, no shared state
          io.each_line do |line|
            next unless buffer.bytesize < OUTPUT_CAP_BYTES

            normalized = line.dup.force_encoding("UTF-8")
            normalized = normalized.scrub unless normalized.valid_encoding?
            buffer << normalized
          end
        rescue IOError
          nil
        end
      end

      def terminate(wait)
        signal_group("TERM", wait.pid)
        return if wait.join(5)

        signal_group("KILL", wait.pid)
      end

      def signal_group(signal, pid)
        Process.kill(signal, -pid)
      rescue Errno::ESRCH, Errno::EPERM
        nil
      end

      def monotonic_now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end

    Change = Struct.new(:modified, :added, :deleted, :source, keyword_init: true) do
      def present
        (modified + added).uniq
      end

      def all
        (modified + added + deleted).uniq
      end
    end

    attr_reader :root

    def initialize(root:, base: nil, files: nil, only: nil, skip: [], test_command: nil,
                   timeout: DEFAULT_TIMEOUT, strict: false, include_output: true,
                   runner: CommandRunner.new, path_lookup: nil)
      @root = File.expand_path(root)
      @base = base
      @explicit_files = files
      @only = only
      @skip = skip
      @test_command = test_command
      @timeout = timeout
      @strict = strict
      @include_output = include_output
      @runner = runner
      @git_runner = CommandRunner.new
      @path_lookup = path_lookup || method(:executable_on_path?)
      validate_selection!
    end

    def call
      change = detect_change
      checks = selected_check_ids.to_h { |id| [id, run_check(id, change)] }
      overall = overall_status(checks)

      {
        "schema_version" => SCHEMA_VERSION,
        "generated_at" => Time.now.utc.iso8601,
        "repository" => root,
        "git" => git_evidence,
        "change" => change_evidence(change),
        "contract_pointers" => contract_pointers(change),
        "checks" => checks,
        "summary" => summary(checks),
        "overall" => overall_evidence(overall)
      }
    end

    def self.exit_code_for(report)
      report.dig("overall", "exit_code")
    end

    private

    def validate_selection!
      unknown = (Array(@only) + Array(@skip)) - CHECK_IDS
      raise ArgumentError, "unknown check id(s): #{unknown.join(', ')}" unless unknown.empty?
      raise ArgumentError, "repository path does not exist: #{root}" unless File.directory?(root)
      raise ArgumentError, "timeout must be positive" unless @timeout.to_f.positive?
    end

    def selected_check_ids
      ids = @only ? CHECK_IDS & @only : CHECK_IDS
      ids - @skip
    end

    # ---- change detection -------------------------------------------------

    def detect_change
      return explicit_change if @explicit_files
      unless git_repo?
        return Change.new(modified: [], added: [], deleted: [],
                          source: "unavailable")
      end

      modified = []
      added = []
      deleted = []
      diff_ranges.each do |range|
        parse_name_status(git("diff", "--name-status", "-z", "--no-renames",
                              *range)).each do |code, path|
          case code
          when "D" then deleted << path
          when "A" then added << path
          else modified << path
          end
        end
      end
      untracked = git("ls-files", "--others", "--exclude-standard", "-z").split("\0")
      deleted.uniq!
      present = (modified + added + untracked).uniq - deleted
      modified_only = (modified - added - untracked) & present
      Change.new(modified: modified_only, added: present - modified_only, deleted: deleted,
                 source: change_source)
    end

    def change_source
      @base ? "git diff #{@base}...HEAD plus working tree" : "git working tree vs HEAD"
    end

    def diff_ranges
      ranges = [["HEAD", "--"]]
      ranges.unshift(["#{@base}...HEAD", "--"]) if @base
      ranges
    end

    def explicit_change
      files = Array(@explicit_files).map { |path| path.to_s.delete_prefix("./") }.reject(&:empty?)
      existing, missing = files.partition { |path| File.file?(File.join(root, path)) }
      Change.new(modified: existing, added: [], deleted: missing, source: "explicit --files")
    end

    def parse_name_status(output)
      entries = output.split("\0").each_slice(2).map { |code, path| [code.to_s[0], path] }
      entries.select { |_, path| path }
    end

    def git_repo?
      return @git_repo if defined?(@git_repo)

      @git_repo = !git("rev-parse", "--is-inside-work-tree").strip.empty?
    end

    def git(*args)
      result = @git_runner.call(["git", "-C", root, *args], chdir: root, timeout: 60)
      return "" unless result.status == :ran && result.exit_code.zero?

      result.stdout
    end

    def git_evidence
      return { "available" => false } unless git_repo?

      {
        "available" => true,
        "head" => git("rev-parse", "HEAD").strip,
        "branch" => git("rev-parse", "--abbrev-ref", "HEAD").strip,
        "base" => @base,
        "dirty" => !git("status", "--porcelain").strip.empty?
      }
    end

    def change_evidence(change)
      {
        "source" => change.source,
        "modified" => change.modified.sort,
        "added" => change.added.sort,
        "deleted" => change.deleted.sort,
        "categories" => categories(change).transform_values(&:sort)
      }
    end

    def categories(change)
      present = change.present
      {
        "ruby" => present.select { |path| ruby_file?(path) },
        "tests" => present.select { |path| test_file?(path) },
        "migrations" => present.select { |path| migration?(path) },
        "dependencies" => present.select { |path| dependency_file?(path) },
        "frontend_unverified" => present.select do |path|
          FRONTEND_EXTENSIONS.include?(File.extname(path))
        end
      }
    end

    def ruby_file?(path)
      RUBY_EXTENSIONS.include?(File.extname(path)) || RUBY_BASENAMES.include?(File.basename(path))
    end

    def test_file?(path)
      path.match?(%r{\A(spec|test)/}) || path.match?(/_(spec|test)\.rb\z/)
    end

    def migration?(path)
      path.match?(%r{\Adb/migrate/[^/]+\.rb\z})
    end

    def dependency_file?(path)
      %w[Gemfile Gemfile.lock].include?(path) || path.end_with?(".gemspec")
    end

    def ruby_or_dependency_change?(change)
      change.present.any? { |path| ruby_file?(path) || dependency_file?(path) }
    end

    def source_file?(path)
      ruby_file?(path) && !test_file?(path) && !migration?(path) && path.match?(%r{\A(app|lib)/})
    end

    def contract_pointers(change)
      pointers = Hash.new { |hash, key| hash[key] = [] }
      change.all.each do |path|
        CONTRACT_POINTERS.each { |pattern, skill| pointers[skill] << path if path.match?(pattern) }
      end
      list = pointers.map { |skill, paths| { "skill" => skill, "paths" => paths.sort } }
      list.sort_by { |entry| entry["skill"] }
    end

    # ---- check dispatch ---------------------------------------------------

    def run_check(id, change)
      check = send(:"check_#{id}", change)
      check["id"] = id
      check
    rescue StandardError => e
      { "id" => id, "status" => "fail", "reason" => "verifier error: #{e.class}: #{e.message}" }
    end

    def check_runtime_profile(_change)
      profile = RuntimeProfile.call(root)
      warnings = Array(profile["warnings"])
      summary = { "ruby" => profile.dig("ruby", "resolved"),
                  "rails" => profile.dig("rails", "resolved") }
      base = { "summary" => summary, "warnings" => warnings }
      return base.merge("status" => "pass") if warnings.empty?

      base.merge("status" => "warn",
                 "reason" => "runtime evidence has #{warnings.length} warning(s)")
    end

    def check_dependency_lock_sync(change)
      return not_applicable("Gemfile unchanged") unless change.present.include?("Gemfile")
      return not_applicable("Gemfile.lock is not tracked") unless tracked?("Gemfile.lock")
      if change.present.include?("Gemfile.lock")
        return pass("Gemfile and Gemfile.lock changed together")
      end

      fail_check("Gemfile changed but Gemfile.lock did not; " \
                 "run `bundle install` and commit the lockfile")
    end

    def check_migration_integrity(change)
      migrations = change.present.select { |path| migration?(path) }
      return not_applicable("no migration files changed") if migrations.empty?

      problems = []
      schema = %w[db/schema.rb db/structure.sql].select { |path| tracked?(path) }
      if schema.any? && !schema.intersect?(change.present)
        problems << "migration changed but #{schema.join(' / ')} did not; " \
                    "run the migration and commit the schema dump"
      end
      edited = change.modified.select { |path| migration?(path) }
      return fail_check(problems.join("; ")) unless problems.empty?
      return pass("#{migrations.length} migration(s) changed with schema dump") if edited.empty?

      warn_check("edited existing migration(s): #{edited.sort.join(', ')}; " \
                 "prefer a new migration once a migration has shipped")
    end

    def check_test_presence(change)
      sources = change.present.select { |path| source_file?(path) }
      return not_applicable("no application/library Ruby source changed") if sources.empty?
      return pass("test or spec files changed alongside source") if change.present.any? do |p|
        test_file?(p)
      end

      warn_check("#{sources.length} source file(s) changed without any test/spec change; " \
                 "confirm existing tests cover the behavior")
    end

    def check_rubocop(change)
      files = change.present.select { |path| ruby_file?(path) }
      return not_applicable("no Ruby files changed") if files.empty?
      return not_applicable("no .rubocop.yml in the repository") unless file?(".rubocop.yml")

      command = tool_command("rubocop") or return skipped_tool("rubocop")
      argv = command + ["--force-exclusion", "--format", "json", "--", *files]
      execute(argv, "rubocop") { |result| rubocop_summary(result.stdout) }
    end

    def check_tests(change)
      unless ruby_or_dependency_change?(change)
        return not_applicable("no Ruby or dependency change")
      end

      argv = test_argv
      return skipped("no test runner detected; pass --test-command") unless argv

      execute(argv, "tests")
    end

    def check_brakeman(change)
      return not_applicable("not a Rails application") unless rails_app?
      unless ruby_or_dependency_change?(change)
        return not_applicable("no Ruby or dependency change")
      end

      command = tool_command("brakeman") or return skipped_tool("brakeman")
      execute(command + ["--no-pager", "--quiet", "--format", "json"], "brakeman") do |result|
        brakeman_summary(result.stdout)
      end
    end

    def check_bundler_audit(change)
      return not_applicable("Gemfile.lock is not present") unless file?("Gemfile.lock")
      return not_applicable("dependencies unchanged") unless change.present.any? do |p|
        dependency_file?(p)
      end

      command = tool_command("bundler-audit") or return skipped_tool("bundler-audit")
      execute(command + ["check"], "bundler-audit")
    end

    def check_zeitwerk(change)
      return not_applicable("not a Rails application") unless rails_app?

      touched = change.all.any? { |path| path.match?(%r{\A(app|lib|config)/}) && ruby_file?(path) }
      return not_applicable("no app/, lib/, or config/ Ruby change") unless touched

      argv = rails_command + ["zeitwerk:check"]
      execute(argv, "zeitwerk")
    end

    # ---- execution --------------------------------------------------------

    def execute(argv, label)
      result = @runner.call(argv, chdir: root, timeout: @timeout)
      if result.status == :not_found
        return skipped("#{argv.first} could not be started: #{result.stderr}")
      end
      return skipped("#{label} is not installed: #{first_line(result)}") if tool_missing?(result)

      evidence = {
        "command" => argv.shelljoin,
        "exit_code" => result.exit_code,
        "duration_seconds" => result.duration.round(2)
      }
      evidence["output_tail"] = output_tail(result) if @include_output
      evidence["summary"] = yield(result) if block_given?

      if result.timed_out
        evidence.merge("status" => "fail", "reason" => "#{label} timed out after #{@timeout}s")
      elsif result.exit_code.zero?
        evidence.merge("status" => "pass")
      else
        evidence.merge("status" => "fail", "reason" => "#{label} exited #{result.exit_code}")
      end
    end

    # `bundle exec` reports a missing executable as 127 and a missing gem as 7.
    def tool_missing?(result)
      return true if result.exit_code == 127

      result.exit_code == 7 && result.stderr.match?(/Could not find .* in/)
    end

    def first_line(result)
      result.stderr.lines.first.to_s.strip
    end

    def output_tail(result)
      combined = [result.stdout, result.stderr].reject(&:empty?).join("\n--- stderr ---\n")
      combined.byteslice([combined.bytesize - OUTPUT_TAIL_BYTES, 0].max, OUTPUT_TAIL_BYTES)
              .to_s.scrub("?")
    end

    def rubocop_summary(stdout)
      data = JSON.parse(stdout)
      offenses = data.fetch("files", []).flat_map do |file|
        file.fetch("offenses", []).map do |o|
          "#{file['path']}:#{o.dig('location', 'line')} #{o['cop_name']}"
        end
      end
      { "offense_count" => data.dig("summary", "offense_count"), "offenses" => offenses.first(20) }
    rescue JSON::ParserError, KeyError, TypeError
      nil
    end

    def brakeman_summary(stdout)
      data = JSON.parse(stdout)
      { "warnings" => Array(data["warnings"]).length, "errors" => Array(data["errors"]).length }
    rescue JSON::ParserError, TypeError
      nil
    end

    # ---- tool and project detection --------------------------------------

    def test_argv
      return Shellwords.split(@test_command) if @test_command

      if Dir.exist?(File.join(root, "spec")) && gem_locked?("rspec-core")
        return bundled + ["exec", "rspec"] if bundled?
        return ["rspec"] if @path_lookup.call("rspec")
      end
      rails_command + ["test"] if rails_app? && Dir.exist?(File.join(root, "test"))
    end

    def tool_command(name)
      return ["bundle", "exec", name] if bundled? && gem_locked?(name)
      return [name] if @path_lookup.call(name)

      nil
    end

    def rails_command
      return ["bin/rails"] unless bundled?

      %w[bundle exec rails]
    end

    def bundled
      ["bundle"]
    end

    def bundled?
      file?("Gemfile") && @path_lookup.call("bundle")
    end

    def rails_app?
      file?("config/application.rb") && (file?("bin/rails") || gem_locked?("rails"))
    end

    def gem_locked?(name)
      lock = File.join(root, "Gemfile.lock")
      return false unless File.file?(lock)

      File.read(lock, encoding: "UTF-8").match?(/^\s{4}#{Regexp.escape(name)} \(/)
    end

    def tracked?(path)
      return file?(path) unless git_repo?

      !git("ls-files", "--", path).strip.empty?
    end

    def file?(path)
      File.file?(File.join(root, path))
    end

    def executable_on_path?(name)
      ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? do |dir|
        candidate = File.join(dir, name)
        File.file?(candidate) && File.executable?(candidate)
      end
    end

    # ---- result helpers ---------------------------------------------------

    def pass(reason)
      { "status" => "pass", "reason" => reason }
    end

    def fail_check(reason)
      { "status" => "fail", "reason" => reason }
    end

    def warn_check(reason)
      { "status" => "warn", "reason" => reason }
    end

    def skipped(reason)
      { "status" => "skipped", "reason" => reason }
    end

    def skipped_tool(name)
      skipped("#{name} is not installed in the project bundle or on PATH")
    end

    def not_applicable(reason)
      { "status" => "not_applicable", "reason" => reason }
    end

    # ---- aggregation ------------------------------------------------------

    def summary(checks)
      counts = %w[pass fail warn skipped not_applicable].to_h { |status| [status, 0] }
      checks.each_value { |check| counts[check["status"]] += 1 }
      counts
    end

    def overall_status(checks)
      statuses = checks.values.map { |check| check["status"] }
      return "fail" if statuses.include?("fail")
      return "incomplete" if statuses.include?("skipped")

      "pass"
    end

    def overall_evidence(status)
      code = case status
             when "fail" then 1
             when "incomplete" then @strict ? 3 : 0
             else 0
             end
      { "status" => status, "strict" => @strict, "exit_code" => code }
    end
  end

  class ChangeVerifier
    # Renders a report as Markdown suitable for a pull-request comment.
    module MarkdownReport
      ICONS = { "pass" => "PASS", "fail" => "FAIL", "warn" => "WARN", "skipped" => "SKIPPED",
                "not_applicable" => "n/a" }.freeze

      module_function

      def call(report)
        lines = ["## Change verification: #{report.dig('overall', 'status').upcase}", ""]
        lines.concat(git_lines(report))
        lines.push("| Check | Status | Detail |", "| --- | --- | --- |")
        report["checks"].each { |id, check| lines << row(id, check) }
        lines.concat(contract_lines(report))
        lines << ""
        lines << "Skipped or not-applicable checks were not run; `incomplete` is not a pass."
        lines.join("\n")
      end

      def git_lines(report)
        git = report["git"]
        return [] unless git["available"]

        head = git["head"].to_s[0, 12]
        dirty = git["dirty"] ? " (dirty worktree)" : ""
        ["`#{head}` on `#{git['branch']}`#{dirty}", ""]
      end

      def row(id, check)
        detail = check["reason"] || check["summary"]&.to_json || ""
        "| #{id} | #{ICONS.fetch(check['status'])} | #{detail.to_s.gsub('|', '\\|').tr("\n",
                                                                                       ' ')} |"
      end

      def contract_lines(report)
        pointers = report["contract_pointers"]
        return [] if pointers.empty?

        skills = pointers.map { |entry| "`#{entry['skill']}`" }.join(", ")
        ["", "Owning skills whose change contract applies " \
             "(routing hint, adherence not verified): #{skills}"]
      end
    end
  end
end
