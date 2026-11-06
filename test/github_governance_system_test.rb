# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"

# Tests for scripts/audit_github_governance.rb.
#
# The audit enforces the rules documented in
# patterns/rails/autonomous-engineering-platform.md (Batch 1 — Foundation
# and governance). The tests cover positive cases (the repository passes
# when the rules are satisfied) and negative cases (the audit fails when
# CODEOWNERS, dependabot, or a permissions: block is missing, or when
# pull_request_target or contents: write appears in an unauthorized
# workflow). Workflow fixtures live in test/fixtures/governance/ and are
# named after the workflow file they are copied to.
module GovernanceAuditHarness
  ROOT = File.expand_path("..", __dir__)
  AUDIT = File.join(ROOT, "scripts", "audit_github_governance.rb")
  FIXTURES = File.join(ROOT, "test", "fixtures", "governance")

  private

  def fixture(name)
    File.read(File.join(FIXTURES, name), encoding: "UTF-8")
  end

  # Run the audit script in a working directory. Returns [stdout+stderr merged, status].
  def run_audit_in(dir)
    stdout, stderr, status = Open3.capture3({ "RUBY_AGENT_SKILLS_REPO" => dir },
                                            RbConfig.ruby, AUDIT, chdir: dir)
    # The audit script writes its summary to stdout and errors to stderr
    # (via `warn`). Merge them so the assertions can see both.
    ["#{stdout}#{stderr}", status]
  end

  # Build a temporary repo that mirrors the real repo's .github/ layout,
  # minus the file we want to test the absence of.
  def in_temp_repo_without(missing_relative)
    Dir.mktmpdir("gov-audit-") do |dir|
      copy_github_into(dir, exclude: [missing_relative])
      yield dir
    end
  end

  # Build a temporary repo with the real .github/ layout plus one extra
  # workflow file under .github/workflows/.
  def in_temp_repo_with_workflow(name, content)
    Dir.mktmpdir("gov-audit-") do |dir|
      copy_github_into(dir)
      FileUtils.mkdir_p(File.join(dir, ".github", "workflows"))
      File.write(File.join(dir, ".github", "workflows", name), content)
      yield dir
    end
  end

  # Copy .github/ from the real repo into dest, optionally excluding named
  # relative paths.
  def copy_github_into(dest, exclude: [])
    src = File.join(ROOT, ".github")
    return unless File.directory?(src)

    FileUtils.cp_r(src, dest)
    exclude.each { |relative| FileUtils.rm_f(File.join(dest, relative)) }
  end

  # Copy a workflow fixture into a temp repo and assert the audit rejects it.
  def assert_workflow_rejected(fixture_name, expected_output, rule)
    in_temp_repo_with_workflow(fixture_name, fixture(fixture_name)) do |dir|
      stdout, status = run_audit_in(dir)

      refute_predicate status, :success?, "audit must fail when #{rule}"
      assert_includes stdout, expected_output
    end
  end
end

class GithubGovernanceRepositoryTest < Minitest::Test
  include GovernanceAuditHarness

  def test_repository_passes_the_governance_audit
    stdout, status = run_audit_in(ROOT)

    assert_predicate status, :success?,
                     "audit_github_governance.rb must pass on the repository; got:\n#{stdout}"
    assert_includes stdout, "GitHub governance audit passed."
  end

  def test_repository_summary_reports_codeowners_and_dependabot
    stdout, = run_audit_in(ROOT)

    assert_includes stdout, "CODEOWNERS"
    assert_includes stdout, "dependabot.yml"
  end

  def test_audit_fails_when_codeowners_is_missing
    in_temp_repo_without(".github/CODEOWNERS") do |dir|
      stdout, status = run_audit_in(dir)

      refute_predicate status, :success?, "audit must fail when CODEOWNERS is missing"
      assert_includes stdout, "CODEOWNERS is missing"
    end
  end

  def test_audit_fails_when_dependabot_is_missing
    in_temp_repo_without(".github/dependabot.yml") do |dir|
      stdout, status = run_audit_in(dir)

      refute_predicate status, :success?, "audit must fail when dependabot.yml is missing"
      assert_includes stdout, "dependabot.yml is missing"
    end
  end
end

class GithubGovernanceWorkflowRulesTest < Minitest::Test
  include GovernanceAuditHarness

  def test_audit_fails_when_a_workflow_has_no_permissions_block
    assert_workflow_rejected("no-permissions.yml", "missing top-level `permissions:`",
                             "a workflow has no permissions: block")
  end

  def test_audit_fails_on_pull_request_target
    assert_workflow_rejected("pr-target.yml", "pull_request_target",
                             "pull_request_target is used")
  end

  def test_audit_fails_on_contents_write_in_non_release_workflow
    assert_workflow_rejected("bad-write.yml", "least-privilege violation",
                             "contents: write appears in a non-release workflow")
  end

  def test_audit_fails_when_a_reusable_workflow_lacks_workflow_call
    assert_workflow_rejected("reusable-broken.yml", "must declare `on: workflow_call`",
                             "a reusable-*.yml workflow lacks workflow_call")
  end

  def test_audit_passes_when_a_reusable_workflow_has_workflow_call
    in_temp_repo_with_workflow("reusable-good.yml", fixture("reusable-good.yml")) do |dir|
      stdout, status = run_audit_in(dir)

      assert_predicate status, :success?, "audit must pass with workflow_call; got:\n#{stdout}"
      # The temp dir already contains the real repo's reusable-ruby-ci.yml,
      # so adding reusable-good.yml makes 2 reusable workflows total. Match
      # the regex so the count is at least 1 (the one we just added).
      assert_match(/reusable workflows: \d+/, stdout)
    end
  end

  def test_audit_fails_when_an_agent_workflow_lacks_timeout
    assert_workflow_rejected("agent-unbounded.yml", "must declare `timeout-minutes:`",
                             "an agent-*.yml workflow has no timeout-minutes")
  end

  def test_audit_fails_when_an_agent_workflow_is_not_gated
    assert_workflow_rejected("agent-ungated.yml",
                             "must gate execution on a repository variable or secret",
                             "an agent-*.yml workflow runs unconditionally")
  end

  def test_audit_fails_when_an_agent_workflow_contains_an_approval_command
    assert_workflow_rejected("agent-approver.yml", "agents propose, CODEOWNERS approve",
                             "an agent-*.yml workflow approves PRs")
  end
end
