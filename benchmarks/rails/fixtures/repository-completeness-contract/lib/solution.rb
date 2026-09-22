# frozen_string_literal: true
class CompletenessAuditor
  def initialize(skills:,patterns:,evaluations:,routes:,system_tests:) = (@skills,@patterns,@evaluations,@routes,@system_tests=skills,patterns,evaluations,routes,system_tests)
  def registry_complete?
    @skills.all? && @patterns.all? && @evaluations.all?
  end
  def routing_complete? = @routes.sort == @skills.sort
  def system_test_complete? = @system_tests[:declared] == @system_tests[:executed]
  def rails_8_1_coverage
    %w[ActiveJob::Continuable Rails.event config/ci.rb render markdown Solid Cache Solid Cable rails credentials:fetch].all?
  end
end
