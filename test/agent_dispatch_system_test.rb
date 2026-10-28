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
class AgentDispatchSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  DISPATCHER = File.join(ROOT, "scripts", "agent_dispatch.rb")

  def test_skips_failsafe_when_agent_command_is_unset
    Dir.mktmpdir("agent-dispatch-") do |dir|
      payload = write_payload(dir, "issue" => 1)
      env = base_env.merge("AGENT_COMMAND" => "")
      stdout, _stderr, status = run_dispatcher(env, "--role", "issue-triage", "--payload", payload)

      assert_predicate status, :success?, "unset AGENT_COMMAND must exit 0 (fail-safe), got exit #{status.exitstatus}"
      assert_includes stdout, "skipped"
      assert_includes stdout, "fail-safe"
    end
  end

  def test_sanitizes_secret_shaped_strings_from_payload
    Dir.mktmpdir("agent-dispatch-") do |dir|
      # A spy command that captures the prompt it receives.
      spy = File.join(dir, "spy.sh")
      File.write(spy, <<~SH)
        #!/bin/sh
        printf '%s' "$AGENT_PROMPT" > prompt.txt
        echo "spy ran"
      SH
      FileUtils.chmod(0o755, spy)

      secret = "ghp_#{'a' * 36}"
      payload = write_payload(dir, "body" => "token was #{secret}")
      env = base_env.merge("AGENT_COMMAND" => spy)
      _out, _err, status = run_dispatcher(env, "--role", "issue-triage", "--payload", payload,
                                          chdir: dir)

      assert_predicate status, :success?
      captured = File.read(File.join(dir, "prompt.txt"))
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

  def test_failing_agent_escalates_after_bounded_attempts
    Dir.mktmpdir("agent-dispatch-") do |dir|
      payload = write_payload(dir, "issue" => 1)
      audit_log = File.join(dir, "audit.jsonl")
      # Fail immediately; keep backoff short so the test is fast.
      env = base_env.merge("AGENT_COMMAND" => "exit 7",
                           "AGENT_MAX_ATTEMPTS" => "2")
      _out, stderr, status = run_dispatcher(env, "--role", "ci-investigator",
                                            "--payload", payload, "--audit-log", audit_log)

      refute_predicate status, :success?, "a persistently failing agent must escalate (non-zero exit)"
      assert_includes stderr, "exhausted 2 attempts"

      attempts = read_audit(audit_log)
      attempt_entries = attempts.select { |e| e["event"] == "attempt" }
      assert_equal 2, attempt_entries.length, "audit log must record exactly the bounded attempts"
      escalated = attempts.find { |e| e["event"] == "escalated" }
      refute_nil escalated, "audit log must record the escalation"
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
      refute File.exist?(ran_file), "the agent must never run on a malformed payload"
    end
  end

  def test_audit_log_records_every_attempt
    Dir.mktmpdir("agent-dispatch-") do |dir|
      audit_log = File.join(dir, "audit.jsonl")
      payload = write_payload(dir, "issue" => 1)
      env = base_env.merge("AGENT_COMMAND" => "echo ok")
      _out, _err, status = run_dispatcher(env, "--role", "pr-reviewer",
                                          "--payload", payload, "--audit-log", audit_log)

      assert_predicate status, :success?
      entries = read_audit(audit_log)
      assert(entries.length >= 1, "audit log must have at least one entry")
      entry = entries.last
      assert_equal "attempt", entry["event"]
      assert_equal "pr-reviewer", entry["role"]
      assert_includes entry, "exit_code"
      assert_includes entry, "duration_seconds"
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

  def run_dispatcher(env, *args, chdir: Dir.pwd)
    Open3.capture3(env, RbConfig.ruby, DISPATCHER, *args, chdir: chdir)
  end

  def read_audit(path)
    return [] unless File.file?(path)

    File.readlines(path).filter_map { |line| JSON.parse(line) }
  end
end
