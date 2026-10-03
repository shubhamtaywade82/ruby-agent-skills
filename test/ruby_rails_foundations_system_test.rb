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

  def test_new_skill_triggers_are_registered
    expected = {
      "rails-application-bootstrap" => "rails new",
      "ruby-gem-development" => "bundle gem"
    }
    observed = expected.to_h do |skill, trigger|
      [skill, manifest.fetch("skills").fetch(skill).fetch("triggers").include?(trigger)]
    end

    assert_equal expected.keys.to_h { |skill| [skill, true] }, observed
  end

  def test_routing_keeps_bootstrap_separate_from_generators
    required = [
      "Create a Rails application / `rails new`",
      "rails new",
      "`rails new` versus generator",
      "rails-generators",
      "rails-application-bootstrap"
    ]

    assert(required.all? { |token| routing.include?(token) })
  end

  def test_routing_keeps_toolchain_and_gem_boundaries
    required = [
      "Ruby toolchain/environment setup",
      "Runtime/version compatibility",
      "ruby-toolchain",
      "Ruby gem authoring/packaging/release",
      "ruby-gem-development"
    ]

    assert(required.all? { |token| routing.include?(token) })
  end

  def test_foundational_evaluations_are_registered
    evaluations = manifest.fetch("evaluations")
    expected = %w[
      rails-application-bootstrap
      ruby-gem-development
      ruby-toolchain-foundation
    ]

    assert_equal expected, (evaluations.keys & expected).sort
  end

  def test_foundational_evaluation_paths_are_registered
    paths = manifest.fetch("evaluations").values.flat_map { |entry| Array(entry.fetch("paths")) }
    expected = %w[
      evals/rails/application-bootstrap-contract.yml
      evals/ruby-gem-development/contract.yml
      evals/ruby-toolchain/contract.yml
    ]

    assert_equal expected, (paths & expected).sort
  end

  def test_validator_invokes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/ruby_rails_foundations_system_test.rb"
  end
end
