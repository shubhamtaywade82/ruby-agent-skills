# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsAuthenticationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-authentication/SKILL.md
    patterns/rails/authentication-mechanism-boundary.md
    patterns/rails/credential-storage-contract.md
    patterns/rails/session-lifecycle-contract.md
    patterns/rails/session-fixation-rotation.md
    patterns/rails/session-revocation-contract.md
    patterns/rails/password-recovery-contract.md
    patterns/rails/login-abuse-controls.md
    patterns/rails/remember-me-contract.md
    patterns/rails/browser-api-auth-boundary.md
    patterns/rails/authentication-context-propagation.md
    patterns/rails/authentication-freshness-boundary.md
    patterns/testing/authentication-testing.md
    evals/rails/authentication-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-authentication")

    assert_equal "skills/rails-authentication/SKILL.md", skill.fetch("path")
    %w[
      authentication
      session
      sign in
      sign out
      password reset
      session fixation
      session revocation
      remember me
      bearer token
      account lockout
    ].each { |trigger| assert_includes skill.fetch("triggers"), trigger }

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      authentication-mechanism-boundary
      credential-storage-contract
      session-lifecycle-contract
      session-fixation-rotation
      session-revocation-contract
      password-recovery-contract
      login-abuse-controls
      remember-me-contract
      browser-api-auth-boundary
      authentication-context-propagation
      authentication-freshness-boundary
    ].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/testing/authentication-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-authentication").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/authentication-contract.yml"
  end

  def test_router_and_agent_contract_include_authentication
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Authentication engineering"
    assert_includes routing, "rails-authentication"
    assert_includes routing, "session-fixation-rotation"

    assert_includes agents, "Rails authentication changes"
    assert_includes agents, "authentication and authorization remain separate"
    assert_includes agents, "session fixation"
    assert_includes agents, "credential material"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/authentication-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-authentication"
    assert_includes evaluation.fetch("skills"), "rails-security"
    assert_includes evaluation.fetch("skills"), "rails-security-engineering"
    assert_includes evaluation.fetch("patterns"), "session-fixation-rotation"
    assert_includes evaluation.fetch("patterns"), "password-recovery-contract"
    assert_includes evaluation.fetch("patterns"), "browser-api-auth-boundary"
    assert_includes evaluation.fetch("patterns"), "authentication-testing"
  end

  def test_skill_covers_authentication_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-authentication/SKILL.md"), encoding: "UTF-8")

    [
      "Authentication mechanism boundary",
      "Credential storage",
      "Authentication state machine",
      "Session lifecycle",
      "Session fixation and rotation",
      "Session revocation",
      "Password reset and recovery",
      "Login abuse controls",
      "Remember-me and persistent login",
      "Browser authentication versus API authentication",
      "Authentication context propagation",
      "Failure contracts",
      "Security-sensitive operations",
      "Observability and audit",
      "Testing strategy",
      "Multi-device session management",
      "Compromise response"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Authentication answers:"
    assert_includes skill, "Authorization answers a different question"
    assert_includes skill, "A successful login must not preserve attacker-controlled pre-authentication session state."
    assert_includes skill, "Reset tokens must not be logged"
    assert_includes skill, "Never serialize passwords, session cookies, bearer tokens"
  end
end
