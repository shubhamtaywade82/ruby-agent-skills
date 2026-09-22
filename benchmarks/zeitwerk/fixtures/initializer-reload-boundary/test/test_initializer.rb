# frozen_string_literal: true

require "minitest/autorun"

class InitializerReloadBoundaryTest < Minitest::Test
  def test_initializer_uses_prepare_lifecycle
    source = File.read(File.expand_path("../config/initializers/api_gateway.rb", __dir__))
    assert_includes source, "to_prepare"
  end
end
