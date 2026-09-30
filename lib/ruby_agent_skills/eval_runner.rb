# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "tmpdir"
require "yaml"
require "time"
require_relative "skill_pack"
require_relative "runtime_profile"
require_relative "runtime_profile"

module RubyAgentSkills
  class EvalRunner
    class Error < StandardError; end

    DEFAULT_TIMEOUT = 900

    attr_reader :root

    def initialize(root:)
      @root = File.expand_path(root)
    end

    def evaluation_files
      Dir[File.join(root, "evals", "**", "*.yml")].sort
    end

    def evaluations
      evaluation_files.map { |path| load_evaluation(path) }
    end

    def find(id)
      path = evaluation_files.find { |candidate| safe_load(candidate)["id"].to_s == id }
      raise Error, "evaluation not found: #{id}" unless path

      load_evaluation(path)
    end

    def packet(id)
      evaluation = find(id)

      {
        "protocol_version" => 1,
        "evaluation" => evaluation.fetch("id"),
        "title" => evaluation.fetch("title"),
        "category" => evaluation.fetch("category"),
        "source" => evaluation.fetch("source"),
        "skills" => evaluation.fetch("skills", []),
        "patterns" => evaluation.fetch("patterns", []),
        "prompt" => evaluation.fetch("prompt"),
        "constraints" => evaluation.fetch("constraints", {}),
        "checks" => evaluation.fetch("checks", []),
        "cases" => evaluation.fetch("cases", [])
      }
    end

    def write_packet(id, output:)
      FileUtils.mkdir_p(File.dirname(File.expand_path(output)))
      File.write(output, JSON.pretty_generate(packet(id)) + "\n", encoding: "UTF-8")
      output
    end

    def run(id:, workspace:, agent_command:, verify_command: nil, output: nil, timeout: DEFAULT_TIMEOUT, skills_enabled: false)
      evaluation = find(id)
      source_workspace = File.expand_path(workspace)
      raise Error, "workspace does not exist: #{source_workspace}" unless Dir.exist?(source_workspace)

      result = base_result(evaluation, agent_command, verify_command, skills_enabled)

      Dir.mktmpdir("ruby-agent-eval-") do |temp_dir|
        FileUtils.cp_r("#{source_workspace}/.", temp_dir)
        ensure_git_repository(temp_dir)
        metadata_dir = File.join(temp_dir, ".ruby-agent-eval")
        FileUtils.mkdir_p(metadata_dir)

        prompt_path = File.join(metadata_dir, "prompt.md")
        eval_path = File.join(metadata_dir, "evaluation.yml")
        result_path = File.join(metadata_dir, "result.json")

        File.write(prompt_path, evaluation.fetch("prompt"), encoding: "UTF-8")
        File.write(eval_path, YAML.dump(evaluation.reject { |k, _| k == "__path" }), encoding: "UTF-8")

        packer = SkillPack.new(root: root)
        runtime_profile = RuntimeProfile.call(temp_dir)
        result["runtime_profile"] = runtime_profile
        skill_pack = materialize_skill_pack(packer, evaluation, temp_dir, runtime_profile, skills_enabled)
        result["compatibility"] = skill_pack.fetch("compatibility") if skills_enabled

        result["configuration"]["runtime_profile"] = runtime_profile
        result["configuration"]["compatibility"] = skill_pack.fetch("compatibility")
        env = runner_env(evaluation, temp_dir, prompt_path, eval_path, result_path, skill_pack, skills_enabled)
        run_command(agent_command, temp_dir, agent_env(env), timeout, result["agent"])
        run_git_snapshot(temp_dir, result["patch"])
        # Only the verifier may report check results.
        FileUtils.rm_f(result_path)

        if verify_command.to_s.strip != ""
          run_command(verify_command, temp_dir, env, timeout, result["verification"])
        end

        apply_verifier_result(result, result_path)
        apply_agent_metadata(result, env.fetch("RUBY_AGENT_METADATA_FILE"))
      end

      result["completed_at"] = Time.now.utc.iso8601
      result["overall"] = overall_status(result)
      write_result(output, result) if output