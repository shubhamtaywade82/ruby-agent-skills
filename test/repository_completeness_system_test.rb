# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"

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
    assert_includes stdout, "README inventory: verified"
  end

  def test_audit_rejects_drifted_readme_inventory_counts
    Dir.mktmpdir do |dir|
      copy = File.join(dir, "repo")
      Dir.mkdir(copy)
      Dir.children(ROOT).reject { |entry| entry == ".git" }.each do |entry|
        FileUtils.cp_r(File.join(ROOT, entry), File.join(copy, entry))
      end

      readme_path = File.join(copy, "README.md")
      readme = File.read(readme_path, encoding: "UTF-8")
      tampered = readme
        .sub(%r{\| Skills \| \*\*\d+\*\* \|}, "| Skills | **75** |")
        .sub(%r{\| Implementation patterns \| \*\*\d+\*\* \|}, "| Implementation patterns | **74** |")
        .sub(%r{\| Evaluation cases \| \*\*\d+\*\* \|}, "| Evaluation cases | **73** |")
        .sub(%r{\| Dedicated system/contract tests \| \*\*\d+\*\* \|}, "| Dedicated system/contract tests | **72** |")
        .sub(%r{\| Manifest version \| \*\*\d+\*\* \|}, "| Manifest version | **3** |")
      File.write(readme_path, tampered)

      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(copy, "scripts", "audit_repository_completeness.rb"),
        chdir: copy
      )

      refute status.success?, "drifted README inventory counts must fail the audit"
      assert_includes stderr, "README Skills count 75"
      assert_includes stderr, "README Implementation patterns count 74"
      assert_includes stderr, "README Evaluation cases count 73"
      assert_includes stderr, "README Dedicated system/contract tests count 72"
      assert_includes stderr, "README manifest version 3"
    end
  end

  def test_audit_defends_every_readme_inventory_row
    audit = File.read(
      File.join(ROOT, "scripts", "audit_repository_completeness.rb"),
      encoding: "UTF-8"
    )

    %w[
      "Skills" => skill_files.length
      "Implementation patterns" => pattern_files.length
      "Evaluation cases" => eval_case_count
      "Dedicated system/contract tests" => system_tests.length
    ].each do |fragment|
      assert_includes audit, fragment, "completeness audit must verify #{fragment}"
    end
    assert_includes audit, 'manifest_version = manifest.fetch("version")',
                   "completeness audit must verify the README manifest version"
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
