# frozen_string_literal: true

require "minitest/autorun"
require "open3"

class RoutingEvidenceVerifierSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_verifier_rejects_non_json_input
    verifier = File.join(ROOT, "bin", "routing-evidence-verify")
    _stdout, stderr, status = Open3.capture3(RbConfig.ruby, verifier, File.join(ROOT, "docs", "ROUTING_EVIDENCE_SCHEMA.md"), chdir: ROOT)
    refute status.success?
    refute_empty stderr
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_evidence_verifier_system_test.rb"
  end
end
