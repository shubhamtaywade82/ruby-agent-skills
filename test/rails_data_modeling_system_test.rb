# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

# Text the data-modeling skill and its neighbours must carry.
module RailsDataModelingContract
  SKILL_DIR = "skills/rails-data-modeling"

  REQUIRED_TEXT = {
    "#{SKILL_DIR}/SKILL.md" => [
      "## Decision framework", "## Version-sensitive compatibility",
      "## Data-model review procedure",
      "Never generate a legacy API in a modern application",
      "Normalize to 3NF by default",
      "A `has_one` needs a unique index on its foreign key",
      "Never \"normalize away\" a historical snapshot.",
      "Tenant-scoped business keys need a composite unique index"
    ],
    "#{SKILL_DIR}/references/normalization-and-keys.md" => ["## Normal forms, applied", "**BCNF**"],
    "#{SKILL_DIR}/references/relationships-and-integrity.md" => ["## Constraint matrix",
                                                                 "## Multi-tenant ownership"],
    "#{SKILL_DIR}/references/types-hierarchies-and-flexible-data.md" => [
      "JSON is not a substitute for relational modeling.",
      "was removed in Rails 8.0"
    ],
    "#{SKILL_DIR}/references/history-and-denormalization.md" => [
      "## Snapshots", "where: \"deleted_at IS NULL\""
    ],
    "#{SKILL_DIR}/references/legacy-schemas-and-api-drift.md" => [
      "| `update_attributes`, `update_attributes!` | removed in Rails 6.1 |",
      "`ActiveRecord::Observer`"
    ],
    "#{SKILL_DIR}/references/aggregates-access-and-evolution.md" => [
      "## Aggregate ownership", "## Query-driven index design",
      "## Write paths", "## Schema evolution"
    ],
    "#{SKILL_DIR}/references/worked-examples.md" => [
      "## 1. Commerce", "## 2. SaaS multi-tenancy", "## 3. JSON versus relational columns",
      "## 4. UUID versus bigint", "## 5. Composite primary key", "## 6. Controlled denormalization"
    ],
    "router/ROUTING.md" => ["## Rails data modeling", "| rails-data-modeling |"],
    "skills/rails-database-engineering/SKILL.md" => [
      "belongs to `rails-data-modeling`", "\"Should this fact be a separate relation?\""
    ],
    "skills/rails-active-record/SKILL.md" => ["rails-data-modeling  -> defines what is modeled"],
    "skills/rails-associations/SKILL.md" => [
      "rails-data-modeling         -> decide the relationship"
    ],
    "skills/ruby-domain-modeling/SKILL.md" => ["use `rails-data-modeling`"],
    "bin/validate" => ["test/rails_data_modeling_system_test.rb"]
  }.freeze
end

class RailsDataModelingSystemTest < Minitest::Test
  include RailsDataModelingContract

  ROOT = File.expand_path("..", __dir__)
  EVALUATION = "evals/data-modeling/data-modeling-contract.yml"

  # Removed or legacy APIs may appear only in the drift table, never in examples.
  REMOVED_API = /update_attributes|find\(:all|set_table_name|set_primary_key|enum \w+: \{/

  def read(relative)
    File.read(File.join(ROOT, relative), encoding: "UTF-8")
  end

  def manifest
    YAML.safe_load(read("skill-manifest.yml"), permitted_classes: [], aliases: false)
  end

  def routing_case(id)
    YAML.safe_load(read("router/ROUTING_CASES.yml")).fetch("cases").find do |entry|
      entry.fetch("id") == id
    end
  end

  def syntax_error(code)
    Dir.mktmpdir("data-modeling-example") do |dir|
      path = File.join(dir, "example.rb")
      File.write(path, code, encoding: "UTF-8")
      _out, err, status = Open3.capture3(RbConfig.ruby, "-c", path)
      status.success? ? nil : err
    end
  end

  def ruby_blocks(relative)
    read(relative).scan(/^\s*```ruby\n(.*?)^\s*```/m).flatten
  end

  def skill_files
    Dir[File.join(ROOT, SKILL_DIR, "**", "*.md")].map { |path| path.delete_prefix("#{ROOT}/") }.sort
  end

  def test_skill_is_registered_routed_and_evaluated
    registration = %w[skills evaluations].map do |key|
      manifest.fetch(key).fetch("rails-data-modeling")
    end

    assert_equal "#{SKILL_DIR}/SKILL.md", registration.first.fetch("path")
    assert_equal [EVALUATION], registration.last.fetch("paths")
    assert_equal ["rails-data-modeling"],
                 routing_case("schema-design-before-migration").fetch("primary_skills")
  end

  def test_required_text_is_present
    REQUIRED_TEXT.each do |relative, snippets|
      text = read(relative)

      snippets.each { |snippet| assert_includes text, snippet, relative }
    end
  end

  def test_ruby_examples_are_valid_syntax_and_avoid_removed_apis
    skill_files.each do |relative|
      ruby_blocks(relative).each_with_index do |code, index|
        assert_nil syntax_error(code), "#{relative} example #{index}"
        refute_match REMOVED_API, code, "#{relative} example #{index} uses a removed API"
      end
    end
  end

  def test_evaluation_covers_the_core_modeling_decisions
    evaluation = YAML.safe_load(read(EVALUATION), permitted_classes: [], aliases: false)

    assert_equal "static-only", evaluation.fetch("coverage")
    assert_equal(%w[snapshot tenant-uniqueness plan-history retirement json-boundary key-choice],
                 evaluation.fetch("cases").map { |entry| entry.fetch("name") })
  end
end
