# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../fixtures/ruby-toolchain-contract/lib/solution"

class RubyToolchainAdvisorReferenceTest < Minitest::Test
  def test_reference_resolves_declared_and_observed_runtime
    assert_equal "supported", RubyToolchainAdvisor.new.resolve(
      declared_ruby: "3.3",
      observed_ruby: "3.3.6",
      ruby_executable: "/usr/local/bin/ruby",
      bundle_executable: "/usr/local/bin/bundle"
    ).fetch("status")
  end
end
