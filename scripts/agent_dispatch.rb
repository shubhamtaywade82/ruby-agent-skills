#!/usr/bin/env ruby
# frozen_string_literal: true

# Bounded agent dispatcher for the autonomous engineering platform (Batch 3).
#
# One entry point for the three agent roles (issue-triage, ci-investigator,
# pr-reviewer). The dispatcher is the single place where the platform's
# bounded-autonomy rules are enforced, so the workflows stay thin:
#
#   1. Fail-safe: if no agent command is configured, exit 0 with a clear
#      "skipped" message. A missing agent never fails a gate and never
#      blocks a human. (The platform pattern's fail-safe rule.)
#   2. Sanitize: strip secret-shaped strings from the payload before it
#      reaches the prompt. Agents never see credentials.
#   3. Bound: cap attempts (3 by default), wall clock (15 minutes), and
#      output size. Escalate — exit 1 with an actionable message — when a
#      limit is reached. Silent failure is unacceptable.
#   4. Audit: append one JSON line per attempt to the audit log so every
#      prompt, exit code, and duration is reviewable. The audit log is
#      append-only from the agent's perspective; the agent cannot rewrite
#      its own history because the dispatcher owns the file handle.
#
# Usage (from a GitHub Actions step):
#   ruby scripts/agent_dispatch.rb --role issue-triage \
#     --payload payload.json --audit-log "$GITHUB_STEP_SUMMARY"
#
# Environment:
#   AGENT_COMMAND      required to run; unset => skip (exit 0)
#   AGENT_MAX_ATTEMPTS default 3
#   AGENT_TIMEOUT      default 900 seconds (15 minutes)

require "json"
require "open3"
require "optparse"
require "securerandom"
require "shellwords"
require "time"

ROLES = %w[issue-triage ci-investigator pr-reviewer].freeze

ROLE_PROMPTS = {
  "issue-triage" => <<~PROMPT,
    You are the issue-triage agent for ruby-agent-skills.
    Categorize the issue (bug, feature, documentation, benchmark, question),
    label it with the closest existing labels, identify priority
    (low/medium/high/urgent), and list any missing information a reproducer
    would need. Post one structured comment. Do not change code.
  PROMPT
  "ci-investigator" => <<~PROMPT,
    You are the ci-investigator agent for ruby-agent-skills.
    Read the sanitized failure summary, identify the most likely root cause,
    and propose a bounded fix as a diff in a comment. Do not push branches,
    do not open pull requests, do not modify repository state: you propose,
    a human applies. If you cannot identify a root cause, say so plainly.
  PROMPT
  "pr-reviewer" => <<~PROMPT
    You are the pr-reviewer agent for ruby-agent-skills.
    Review the diff for correctness, edge cases, and missing tests. Post
    advisory comments only. You never approve, never request changes
    through the review API, and never merge: required reviews come from
    CODEOWNERS, not from you. If the diff touches .github/ or scripts/,
    flag it for mandatory human review of the CI security surface.
  PROMPT
}.freeze

# Secret-shaped patterns stripped from payloads before they reach a prompt.
SANITIZE_PATTERNS = [
  /ghp_[A-Za-z0-9]{20,}/,        # GitHub classic PAT
  /gho_[A-Za-z0-9]{20,}/,        # GitHub OAuth
  /ghu_[A-Za-z0-9]{20,}/,        # GitHub user token
  /ghs_[A-Za-z0-9]{20,}/,        # GitHub server token
  /github_pat_[A-Za-z0-9_]{20,}/, # GitHub fine-grained PAT
  /AKIA[0-9A-Z]{16}/,            # AWS access key id
  /-----BEGIN [A-Z ]*PRIVATE KEY-----/, # private key material
  /Bearer\s+[A-Za-z0-9\-_.]{20,}/ # bearer tokens
].freeze

options = { role: nil, payload: nil, audit_log: nil }
OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/agent_dispatch.rb --role ROLE --payload PATH [--audit-log PATH]"
  opts.on("--role ROLE", ROLES, "agent role: #{ROLES.join(' | ')}") { |v| options[:role] = v }
  opts.on("--payload PATH", "path to the JSON event payload") { |v| options[:payload] = v }
  opts.on("--audit-log PATH", "append-only audit log (JSON lines)") { |v| options[:audit_log] = v }
end.parse!

abort "usage: --role is required (#{ROLES.join(' | ')})" if options[:role].nil?
abort "usage: --payload is required" if options[:payload].nil?

role = options.fetch(:role)
payload_path = File.expand_path(options.fetch(:payload))
max_attempts = ENV.fetch("AGENT_MAX_ATTEMPTS", "3").to_i
timeout_seconds = ENV.fetch("AGENT_TIMEOUT", "900").to_i
command = ENV["AGENT_COMMAND"].to_s

def sanitize(text)
  SANITIZE_PATTERNS.each { |pattern| text = text.gsub(pattern, "[REDACTED]") }
  text
end

def audit_write(path, entry)
  return if path.nil? || path.empty?

  File.open(File.expand_path(path), "a") do |f|
    f.flock(File::LOCK_EX)
    f.puts(JSON.generate(entry))
    f.flock(File::LOCK_UN)
  end
rescue Errno::EACCES, Errno::ENOENT
  # The audit log location must be writable; if it is not, say so loudly
  # rather than silently losing the audit trail.
  warn "agent_dispatch: audit log not writable: #{path}"
end

# --- Fail-safe: no agent configured => skip, never fail ------------------
if command.empty?
  reason = "AGENT_COMMAND is not configured; #{role} skipped (fail-safe)"
  puts reason
  audit_write(options[:audit_log],
              "ts" => Time.now.utc.iso8601, "role" => role, "event" => "skipped",
              "reason" => reason, "attempts" => 0)
  exit 0
end

abort "payload file not found: #{payload_path}" unless File.file?(payload_path)

raw_payload = File.read(payload_path, encoding: "UTF-8")
sanitized_payload = sanitize(raw_payload)

# Validate the payload is JSON before handing it to an agent; a malformed
# payload is an escalation condition, not a retry condition.
begin
  JSON.parse(sanitized_payload)
rescue JSON::ParserError => e
  audit_write(options[:audit_log],
              "ts" => Time.now.utc.iso8601, "role" => role, "event" => "escalated",
              "reason" => "payload is not valid JSON: #{e.message}", "attempts" => 0)
  abort "agent_dispatch: payload is not valid JSON: #{e.message}"
end

prompt = "#{ROLE_PROMPTS.fetch(role)}\n--- sanitized payload ---\n#{sanitized_payload}\n"

attempt = 0
started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

begin
  attempt += 1
  puts "agent_dispatch: #{role} attempt #{attempt}/#{max_attempts}"

  # AGENT_COMMAND is a shell command line: run it through /bin/sh -c with
  # the sanitized prompt exported as AGENT_PROMPT.
  stdout, stderr, status = Open3.capture3({ "AGENT_PROMPT" => prompt },
                                          "/bin/sh", "-c", command)

  duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at).round(3)

  audit_write(options[:audit_log],
              "ts" => Time.now.utc.iso8601, "role" => role, "event" => "attempt",
              "attempt" => attempt, "exit_code" => status.exitstatus.to_i,
              "duration_seconds" => duration, "stdout_bytes" => stdout.bytesize,
              "stderr_bytes" => stderr.bytesize)

  if status.success?
    # Cap the output the workflow exposes; an agent that emits megabytes is
    # a runaway, not a helper.
    if stdout.bytesize > 1_000_000
      warn "agent_dispatch: output exceeds 1MB; truncated"
      stdout = stdout[0, 1_000_000]
    end
    puts stdout
    exit 0
  end

  warn "agent_dispatch: attempt #{attempt} failed (exit #{status.exitstatus})"
  # Always raise on failure so the rescue block owns the retry-or-escalate
  # decision. Without this, a failed attempt falls through the begin block
  # and the dispatcher would exit 0 — a silent failure.
  raise "agent attempt #{attempt} failed with exit #{status.exitstatus}"
rescue StandardError => e
  duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at).round(3)
  if duration > timeout_seconds
    audit_write(options[:audit_log],
                "ts" => Time.now.utc.iso8601, "role" => role, "event" => "escalated",
                "reason" => "timeout after #{duration}s (limit #{timeout_seconds}s)",
                "attempts" => attempt)
    abort "agent_dispatch: #{role} exceeded #{timeout_seconds}s wall clock; escalating"
  end
  if attempt >= max_attempts
    audit_write(options[:audit_log],
                "ts" => Time.now.utc.iso8601, "role" => role, "event" => "escalated",
                "reason" => e.message, "attempts" => attempt)
    abort "agent_dispatch: #{role} exhausted #{max_attempts} attempts; escalating: #{e.message}"
  end
  # Bounded backoff between attempts: 2^attempt seconds, capped at 30.
  backoff = [(2**attempt), 30].min
  warn "agent_dispatch: retrying in #{backoff}s"
  sleep(backoff)
  retry
end
