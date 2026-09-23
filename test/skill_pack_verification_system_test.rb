# frozen_string_literal: true

require "minitest/autorun"
require "open3"

class SkillPackVerificationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_verifier_requires_an_installation_root
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "bin", "skill-pack-verify"),
      chdir: ROOT
    )

    refute status.success?
    assert_empty stdout
    assert_includes stderr, "--root is required"
  end

  def test_installer_documents_verification_command
    source = File.read(File.join(ROOT, "bin", "install"), encoding: "UTF-8")
    verifier = File.read(File.join(ROOT, "bin", "skill-pack-verify"), encoding: "UTF-8")

    assert_includes source, "INSTALLATION.json"
    assert_includes verifier, "skill_manifest_sha256"
    assert_includes verifier, "routing_contract_sha256"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/skill_pack_verification_system_test.rb"
  end
end
