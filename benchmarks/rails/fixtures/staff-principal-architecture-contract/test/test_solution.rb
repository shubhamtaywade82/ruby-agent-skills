# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class ArchitectureDecisionTest < Minitest::Test
  def setup
    @decision=ArchitectureDecision.new(problem:"cyclic modules",owner:"billing",dependency_direction:"domain->ports->adapters",data_owner:"billing")
  end
  def test_problem_ownership_and_direction_are_explicit
    assert ArchitectureReview.new(@decision).evidence_complete?
    assert_equal "billing",@decision.data_owner
    refute_empty @decision.dependency_direction
  end
  def test_no_change_is_an_explicit_alternative
    assert_includes @decision.alternatives,:no_change
  end
  def test_migration_and_fitness_are_executable
    assert_includes @decision.migration_plan,:cutover
    assert_includes @decision.fitness_rule,"forbid dependency"
  end
end
