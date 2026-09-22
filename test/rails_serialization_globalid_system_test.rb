# frozen_string_literal: true
require "minitest/autorun"
require "yaml"

class RailsSerializationGlobalidSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  REQUIRED_PATHS = %w[
    skills/rails-serialization-globalid-engineering/SKILL.md
    patterns/rails/serialization-boundary-contract.md
    patterns/rails/serializable-hash-allowlist.md
    patterns/rails/json-representation-contract.md
    patterns/rails/nested-serialization-boundary.md
    patterns/rails/sensitive-serialization-contract.md
    patterns/rails/serialization-versioning-contract.md
    patterns/rails/globalid-identity-contract.md
    patterns/rails/signed-globalid-integrity-contract.md
    patterns/rails/globalid-locator-allowlist.md
    patterns/rails/globalid-resolution-failure-contract.md
    patterns/rails/activejob-argument-serialization-contract.md
    patterns/rails/custom-activejob-serializer-contract.md
    evals/rails/serialization-globalid-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each { |p| assert File.file?(File.join(ROOT, p)), "missing #{p}" }
  end

  def test_manifest_registration
    m=YAML.safe_load(File.read(File.join(ROOT,"skill-manifest.yml"),encoding:"UTF-8"))
    s=m.fetch("skills").fetch("rails-serialization-globalid-engineering")
    assert_equal "skills/rails-serialization-globalid-engineering/SKILL.md",s.fetch("path")
    %w[serialization serializable_hash as_json to_json GlobalID SignedGlobalID GlobalID::Locator to_global_id to_signed_global_id to_sgid Active Job arguments custom serializer deserialization].each { |t| assert_includes s.fetch("triggers"), t }
    rails=m.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.grep(%r{^patterns/rails/}).each { |p| assert_includes rails,p }
    assert_includes m.fetch("evaluations").fetch("rails-serialization-globalid-engineering").fetch("paths"), "evals/rails/serialization-globalid-contract.yml"
  end

  def test_router_agents_validator
    routing=File.read(File.join(ROOT,"router/ROUTING.md"),encoding:"UTF-8")
    agents=File.read(File.join(ROOT,"AGENTS.md"),encoding:"UTF-8")
    validator=File.read(File.join(ROOT,"bin/validate"),encoding:"UTF-8")
    assert_includes routing,"Rails Serialization and Global IDs engineering"
    assert_includes routing,"rails-serialization-globalid-engineering"
    assert_includes agents,"Rails serialization/Global ID changes"
    assert_includes agents,"Signed Global ID"
    assert_includes validator,"rails_serialization_globalid_system_test.rb"
  end

  def test_evaluation_contract
    e=YAML.safe_load(File.read(File.join(ROOT,"evals/rails/serialization-globalid-contract.yml"),encoding:"UTF-8"))
    assert_includes e.fetch("skills"),"rails-serialization-globalid-engineering"
    assert_includes e.fetch("patterns"),"globalid-identity-contract"
    assert_includes e.fetch("patterns"),"custom-activejob-serializer-contract"
    assert_equal "scope_control",e.fetch("checks").last
  end

  def test_skill_contract
    s=File.read(File.join(ROOT,"skills/rails-serialization-globalid-engineering/SKILL.md"),encoding:"UTF-8")
    [
      "Serialization boundary","ActiveModel serialization","JSON representation",
      "Nested serialization and performance","Sensitive data serialization",
      "Payload versioning and compatibility","Global ID identity contract",
      "Signed Global IDs","Global ID resolution and authorization",
      "Active Job arguments and serializers","Deserialization failures","Testing strategy"
    ].each { |x| assert_includes s,x }
    assert_includes s,"Signature integrity is not authorization."
  end
end
