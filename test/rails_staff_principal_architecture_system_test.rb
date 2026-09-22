# frozen_string_literal: true
require "minitest/autorun"
require "yaml"

class RailsStaffPrincipalArchitectureSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  REQUIRED_PATHS = %w[
    skills/rails-staff-principal-architecture/SKILL.md
    patterns/rails/architecture-problem-statement.md
    patterns/rails/dependency-direction-contract.md
    patterns/rails/bounded-context-contract.md
    patterns/rails/modular-monolith-boundary.md
    patterns/rails/data-ownership-contract.md
    patterns/rails/shared-kernel-contract.md
    patterns/rails/application-service-boundary.md
    patterns/rails/cross-cutting-ownership-contract.md
    patterns/rails/change-coupling-contract.md
    patterns/rails/distributed-boundary-readiness.md
    patterns/rails/architectural-migration-contract.md
    patterns/rails/architecture-decision-record-contract.md
    patterns/rails/architecture-fitness-check.md
    patterns/rails/architecture-tradeoff-contract.md
    patterns/rails/architecture-ownership-contract.md
    evals/rails/staff-principal-architecture-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each { |p| assert File.file?(File.join(ROOT,p)), "missing #{p}" }
  end

  def test_manifest_registration
    m=YAML.safe_load(File.read(File.join(ROOT,"skill-manifest.yml"),encoding:"UTF-8"))
    s=m.fetch("skills").fetch("rails-staff-principal-architecture")
    assert_equal "skills/rails-staff-principal-architecture/SKILL.md",s.fetch("path")
    %w[architecture staff principal modular monolith bounded context dependency direction data ownership coupling extraction migration ADR fitness tradeoff ownership].each { |t| assert_includes s.fetch("triggers"), t }
    rails=m.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.grep(%r{^patterns/rails/}).each { |p| assert_includes rails,p }
    assert_includes m.fetch("evaluations").fetch("rails-staff-principal-architecture").fetch("paths"), "evals/rails/staff-principal-architecture-contract.yml"
  end

  def test_router_agents_validator
    routing=File.read(File.join(ROOT,"router/ROUTING.md"),encoding:"UTF-8")
    agents=File.read(File.join(ROOT,"AGENTS.md"),encoding:"UTF-8")
    validator=File.read(File.join(ROOT,"bin/validate"),encoding:"UTF-8")
    assert_includes routing,"Rails Staff and Principal Architecture"
    assert_includes routing,"rails-staff-principal-architecture"
    assert_includes agents,"Rails staff/principal architecture changes"
    assert_includes agents,"dependency direction"
    assert_includes validator,"rails_staff_principal_architecture_system_test.rb"
  end

  def test_evaluation_contract
    e=YAML.safe_load(File.read(File.join(ROOT,"evals/rails/staff-principal-architecture-contract.yml"),encoding:"UTF-8"))
    assert_includes e.fetch("skills"),"rails-staff-principal-architecture"
    assert_includes e.fetch("patterns"),"data-ownership-contract"
    assert_includes e.fetch("patterns"),"distributed-boundary-readiness"
    assert_equal "scope_control",e.fetch("checks").last
  end

  def test_skill_contract
    s=File.read(File.join(ROOT,"skills/rails-staff-principal-architecture/SKILL.md"),encoding:"UTF-8")
    [
      "Architecture decision sequence","Boundary design","Dependency direction",
      "Modularity and modular monoliths","Bounded contexts and shared kernel",
      "Data ownership","Dependency graph and cycle control","Change coupling",
      "Extraction and service decomposition","Architectural migration",
      "Architecture decision records","Architecture fitness and enforcement",
      "Team ownership and operational responsibility"
    ].each { |x| assert_includes s,x }
    assert_includes s,"Do not introduce layers, services, packages, engines, abstractions, or distributed systems merely because they are fashionable."
  end
end
