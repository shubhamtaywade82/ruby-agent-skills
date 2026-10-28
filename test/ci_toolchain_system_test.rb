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

  def test_validate_workflow_uses_node24_compatible_checkout
    # Since the Batch 2 refactor (iter 196), validate.yml is a thin caller;
    # the checkout step lives in the reusable workflow it calls. The pinned
    # checkout version must be found in one of the two.
    workflow = File.read(File.join(ROOT, ".github", "workflows", "validate.yml"), encoding: "UTF-8")
    reusable = File.read(File.join(ROOT, ".github", "workflows", "reusable-ruby-ci.yml"), encoding: "UTF-8")
    combined = workflow + reusable

    assert_includes combined, "actions/checkout@v7"
    refute_includes combined, "actions/checkout@v4"
  end
end
