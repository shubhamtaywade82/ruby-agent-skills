#!/usr/bin/env ruby
# frozen_string_literal: true

# GitHub governance audit.
#
# Enforces the rules documented in
# patterns/rails/autonomous-engineering-platform.md (Batch 1 — Foundation
# and governance). The audit is intentionally narrow and deterministic; it
# does not try to be a general CI/CD security scanner.
#
# Checks:
#   1. .github/CODEOWNERS exists and covers protected paths
#   2. .github/dependabot.yml exists and covers the github-actions,
#      bundler, and (when present) ruby-version ecosystems
#   3. every workflow in .github/workflows/ has an explicit `permissions:`
#      block (default permissive permissions are a security smell)
#   4. no workflow uses the `pull_request_target` trigger for untrusted PRs
#      (it runs in the base branch's context with the default token)
#   5. the `permissions:` block on every workflow is the minimum required;
#      `contents: write` is allowed only on the release workflow
#
# Usage:
#   ruby scripts/audit_github_governance.rb

ROOT = ENV["RUBY_AGENT_SKILLS_REPO"] ? File.expand_path(ENV["RUBY_AGENT_SKILLS_REPO"]) : File.expand_path("..", __dir__)
GITHUB_DIR = File.join(ROOT, ".github")
WORKFLOWS_DIR = File.join(GITHUB_DIR, "workflows")

errors = []
warnings = []

# --- Check 1: CODEOWNERS exists and covers protected paths ---------------
codeowners_path = File.join(GITHUB_DIR, "CODEOWNERS")
unless File.file?(codeowners_path)
  errors << ".github/CODEOWNERS is missing — every protected path needs an owner (see patterns/rails/autonomous-engineering-platform.md)"
end

if File.file?(codeowners_path)
  codeowners = File.read(codeowners_path, encoding: "UTF-8")
  protected_paths = %w[
    .github/
    skills/
    patterns/
    evals/
    bin/
    scripts/
    test/
    skill-manifest.yml
  ]
  missing_owners = protected_paths.reject { |path| codeowners.match?(/^#{Regexp.escape(path)}/) }
  unless missing_owners.empty?
    errors << ".github/CODEOWNERS is missing ownership rules for: #{missing_owners.join(", ")}"
  end
end

# --- Check 2: dependabot.yml exists and covers required ecosystems -------
dependabot_path = File.join(GITHUB_DIR, "dependabot.yml")
unless File.file?(dependabot_path)
  errors << ".github/dependabot.yml is missing — every ecosystem needs an update policy (see patterns/rails/autonomous-engineering-platform.md)"
end

if File.file?(dependabot_path)
  require "yaml"
  begin
    dependabot = YAML.safe_load(File.read(dependabot_path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
    ecosystems = (dependabot.is_a?(Hash) ? dependabot["updates"] : []).to_a.filter_map { |u| u["package-ecosystem"] if u.is_a?(Hash) }
    required_ecosystems = %w[github-actions bundler]
    missing_ecosystems = required_ecosystems.reject { |e| ecosystems.include?(e) }
    unless missing_ecosystems.empty?
      errors << ".github/dependabot.yml is missing update policies for: #{missing_ecosystems.join(", ")}"
    end
  rescue Psych::Exception => e
    errors << ".github/dependabot.yml is not valid YAML: #{e.message}"
  end
end

# --- Check 3 & 4 & 5: every workflow has permissions block, no
# pull_request_target, minimum-scope permissions --------------------------

workflow_files = Dir[File.join(WORKFLOWS_DIR, "*.yml")].sort
abort "no GitHub Actions workflow files found in .github/workflows/" if workflow_files.empty?

workflow_files.each do |path|
  relative = path.delete_prefix(ROOT + "/")
  text = File.read(path, encoding: "UTF-8")

  # Check 3: explicit permissions block at the top level
  unless text.match?(/^permissions:/)
    errors << "#{relative}: missing top-level `permissions:` block (default permissive permissions are a security smell)"
  end

  # Check 4: no pull_request_target trigger (high-risk for untrusted PRs)
  if text.match?(/^on:.*pull_request_target|^\s+-?\s*pull_request_target\b/)
    errors << "#{relative}: uses `pull_request_target` trigger — runs in base branch's context with default token (see patterns/rails/autonomous-engineering-platform.md)"
  end

  # Check 5: contents: write allowed only on the release workflow
  if text.match?(/^\s*contents:\s*write\b/) && !relative.end_with?("release.yml")
    errors << "#{relative}: declares `contents: write` but is not the release workflow — least-privilege violation"
  end

  # Check 5b: pull requests (forks) get read-only by default. If a workflow
  # declares write on something other than contents in a PR-triggered
  # workflow, warn (not error — some workflows genuinely need it, like
  # `pull-requests: write` for PR comments).
  if text.match?(/^on:.*pull_request\b/) && !text.match?(/^on:.*pull_request_target\b/)
    write_scopes = text.scan(/^\s*(\w+):\s*write\b/).flatten.reject { |s| s == "contents" }
    unless write_scopes.empty?
      warnings << "#{relative}: PR-triggered workflow declares write on #{write_scopes.join(", ")} — verify it is justified"
    end
  end
end

# --- Check 6: reusable-*.yml workflows declare on: workflow_call --------
# A reusable workflow file that does not declare workflow_call cannot be
# called by other workflows — it is dead weight, or worse, a misconfigured
# copy of an inline workflow.

reusable_workflows = workflow_files.select { |p| File.basename(p).start_with?("reusable-") }
reusable_workflows.each do |path|
  relative = path.delete_prefix(ROOT + "/")
  text = File.read(path, encoding: "UTF-8")

  unless text.match?(/^on:\s*\n\s+workflow_call:/) || text.match?(/^on:\s*workflow_call/)
    errors << "#{relative}: reusable workflow must declare `on: workflow_call` so it can be called from other workflows"
  end
end

# --- Report --------------------------------------------------------------

puts "GitHub governance audit"
if File.file?(codeowners_path)
  codeowners_lines = File.readlines(codeowners_path).count { |line| line.match?(/^\S/) }
  puts "  CODEOWNERS: #{codeowners_lines} ownership rules"
end
if File.file?(dependabot_path)
  puts "  dependabot.yml: present"
end
puts "  workflows audited: #{workflow_files.length}"
puts "  reusable workflows: #{reusable_workflows.length}" unless reusable_workflows.empty?
warnings.each { |w| puts "WARN: #{w}" }

if errors.any?
  errors.each { |e| warn "ERROR: #{e}" }
  abort "#{errors.length} GitHub governance audit error(s)"
end

puts "GitHub governance audit passed."
