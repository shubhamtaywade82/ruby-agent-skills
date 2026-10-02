# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"
require "json"
require "rbconfig"
require "yaml"
require_relative "../lib/ruby_agent_skills/change_verifier"

ROOT = File.expand_path("..", __dir__)

# Scripted stand-in for CommandRunner: records every argv and answers from a
# table keyed by the executable name (the last matching entry wins).
class ScriptedRunner
  attr_reader :calls

  def initialize(responses = {})
    @responses = responses
    @calls = []
  end

  def call(argv, chdir:, timeout:)
    @calls << { argv: argv, chdir: chdir, timeout: timeout }
    key = @responses.keys.reverse.find { |name| argv.include?(name) }
    @responses.fetch(key) { ok }
  end

  def ok(stdout = "")
    RubyAgentSkills::ChangeVerifier::Result.new(status: :ran, exit_code: 0, stdout: stdout, stderr: "",
                                                duration: 0.01, timed_out: false)
  end
end

module ChangeVerifierHelpers
  V = RubyAgentSkills::ChangeVerifier

  def result(exit_code:, stdout: "", stderr: "", timed_out: false)
    V::Result.new(status: :ran, exit_code: exit_code, stdout: stdout, stderr: stderr,
                  duration: 0.01, timed_out: timed_out)
  end

  def with_project(files = {})
    Dir.mktmpdir do |dir|
      files.each do |path, content|
        FileUtils.mkdir_p(File.dirname(File.join(dir, path)))
        File.write(File.join(dir, path), content)
      end
      yield dir
    end
  end

  def git(dir, *args)
    out, err, status = Open3.capture3("git", "-C", dir, *args)
    raise "git #{args.join(' ')} failed: #{err}" unless status.success?

    out
  end

  def init_repo(dir)
    git(dir, "init", "-q")
    git(dir, "config", "user.email", "test@example.com")
    git(dir, "config", "user.name", "Test")
    git(dir, "add", "-A")
    git(dir, "commit", "-q", "--allow-empty", "-m", "init")
  end

  def write(dir, path, content = "x\n")
    FileUtils.mkdir_p(File.dirname(File.join(dir, path)))
    File.write(File.join(dir, path), content)
  end

  def verify(dir, runner: ScriptedRunner.new, **)
    V.new(root: dir, runner: runner, path_lookup: ->(_name) { true }, **).call
  end
end

class ChangeVerifierDetectionTest < Minitest::Test
  include ChangeVerifierHelpers

  def test_classifies_added_modified_untracked_and_deleted_files_from_git
    with_project("app/models/a.rb" => "1", "app/models/gone.rb" => "1", "README.md" => "1") do |dir|
      init_repo(dir)
      write(dir, "app/models/a.rb", "2")
      write(dir, "app/models/new.rb")
      File.delete(File.join(dir, "app/models/gone.rb"))

      change = verify(dir, only: ["test_presence"]).fetch("change")

      assert_equal ["app/models/a.rb"], change.fetch("modified")
      assert_equal ["app/models/new.rb"], change.fetch("added")
      assert_equal ["app/models/gone.rb"], change.fetch("deleted")
    end
  end

  def test_base_ref_includes_committed_branch_changes
    with_project("app/models/a.rb" => "1") do |dir|
      init_repo(dir)
      git(dir, "checkout", "-q", "-b", "feature")
      write(dir, "app/models/b.rb")
      git(dir, "add", "-A")
      git(dir, "commit", "-q", "-m", "feature")
      base = git(dir, "rev-parse", "HEAD~1").strip

      without_base = verify(dir, only: ["test_presence"]).fetch("change")
      with_base = verify(dir, base: base, only: ["test_presence"]).fetch("change")

      assert_empty without_base.fetch("added")
      assert_equal ["app/models/b.rb"], with_base.fetch("added")
      assert_includes with_base.fetch("source"), base
    end
  end

  def test_explicit_files_skip_git_detection
    with_project("app/models/a.rb" => "1") do |dir|
      report = verify(dir, files: ["./app/models/a.rb", "app/models/missing.rb"],
                           only: ["test_presence"])

      assert_equal "explicit --files", report.dig("change", "source")
      assert_equal ["app/models/a.rb"], report.dig("change", "modified")
      assert_equal ["app/models/missing.rb"], report.dig("change", "deleted")
      refute report.dig("git", "available")
    end
  end

  def test_non_git_directory_reports_unavailable_change_source
    with_project("app/models/a.rb" => "1") do |dir|
      report = verify(dir, only: ["rubocop"])

      assert_equal "unavailable", report.dig("change", "source")
      assert_equal "not_applicable", report.dig("checks", "rubocop", "status")
    end
  end

  def test_contract_pointers_name_only_skills_that_exist_in_the_pack
    pointed = RubyAgentSkills::ChangeVerifier::CONTRACT_POINTERS.map(&:last).uniq
    manifest_skills = Dir[File.join(ROOT, "skills", "*", "SKILL.md")].map do |path|
      File.basename(File.dirname(path))
    end

    assert_empty pointed - manifest_skills
  end

  def test_contract_pointers_map_changed_paths_to_owning_skills
    with_project("db/migrate/20240101000000_x.rb" => "1",
                 "app/controllers/a_controller.rb" => "1") do |dir|
      report = verify(dir,
                      files: %w[db/migrate/20240101000000_x.rb app/controllers/a_controller.rb], only: [])
      skills = report.fetch("contract_pointers").map { |entry| entry.fetch("skill") }

      assert_equal %w[rails-action-controller rails-database-engineering], skills
    end
  end
end

class ChangeVerifierChecksTest < Minitest::Test
  include ChangeVerifierHelpers

  def test_documentation_only_change_runs_no_tools_and_passes
    with_project("README.md" => "1", ".rubocop.yml" => "AllCops: {}\n") do |dir|
      runner = ScriptedRunner.new
      report = verify(dir, files: ["README.md"], runner: runner, skip: ["runtime_profile"])

      assert_equal "pass", report.dig("overall", "status")
      assert_empty runner.calls
    end
  end

  def test_rubocop_runs_on_changed_ruby_files_only_and_passes_paths_after_double_dash
    with_project(".rubocop.yml" => "AllCops: {}\n", "Gemfile" => "",
                 "Gemfile.lock" => "    rubocop (1.0)\n") do |dir|
      runner = ScriptedRunner.new("rubocop" => ScriptedRunner.new.ok('{"files":[],"summary":{"offense_count":0}}'))
      files = ["-rf.rb", "lib/a.rb", "README.md"]
      files.each { |path| write(dir, path) }

      report = verify(dir, files: files, runner: runner, only: ["rubocop"])
      argv = runner.calls.first.fetch(:argv)

      assert_equal %w[bundle exec rubocop], argv.first(3)
      assert_equal ["--", "-rf.rb", "lib/a.rb"], argv.last(3)
      assert_equal "pass", report.dig("checks", "rubocop", "status")
      assert_equal 0, report.dig("checks", "rubocop", "summary", "offense_count")
    end
  end

  def test_rubocop_offenses_fail_the_check_and_are_summarised
    offenses = { files: [{ path: "lib/a.rb", offenses: [{ cop_name: "Lint/Void", location: { line: 3 } }] }],
                 summary: { offense_count: 1 } }
    with_project(".rubocop.yml" => "AllCops: {}\n", "lib/a.rb" => "1") do |dir|
      runner = ScriptedRunner.new("rubocop" => result(exit_code: 1, stdout: offenses.to_json))

      report = verify(dir, files: ["lib/a.rb"], runner: runner, only: ["rubocop"])

      assert_equal "fail", report.dig("checks", "rubocop", "status")
      assert_equal ["lib/a.rb:3 Lint/Void"], report.dig("checks", "rubocop", "summary", "offenses")
      assert_equal 1, report.dig("overall", "exit_code")
    end
  end

  def test_missing_tool_is_skipped_and_overall_is_incomplete_never_pass
    with_project(".rubocop.yml" => "AllCops: {}\n", "lib/a.rb" => "1") do |dir|
      lenient = V.new(root: dir, files: ["lib/a.rb"], only: ["rubocop"], path_lookup: lambda { |_|
        false
      })
      strict = V.new(root: dir, files: ["lib/a.rb"], only: ["rubocop"], path_lookup: lambda { |_|
        false
      },
                     strict: true)

      report = lenient.call

      assert_equal "skipped", report.dig("checks", "rubocop", "status")
      assert_equal "incomplete", report.dig("overall", "status")
      assert_equal 0, report.dig("overall", "exit_code")
      assert_equal 3, strict.call.dig("overall", "exit_code")
    end
  end

  def test_bundler_missing_executable_exit_127_is_skipped_not_failed
    with_project(".rubocop.yml" => "AllCops: {}\n", "Gemfile" => "", "Gemfile.lock" => "    rubocop (1.0)\n",
                 "lib/a.rb" => "1") do |dir|
      runner = ScriptedRunner.new("rubocop" => result(exit_code: 127,
                                                      stderr: "bundler: command not found: rubocop"))

      report = verify(dir, files: ["lib/a.rb"], runner: runner, only: ["rubocop"])

      assert_equal "skipped", report.dig("checks", "rubocop", "status")
    end
  end

  def test_test_command_override_is_split_without_a_shell
    with_project("lib/a.rb" => "1") do |dir|
      runner = ScriptedRunner.new
      verify(dir, files: ["lib/a.rb"], runner: runner, only: ["tests"],
                  test_command: "echo a; touch pwned")

      assert_equal ["echo", "a;", "touch", "pwned"], runner.calls.first.fetch(:argv)
    end
  end

  def test_rspec_is_detected_from_the_lockfile_and_failure_fails_the_check
    with_project("spec/a_spec.rb" => "", "Gemfile" => "", "Gemfile.lock" => "    rspec-core (3.13.0)\n",
                 "lib/a.rb" => "1") do |dir|
      runner = ScriptedRunner.new("rspec" => result(exit_code: 1, stdout: "1 failure"))

      report = verify(dir, files: ["lib/a.rb"], runner: runner, only: ["tests"])

      assert_equal %w[bundle exec rspec], runner.calls.first.fetch(:argv)
      assert_equal "fail", report.dig("checks", "tests", "status")
      assert_includes report.dig("checks", "tests", "output_tail"), "1 failure"
    end
  end

  def test_no_test_runner_is_skipped_with_an_actionable_reason
    with_project("lib/a.rb" => "1") do |dir|
      report = verify(dir, files: ["lib/a.rb"], only: ["tests"])

      assert_equal "skipped", report.dig("checks", "tests", "status")
      assert_includes report.dig("checks", "tests", "reason"), "--test-command"
    end
  end

  def test_no_output_omits_command_output_tails
    with_project("lib/a.rb" => "1") do |dir|
      runner = ScriptedRunner.new("echo" => result(exit_code: 0, stdout: "secret-token"))
      report = verify(dir, files: ["lib/a.rb"], runner: runner, only: ["tests"], test_command: "echo hi",
                           include_output: false)

      refute report.dig("checks", "tests").key?("output_tail")
      refute_includes JSON.generate(report), "secret-token"
    end
  end

  def test_timeout_fails_the_check
    with_project("lib/a.rb" => "1") do |dir|
      runner = ScriptedRunner.new("sleeper" => result(exit_code: 1, timed_out: true))
      report = verify(dir, files: ["lib/a.rb"], runner: runner, only: ["tests"],
                           test_command: "sleeper", timeout: 7)

      assert_equal "fail", report.dig("checks", "tests", "status")
      assert_includes report.dig("checks", "tests", "reason"), "timed out after 7"
    end
  end

  def test_rails_checks_apply_only_to_rails_applications
    with_project("lib/a.rb" => "1") do |dir|
      report = verify(dir, files: ["lib/a.rb"], only: %w[brakeman zeitwerk])

      assert_equal "not_applicable", report.dig("checks", "brakeman", "status")
      assert_equal "not_applicable", report.dig("checks", "zeitwerk", "status")
    end
  end

  def test_rails_application_runs_zeitwerk_and_brakeman
    files = { "config/application.rb" => "", "bin/rails" => "", "app/models/a.rb" => "1",
              "Gemfile" => "", "Gemfile.lock" => "    rails (8.0.0)\n    brakeman (7.0.0)\n" }
    with_project(files) do |dir|
      runner = ScriptedRunner.new("brakeman" => result(exit_code: 0,
                                                       stdout: '{"warnings":[],"errors":[]}'))

      report = verify(dir, files: ["app/models/a.rb"], runner: runner, only: %w[brakeman zeitwerk])
      commands = runner.calls.map { |call| call.fetch(:argv).join(" ") }

      assert_includes commands, "bundle exec rails zeitwerk:check"
      assert(commands.any? { |command| command.start_with?("bundle exec brakeman --no-pager") })
      assert_equal({ "warnings" => 0, "errors" => 0 }, report.dig("checks", "brakeman", "summary"))
    end
  end

  def test_bundler_audit_runs_only_when_dependencies_changed
    with_project("Gemfile" => "", "Gemfile.lock" => "    bundler-audit (0.9.0)\n",
                 "lib/a.rb" => "1") do |dir|
      unchanged = verify(dir, files: ["lib/a.rb"], only: ["bundler_audit"])
      changed = verify(dir, files: ["Gemfile.lock"], only: ["bundler_audit"])

      assert_equal "not_applicable", unchanged.dig("checks", "bundler_audit", "status")
      assert_equal "pass", changed.dig("checks", "bundler_audit", "status")
    end
  end

  def test_verifier_error_in_one_check_is_reported_as_fail_not_raised
    with_project("lib/a.rb" => "1") do |dir|
      exploding = Object.new
      def exploding.call(*, **) = raise("boom")

      report = V.new(root: dir, files: ["lib/a.rb"], only: ["tests"], test_command: "x", runner: exploding,
                     path_lookup: ->(_) { true }).call

      assert_equal "fail", report.dig("checks", "tests", "status")
      assert_includes report.dig("checks", "tests", "reason"), "boom"
    end
  end

  def test_only_and_skip_select_checks_and_reject_unknown_ids
    with_project("README.md" => "1") do |dir|
      assert_equal %w[tests],
                   verify(dir, files: ["README.md"], only: ["tests"]).fetch("checks").keys
      refute_includes verify(dir, files: ["README.md"], skip: ["tests"]).fetch("checks").keys,
                      "tests"
      assert_raises(ArgumentError) { V.new(root: dir, only: ["nope"]) }
      assert_raises(ArgumentError) { V.new(root: "/nonexistent-#{rand(1_000_000)}") }
      assert_raises(ArgumentError) { V.new(root: dir, timeout: 0) }
    end
  end
end

class ChangeVerifierStructuralChecksTest < Minitest::Test
  include ChangeVerifierHelpers

  def test_gemfile_change_without_lockfile_change_fails
    with_project("Gemfile" => "1", "Gemfile.lock" => "1") do |dir|
      init_repo(dir)
      write(dir, "Gemfile", "2")

      check = verify(dir, only: ["dependency_lock_sync"]).dig("checks", "dependency_lock_sync")

      assert_equal "fail", check.fetch("status")

      write(dir, "Gemfile.lock", "2")

      assert_equal "pass",
                   verify(dir, only: ["dependency_lock_sync"]).dig("checks",
                                                                   "dependency_lock_sync", "status")
    end
  end

  def test_untracked_lockfile_makes_lock_sync_not_applicable
    with_project("Gemfile" => "1") do |dir|
      init_repo(dir)
      write(dir, "Gemfile", "2")

      assert_equal "not_applicable",
                   verify(dir, only: ["dependency_lock_sync"]).dig("checks",
                                                                   "dependency_lock_sync", "status")
    end
  end

  def test_migration_without_schema_dump_fails_and_with_it_passes
    with_project("db/schema.rb" => "1") do |dir|
      init_repo(dir)
      write(dir, "db/migrate/20240101000000_add_x.rb")

      assert_equal "fail",
                   verify(dir, only: ["migration_integrity"]).dig("checks", "migration_integrity",
                                                                  "status")

      write(dir, "db/schema.rb", "2")

      assert_equal "pass",
                   verify(dir, only: ["migration_integrity"]).dig("checks", "migration_integrity",
                                                                  "status")
    end
  end

  def test_editing_a_committed_migration_warns_but_does_not_fail_overall
    with_project("db/schema.rb" => "1", "db/migrate/20240101000000_add_x.rb" => "1") do |dir|
      init_repo(dir)
      write(dir, "db/schema.rb", "2")
      write(dir, "db/migrate/20240101000000_add_x.rb", "2")

      report = verify(dir, only: ["migration_integrity"])

      assert_equal "warn", report.dig("checks", "migration_integrity", "status")
      assert_equal "pass", report.dig("overall", "status")
    end
  end

  def test_source_change_without_test_change_warns
    with_project("app/models/a.rb" => "1", "spec/models/a_spec.rb" => "1") do |dir|
      warned = verify(dir, files: ["app/models/a.rb"], only: ["test_presence"])
      covered = verify(dir, files: ["app/models/a.rb", "spec/models/a_spec.rb"],
                            only: ["test_presence"])

      assert_equal "warn", warned.dig("checks", "test_presence", "status")
      assert_equal "pass", covered.dig("checks", "test_presence", "status")
    end
  end
end

class ChangeVerifierRunnerTest < Minitest::Test
  def test_runner_kills_a_command_that_exceeds_the_timeout
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = RubyAgentSkills::ChangeVerifier::CommandRunner.new
                                                           .call([RbConfig.ruby, "-e",
                                                                  "sleep 30"], chdir: Dir.pwd, timeout: 1)

    assert result.timed_out
    assert_operator Process.clock_gettime(Process::CLOCK_MONOTONIC) - started, :<, 15
  end

  def test_runner_normalizes_non_ascii_command_output
    result = RubyAgentSkills::ChangeVerifier::CommandRunner.new
                                                           .call([RbConfig.ruby, "-e", "STDOUT.write(%q{hello — world})"],
                                                                 chdir: Dir.pwd, timeout: 5)

    assert result.stdout.valid_encoding?
    assert_equal "hello — world", result.stdout
  end

  def test_runner_reports_missing_executables_without_raising
    result = RubyAgentSkills::ChangeVerifier::CommandRunner.new
                                                           .call(["definitely-not-a-real-binary"], chdir: Dir.pwd, timeout: 5)

    assert_equal :not_found, result.status
  end

  def test_runner_does_not_leak_bundler_environment_into_the_project
    result = RubyAgentSkills::ChangeVerifier::CommandRunner.new
                                                           .call([RbConfig.ruby, "-e",
                                                                  'print ENV["BUNDLE_GEMFILE"].inspect'], chdir: Dir.pwd, timeout: 10)

    assert_equal "nil", result.stdout
  end
end

class VerifyChangeCliTest < Minitest::Test
  include ChangeVerifierHelpers

  def cli(dir, *, env: {})
    Open3.capture3(env, RbConfig.ruby, File.join(ROOT, "bin/verify-change"), dir, *)
  end

  def test_json_report_carries_provenance_and_writes_an_evidence_file
    with_project("README.md" => "1") do |dir|
      init_repo(dir)
      write(dir, "README.md", "2")
      out = File.join(dir, "tmp", "evidence.json")

      stdout, stderr, status = cli(dir, "--out", out, "--skip", "runtime_profile")
      report = JSON.parse(stdout)

      assert_predicate status, :success?, stderr
      assert_equal 1, report.fetch("schema_version")
      assert_equal git(dir, "rev-parse", "HEAD").strip, report.dig("git", "head")
      assert_match(/\A\d{4}-\d\d-\d\dT/, report.fetch("generated_at"))
      assert_equal report.except("generated_at"), JSON.parse(File.read(out)).except("generated_at")
    end
  end

  def test_failing_change_exits_one_and_strict_incomplete_exits_three
    with_project("Gemfile" => "1", "Gemfile.lock" => "1", "lib/a.rb" => "1",
                 ".rubocop.yml" => "AllCops: {}\n") do |dir|
      init_repo(dir)
      write(dir, "Gemfile", "2")

      _, _, failing = cli(dir, "--only", "dependency_lock_sync")

      assert_equal 1, failing.exitstatus

      write(dir, "Gemfile.lock", "2")
      write(dir, "lib/a.rb", "2")
      bare_path = File.dirname(Open3.capture2("which", "git").first.strip)
      bin = File.join(dir, "bin-only")
      FileUtils.mkdir_p(bin)
      File.symlink(File.join(bare_path, "git"), File.join(bin, "git"))
      _, _, lenient = cli(dir, "--only", "rubocop", env: { "PATH" => bin })
      _, _, strict = cli(dir, "--only", "rubocop", "--strict", env: { "PATH" => bin })

      assert_equal 0, lenient.exitstatus
      assert_equal 3, strict.exitstatus
    end
  end

  def test_usage_errors_exit_two
    with_project("README.md" => "1") do |dir|
      assert_equal 2, cli(dir, "--only", "nope").last.exitstatus
      assert_equal 2, cli(dir, "--format", "xml").last.exitstatus
      assert_equal 2, cli(File.join(dir, "missing")).last.exitstatus
    end
  end

  def test_markdown_format_and_list_checks
    with_project("README.md" => "1") do |dir|
      markdown, = cli(dir, "--format", "markdown", "--files", "README.md")
      checks, = cli(dir, "--list-checks")

      assert_includes markdown, "## Change verification: "
      assert_includes markdown, "| rubocop |"
      assert_equal RubyAgentSkills::ChangeVerifier::CHECK_IDS, checks.split
    end
  end

  def test_verifies_this_repository_layout_end_to_end_on_a_docs_only_change
    stdout, _, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "bin/verify-change"), ROOT,
                                       "--files", "README.md", "--skip", "runtime_profile")

    assert_predicate status, :success?
    assert_equal "pass", JSON.parse(stdout).dig("overall", "status")
  end

  def test_documentation_and_manifest_register_the_tool
    doc = File.read(File.join(ROOT, "docs/VERIFY_CHANGE.md"), encoding: "UTF-8")
    manifest = YAML.safe_load_file(File.join(ROOT, "skill-manifest.yml"), permitted_classes: [],
                                                                          aliases: false)

    assert_equal "bin/verify-change", manifest.dig("installation", "change_verifier")
    RubyAgentSkills::ChangeVerifier::CHECK_IDS.each { |id| assert_includes doc, "`#{id}`" }
  end
end
