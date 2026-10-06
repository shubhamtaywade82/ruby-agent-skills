# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

# Pins the verification gates added to their owning skills (Iteration 156) so
# a later edit cannot silently drop one. Each gate lives in the skill that
# owns the boundary; no new skill was created for them.
class EngineeringGatesSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  GATES = {
    "skills/rails-engines-railties-engineering/SKILL.md" => [
      "### Installer generators must be rerunnable",
      "**Rerun** the generator; the second run must leave the host unchanged",
      "### Extracting host code into an engine",
      "confirm that the dummy application boots"
    ],
    "skills/rails-performance/references/query-performance.md" => [
      "## Query-count regression gate",
      "`assert_queries_count(3) { get orders_path }`",
      "make_database_queries(count: 3)",
      "`EXPLAIN ANALYZE` executes the query"
    ],
    "skills/rails-hotwire/SKILL.md" => [
      "prove that before enhancing it",
      "`driven_by :rack_test`"
    ],
    "skills/ruby-tdd-refactoring/SKILL.md" => [
      "Characterization gate:",
      "Never combine a structural change and a behavior change in one commit."
    ],
    "skills/rails-database-engineering/references/seed-data.md" => [
      "## Seeds must be rerunnable",
      "`find_or_create_by!(natural_key: ...)`",
      "## Secrets never live in seeds",
      "Run `bin/rails db:seed` twice"
    ],
    "skills/change-review/SKILL.md" => [
      "## Always-critical findings",
      "`params.permit!`",
      "real `file:line` from the diff"
    ],
    "skills/rails-authorization/SKILL.md" => [
      "Verify denial with tests, not by trying an action by hand.",
      "authorizing the `/graphql` controller action is not enough"
    ],
    "skills/rails-api-integration/references/graphql.md" => [
      "def self.authorized?(object, context)",
      "def self.scope_items(items, context)",
      "use GraphQL::Dataloader",
      "`max_depth` and `max_complexity`",
      "disable_introspection_entry_points"
    ]
  }.freeze

  TRIGGERS = {
    "rails-api-integration" => ["GraphQL", "graphql-ruby", "GraphQL Dataloader"],
    "rails-database-engineering" => ["db:seed", "seeds.rb"],
    "rails-engines-railties-engineering" => ["install generator", "engine extraction"],
    "rails-performance" => ["query count", "assert_queries_count"]
  }.freeze

  def read(relative)
    File.read(File.join(ROOT, relative), encoding: "UTF-8")
  end

  def test_each_gate_is_stated_in_its_owning_skill
    GATES.each do |relative, phrases|
      text = read(relative)

      phrases.each { |phrase| assert_includes text, phrase, "#{relative} lost: #{phrase}" }
    end
  end

  def test_new_references_are_linked_from_their_skill
    {
      "skills/rails-database-engineering/SKILL.md" => "references/seed-data.md",
      "skills/rails-api-integration/SKILL.md" => "references/graphql.md"
    }.each { |skill, reference| assert_includes read(skill), "](#{reference})" }
  end

  def test_gates_are_routable_from_manifest_triggers
    skills = YAML.safe_load(read("skill-manifest.yml")).fetch("skills")

    TRIGGERS.each do |skill, triggers|
      triggers.each { |trigger| assert_includes skills.fetch(skill).fetch("triggers"), trigger }
    end
  end

  def test_graphql_routing_keeps_policy_with_authorization
    routing = read("router/ROUTING.md")

    assert_includes routing, "### GraphQL (graphql-ruby)"
    assert_includes routing,
                    "| Protect GraphQL objects, fields, mutations, or lists | rails-authorization |"
  end

  def test_validator_executes_this_system_test
    assert_includes read("bin/validate"), "test/engineering_gates_system_test.rb"
  end
end
