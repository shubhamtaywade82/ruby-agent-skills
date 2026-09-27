# frozen_string_literal: true
class ReportsEngine
  def self.isolate_namespace = raise(NotImplementedError)
  def self.mount_path = raise(NotImplementedError)
  def self.configuration = raise(NotImplementedError)
end
class ReportsRailtie
  def initialize(host_config={}) = @host_config=host_config
  def initialize_hook = raise(NotImplementedError)
  def generator_output = raise(NotImplementedError)
  def gemspec_contract = raise(NotImplementedError)
end
class DummyHostApp
  def initialize = raise(NotImplementedError)
  def mount(engine:) = raise(NotImplementedError)
  attr_reader :mounted
end
