# frozen_string_literal: true

require "minitest/autorun"
require "shellwords"
require "tmpdir"
require "yaml"
require_relative "../lib/ruby_agent_skills/eval_runner"

# EvalRunner captures agent stdout/stderr and the post-run git diff via
# Open3, which tags the bytes with Encoding.default_external. A runner with
# no UTF-8 locale configured (US-ASCII, as in a bare container) then crashes
# JSON.pretty_generate the moment an agent's diff contains a non-ASCII byte
# (an em dash, a curly quote), even though the bytes are valid UTF-8.
#
# Also covers a bug that surfaced fixing the above: `stdout = +"", stderr =
# +"", status = nil, timed_out = false` is Ruby multiple assignment, so
# stdout silently became ["", "", nil, false] whenever the agent timed out
# (the only path that never reassigns it from out.read).
class EvalRunnerEncodingSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  FIXTURE = File.join(ROOT, "benchmarks", "rails", "fixtures", "action-cable-contract")
  TIMEOUT = 60

  # Appends a real UTF-8 em dash to a tracked file, exactly the byte
  # sequence (\xE2\x80\x94) that crashed the reported run.
  AGENT_COMMAND = "ruby -e 'File.write(\"lib/solution.rb\", " \
                  "File.read(\"lib/solution.rb\") + \"# note \\u2014 end\\n\")'"

  def runner
    RubyAgentSkills::EvalRunner.new(root: ROOT)
  end

  def with_ascii_locale
    original = { "LANG" => ENV.fetch("LANG", nil), "LC_ALL" => ENV.fetch("LC_ALL", nil) }
    ENV["LANG"] = "C"
    ENV["LC_ALL"] = "C"
    yield
  ensure
    original.each { |key, value| ENV[key] = value }
  end

  def run_with_non_ascii_diff(output_path)
    with_ascii_locale do
      runner.run(
        id: "action-cable-contract",
        workspace: FIXTURE,
        agent_command: AGENT_COMMAND,
        verify_command: "ruby -e 'puts({\"checks\" => {}}.to_json)'",
        output: output_path,
        timeout: TIMEOUT
      )
    end
  end

  def test_a_non_ascii_diff_does_not_crash_result_writing
    Dir.mktmpdir("eval-runner-encoding") do |output_dir|
      output_path = File.join(output_dir, "result.json")
      result = run_with_non_ascii_diff(output_path)
      diff = result.fetch("patch").fetch("diff")

      assert_includes diff, "—"
      assert_equal Encoding::UTF_8, diff.encoding
      assert_includes File.read(output_path, encoding: "UTF-8"), "—"
    end
  end

  def run_with_timeout(output_path)
    runner.run(
      id: "action-cable-contract",
      workspace: FIXTURE,
      agent_command: "sleep 5",
      output: output_path,
      timeout: 1
    )
  end

  def test_a_timed_out_agent_still_writes_a_valid_string_result
    Dir.mktmpdir("eval-runner-encoding") do |output_dir|
      output_path = File.join(output_dir, "result.json")
      agent = run_with_timeout(output_path).fetch("agent")

      assert agent.fetch("timed_out")
      assert_instance_of String, agent.fetch("stdout")
      assert_instance_of String, agent.fetch("stderr")
    end
  end

  def test_validator_registers_this_system_test
    validate = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validate, "test/eval_runner_encoding_system_test.rb"
  end
end
