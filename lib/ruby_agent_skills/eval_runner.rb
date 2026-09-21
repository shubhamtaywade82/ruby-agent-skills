# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "tmpdir"
require "yaml"
require "time"

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

    def run(id:, workspace:, agent_command:, verify_command: nil, output: nil, timeout: DEFAULT_TIMEOUT)
      evaluation = find(id)
      source_workspace = File.expand_path(workspace)
      raise Error, "workspace does not exist: #{source_workspace}" unless Dir.exist?(source_workspace)

      result = base_result(evaluation, agent_command, verify_command)

      Dir.mktmpdir("ruby-agent-eval-") do |temp_dir|
        FileUtils.cp_r("#{source_workspace}/.", temp_dir)
        metadata_dir = File.join(temp_dir, ".ruby-agent-eval")
        FileUtils.mkdir_p(metadata_dir)

        prompt_path = File.join(metadata_dir, "prompt.md")
        eval_path = File.join(metadata_dir, "evaluation.yml")
        result_path = File.join(metadata_dir, "result.json")

        File.write(prompt_path, evaluation.fetch("prompt"), encoding: "UTF-8")
        File.write(eval_path, YAML.dump(evaluation.reject { |k, _| k == "__path" }), encoding: "UTF-8")

        env = runner_env(evaluation, prompt_path, eval_path, result_path)
        run_command(agent_command, temp_dir, env, timeout, result["agent"])
        run_git_snapshot(temp_dir, result["patch"])

        if verify_command.to_s.strip != ""
          run_command(verify_command, temp_dir, env, timeout, result["verification"])
        end

        apply_verifier_result(result, result_path)
      end

      result["completed_at"] = Time.now.utc.iso8601
      result["overall"] = overall_status(result)
      write_result(output, result) if output
      result
    end

    private

    def safe_load(path)
      YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
    rescue Psych::Exception => e
      raise Error, "invalid evaluation YAML #{path}: #{e.message}"
    end

    def load_evaluation(path)
      data = safe_load(path)
      data["__path"] = path.delete_prefix(root + "/") if path.start_with?(root + "/")
      data
    end

    def base_result(evaluation, agent_command, verify_command)
      {
        "protocol_version" => 1,
        "evaluation" => evaluation.fetch("id"),
        "title" => evaluation.fetch("title"),
        "started_at" => Time.now.utc.iso8601,
        "agent" => {
          "command" => agent_command, "exit_code" => nil, "timed_out" => false,
          "stdout" => nil, "stderr" => nil, "duration_seconds" => nil
        },
        "verification" => {
          "configured" => !verify_command.to_s.strip.empty?, "command" => verify_command,
          "exit_code" => nil, "timed_out" => false, "stdout" => nil, "stderr" => nil,
          "duration_seconds" => nil
        },
        "patch" => { "git_repository" => false, "status" => nil, "diff_stat" => nil, "diff" => nil },
        "checks" => evaluation.fetch("checks", []).to_h { |check| [check, { "status" => "not_evaluated" }] }
      }
    end

    def runner_env(evaluation, prompt_path, eval_path, result_path)
      {
        "RUBY_AGENT_EVAL_ID" => evaluation.fetch("id"),
        "RUBY_AGENT_EVAL_PROMPT" => prompt_path,
        "RUBY_AGENT_EVAL_FILE" => eval_path,
        "RUBY_AGENT_EVAL_RESULT_FILE" => result_path
      }
    end

    def run_command(command, chdir, env, timeout, target)
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      stdout = +"", stderr = +"", status = nil, timed_out = false

      Open3.popen3(env, command, chdir: chdir) do |stdin, out, err, wait_thread|
        stdin.close
        begin
          require "timeout"
          Timeout.timeout(timeout) do
            stdout = out.read
            stderr = err.read
          end
          status = wait_thread.value
        rescue Timeout::Error
          timed_out = true
          Process.kill("TERM", wait_thread.pid) rescue nil
          Process.wait(wait_thread.pid) rescue nil
        end
      end

      target["exit_code"] = status&.exitstatus
      target["timed_out"] = timed_out
      target["stdout"] = stdout
      target["stderr"] = stderr
      target["duration_seconds"] = elapsed(started)
    end

    def run_git_snapshot(workdir, patch)
      return unless Dir.exist?(File.join(workdir, ".git"))

      patch["git_repository"] = true
      patch["status"] = Open3.capture2("git", "-C", workdir, "status", "--short").first
      patch["diff_stat"] = Open3.capture2("git", "-C", workdir, "diff", "--stat").first
      patch["diff"] = Open3.capture2("git", "-C", workdir, "diff", "--binary").first
    end

    def apply_verifier_result(result, result_path)
      return unless File.file?(result_path)

      parsed = JSON.parse(File.read(result_path, encoding: "UTF-8"))
      checks = parsed.fetch("checks", {})
      checks.each do |name, value|
        next unless result["checks"].key?(name)
        result["checks"][name] = value.is_a?(Hash) ? value : { "status" => value.to_s }
      end
      result["verification"]["reported_result"] = parsed.fetch("metadata", {})
    rescue JSON::ParserError => e
      result["verification"]["reported_result_error"] = "invalid verifier JSON: #{e.message}"
    rescue KeyError
      result["verification"]["reported_result_error"] = "verifier JSON must contain a checks mapping"
    end

    def overall_status(result)
      statuses = result["checks"].values.map { |value| value.fetch("status", "not_evaluated") }
      return "failed" if result["agent"]["timed_out"] || result["verification"]["timed_out"]
      return "failed" if result["agent"]["exit_code"] && result["agent"]["exit_code"] != 0
      return "failed" if result["verification"]["exit_code"] && result["verification"]["exit_code"] != 0
      return "failed" if statuses.include?("fail")
      return "passed" if statuses.any? && statuses.none? { |status| status == "not_evaluated" }
      "incomplete"
    end

    def write_result(output, result)
      FileUtils.mkdir_p(File.dirname(File.expand_path(output)))
      File.write(output, JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
    end

    def elapsed(started)
      (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).round(3)
    end
  end
end
