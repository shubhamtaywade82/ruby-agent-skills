# frozen_string_literal: true
require "minitest/autorun"
require "yaml"

class RailsInitializationConfigurationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  REQUIRED_PATHS = %w[
    skills/rails-initialization-configuration-engineering/SKILL.md
    patterns/rails/configuration-ownership-contract.md
    patterns/rails/configuration-precedence-contract.md
    patterns/rails/initializer-dependency-contract.md
    patterns/rails/lifecycle-hook-contract.md
    patterns/rails/reload-safe-initializer.md
    patterns/rails/boot-external-dependency-boundary.md
    patterns/rails/environment-configuration-contract.md
    patterns/rails/boot-failure-contract.md
    patterns/rails/application-config-contract.md
    patterns/rails/initializer-testing-contract.md
    patterns/rails/boot-performance-contract.md
    evals/rails/initialization-configuration-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each { |p| assert File.file?(File.join(ROOT,p)), "missing #{p}" }
  end

  def test_manifest_registration
    m=YAML.safe_load(File.read(File.join(ROOT,"skill-manifest.yml"),encoding:"UTF-8"))
    s=m.fetch("skills").fetch("rails-initialization-configuration-engineering")
    assert_equal "skills/rails-initialization-configuration-engineering/SKILL.md",s.fetch("path")
    %w[initializer config.initializers config/application.rb config/environment.rb config/boot.rb config.ru config.x before_initialize after_initialize to_prepare load_defaults].each{|t| assert_includes s.fetch("triggers"),t}
    paths=m.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.grep(%r{^patterns/rails/}).each{|p| assert_includes paths,p}
    assert_includes m.fetch("patterns").fetch("testing").fetch("paths"),"patterns/rails/initializer-testing-contract.md"
    assert_includes m.fetch("evaluations").fetch("rails-initialization-configuration-engineering").fetch("paths"),"evals/rails/initialization-configuration-contract.yml"
  end

  def test_router_agents_validator
    routing=File.read(File.join(ROOT,"router/ROUTING.md"),encoding:"UTF-8")
    agents=File.read(File.join(ROOT,"AGENTS.md"),encoding:"UTF-8")
    validator=File.read(File.join(ROOT,"bin/validate"),encoding:"UTF-8")
    assert_includes routing,"Rails Initialization and Configuration engineering"
    assert_includes routing,"rails-initialization-configuration-engineering"
    assert_includes agents,"Rails initialization/configuration changes"
    assert_includes agents,"initializer"
    assert_includes validator,"rails_initialization_configuration_system_test.rb"
  end

  def test_evaluation_contract
    e=YAML.safe_load(File.read(File.join(ROOT,"evals/rails/initialization-configuration-contract.yml"),encoding:"UTF-8"))
    assert_includes e.fetch("skills"),"rails-initialization-configuration-engineering"
    assert_includes e.fetch("patterns"),"configuration-precedence-contract"
    assert_includes e.fetch("patterns"),"reload-safe-initializer"
    assert_equal "scope_control",e.fetch("checks").last
  end

  def test_skill_contract
    s=File.read(File.join(ROOT,"skills/rails-initialization-configuration-engineering/SKILL.md"),encoding:"UTF-8")
    %w[Core contract Configuration ownership Configuration precedence Initialization ordering Lifecycle hooks and reloading External dependencies at boot Environment separation Secrets and configuration safety Testing strategy].each{|x| assert_includes s,x}
    assert_includes s,"Do not claim boot correctness from static inspection alone."
  end
end
