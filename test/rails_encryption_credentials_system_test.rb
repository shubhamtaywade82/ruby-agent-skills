# frozen_string_literal: true
require "minitest/autorun"
require "yaml"

class RailsEncryptionCredentialsSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  REQUIRED_PATHS = %w[
    skills/rails-encryption-credentials-engineering/SKILL.md
    patterns/rails/credentials-store-contract.md
    patterns/rails/credentials-environment-selection.md
    patterns/rails/master-key-boundary.md
    patterns/rails/credentials-editing-workflow.md
    patterns/rails/secret-key-base-contract.md
    patterns/rails/credentials-redaction-contract.md
    patterns/rails/active-record-encryption-contract.md
    patterns/rails/deterministic-encryption-query-contract.md
    patterns/rails/encrypted-storage-capacity-contract.md
    patterns/rails/encrypted-data-migration-contract.md
    patterns/rails/encryption-key-rotation-contract.md
    patterns/rails/credentials-testing-contract.md
    evals/rails/encryption-credentials-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each { |p| assert File.file?(File.join(ROOT, p)), "missing #{p}" }
  end

  def test_manifest_registration
    m=YAML.safe_load(File.read(File.join(ROOT,"skill-manifest.yml"),encoding:"UTF-8"))
    s=m.fetch("skills").fetch("rails-encryption-credentials-engineering")
    assert_equal "skills/rails-encryption-credentials-engineering/SKILL.md",s.fetch("path")
    %w[credentials config/credentials.yml.enc config/credentials master.key RAILS_MASTER_KEY credentials:edit credentials:show secret_key_base Active Record Encryption ActiveRecord::Encryption encrypts deterministic encryption encrypted attribute key rotation db:encryption:init].each { |t| assert_includes s.fetch("triggers"), t }
    rails=m.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.grep(%r{^patterns/rails/}).each { |p| assert_includes rails,p }
    assert_includes m.fetch("patterns").fetch("testing").fetch("paths"), "patterns/rails/credentials-testing-contract.md"
    assert_includes m.fetch("evaluations").fetch("rails-encryption-credentials-engineering").fetch("paths"), "evals/rails/encryption-credentials-contract.yml"
  end

  def test_router_agents_validator
    routing=File.read(File.join(ROOT,"router/ROUTING.md"),encoding:"UTF-8")
    agents=File.read(File.join(ROOT,"AGENTS.md"),encoding:"UTF-8")
    validator=File.read(File.join(ROOT,"bin/validate"),encoding:"UTF-8")
    assert_includes routing,"Rails Encryption and Credentials engineering"
    assert_includes routing,"rails-encryption-credentials-engineering"
    assert_includes agents,"Rails encryption/credentials changes"
    assert_includes agents,"RAILS_MASTER_KEY"
    assert_includes validator,"rails_encryption_credentials_system_test.rb"
  end

  def test_evaluation_contract
    e=YAML.safe_load(File.read(File.join(ROOT,"evals/rails/encryption-credentials-contract.yml"),encoding:"UTF-8"))
    assert_includes e.fetch("skills"),"rails-encryption-credentials-engineering"
    assert_includes e.fetch("patterns"),"active-record-encryption-contract"
    assert_includes e.fetch("patterns"),"encryption-key-rotation-contract"
    assert_equal "scope_control",e.fetch("checks").last
  end

  def test_skill_contract
    s=File.read(File.join(ROOT,"skills/rails-encryption-credentials-engineering/SKILL.md"),encoding:"UTF-8")
    [
      "Credential stores and environment selection","Master-key boundary","Secret lifecycle",
      "Application-level encryption","Key management","Storage and query implications",
      "Migration and rotation","Secret-safe observability","Testing strategy"
    ].each { |x| assert_includes s,x }
    assert_includes s,"Do not claim a secret is secure merely because it is encrypted at rest."
  end
end
