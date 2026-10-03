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

  def test_foundational_skills_are_registered_with_distinct_boundaries
    skills = manifest.fetch("skills")

    {
      "ruby-toolchain" => "skills/ruby-toolchain/SKILL.md",
      "rails-application-bootstrap" => "skills/rails-application-bootstrap/SKILL.md",
      "ruby-gem-development" => "skills/ruby-gem-development/SKILL.md"
    }.each do |name, path|
      assert_equal path, skills.fetch(name).fetch("path")
    end

    assert_includes skills.fetch("rails-application-bootstrap").fetch("triggers"), "rails new"
    assert_includes skills.fetch("ruby-gem-development").fetch("triggers"), "bundle gem"
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

  def test_evaluations_are_registered
    evaluations = manifest.fetch("evaluations")

    assert_includes evaluations.keys, "ruby-toolchain-foundation"
    assert_includes evaluations.keys, "rails-application-bootstrap"
    assert_includes evaluations.keys, "ruby-gem-development"

    paths = evaluations.values.flat_map { |entry| Array(entry.fetch("paths")) }
    assert_includes paths, "evals/ruby-toolchain/contract.yml"
    assert_includes paths, "evals/rails/application-bootstrap-contract.yml"
    assert_includes paths, "evals/ruby-gem-development/contract.yml"
  end

  def test_validator_invokes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/ruby_rails_foundations_system_test.rb"
  end
end
