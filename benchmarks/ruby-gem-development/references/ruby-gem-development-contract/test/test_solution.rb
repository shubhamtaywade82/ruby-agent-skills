# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class RubyGemDevelopmentAdvisorReferenceTest < Minitest::Test
  def test_reference_gem_skeleton_command
    assert_equal(
      "bundle gem fixture_gem",
      RubyGemDevelopmentAdvisor.new.skeleton_command("fixture_gem")
    )
  end
end
