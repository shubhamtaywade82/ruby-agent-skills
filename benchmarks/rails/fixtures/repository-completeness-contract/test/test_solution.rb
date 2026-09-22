# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class CompletenessAuditorTest < Minitest::Test
  def setup
    @audit=CompletenessAuditor.new(skills:%w[a b],patterns:[true],evaluations:[true],routes:%w[a b],system_tests:{declared:40,executed:40})
  end
  def test_registry_and_routing_contracts
    assert @audit.registry_complete?
    assert @audit.routing_complete?
    assert @audit.system_test_complete?
  end
  def test_version_sensitive_coverage_is_explicit
    assert @audit.rails_8_1_coverage
  end
end
