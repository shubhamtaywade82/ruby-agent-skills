# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class InitializationConfigurationTest < Minitest::Test
  def test_precedence_and_boot_failure
    config=AppConfig.new(env: :production,env_value: :eu)
    assert_equal :eu,config.region
    assert_raises(RuntimeError){Initializer.new(config:config).boot(required:nil)}
  end
  def test_reload_is_idempotent
    state={subscriptions:1}
    result=Initializer.new(config:AppConfig.new(env: :test)).reload(state:)
    assert_equal state,result
    refute_same state,result
  end
  def test_external_dependency_has_explicit_timeout
    result=Initializer.new(config:AppConfig.new(env: :test)).external_dependency(timeout:2)
    assert_equal 2,result[:timeout]
  end
end
