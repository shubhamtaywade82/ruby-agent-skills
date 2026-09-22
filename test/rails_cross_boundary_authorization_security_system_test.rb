# frozen_string_literal: true
require "minitest/autorun"
require "yaml"

class RailsCrossBoundaryAuthorizationSecuritySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  REQUIRED_PATHS = %w[
    skills/rails-cross-boundary-authorization-security/SKILL.md
    patterns/rails/authorization-context-contract.md
    patterns/rails/authorization-decision-boundary.md
    patterns/rails/authorized-resource-resolution.md
    patterns/rails/controller-service-authorization-composition.md
    patterns/rails/background-reauthorization-composition.md
    patterns/rails/api-authorization-composition.md
    patterns/rails/realtime-authorization-composition.md
    patterns/rails/engine-authorization-composition.md
    patterns/rails/operational-authorization-composition.md
    patterns/rails/event-consumer-authorization-contract.md
    patterns/rails/capability-propagation-contract.md
    patterns/rails/authorization-denial-contract.md
    patterns/rails/authorization-cache-composition.md
    patterns/rails/authorization-audit-composition.md
    evals/security/cross-boundary-authorization-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each { |p| assert File.file?(File.join(ROOT, p)), "missing #{p}" }
  end

  def test_manifest_registration
    m=YAML.safe_load(File.read(File.join(ROOT,"skill-manifest.yml"),encoding:"UTF-8"))
    s=m.fetch("skills").fetch("rails-cross-boundary-authorization-security")
    assert_equal "skills/rails-cross-boundary-authorization-security/SKILL.md",s.fetch("path")
    %w[authorization cross-boundary policy tenant service job API Action Cable engine operational command event capability denial cache audit].each { |t| assert_includes s.fetch("triggers"), t }
    rails=m.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.grep(%r{^patterns/rails/}).each { |p| assert_includes rails,p }
    assert_includes m.fetch("evaluations").fetch("rails-cross-boundary-authorization-security").fetch("paths"), "evals/security/cross-boundary-authorization-contract.yml"
  end

  def test_router_agents_validator
    routing=File.read(File.join(ROOT,"router/ROUTING.md"),encoding:"UTF-8")
    agents=File.read(File.join(ROOT,"AGENTS.md"),encoding:"UTF-8")
    validator=File.read(File.join(ROOT,"bin/validate"),encoding:"UTF-8")
    assert_includes routing,"Rails Cross-Boundary Authorization and Security Composition"
    assert_includes routing,"rails-cross-boundary-authorization-security"
    assert_includes agents,"Rails cross-boundary authorization/security changes"
    assert_includes agents,"re-authorize"
    assert_includes validator,"rails_cross_boundary_authorization_security_system_test.rb"
  end

  def test_evaluation_contract
    e=YAML.safe_load(File.read(File.join(ROOT,"evals/security/cross-boundary-authorization-contract.yml"),encoding:"UTF-8"))
    assert_includes e.fetch("skills"),"rails-cross-boundary-authorization-security"
    assert_includes e.fetch("patterns"),"background-reauthorization-composition"
    assert_includes e.fetch("patterns"),"authorization-cache-composition"
    assert_equal "scope_control",e.fetch("checks").last
  end

  def test_skill_contract
    s=File.read(File.join(ROOT,"skills/rails-cross-boundary-authorization-security/SKILL.md"),encoding:"UTF-8")
    [
      "Authorization composition model","Resource resolution","Controller and service parity",
      "Background re-authorization","API composition","Realtime composition","Engine composition",
      "Operational and administrative commands","Event and message consumers","Capability propagation",
      "Denial semantics","Authorization caching","Audit and evidence","Security testing strategy"
    ].each { |x| assert_includes s,x }
    assert_includes s,"Never treat a controller check as proof that a service, job, event consumer, engine, task, or channel is authorized."
  end
end
