# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"

# Tests for scripts/audit_github_governance.rb.
#
# The audit enforces the rules documented in
# patterns/rails/autonomous-engineering-platform.md (Batch 1 — Foundation
# and governance). The tests cover positive cases (the repository passes
# when the rules are satisfied) and negative cases (the audit fails when
# CODEOWNERS, dependabot, or a permissions: block is missing, or when
# pull_request_target or contents: write appears in an unauthorized
# workflow).
class GithubGovernanceSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  AUDIT = File.join(ROOT, "scripts", "audit_github_governance.rb")

  def test_repository_passes_the_governance_audit
    stdout, status = run_audit_in_repository
    assert_predicate status, :success?, "audit_github_governance.rb must pass on the repository; got:\n#{stdout}"
    assert_includes stdout, "GitHub governance audit passed."
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

  def test_audit_fails_when_a_workflow_has_no_permissions_block
    in_temp_repo_with_workflow("no-permissions.yml", <<~YAML) do |dir|
      name: No permissions
      on:
        push:
          branches: ["main"]
      jobs:
        build:
          runs-on: ubuntu-latest
          steps:
            - run: echo "no permissions block"
    YAML
      stdout, status = run_audit_in(dir)
      refute_predicate status, :success?, "audit must fail when a workflow has no permissions: block"
      assert_includes stdout, "missing top-level `permissions:`"
    end
  end

  def test_audit_fails_on_pull_request_target
    in_temp_repo_with_workflow("pr-target.yml", <<~YAML) do |dir|
      name: Pull request target
      on:
        pull_request_target:
      permissions:
        contents: read
      jobs:
        build:
          runs-on: ubuntu-latest
          steps:
            - run: echo "dangerous trigger"
    YAML
      stdout, status = run_audit_in(dir)
      refute_predicate status, :success?, "audit must fail when pull_request_target is used"
      assert_includes stdout, "pull_request_target"
    end
  end

  def test_audit_fails_on_contents_write_in_non_release_workflow
    in_temp_repo_with_workflow("bad-write.yml", <<~YAML) do |dir|
      name: Unauthorized contents write
      on:
        push:
          branches: ["main"]
      permissions:
        contents: write
      jobs:
        build:
          runs-on: ubuntu-latest
          steps:
            - run: echo "leaky scope"
    YAML
      stdout, status = run_audit_in(dir)
      refute_predicate status, :success?, "audit must fail when contents: write appears in a non-release workflow"
      assert_includes stdout, "least-privilege violation"
    end
  end

  def test_audit_fails_when_a_reusable_workflow_lacks_workflow_call
    in_temp_repo_with_workflow("reusable-broken.yml", <<~YAML) do |dir|
      name: Reusable without workflow_call
      on:
        push:
          branches: ["main"]
      permissions:
        contents: read
      jobs:
        build:
          runs-on: ubuntu-latest
          steps:
            - run: echo "misconfigured"
    YAML
      stdout, status = run_audit_in(dir)
      refute_predicate status, :success?, "audit must fail when a reusable-*.yml workflow lacks workflow_call"
      assert_includes stdout, "must declare `on: workflow_call`"
    end
  end

  def test_audit_passes_when_a_reusable_workflow_has_workflow_call
    in_temp_repo_with_workflow("reusable-good.yml", <<~YAML) do |dir|
      name: Reusable with workflow_call
      on:
        workflow_call:
      permissions:
        contents: read
      jobs:
        build:
          runs-on: ubuntu-latest
          steps:
            - run: echo "correct"
    YAML
      stdout, status = run_audit_in(dir)
      assert_predicate status, :success?, "audit must pass when a reusable-*.yml workflow declares workflow_call; got:\n#{stdout}"
      # The temp dir already contains the real repo's reusable-ruby-ci.yml,
      # so adding reusable-good.yml makes 2 reusable workflows total. Match
      # the regex so the count is at least 1 (the one we just added).
      assert_match(/reusable workflows: \d+/, stdout)
    end
  end

  private

  # Run the audit against the actual repository.
  def run_audit_in_repository
    run_audit_in(ROOT)
  end

  # Run the audit script in a working directory. Returns [stdout+stderr merged, status].
  def run_audit_in(dir)
    stdout, stderr, status = Open3.capture3({ "RUBY_AGENT_SKILLS_REPO" => dir },
                                            RbConfig.ruby, AUDIT, chdir: dir)
    # The audit script writes its summary to stdout and errors to stderr
    # (via `warn`). Merge them so the assertions can see both.
    ["#{stdout}#{stderr}", status]
  end

  require "open3"

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

  # Copy .github/ (and the audit script's expected layout) from the real
  # repo, optionally excluding named relative paths.
  def copy_github_into(dest, exclude: [])
    src = File.join(ROOT, ".github")
    return unless File.directory?(src)

    FileUtils.cp_r(src, dest)
    exclude.each do |relative|
      path = File.join(dest, relative)
      FileUtils.rm_f(path) if File.exist?(path)
    end

    # The audit script's ROOT is one level above .github/. Copy a minimal
    # skill-manifest.yml so the audit script's path operations don't fail
    # if the script is ever expanded.
    return if File.exist?(File.join(dest, "skill-manifest.yml"))
  end
end
