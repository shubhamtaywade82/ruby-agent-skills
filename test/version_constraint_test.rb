# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/ruby_agent_skills/version_constraint"

class VersionConstraintTest < Minitest::Test
  V = RubyAgentSkills::VersionConstraint

  def test_supports_standard_gem_requirements
    assert V.satisfies?("8.1.4", ">= 8.1")
    assert V.satisfies?("8.1.4", "~> 8.1")
    refute V.satisfies?("7.2.2", ">= 8.1")
    refute V.satisfies?("8.2.0", "~> 8.1")
  end

  def test_supports_comma_separated_requirements
    assert V.satisfies?("3.3.12", ">= 3.2, < 3.4")
    refute V.satisfies?("3.4.1", ">= 3.2, < 3.4")
  end

  def test_normalizes_ruby_patch_identifiers
    assert V.satisfies?("3.3.6p108", ">= 3.3")
  end

  def test_rejects_invalid_requirements
    assert_raises(V::InvalidRequirement) { V.satisfies?("8.1.4", "rails-eight") }
    assert_raises(V::InvalidVersion) { V.satisfies?("not-a-version", ">= 8.1") }
  end

  def test_evaluates_runtime_profile_states
    profile = {
      "ruby" => { "resolved" => "3.3.12", "status" => "resolved" },
      "rails" => { "resolved" => "8.1.4", "status" => "resolved" }
    }

    result = V.evaluate(
      { "ruby" => ">= 3.2", "rails" => "~> 8.1" },
      profile
    )

    assert_equal "supported", result.fetch("status")
    assert_equal "supported", result.dig("requirements", "ruby", "status")
    assert_equal "supported", result.dig("requirements", "rails", "status")
  end

  def test_marks_conflicted_runtime_as_conflict
    profile = {
      "rails" => { "resolved" => nil, "status" => "conflict" }
    }

    result = V.evaluate({ "rails" => ">= 8.1" }, profile)

    assert_equal "conflict", result.fetch("status")
  end

  def test_marks_missing_runtime_as_unknown
    result = V.evaluate(
      { "rails" => ">= 8.1" },
      { "rails" => { "resolved" => nil, "status" => "unknown" } }
    )

    assert_equal "unknown", result.fetch("status")
    assert_equal "unknown", result.dig("requirements", "rails", "status")
  end

  def test_empty_requirements_are_unspecified
    assert_equal "unspecified", V.evaluate({}, {}).fetch("status")
  end
end
