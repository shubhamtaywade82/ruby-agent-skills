# frozen_string_literal: true
class ArchitectureDecision
  attr_reader :problem,:owner,:dependency_direction,:data_owner
  def initialize(problem:,owner:,dependency_direction:,data_owner:) = (@problem,@owner,@dependency_direction,@data_owner=problem,owner,dependency_direction,data_owner)
  def alternatives = raise(NotImplementedError)
  def migration_plan = raise(NotImplementedError)
  def tradeoffs = raise(NotImplementedError)
  def fitness_rule = raise(NotImplementedError)
end
class ArchitectureReview
  def initialize(decision) = @decision=decision
  def evidence_complete? = raise(NotImplementedError)
end
