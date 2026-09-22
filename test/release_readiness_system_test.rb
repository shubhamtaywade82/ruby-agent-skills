# frozen_string_literal: true

require "minitest/autorun"
require "open3"

class ReleaseReadinessSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_release_readiness_audit_passes
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts", "audit_release_readiness.rb"),
      chdir: ROOT
    )

    assert status.success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "Release readiness audit passed."
  end

  def test_public_release_files_exist
    %w[CONTRIBUTING.md SECURITY.md CHANGELOG.md].each do |path|
      assert File.file?(File.join(ROOT, path)), "missing #{path}"
    end
  end
end
