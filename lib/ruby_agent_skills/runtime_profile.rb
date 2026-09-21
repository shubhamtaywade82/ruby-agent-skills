# frozen_string_literal: true


module RubyAgentSkills
  module RuntimeProfile
    module_function

    def call(root)
      root = File.expand_path(root)

      {
        "schema_version" => 1,
        "repository" => root,
        "ruby" => resolve_ruby(root),
        "rails" => resolve_rails(root),
        "bundler" => resolve_bundler(root),
        "ci" => resolve_ci_versions(root),
        "evidence_files" => evidence_files(root),
        "warnings" => warnings(root)
      }
    end

    def resolve_ruby(root)
      candidates = []

      exact = read(root, ".ruby-version")
      add_candidate(candidates, exact.strip, ".ruby-version", "exact") if exact && !exact.strip.empty?

      lock = read(root, "Gemfile.lock")
      if lock
        ruby = lock[/^RUBY VERSION\n\s+ruby\s+([^\s]+)/, 1]
        add_candidate(candidates, ruby, "Gemfile.lock:RUBY VERSION", "lockfile_ruby") if ruby
      end

      gemfile = read(root, "Gemfile")
      if gemfile
        gemfile.scan(/^\s*ruby\s+(.+)$/).each do |match|
          add_candidate(candidates, match.first.strip, "Gemfile:ruby", "ruby_constraint")
        end
      end

      Dir[File.join(root, "*.gemspec")].sort.each do |path|
        content = File.read(path, encoding: "UTF-8")
        content.scan(/required_ruby_version\s*=\s*([^\n]+)/).each do |match|
          add_candidate(candidates, match.first.strip, relative(root, path) + ":required_ruby_version", "gemspec_constraint")
        end
      end

      tool_versions = read(root, ".tool-versions")
      if tool_versions
        line = tool_versions.lines.find { |entry| entry.match?(/^ruby\s+/) }
        add_candidate(candidates, line.split.drop(1).join(" "), ".tool-versions:ruby", "tool_version") if line
      end

      [".mise.toml", "mise.toml"].each do |name|
        content = read(root, name)
        next unless content

        content.scan(/ruby\s*=\s*["']([^"']+)["']/).flatten.each do |version|
          add_candidate(candidates, version, name + ":ruby", "tool_version")
        end
      end

      resolved = resolution(candidates, %w[lockfile_ruby exact])
      build_version_result(resolved, candidates, preferred_conflict_types: %w[lockfile_ruby exact])
    end

    def resolve_rails(root)
      candidates = []
      lock = read(root, "Gemfile.lock")

      if lock
        rails = lock[/^\s{4}rails \(([^)]+)\)$/, 1]
        add_candidate(candidates, rails, "Gemfile.lock:rails", "lockfile_rails") if rails
      end

      gemfile = read(root, "Gemfile")
      if gemfile
        gemfile.scan(/^\s*gem\s+["']rails["']\s*(?:,\s*(.+))?$/).each do |match|
          add_candidate(candidates, (match.first || "any").strip, "Gemfile:rails", "rails_constraint")
        end
      end

      resolved = resolution(candidates, %w[lockfile_rails])
      build_version_result(resolved, candidates, preferred_conflict_types: %w[lockfile_rails])
    end

    def resolve_bundler(root)
      lock = read(root, "Gemfile.lock")
      candidate = lock && lock[/^BUNDLED WITH\n\s+(.+)$/, 1]

      {
        "resolved" => candidate,
        "source" => candidate ? "Gemfile.lock:BUNDLED WITH" : nil,
        "status" => candidate ? "resolved" : "unknown"
      }
    end

    def resolve_ci_versions(root)
      files = Dir[
        File.join(root, ".github/workflows/**/*.{yml,yaml}"),
        File.join(root, ".gitlab-ci.yml")
      ].uniq.sort

      ruby_versions = []
      rails_versions = []

      files.each do |path|
        content = File.read(path, encoding: "UTF-8")
        content.scan(/ruby-version\s*:\s*["']?([^\s"']+)/).each do |match|
          ruby_versions << [match.first, relative(root, path)]
        end
        content.scan(/\bruby:\s*\[([^\]]+)\]/).each do |match|
          match.first.scan(/["']?([0-9]+(?:\.[0-9]+){1,2})["']?/).each do |version|
            ruby_versions << [version.first, relative(root, path)]
          end
        end
        content.scan(/rails-version\s*:\s*["']?([^\s"']+)/).each do |match|
          rails_versions << [match.first, relative(root, path)]
        end
      end

      {
        "ruby_versions" => ruby_versions.uniq.map { |version, source| { "version" => version, "source" => source } },
        "rails_versions" => rails_versions.uniq.map { |version, source| { "version" => version, "source" => source } }
      }
    end

    def evidence_files(root)
      candidates = [
        ".ruby-version",
        "Gemfile",
        "Gemfile.lock",
        ".tool-versions",
        ".mise.toml",
        "mise.toml",
        *Dir[File.join(root, "*.gemspec")].map { |path| relative(root, path) },
        *Dir[File.join(root, ".github/workflows/**/*.{yml,yaml}")].map { |path| relative(root, path) },
        ".gitlab-ci.yml"
      ]

      candidates.select { |path| File.file?(File.join(root, path)) }.uniq.sort
    end

    def warnings(root)
      warnings = []
      warnings << "Gemfile.lock is missing; concrete dependency versions cannot be resolved." unless File.file?(File.join(root, "Gemfile.lock"))
      warnings << ".ruby-version is missing; inspect other runtime sources before choosing Ruby APIs." unless File.file?(File.join(root, ".ruby-version"))
      warnings
    end

    def read(root, path)
      full_path = File.join(root, path)
      File.file?(full_path) ? File.read(full_path, encoding: "UTF-8") : nil
    end

    def relative(root, path)
      path.delete_prefix(root + "/")
    end

    def add_candidate(collection, value, source, type)
      return if value.to_s.strip.empty?

      normalized = value.to_s.strip
      collection << {
        "value" => normalized,
        "source" => source,
        "type" => type,
        "comparison_value" => ruby_comparison_value(normalized)
      }
    end

    def ruby_comparison_value(value)
      normalized = value.sub(/^ruby-/, "").sub(/p\d+.*$/, "")
      match = normalized.match(/\A(\d+)(?:\.(\d+))?(?:\.(\d+))?/)
      return normalized unless match

      [match[1], match[2], match[3]].compact.join(".")
    end

    def resolution(candidates, preferred_types)
      preferred = candidates.select { |candidate| preferred_types.include?(candidate["type"]) }
      return nil if preferred.empty?

      values = preferred.map { |candidate| candidate["value"] }.uniq
      values.one? ? values.first : nil
    end

    def build_version_result(resolved, candidates, preferred_conflict_types:)
      preferred = candidates.select { |candidate| preferred_conflict_types.include?(candidate["type"]) }
      comparison_values = preferred.map do |candidate|
        candidate.fetch("comparison_value", candidate.fetch("value"))
      end.uniq
      conflict = comparison_values.length > 1

      {
        "resolved" => conflict ? nil : resolved,
        "candidates" => candidates,
        "conflict" => conflict,
        "status" => if conflict
          "conflict"
        elsif resolved
          "resolved"
        elsif candidates.empty?
          "unknown"
        else
          "constrained"
        end
      }
    end
  end
end
