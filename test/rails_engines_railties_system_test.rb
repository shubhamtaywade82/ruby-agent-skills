# frozen_string_literal: true
require "minitest/autorun"
require "yaml"

class RailsEnginesRailtiesSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  REQUIRED_PATHS = %w[
    skills/rails-engines-railties-engineering/SKILL.md
    patterns/rails/engine-boundary-contract.md
    patterns/rails/engine-namespace-isolation.md
    patterns/rails/engine-mount-routing-contract.md
    patterns/rails/engine-configuration-boundary.md
    patterns/rails/railtie-initialization-boundary.md
    patterns/rails/engine-autoloading-contract.md
    patterns/rails/engine-dependency-compatibility.md
    patterns/rails/engine-host-override-contract.md
    patterns/rails/engine-generator-task-contract.md
    patterns/rails/engine-asset-integration-contract.md
    patterns/rails/engine-dummy-app-testing.md
    patterns/rails/engine-cross-engine-composition.md
    evals/rails/engines-railties-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each { |p| assert File.file?(File.join(ROOT, p)), "missing #{p}" }
  end

  def test_manifest_registration
    m=YAML.safe_load(File.read(File.join(ROOT,"skill-manifest.yml"),encoding:"UTF-8"))
    s=m.fetch("skills").fetch("rails-engines-railties-engineering")
    assert_equal "skills/rails-engines-railties-engineering/SKILL.md",s.fetch("path")
    %w[Rails::Engine Rails::Railtie Engine Railtie plugin mountable isolate_namespace engine routes engine.rb railtie.rb generators engine gemspec].each { |t| assert_includes s.fetch("triggers"), t }
    rails=m.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.grep(%r{^patterns/rails/}).each { |p| assert_includes rails,p }
    assert_includes m.fetch("patterns").fetch("testing").fetch("paths"), "patterns/rails/engine-dummy-app-testing.md"
    assert_includes m.fetch("evaluations").fetch("rails-engines-railties-engineering").fetch("paths"), "evals/rails/engines-railties-contract.yml"
  end

  def test_router_agents_validator
    routing=File.read(File.join(ROOT,"router/ROUTING.md"),encoding:"UTF-8")
    agents=File.read(File.join(ROOT,"AGENTS.md"),encoding:"UTF-8")
    validator=File.read(File.join(ROOT,"bin/validate"),encoding:"UTF-8")
    assert_includes routing,"Rails Engines and Railties engineering"
    assert_includes routing,"rails-engines-railties-engineering"
    assert_includes agents,"Rails Engine/Railtie changes"
    assert_includes agents,"isolate_namespace"
    assert_includes validator,"rails_engines_railties_system_test.rb"
  end

  def test_evaluation_contract
    e=YAML.safe_load(File.read(File.join(ROOT,"evals/rails/engines-railties-contract.yml"),encoding:"UTF-8"))
    assert_includes e.fetch("skills"),"rails-engines-railties-engineering"
    assert_includes e.fetch("patterns"),"engine-namespace-isolation"
    assert_includes e.fetch("patterns"),"engine-dummy-app-testing"
    assert_equal "scope_control",e.fetch("checks").last
  end

  def test_skill_contract
    s=File.read(File.join(ROOT,"skills/rails-engines-railties-engineering/SKILL.md"),encoding:"UTF-8")
    [
      "Core contract","Repository inspection","Engine boundary and isolation","Mounting and routing",
      "Engine configuration","Railtie and initialization","Dependencies and compatibility",
      "Autoloading and load order","Generators, tasks, and migrations","Testing strategy"
    ].each { |x| assert_includes s,x }
    assert_includes s,"Do not claim engine compatibility or isolation from static structure alone."
  end
end
