# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RubyRailsFoundationsSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def manifest
    YAML.safe_load(
      File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
  end

  def routing
    File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")
  end

  def test_ruby_toolchain_skill_is_registered
    assert_equal "skills/ruby-toolchain/SKILL.md",
                 manifest.fetch("skills").fetch("ruby-toolchain").fetch("path")
  end

  def test_rails_application_bootstrap_skill_is_registered
    assert_equal "skills/rails-application-bootstrap/SKILL.md",
                 manifest.fetch("skills").fetch("rails-application-bootstrap").fetch("path")
  end

  def test_ruby_gem_development_skill_is_registered
    assert_equal "skills/ruby-gem-development/SKILL.md",
                 manifest.fetch("skills").fetch("ruby-gem-development").fetch("path")
  end

  def test_rails_bootstrap_trigger_is_registered
    assert_includes manifest.fetch("skills").fetch("rails-application-bootstrap").fetch("triggers"), "rails new"
  end

  def test_ruby_gem_trigger_is_registered
    assert_includes manifest.fetch("skills").fetch("ruby-gem-development").fetch("triggers"), "bundle gem"
  end

  def test_routing_keeps_bootstrap_separate_from_generators
    text = routing

    assert_includes text, "Create a Rails application /"
    assert_includes text, "rails new"
    assert_includes text, "rails new versus generator"
    assert_includes text, "rails-generators"
    assert_includes text, "rails-application-bootstrap"
  end

  def test_routing_keeps_toolchain_separate_from_runtime_compatibility
    text = routing

    assert_includes text, "Ruby toolchain/environment setup"
    assert_includes text, "Runtime/version compatibility"
    assert_includes text, "ruby-toolchain"
  end

  def test_routing_keeps_gem_authoring_separate_from_dependency_installation
    text = routing

    assert_includes text, "Ruby gem authoring/packaging/release"
    assert_includes text, "ruby-gem-development"
  end

  def test_ruby_toolchain_evaluation_is_registered
    assert_includes manifest.fetch("evaluations").keys, "ruby-toolchain-foundation"
  end

  def test_rails_bootstrap_evaluation_is_registered
    assert_includes manifest.fetch("evaluations").keys, "rails-application-bootstrap"
  end

  def test_ruby_gem_development_evaluation_is_registered
    assert_includes manifest.fetch("evaluations").keys, "ruby-gem-development"
  end

  def test_foundational_evaluation_paths_are_registered
    paths = manifest.fetch("evaluations").values.flat_map { |entry| Array(entry.fetch("paths")) }

    assert_includes paths, "evals/ruby-toolchain/contract.yml"
    assert_includes paths, "evals/rails/application-bootstrap-contract.yml"
    assert_includes paths, "evals/ruby-gem-development/contract.yml"
  end

  def test_validator_invokes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/ruby_rails_foundations_system_test.rb"
  end
end
