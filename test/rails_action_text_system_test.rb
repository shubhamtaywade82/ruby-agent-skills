# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsActionTextSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-action-text/SKILL.md
    patterns/rails/action-text-content-contract.md
    patterns/rails/action-text-sanitization-security.md
    patterns/rails/action-text-attachment-authorization.md
    patterns/rails/action-text-rendering.md
    patterns/rails/action-text-api-boundary.md
    patterns/rails/action-text-preload-performance.md
    patterns/rails/action-text-lifecycle.md
    patterns/rails/action-text-attachable-contract.md
    patterns/rails/action-text-testing.md
    evals/rails/action-text-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-action-text")

    assert_equal "skills/rails-action-text/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Action Text"
    assert_includes skill.fetch("triggers"), "has_rich_text"
    assert_includes skill.fetch("triggers"), "Trix"
    assert_includes skill.fetch("triggers"), "Signed Global ID attachable"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[action-text-content-contract action-text-sanitization-security action-text-attachment-authorization action-text-rendering action-text-api-boundary action-text-preload-performance action-text-lifecycle action-text-attachable-contract].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/action-text-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-action-text").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/action-text-contract.yml"
  end

  def test_router_and_agent_contract_include_action_text
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Action Text"
    assert_includes routing, "rails-action-text"
    assert_includes routing, "action-text-attachment-authorization"
    assert_includes agents, "Rails Action Text changes"
    assert_includes agents, "Signed Global IDs as authorization"
    assert_includes agents, "server-side sanitization"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/action-text-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-action-text"
    assert_includes evaluation.fetch("skills"), "rails-security"
    assert_includes evaluation.fetch("skills"), "rails-active-storage"
    assert_includes evaluation.fetch("patterns"), "action-text-sanitization-security"
    assert_includes evaluation.fetch("patterns"), "action-text-attachment-authorization"
    assert_includes evaluation.fetch("patterns"), "action-text-api-boundary"
  end

  def test_skill_covers_action_text_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-action-text/SKILL.md"), encoding: "UTF-8")

    [
      "Ownership boundary",
      "Content contract",
      "Editing authorization",
      "Trix/editor boundary",
      "Sanitization boundary",
      "Links and URLs",
      "Attachments",
      "Signed Global ID attachables",
      "Attachables and rendering",
      "Missing attachables",
      "Rendering boundary",
      "API boundary",
      "Rich text and localization",
      "Forms and parameters",
      "Persistence and lifecycle",
      "Performance and N+1",
      "Caching rendered rich text",
      "Content size and resource limits",
      "Search/indexing",
      "Security and privacy",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Never treat successful sanitization as proof that the user was authorized to reference every embedded object."
    assert_includes skill, "Never let a user embed arbitrary privileged objects merely because they can construct or obtain a signed identifier."
    assert_includes skill, "Never claim rich-text safety merely because the content originated in Trix."
    assert_includes skill, "Do not expose internal Action Text storage tables as a public API contract."
  end
end
