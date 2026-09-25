# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"
require "json"
require "rbconfig"

ROOT = File.expand_path("..", __dir__)

class SecurityAuditCliTest < Minitest::Test
  def test_reports_skipped_tools_when_not_installed_in_a_project_without_gemfile
    Dir.mktmpdir do |root|
      output, status = Open3.capture2({ "PATH" => "" }, RbConfig.ruby, File.join(ROOT, "bin/security-audit"), root)

      assert status.success?
      result = JSON.parse(output)
      assert_equal 1, result.fetch("schema_version")
      assert_equal root, result.fetch("repository")
      assert result.fetch("checks").fetch("brakeman").fetch("status").to_s.match?(/pass|fail|skipped/)
      assert result.fetch("checks").fetch("bundler-audit").fetch("status").to_s.match?(/pass|fail|skipped/)
    end
  end
end
