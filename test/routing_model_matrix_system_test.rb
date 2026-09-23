# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RoutingModelMatrixSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_matrix_is_not_a_ranking_system
    config = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_MODEL_MATRIX.yml"), encoding: "UTF-8"),
      permitted_classes: [], aliases: false
    )
    assert_empty config.fetch("models")
    assert_equal true, config.fetch("controls").fetch("descriptive_comparison_only")
    assert_equal true, config.fetch("controls").fetch("do_not_compare_unexecuted_models")
  end

  def test_schema_exists
    assert File.file?(File.join(ROOT, "docs", "ROUTING_MODEL_MATRIX_SCHEMA.md"))
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_model_matrix_system_test.rb"
  end
end
