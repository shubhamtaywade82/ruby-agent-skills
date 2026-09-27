# frozen_string_literal: true
class AppConfig
  attr_reader :region
  def initialize(env:,env_value:nil) = raise(NotImplementedError)
end
class Initializer
  def initialize(config:) = @config=config
  def boot(required:)
    raise NotImplementedError
  end
  def reload(state:) = raise(NotImplementedError)
  def external_dependency(timeout:) = raise(NotImplementedError)
end
class BootContract
  def initialize(config:) = raise(NotImplementedError)
  def start(required:) = raise(NotImplementedError)
end
