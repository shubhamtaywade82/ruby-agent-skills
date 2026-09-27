# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class DocumentationConsistencySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def source(path)
    File.read(File.join(ROOT, path), encoding: "UTF-8")
  end

  def test_documentation_audit_is_registered_and_executable
    script = source("scripts/audit_documentation_consistency.rb")
    assert_includes script, "CHANGELOG.md"
    assert_includes script, "IMPLEMENTATION_HANDOFF.md"
    assert_includes script, "evaluation_count"
    assert_includes script, "Current milestone"
  end

  def test_documentation_audit_passes_current_repository_state
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts", "audit_documentation_consistency.rb"),
      chdir: ROOT
    )

    assert status.success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "Documentation consistency audit passed."
  end

  def test_documentation_audit_detects_stale_handoff_inventory
    Dir.mktmpdir("documentation-consistency") do |dir|
      readme = source("README.md")
      handoff = source("docs/IMPLEMENTATION_HANDOFF.md")
      changelog = source("CHANGELOG.md")
      manifest = source("skill-manifest.yml")

      File.write(File.join(dir, "README.md"), readme, encoding: "UTF-8")
      FileUtils.mkdir_p(File.join(dir, "docs"))
      FileUtils.mkdir_p(File.join(dir, "skills"))
      FileUtils.mkdir_p(File.join(dir, "patterns"))
      FileUtils.mkdir_p(File.join(dir, "evals"))
      FileUtils.mkdir_p(File.join(dir, "test"))
      File.write(File.join(dir, "docs", "IMPLEMENTATION_HANDOFF.md"), handoff.sub("442 evaluation cases", "436 evaluation cases"), encoding: "UTF-8")
      Dir[File.join(ROOT, "skills", "*", "SKILL.md")].first && FileUtils.cp_r(File.join(ROOT, "skills"), dir)
      FileUtils.cp_r(File.join(ROOT, "patterns"), dir)
      FileUtils.cp_r(File.join(ROOT, "evals"), dir)
      FileUtils.cp_r(File.join(ROOT, "test"), dir)
      File.write(File.join(dir, "CHANGELOG.md"), changelog, encoding: "UTF-8")
      File.write(File.join(dir, "skill-manifest.yml"), manifest, encoding: "UTF-8")
      
      audit = File.join(ROOT, "scripts", "audit_documentation_consistency.rb")

      _stdout, stderr, status = Open3.capture3(RbConfig.ruby, audit, "--root", dir, chdir: ROOT)
      refute status.success?
      assert_includes stderr, "IMPLEMENTATION_HANDOFF.md"
    end
  end

  def test_validator_invokes_this_system_test
    assert_includes source("bin/validate"), "test/documentation_consistency_system_test.rb"
  end
end
