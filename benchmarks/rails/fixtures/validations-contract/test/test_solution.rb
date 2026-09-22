# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class ValidationsContractTest < Minitest::Test
  def test_default_context_does_not_apply_publish_only_rules
    project = Project.new(name: "Roadmap", tenant_id: 10)
    assert project.valid?
    refute project.valid?(context: :publish)
    assert_equal :blank, project.errors.details[:description].first[:type]
  end

  def test_conditional_invitation_validation_is_deterministic
    assert Invitation.new(delivery: :sms).valid?
    refute Invitation.new(delivery: :email).valid?
  end

  def test_tenant_scoped_uniqueness_is_explicit
    rule = TenantTokenUniqueness.new(
      1 => { tenant_id: 10, token: "abc" },
      2 => { tenant_id: 11, token: "abc" }
    )
    refute rule.available?(tenant_id: 10, token: "abc")
    assert rule.available?(tenant_id: 11, token: "abc")
  end

  def test_errors_have_stable_identity
    project = Project.new(name: "", tenant_id: 10)
    refute project.valid?
    assert_equal :blank, project.errors.details[:name].first[:type]
  end

  def test_reusable_rule_can_be_shared_without_workflow_side_effects
    rule = ReusableDomainValidator.new { |value| value.to_s.length >= 3 }
    project = Project.new(name: "ok", tenant_id: 10, domain_rule: rule)
    refute project.valid?
    assert_equal :invalid, project.errors.details[:name].first[:type]
  end
end
