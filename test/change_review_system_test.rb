# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class ChangeReviewSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  EVALUATION = "evals/agent-workflow/change-review-contract.yml"

  # Text each file must carry: the two-axis contract and the disciplines
  # folded into the skills that already own them.
  REQUIRED_TEXT = {
    "router/ROUTING.md" => [
      "| Branch/PR/diff review for standards and spec fidelity | change-review |",
      "### Change review"
    ],
    "skills/change-review/SKILL.md" => [
      "**Standards**", "**Spec**", "git rev-parse", "main...HEAD", "no spec available",
      "Never merge or re-rank findings across axes",
      "Never report a smell as a violation",
      "Never claim a test, linter, or CI run passed unless its output was observed"
    ],
    "skills/change-review/references/smell-baseline.md" => ["The repository overrides."],
    "skills/ruby-debugging/SKILL.md" => ["**The feedback loop is the work.**", "**red-capable**",
                                         "[DEBUG-a4f2]"],
    "skills/ruby-tdd-refactoring/SKILL.md" => ["## Test seams", "vertical slices"],
    "skills/ruby-tdd-refactoring/references/test-quality.md" => ["## Tautological tests"],
    "skills/ruby-domain-modeling/SKILL.md" => ["## Domain language and decisions"],
    "skills/ruby-domain-modeling/references/context-and-adrs.md" => [
      "## What qualifies as a decision record"
    ],
    "skills/ruby-api-design/SKILL.md" => ["**Deletion test**"],
    "skills/ruby-api-design/references/deep-modules.md" => ["## Dependency categories"],
    "skills/agent-workflow/SKILL.md" => ["## Implementation loop"],
    "bin/validate" => ["test/change_review_system_test.rb"]
  }.freeze

  ADAPTED_SKILLS = %w[
    change-review ruby-debugging ruby-tdd-refactoring
    ruby-domain-modeling ruby-api-design agent-workflow
  ].freeze
  CREDIT = ["https://github.com/mattpocock/skills",
            "MIT License, Copyright (c) 2026 Matt Pocock"].freeze

  def read(relative)
    File.read(File.join(ROOT, relative), encoding: "UTF-8")
  end

  def load_yaml(relative)
    YAML.safe_load(read(relative), permitted_classes: [], aliases: false)
  end

  def test_change_review_is_registered_with_non_colliding_triggers
    manifest = load_yaml("skill-manifest.yml")
    skill = manifest.fetch("skills").fetch("change-review")

    assert_equal "skills/change-review/SKILL.md", skill.fetch("path")
    refute_includes skill.fetch("triggers"), "code review",
                    "code review already belongs to ruby-clean-code"
    assert_equal [EVALUATION], manifest.fetch("evaluations").fetch("change-review").fetch("paths")
  end

  def test_routing_cases_separate_change_review_from_minimality_review
    by_id = load_yaml("router/ROUTING_CASES.yml").fetch("cases").to_h do |entry|
      [entry.fetch("id"), entry]
    end
    primaries = %w[branch-review-standards-and-spec diff-simplification-review].map do |id|
      by_id.fetch(id).fetch("primary_skills")
    end

    assert_equal [["change-review"], ["stack-minimality-review"]], primaries
  end

  def test_required_text_is_present
    REQUIRED_TEXT.each do |relative, snippets|
      text = read(relative)

      snippets.each { |snippet| assert_includes text, snippet, relative }
    end
  end

  def test_evaluation_covers_both_axes_and_the_missing_spec_case
    evaluation = load_yaml(EVALUATION)
    names = evaluation.fetch("cases").map { |entry| entry.fetch("name") }
    expected = %w[spec-gap-behind-clean-standards contract-breach-behind-met-spec no-spec
                  smell-overridden-by-repository]

    assert_equal "static-only", evaluation.fetch("coverage")
    assert_equal expected, names
  end

  def test_adaptations_credit_the_mit_licensed_source
    ADAPTED_SKILLS.each do |name|
      source = read("skills/#{name}/SKILL.md")

      CREDIT.each { |credit| assert_includes source, credit, name }
    end
  end
end
