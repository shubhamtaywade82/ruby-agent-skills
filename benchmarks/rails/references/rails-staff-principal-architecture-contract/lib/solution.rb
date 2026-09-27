# frozen_string_literal: true
class ArchitectureDecision
  attr_reader :problem,:owner,:dependency_direction,:data_owner
  def initialize(problem:,owner:,dependency_direction:,data_owner:) = (@problem,@owner,@dependency_direction,@data_owner=problem,owner,dependency_direction,data_owner)
  def alternatives = [:no_change,:modular_boundary,:service_extraction]
  def migration_plan = [:compatibility,:dual_read_or_write,:cutover,:cleanup,:verify]
  def tradeoffs = {latency: :lower,complexity: :higher,operability: :explicit}
  def fitness_rule = "forbid dependency from #{owner} to infrastructure internals"
end
class ArchitectureReview
  def initialize(decision) = @decision=decision
  def evidence_complete? = !@decision.problem.empty? && !@decision.data_owner.nil? && @decision.alternatives.include?(:no_change)
end
