# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class DocumentationConsistencySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def source(path)
    File.read(File.join(ROOT, path), encoding: "UTF-8")
  end

  def test_documentation_audit_is_registered_and_executable
    script = source("scripts/audit_documentation_consistency.rb")

    assert_includes script, "CHANGELOG.md"
    assert_includes script, "IMPLEMENTATION_HANDOFF.md"
    assert_includes script, "evaluation_count"
    assert_includes script, "Current milestone"
    assert_includes script, "ITERATIONS.md"
  end

  def test_documentation_audit_passes_current_repository_state
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts", "audit_documentation_consistency.rb"),
      chdir: ROOT
    )

    assert status.success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "Documentation consistency audit passed."
  end

  # Builds a temporary repository root from the real documents, applying
  # per-file edits, and returns the audit's [stderr, status].
  def audit_with(edits = {})
    Dir.mktmpdir("documentation-consistency") do |dir|
      %w[skills patterns evals test router].each { |path| FileUtils.cp_r(File.join(ROOT, path), dir) }
      FileUtils.mkdir_p(File.join(dir, "docs"))
      %w[README.md RELEASE.md CHANGELOG.md skill-manifest.yml docs/IMPLEMENTATION_HANDOFF.md docs/ITERATIONS.md].each do |path|
        text = source(path)
        text = edits[path].call(text) if edits.key?(path)
        File.write(File.join(dir, path), text, encoding: "UTF-8")
      end

      audit = File.join(ROOT, "scripts", "audit_documentation_consistency.rb")
      _stdout, stderr, status = Open3.capture3(RbConfig.ruby, audit, "--root", dir, chdir: ROOT)
      [stderr, status]
    end
  end

  def test_documentation_audit_detects_stale_routing_campaign_run_count
    stderr, status = audit_with(
      # Off by one from whatever the current documented count is.
      "docs/IMPLEMENTATION_HANDOFF.md" => lambda do |text|
        text.sub(/(\d+) public cases × 3 repetitions = \d+/) do
          stale = Regexp.last_match(1).to_i + 1
          "#{stale} public cases × 3 repetitions = #{stale * 3}"
        end
      end
    )

    refute status.success?
    assert_includes stderr, "public routing campaign run-count documentation drift"
  end

  def test_documentation_audit_detects_stale_handoff_inventory
    stderr, status = audit_with("docs/IMPLEMENTATION_HANDOFF.md" => ->(text) { text.sub(/\d+ evaluation cases/, "1 evaluation cases") })

    refute status.success?
    assert_includes stderr, "IMPLEMENTATION_HANDOFF.md"
  end

  def test_documentation_audit_rejects_iteration_history_in_readme
    stderr, status = audit_with("README.md" => ->(text) { "#{text}\n## Iteration 131 — Something\n" })

    refute status.success?
    assert_includes stderr, "README.md mentions iterations"
  end

  def test_documentation_audit_requires_ordered_iterations_with_latest_section
    stderr, status = audit_with(
      "docs/ITERATIONS.md" => lambda do |text|
        text.sub(/^## Iteration 41 — /, "## Iteration 999 — ").sub(/^## Iteration (\d+) — (?!.*^## Iteration)/m, "## Iteration 0 — ")
      end
    )

    refute status.success?
    assert_includes stderr, "not in ascending order"
    assert_includes stderr, "has no section for Iteration"
  end

  def test_documentation_audit_detects_stale_release_inventory
    stderr, status = audit_with("RELEASE.md" => ->(text) { text.sub(/\d+ agent-executable skills/, "91 agent-executable skills") })

    refute status.success?
    assert_includes stderr, "RELEASE.md skills count drift"
  end

  def test_validator_invokes_this_system_test
    assert_includes source("bin/validate"), "test/documentation_consistency_system_test.rb"
  end
end
