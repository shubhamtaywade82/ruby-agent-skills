# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsActiveStorageSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-active-storage/SKILL.md
    patterns/rails/active-storage-boundary.md
    patterns/rails/active-storage-upload-security.md
    patterns/rails/active-storage-direct-upload.md
    patterns/rails/active-storage-serving.md
    patterns/rails/active-storage-processing.md
    patterns/rails/active-storage-purge.md
    patterns/rails/active-storage-testing.md
    evals/rails/active-storage-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-active-storage")

    assert_equal "skills/rails-active-storage/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Active Storage"
    assert_includes skill.fetch("triggers"), "direct upload"
    assert_includes skill.fetch("triggers"), "authenticated file access"
    assert_includes skill.fetch("triggers"), "storage migration"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[active-storage-boundary active-storage-upload-security active-storage-direct-upload active-storage-serving active-storage-processing active-storage-purge].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/active-storage-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-active-storage").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/active-storage-contract.yml"
  end

  def test_router_and_agent_contract_include_active_storage
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Active Storage"
    assert_includes routing, "rails-active-storage"
    assert_includes routing, "active-storage-serving"
    assert_includes agents, "Rails Active Storage changes"
    assert_includes agents, "blob identifier as an object reference, not as authorization"
    assert_includes agents, "direct uploads as a staged lifecycle"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/active-storage-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-active-storage"
    assert_includes evaluation.fetch("skills"), "rails-security"
    assert_includes evaluation.fetch("patterns"), "active-storage-upload-security"
    assert_includes evaluation.fetch("patterns"), "active-storage-serving"
    assert_includes evaluation.fetch("patterns"), "active-storage-purge"
  end

  def test_skill_covers_active_storage_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-active-storage/SKILL.md"), encoding: "UTF-8")

    [
      "Attachment boundary",
      "File contract",
      "Upload authorization",
      "Tenant isolation",
      "Storage service selection",
      "Provider boundary",
      "Direct uploads",
      "File validation",
      "Serving private files",
      "Authenticated file controllers",
      "Analysis",
      "Variants and previews",
      "Replacement and deletion semantics",
      "Purge lifecycle",
      "Unattached and orphaned uploads",
      "Storage migration and mirrors",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Never interpret possession of a signed blob ID as proof that the caller owns the target resource."
    assert_includes skill, "Never switch private storage to public as a debugging shortcut."
    assert_includes skill, "Do not retry every storage error blindly."
    assert_includes skill, "Never claim storage durability, complete replication, or successful migration without provider/runtime evidence."
  end
end
