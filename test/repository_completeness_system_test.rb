# frozen_string_literal: true

require "minitest/autorun"
require "open3"

class RepositoryCompletenessSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_completeness_audit_passes
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts", "audit_repository_completeness.rb"),
      chdir: ROOT
    )

    assert status.success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "Completeness audit passed."
  end

  def test_validator_invokes_every_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    Dir[File.join(ROOT, "test", "*_system_test.rb")].each do |path|
      relative = path.delete_prefix(ROOT + "/")
      assert_includes validator, relative, "bin/validate must invoke #{relative}"
    end
  end

  def test_iteration_46_framework_delta_is_documented
    readme = File.read(File.join(ROOT, "README.md"), encoding: "UTF-8")
    audit = File.read(File.join(ROOT, "docs", "REPOSITORY_COMPLETENESS_AUDIT.md"), encoding: "UTF-8")

    assert_includes readme, "## Repository-wide Completeness and Gap Audit"
    assert_includes readme, "## Evaluation and Benchmark Hardening"
    assert_includes readme, "Iteration 48 — Final Release and Public-Readiness Hardening"
    %w[
      ActiveJob::Continuable
      Rails.event
      Markdown rendering
      deprecated associations
      config/ci.rb
      Solid Cache
      Solid Cable
      Kamal
      rails credentials:fetch
    ].each { |term| assert_includes audit, term }
  end
end
