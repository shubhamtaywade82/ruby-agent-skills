# frozen_string_literal: true
class AppConfig
  attr_reader :region
  def initialize(env:,env_value:nil) = @region=env_value || (env==:production ? :us : :test)
end
class Initializer
  def initialize(config:) = @config=config
  def boot(required:)
    raise "missing required configuration" if required.nil?
    {phase: :boot,region:@config.region}
  end
  def reload(state:) = state.dup
  def external_dependency(timeout:) = {timeout:timeout,ready:true}
end
class BootContract
  def initialize(config:) = @initializer=Initializer.new(config:)
  def start(required:) = @initializer.boot(required:)
end
