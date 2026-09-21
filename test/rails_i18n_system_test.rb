# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsI18nSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-i18n/SKILL.md
    patterns/rails/i18n-locale-resolution.md
    patterns/rails/i18n-translation-key-contract.md
    patterns/rails/i18n-pluralization-formatting.md
    patterns/rails/i18n-localized-routing.md
    patterns/rails/i18n-context-propagation.md
    patterns/rails/i18n-cache-identity.md
    patterns/rails/i18n-security-boundary.md
    patterns/rails/i18n-testing.md
    evals/rails/i18n-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-i18n")

    assert_equal "skills/rails-i18n/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "I18n"
    assert_includes skill.fetch("triggers"), "locale negotiation"
    assert_includes skill.fetch("triggers"), "pluralization"
    assert_includes skill.fetch("triggers"), "missing translation"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[i18n-locale-resolution i18n-translation-key-contract i18n-pluralization-formatting i18n-localized-routing i18n-context-propagation i18n-cache-identity i18n-security-boundary].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/i18n-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-i18n").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/i18n-contract.yml"
  end

  def test_router_and_agent_contract_include_i18n
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails I18n"
    assert_includes routing, "rails-i18n"
    assert_includes routing, "i18n-cache-identity"
    assert_includes agents, "Rails I18n changes"
    assert_includes agents, "I18n.with_locale"
    assert_includes agents, "locale is presentation context, not authorization"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/i18n-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-i18n"
    assert_includes evaluation.fetch("skills"), "rails-security"
    assert_includes evaluation.fetch("patterns"), "i18n-locale-resolution"
    assert_includes evaluation.fetch("patterns"), "i18n-context-propagation"
    assert_includes evaluation.fetch("patterns"), "i18n-cache-identity"
  end

  def test_skill_covers_i18n_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-i18n/SKILL.md"), encoding: "UTF-8")

    [
      "Locale contract",
      "Locale resolution",
      "Request locale isolation",
      "Thread, fiber, and concurrency boundaries",
      "Background jobs and locale propagation",
      "Translation key contract",
      "Interpolation",
      "Pluralization",
      "Date, time, number, and currency localization",
      "Localized views and templates",
      "Localized routes and URLs",
      "Locale negotiation",
      "Model and validation translations",
      "API localization",
      "Action Mailer localization",
      "Caching and locale",
      "Missing translations",
      "Fallback behavior",
      "Custom backends",
      "Security and privacy",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Do not use locale as a substitute for timezone."
    assert_includes skill, "A locale is presentation context, not authorization."
    assert_includes skill, "Do not make frontend logic depend on exact translated English text."
    assert_includes skill, "Do not let arbitrary request input become a locale"
  end
end
