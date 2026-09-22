# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class EnginesRailtiesTest < Minitest::Test
  def test_engine_boundary_and_mount
    assert_equal "Reports",ReportsEngine.isolate_namespace
    app=DummyHostApp.new; app.mount(engine:ReportsEngine)
    assert_equal "/reports",app.mounted
  end
  def test_railtie_is_narrow_and_version_aware
    railtie=ReportsRailtie.new; assert_equal :configured,railtie.initialize_hook
    assert_includes railtie.gemspec_contract[:required_rails],">= 8.0"
  end
  def test_generator_output_is_explicit
    assert_equal ["reports:migrate"],ReportsRailtie.new.generator_output
  end
end
