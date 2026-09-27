# frozen_string_literal: true

require "minitest/autorun"

class InitializerReloadBoundaryTest < Minitest::Test
  def source
    File.read(File.expand_path("../config/initializers/api_gateway.rb", __dir__))
  end

  def test_initializer_uses_prepare_lifecycle
    assert_includes source, "to_prepare"
  end

  def test_reloadable_constant_is_not_required_or_cached_at_boot
    refute_match(/require\s+["'].*api_gateway/, source)
    refute_match(/^\s*\w+\s*=\s*ApiGateway\b/, source)
  end
end
