# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "fileutils"
require "tmpdir"

# A minimal valid catalog. `%<name>s` placeholders are filled per call so each
# test can break exactly one property and attribute the failure to it.
CATALOG_TEMPLATE = <<~YAML
  version: 1
  owner: %<owner>s
  source:
    ref: https://example.com
  tools:
    %<tool>s:
      category: %<category>s
      %<identifier>s
  selection:
    rules:
      - "rule one"
YAML

# Two `tool-a` keys: YAML keeps only the last definition, so the parsed mapping
# looks sound and only a count of the raw key lines exposes the duplicate.
DUPLICATED_TEMPLATE = <<~YAML
  version: 1
  owner: alpha
  source:
    ref: https://example.com
  tools:
    tool-a:
      category: cat_one
      gem: gem-a
    tool-a:
      category: cat_other
      gem: gem-z
  selection:
    rules:
      - "rule one"
YAML

class DataCatalogsSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  AUDIT = File.join(ROOT, "scripts", "audit_data_catalogs.rb")

  def test_repository_passes_data_catalog_audit
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, AUDIT, chdir: ROOT)

    assert_predicate status, :success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "Data catalog audit passed."
  end

  def test_audit_rejects_an_owner_that_is_not_an_installed_skill
    with_fixture do |dir|
      make_catalog(dir, "alpha", catalog(owner: "missing-skill"))

      refute_predicate audit_status(dir), :success?, "an owner with no SKILL.md must fail"
    end
  end

  def test_audit_rejects_a_catalog_missing_a_required_top_level_key
    with_fixture do |dir|
      make_catalog(dir, "alpha", catalog(owner: "alpha").sub(/^selection:.*\z/m, ""))

      refute_predicate audit_status(dir), :success?, "a missing top-level key must fail"
    end
  end

  def test_audit_rejects_a_tool_without_a_category
    with_fixture do |dir|
      make_catalog(dir, "alpha", catalog(owner: "alpha").sub(/^    category: cat_one$\n/, ""))

      refute_predicate audit_status(dir), :success?, "a tool with no category must fail"
    end
  end

  def test_audit_rejects_a_duplicate_key_that_yaml_collapses
    with_fixture do |dir|
      make_catalog(dir, "alpha", DUPLICATED_TEMPLATE)

      _stdout, stderr, status = audit(dir)

      refute_predicate status, :success?, "a duplicate key must fail even though YAML hides it"
      assert_includes stderr, "duplicate key(s)"
    end
  end

  def test_audit_rejects_conflicting_identifiers_for_one_key
    with_fixture do |dir|
      make_catalog(dir, "beta", catalog(owner: "beta", tool: "tool-a", command: "bin/different"))

      _stdout, stderr, status = audit(dir)

      refute_predicate status, :success?, "the same key with two identifiers must fail"
      assert_includes stderr, "conflicting identifiers"
    end
  end

  def test_audit_rejects_the_same_gem_registered_twice
    with_fixture do |dir|
      make_catalog(dir, "beta", catalog(owner: "beta", tool: "tool-b", gem: "gem-a"))

      _stdout, stderr, status = audit(dir)

      refute_predicate status, :success?, "one gem registered in two catalogs must fail"
      assert_includes stderr, "gem \"gem-a\" registered in"
    end
  end

  private

  def audit(dir)
    Open3.capture3(RbConfig.ruby, AUDIT, "--root", dir, chdir: ROOT)
  end

  def audit_status(dir)
    audit(dir).last
  end

  # Builds a minimal repository holding both owner skills and two valid catalogs.
  def with_fixture
    Dir.mktmpdir do |dir|
      %w[skills/alpha skills/beta].each do |skill|
        FileUtils.mkdir_p(File.join(dir, skill))
        File.write(File.join(dir, skill, "SKILL.md"), "name: #{File.basename(skill)}\n")
      end

      make_catalog(dir, "alpha", catalog(owner: "alpha"))
      make_catalog(dir, "beta", catalog(owner: "beta", tool: "tool-b", command: "bin/run-b"))
      yield dir
    end
  end

  def make_catalog(dir, name, body)
    FileUtils.mkdir_p(File.join(dir, "data", name))
    File.write(File.join(dir, "data", name, "tools.yml"), body)
  end

  def catalog(owner:, tool: "tool-a", gem: "gem-a", command: nil, category: "cat_one")
    identifier = command ? "command: #{command}" : "gem: #{gem}"
    format(CATALOG_TEMPLATE, owner: owner, tool: tool, category: category, identifier: identifier)
  end
end
