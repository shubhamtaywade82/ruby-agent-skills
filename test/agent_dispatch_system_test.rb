# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "json"

# Tests for scripts/agent_dispatch.rb — the bounded agent dispatcher from
# the autonomous engineering platform (Batch 3).
#
# The dispatcher is the single place where the platform's bounded-autonomy
# rules are enforced, so its behaviour is pinned by tests:
#   - fail-safe: no AGENT_COMMAND => exit 0 with a skip message, never a failure
#   - sanitization: secret-shaped strings never reach the prompt
#   - bounded retries: a failing agent is retried at most N times, then escalated
#   - audit trail: every attempt appends a JSON line with role, exit code, duration
#   - malformed payload: escalation, not retry
module AgentDispatchHarness
  ROOT = File.expand_path("..", __dir__)
  DISPATCHER = File.join(ROOT, "scripts", "agent_dispatch.rb")

  private

  def base_env
    # Clear AGENT_COMMAND inheritance; each test sets its own.
    { "AGENT_COMMAND" => "", "AGENT_MAX_ATTEMPTS" => "3", "AGENT_TIMEOUT" => "900" }
  end

  def write_payload(dir, data)
    path = File.join(dir, "payload.json")
    File.write(path, JSON.generate(data))
    path
  end

  def run_dispatcher(env, *, chdir: Dir.pwd)
    Open3.capture3(env, RbConfig.ruby, DISPATCHER, *, chdir: chdir)
  end

  def read_audit(path)
    return [] unless File.file?(path)

    File.readlines(path).filter_map { |line| JSON.parse(line) }
  end

  # A spy agent that records the prompt it receives in prompt.txt.
  def write_spy(dir)
    spy = File.join(dir, "spy.sh")
    File.write(spy, <<~SH)
      #!/bin/sh
      printf '%s' "$AGENT_PROMPT" > prompt.txt
      echo "spy ran"
    SH
    FileUtils.chmod(0o755, spy)
    spy
  end

  # Returns [status, captured prompt].
  def capture_prompt(dir, body)
    env = base_env.merge("AGENT_COMMAND" => write_spy(dir))
    payload = write_payload(dir, "body" => body)
    _out, _err, status = run_dispatcher(env, "--role", "issue-triage",
                                        "--payload", payload, chdir: dir)
    [status, File.read(File.join(dir, "prompt.txt"))]
  end
end

class AgentDispatchSystemTest < Minitest::Test
  include AgentDispatchHarness

  def test_skips_failsafe_when_agent_command_is_unset
    Dir.mktmpdir("agent-dispatch-") do |dir|
      payload = write_payload(dir, "issue" => 1)
      env = base_env.merge("AGENT_COMMAND" => "")
      stdout, _stderr, status = run_dispatcher(env, "--role", "issue-triage", "--payload", payload)

      assert_predicate status, :success?,
                       "unset AGENT_COMMAND must exit 0 (fail-safe), got exit #{status.exitstatus}"
      assert_includes stdout, "skipped"
      assert_includes stdout, "fail-safe"
    end
  end

  def test_sanitizes_secret_shaped_strings_from_payload
    Dir.mktmpdir("agent-dispatch-") do |dir|
      secret = "ghp_#{'a' * 36}"
      status, captured = capture_prompt(dir, "token was #{secret}")

      assert_predicate status, :success?
      refute_includes captured, secret, "the PAT-shaped string must never reach the prompt"
      assert_includes captured, "[REDACTED]"
    end
  end

  def test_successful_agent_run_passes_through
    Dir.mktmpdir("agent-dispatch-") do |dir|
      payload = write_payload(dir, "issue" => 1)
      env = base_env.merge("AGENT_COMMAND" => "echo agent-ok")
      stdout, _stderr, status = run_dispatcher(env, "--role", "pr-reviewer", "--payload", payload)

      assert_predicate status, :success?
      assert_includes stdout, "agent-ok"
    end
  end

  def test_malformed_payload_escalates_without_retry
    Dir.mktmpdir("agent-dispatch-") do |dir|
      bad_payload = File.join(dir, "bad.json")
      File.write(bad_payload, "{not valid json")

      ran_file = File.join(dir, "ran")
      env = base_env.merge("AGENT_COMMAND" => "touch #{ran_file}")
      _out, stderr, status = run_dispatcher(env, "--role", "issue-triage", "--payload", bad_payload)

      refute_predicate status, :success?, "malformed payload is an escalation, not a retry"
      assert_includes stderr, "not valid JSON"
      refute_path_exists ran_file, "the agent must never run on a malformed payload"
    end
  end

  def test_rejects_unknown_role
    Dir.mktmpdir("agent-dispatch-") do |dir|
      payload = write_payload(dir, "issue" => 1)
      env = base_env.merge("AGENT_COMMAND" => "echo should-not-run")
      _out, stderr, status = run_dispatcher(env, "--role", "not-a-role", "--payload", payload)

      refute_predicate status, :success?
      assert_match(/role|usage/i, stderr)
    end
  end
end

class AgentDispatchBoundedAutonomyTest < Minitest::Test
  include AgentDispatchHarness

  def test_failing_agent_escalates_after_bounded_attempts
    Dir.mktmpdir("agent-dispatch-") do |dir|
      stderr, status, _entries = run_failing_agent(dir)

      refute_predicate status, :success?,
                       "a persistently failing agent must escalate (non-zero exit)"
      assert_includes stderr, "exhausted 2 attempts"
    end
  end

  def test_failing_agent_audit_records_exactly_the_bounded_attempts_and_escalation
    Dir.mktmpdir("agent-dispatch-") do |dir|
      _stderr, _status, entries = run_failing_agent(dir)
      attempts = entries.select { |e| e["event"] == "attempt" }

      assert_equal 2, attempts.length, "audit log must record exactly the bounded attempts"
      refute_nil entries.find { |e| e["event"] == "escalated" },
                 "audit log must record the escalation"
    end
  end

  def test_audit_log_records_every_attempt
    Dir.mktmpdir("agent-dispatch-") do |dir|
      status, entries = run_passing_agent(dir)

      assert_predicate status, :success?
      assert_operator entries.length, :>=, 1, "audit log must have at least one entry"
      assert_equal %w[attempt pr-reviewer], entries.last.values_at("event", "role")
    end
  end

  def test_audit_entry_records_exit_code_and_duration
    Dir.mktmpdir("agent-dispatch-") do |dir|
      _status, entries = run_passing_agent(dir)

      assert_operator entries.length, :>=, 1, "audit log must have at least one entry"
      assert_includes entries.last, "exit_code"
      assert_includes entries.last, "duration_seconds"
    end
  end

  private

  def run_failing_agent(dir)
    payload = write_payload(dir, "issue" => 1)
    audit_log = File.join(dir, "audit.jsonl")
    # Fail immediately; keep backoff short so the test is fast.
    env = base_env.merge("AGENT_COMMAND" => "exit 7", "AGENT_MAX_ATTEMPTS" => "2")
    _out, stderr, status = run_dispatcher(env, "--role", "ci-investigator",
                                          "--payload", payload, "--audit-log", audit_log)
    [stderr, status, read_audit(audit_log)]
  end

  def run_passing_agent(dir)
    payload = write_payload(dir, "issue" => 1)
    audit_log = File.join(dir, "audit.jsonl")
    env = base_env.merge("AGENT_COMMAND" => "echo ok")
    _out, _err, status = run_dispatcher(env, "--role", "pr-reviewer",
                                        "--payload", payload, "--audit-log", audit_log)
    [status, read_audit(audit_log)]
  end
end
