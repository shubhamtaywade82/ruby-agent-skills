# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsActiveRecordSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-active-record/SKILL.md
    patterns/rails/active-record-model-boundary.md
    patterns/rails/active-record-query-contract.md
    patterns/rails/active-record-relation-composition.md
    patterns/rails/active-record-scope-contract.md
    patterns/rails/active-record-persistence-lifecycle.md
    patterns/rails/active-record-callback-contract.md
    patterns/rails/active-record-bulk-write-boundary.md
    patterns/rails/active-record-strict-loading.md
    patterns/rails/active-record-deletion-contract.md
    patterns/rails/active-record-testing.md
    evals/rails/active-record-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-active-record")

    assert_equal "skills/rails-active-record/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Active Record"
    assert_includes skill.fetch("triggers"), "ActiveRecord::Relation"
    assert_includes skill.fetch("triggers"), "update_all"
    assert_includes skill.fetch("triggers"), "after_commit"
    assert_includes skill.fetch("triggers"), "strict_loading"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      active-record-model-boundary
      active-record-query-contract
      active-record-relation-composition
      active-record-scope-contract
      active-record-persistence-lifecycle
      active-record-callback-contract
      active-record-bulk-write-boundary
      active-record-strict-loading
      active-record-deletion-contract
    ].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/active-record-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-active-record").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/active-record-contract.yml"
  end

  def test_router_and_agent_contract_include_active_record
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Active Record"
    assert_includes routing, "rails-active-record"
    assert_includes routing, "active-record-query-contract"
    assert_includes agents, "Rails Active Record changes"
    assert_includes agents, "ActiveRecord::Relation"
    assert_includes agents, "default_scope"
    assert_includes agents, "after_commit"
    assert_includes agents, "bulk operations"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/active-record-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-active-record"
    assert_includes evaluation.fetch("skills"), "rails-database-engineering"
    assert_includes evaluation.fetch("patterns"), "active-record-query-contract"
    assert_includes evaluation.fetch("patterns"), "active-record-callback-contract"
    assert_includes evaluation.fetch("patterns"), "active-record-bulk-write-boundary"
    assert_includes evaluation.fetch("patterns"), "active-record-testing"
  end

  def test_skill_covers_active_record_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-active-record/SKILL.md"), encoding: "UTF-8")

    [
      "Model boundary",
      "Relation semantics",
      "Query composition",
      "Scopes and default_scope",
      "Loading strategy",
      "Projection and calculations",
      "Persistence lifecycle",
      "Callbacks",
      "Bulk writes and deletes",
      "Deletion semantics",
      "Dirty and persistence state",
      "Transactions and consistency",
      "Security and tenant scope",
      "Performance and capacity",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Never use default_scope as an authorization mechanism."
    assert_includes skill, "Do not use callbacks to hide"
    assert_includes skill, "A bulk operation is not automatically equivalent"
    assert_includes skill, "Never replace destroy_all with delete_all"
    assert_includes skill, "after_commit"
  end
end
