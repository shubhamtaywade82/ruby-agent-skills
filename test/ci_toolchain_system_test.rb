# frozen_string_literal: true

require "minitest/autorun"
require "open3"

class CiToolchainSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_ci_toolchain_audit_passes
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts", "audit_ci_toolchain.rb"),
      chdir: ROOT
    )

    assert status.success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "CI toolchain audit passed."
  end

  def test_every_workflow_sha_pins_checkout
    # Autonomous Engineering Platform pinning policy (.github/GOVERNANCE.md):
    # actions/checkout must be pinned to a full commit SHA with a version
    # comment; bare mutable tags are rejected by audit_ci_toolchain.rb, and
    # this test independently asserts the same invariant across ALL workflows.
    workflows = Dir[File.join(ROOT, ".github", "workflows", "*.yml")]

    refute_empty workflows

    workflows.each do |path|
      text = File.read(path, encoding: "UTF-8")

      refute_includes text, "actions/checkout@v4"
      refute_match(%r{actions/checkout@v\d+(?:\.\d+){0,2}}, text), path
      assert_match(%r{actions/checkout@[0-9a-f]{40}\s*#\s*v\d+}, text), path
    end
  end
end
