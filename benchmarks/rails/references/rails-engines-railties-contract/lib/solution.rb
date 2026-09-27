# frozen_string_literal: true
class ReportsEngine
  def self.isolate_namespace = "Reports"
  def self.mount_path = "/reports"
  def self.configuration = {default_role:"viewer"}
end
class ReportsRailtie
  def initialize(host_config={}) = @host_config=host_config
  def initialize_hook = :configured
  def generator_output = ["reports:migrate"]
  def gemspec_contract = {required_ruby:">= 3.3",required_rails:">= 8.0"}
end
class DummyHostApp
  def initialize = @mounted=false
  def mount(engine:) = @mounted=engine.mount_path
  attr_reader :mounted
end
