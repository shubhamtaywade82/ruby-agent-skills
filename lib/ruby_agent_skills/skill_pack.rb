# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "yaml"

module RubyAgentSkills
  class SkillPack
    class Error < StandardError; end

    attr_reader :root

    def initialize(root:)
      @root = File.expand_path(root)
      @manifest_path = File.join(@root, "skill-manifest.yml")
      @manifest = YAML.safe_load(
        File.read(@manifest_path, encoding: "UTF-8"),
        permitted_classes: [],
        aliases: false
      )
    end

    def materialize(evaluation:, workspace:)
      target = File.join(workspace, ".ruby-agent-eval", "skill-pack")
      skills_dir = File.join(target, "skills")
      patterns_dir = File.join(target, "patterns")
      FileUtils.mkdir_p(skills_dir)
      FileUtils.mkdir_p(patterns_dir)

      selected_skills = Array(evaluation.fetch("skills", [])).map(&:to_s)
      selected_patterns = Array(evaluation.fetch("patterns", [])).map do |pattern|
        pattern.to_s.sub(%r{\Apattern:}, "")
      end

      skill_files = selected_skills.map do |skill|
        source = @manifest.fetch("skills").fetch(skill).fetch("path")
        destination = File.join(skills_dir, skill, "SKILL.md")
        copy_file(source, destination)
        { "id" => skill, "path" => relative_path(destination), "sha256" => digest(source) }
      end

      pattern_files = selected_patterns.map do |pattern|
        source = resolve_pattern(pattern)
        destination = File.join(patterns_dir, File.basename(source))
        copy_file(source, destination)
        { "id" => pattern, "path" => relative_path(destination), "sha256" => digest(source) }
      end

      manifest = {
        "protocol_version" => 1,
        "skills_enabled" => true,
        "skill_manifest_sha256" => Digest::SHA256.file(@manifest_path).hexdigest,
        "skills" => skill_files,
        "patterns" => pattern_files
      }

      manifest_path = File.join(target, "manifest.json")
      File.write(manifest_path, JSON.pretty_generate(manifest) + "\n", encoding: "UTF-8")

      context_path = File.join(target, "context.md")
      write_context(context_path, evaluation, skill_files, pattern_files)

      {
        "root" => target,
        "skills_dir" => skills_dir,
        "patterns_dir" => patterns_dir,
        "manifest" => manifest_path,
        "context" => context_path,
        "skills" => selected_skills,
        "patterns" => selected_patterns
      }
    end

    def write_baseline_context(evaluation:, workspace:)
      target = File.join(workspace, ".ruby-agent-eval", "skill-pack")
      FileUtils.mkdir_p(target)

      FileUtils.mkdir_p(File.join(target, "skills"))
      FileUtils.mkdir_p(File.join(target, "patterns"))

      manifest = {
        "protocol_version" => 1,
        "skills_enabled" => false,
        "skill_manifest_sha256" => Digest::SHA256.file(@manifest_path).hexdigest,
        "skills" => [],
        "patterns" => []
      }
      manifest_path = File.join(target, "manifest.json")
      File.write(manifest_path, JSON.pretty_generate(manifest) + "\n", encoding: "UTF-8")

      context_path = File.join(target, "context.md")
      File.write(
        context_path,
        "# Benchmark task\n\n#{evaluation.fetch("prompt").strip}\n",
        encoding: "UTF-8"
      )

      {
        "root" => target,
        "skills_dir" => File.join(target, "skills"),
        "patterns_dir" => File.join(target, "patterns"),
        "manifest" => manifest_path,
        "context" => context_path,
        "skills" => [],
        "patterns" => []
      }
    end

    private

    def resolve_pattern(pattern)
      paths = @manifest.fetch("patterns").values.flat_map { |entry| entry.fetch("paths") }
      relative = pattern.sub(%r{\Apatterns/}, "")
      exact = paths.find { |path| path.delete_prefix("patterns/").delete_suffix(".md") == relative }
      return exact if exact

      candidates = paths.select { |path| File.basename(path, ".md") == File.basename(relative) }
      return candidates.first if candidates.length == 1

      raise Error, "ambiguous pattern: #{pattern} (#{candidates.join(", ")})" if candidates.length > 1
      raise Error, "unknown pattern: #{pattern}"
    end

    def copy_file(source_relative, destination)
      source = File.join(@root, source_relative)
      raise Error, "missing source file: #{source_relative}" unless File.file?(source)

      FileUtils.mkdir_p(File.dirname(destination))
      FileUtils.cp(source, destination)
    end

    def digest(source_relative)
      Digest::SHA256.file(File.join(@root, source_relative)).hexdigest
    end

    def relative_path(path)
      path.sub(%r{\A.*?/(\.ruby-agent-eval/.*)\z}, "\\1")
    end

    def write_context(path, evaluation, skill_files, pattern_files)
      lines = ["# Benchmark task", "", evaluation.fetch("prompt").strip, "", "# Enabled skills"]

      skill_files.each do |entry|
        lines << ""
        lines << "## #{entry.fetch("id")}"
        lines << File.read(File.join(root, @manifest.fetch("skills").fetch(entry.fetch("id")).fetch("path")), encoding: "UTF-8").strip
      end

      unless pattern_files.empty?
        lines << ""
        lines << "# Enabled patterns"
        pattern_files.each do |entry|
          lines << ""
          lines << "## #{entry.fetch("id")}"
          source = resolve_pattern(entry.fetch("id"))
          lines << File.read(File.join(root, source), encoding: "UTF-8").strip
        end
      end

      File.write(path, lines.join("\n") + "\n", encoding: "UTF-8")
    end
  end
end
