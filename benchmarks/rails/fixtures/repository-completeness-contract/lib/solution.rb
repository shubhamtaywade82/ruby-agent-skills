# frozen_string_literal: true
class CompletenessAuditor
  def initialize(skills:,patterns:,evaluations:,routes:,system_tests:) = (@skills,@patterns,@evaluations,@routes,@system_tests=skills,patterns,evaluations,routes,system_tests)
  def registry_complete?
    raise NotImplementedError
  end
  def routing_complete? = raise(NotImplementedError)
  def system_test_complete? = raise(NotImplementedError)
  def rails_8_1_coverage
    raise NotImplementedError
  end
end
