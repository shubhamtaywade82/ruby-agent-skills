# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

# Builds local planning trackers in temporary directories and runs the
# planning-tracker script against them.
module PlanningTrackerFixture
  ROOT = File.expand_path("..", __dir__)
  TRACKER = File.join(ROOT, "skills", "planning-tracker", "scripts", "tracker.rb")

  def write_item(dir, id, slug, **fields)
    front = { "id" => id, "title" => slug.tr("-", " "), "kind" => "decision", "status" => "open" }
            .merge(fields.transform_keys(&:to_s))
    path = File.join(dir, format("%<id>04d-%<slug>s.md", id: id, slug: slug))
    File.write(path, "#{front.to_yaml}---\n\nBody\n", encoding: "UTF-8")
  end

  BROKEN_ITEM_ERRORS = ["blocking cycle: 6 -> 7 -> 6", "kind must be one of", "missing item 42",
                        "missing item 99"].freeze

  # Two items that block each other, and one with a bad kind and missing links.
  def write_broken_items(dir)
    write_item(dir, 6, "loop-a", blocked_by: [7])
    write_item(dir, 7, "loop-b", blocked_by: [6])
    write_item(dir, 8, "bad-item", kind: "task", parent: 99, blocked_by: [42])
  end

  def tracker(dir, *)
    Open3.capture3(RbConfig.ruby, TRACKER, *, "--root", dir, chdir: ROOT)
  end

  # A map with a closed decision, an open decision it unblocks, a decision
  # blocked by that, and a claimed decision.
  def with_refund_map
    Dir.mktmpdir("planning-tracker") do |dir|
      write_item(dir, 1, "refunds-map", kind: "map")
      write_item(dir, 2, "tax-split", parent: 1, status: "closed")
      write_item(dir, 3, "ledger-entry", parent: 1, blocked_by: [2])
      write_item(dir, 4, "export-format", parent: 1, blocked_by: [3])
      write_item(dir, 5, "provider-api", parent: 1, assignee: "session-a")
      File.write(File.join(dir, "README.md"), "# Planning\n", encoding: "UTF-8")
      yield dir
    end
  end
end

class PlanningLayerSystemTest < Minitest::Test
  include PlanningTrackerFixture

  SKILLS = %w[planning-tracker planning-interview planning-spec planning-tickets
              planning-wayfinder].freeze
  EVALUATIONS = {
    "planning-spec" => "evals/agent-workflow/planning-spec-contract.yml",
    "planning-tickets" => "evals/agent-workflow/planning-tickets-contract.yml",
    "planning-wayfinder" => "evals/agent-workflow/planning-wayfinder-contract.yml"
  }.freeze

  def read(relative)
    File.read(File.join(ROOT, relative), encoding: "UTF-8")
  end

  def manifest
    YAML.safe_load(read("skill-manifest.yml"), permitted_classes: [], aliases: false)
  end

  def test_skills_are_registered_routed_and_credited
    skills = manifest.fetch("skills")
    routing = read("router/ROUTING.md")

    SKILLS.each do |name|
      assert_equal "planning", skills.fetch(name).fetch("family"), name
      assert_includes routing, "| #{name} |", name
      assert_includes read("skills/#{name}/SKILL.md"),
                      "MIT License, Copyright (c) 2026 Matt Pocock", name
    end
  end

  def test_evaluations_are_registered_and_static_only
    evaluations = manifest.fetch("evaluations")

    EVALUATIONS.each do |name, path|
      assert_equal [path], evaluations.fetch(name).fetch("paths")
      assert_equal "static-only", YAML.safe_load(read(path)).fetch("coverage"), path
    end
  end

  def test_routing_cases_cover_the_planning_boundaries
    cases = YAML.safe_load(read("router/ROUTING_CASES.yml")).fetch("cases").to_h do |c|
      [c.fetch("id"), c]
    end
    primaries = %w[spec-then-tickets-not-wayfinder multi-session-effort-needs-a-map].map do |id|
      cases.fetch(id).fetch("primary_skills")
    end

    assert_equal [["planning-spec"], ["planning-wayfinder"]], primaries
  end

  def test_frontier_skips_closed_blocked_claimed_and_map_items
    with_refund_map do |dir|
      stdout, stderr, status = tracker(dir, "frontier", "--json")

      assert_predicate status, :success?, stderr
      assert_equal([3], JSON.parse(stdout).map { |item| item.fetch("id") })
    end
  end

  def test_frontier_can_include_claimed_items_and_filter_by_parent
    with_refund_map do |dir|
      stdout, _stderr, _status = tracker(dir, "frontier", "--parent", "1", "--include-claimed",
                                         "--json")

      assert_equal([3, 5], JSON.parse(stdout).map { |item| item.fetch("id") })
    end
  end

  def test_validate_passes_and_next_id_follows_the_highest_id
    with_refund_map do |dir|
      validate_out, validate_err, validate_status = tracker(dir, "validate")
      next_out, = tracker(dir, "next-id")

      assert_predicate validate_status, :success?, validate_err
      assert_includes validate_out, "Tracker valid: 5 items"
      assert_equal "0006", next_out.strip
    end
  end

  def test_validate_rejects_cycles_missing_links_and_bad_fields
    with_refund_map do |dir|
      write_broken_items(dir)
      _stdout, stderr, status = tracker(dir, "validate")

      assert_equal 1, status.exitstatus
      BROKEN_ITEM_ERRORS.each { |error| assert_includes stderr, error }
    end
  end

  def test_validate_rejects_an_id_that_does_not_match_its_file_name
    with_refund_map do |dir|
      File.write(File.join(dir, "0009-mismatch.md"),
                 "---\nid: 10\ntitle: x\nkind: ticket\nstatus: open\n---\n")
      _stdout, stderr, status = tracker(dir, "validate")

      refute_predicate status, :success?
      assert_includes stderr, "id 10 does not match file number 9"
    end
  end

  def test_validator_executes_this_system_test
    assert_includes read("bin/validate"), "test/planning_layer_system_test.rb"
  end

  def test_planning_spec_names_the_regression_surface
    text = read("skills/planning-spec/SKILL.md")

    assert_includes text, "**Name the regression surface.**"
    assert_includes text, "regression surface"
    assert_includes text, "Never mark a touched boundary's dependents as safe"
  end
end
