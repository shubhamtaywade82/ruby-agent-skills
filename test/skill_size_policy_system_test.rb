# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

# Runs scripts/validate_skills.rb against mutated copies of the repository.
module SkillSizePolicyFixture
  ROOT = File.expand_path("..", __dir__)
  VALIDATOR = File.join(ROOT, "scripts", "validate_skills.rb")
  SKILL = "rails-active-record"

  def run_validator(root)
    Open3.capture3(RbConfig.ruby, VALIDATOR, "--root", root, chdir: ROOT)
  end

  # Copies the real skills and manifest into a temporary root, applies the
  # mutation to the copied skill directory, and returns [stdout, stderr, status].
  def validate_with
    Dir.mktmpdir("skill-size-policy") do |dir|
      FileUtils.cp_r(File.join(ROOT, "skills"), dir)
      FileUtils.cp(File.join(ROOT, "skill-manifest.yml"), dir)
      yield File.join(dir, "skills", SKILL)
      run_validator(dir)
    end
  end

  def append(path, text)
    File.open(path, "a", encoding: "UTF-8") { |file| file.write(text) }
  end
end

class SkillSizePolicySystemTest < Minitest::Test
  include SkillSizePolicyFixture

  def test_validator_passes_current_repository_and_reports_policy
    stdout, stderr, status = run_validator(ROOT)

    assert_predicate status, :success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "Size policy: SKILL.md <= 500 lines and <= ~5000 estimated tokens"
    assert_includes stdout, "one level deep"
  end

  def test_every_skill_is_within_the_hard_limits
    Dir[File.join(ROOT, "skills", "*", "SKILL.md")].each do |path|
      text = File.read(path, encoding: "UTF-8")

      assert_operator text.lines.length, :<=, 500, path
      assert_operator (text.bytesize / 4.0).ceil, :<=, 5_000, path
    end
  end

  def test_rejects_skill_over_line_limit
    _stdout, stderr, status = validate_with do |dir|
      append(File.join(dir, "SKILL.md"), "- line\n" * 400)
    end

    refute_predicate status, :success?
    assert_includes stderr, "exceeds the 500-line SKILL.md limit"
  end

  def test_rejects_skill_over_token_limit
    _stdout, stderr, status = validate_with do |dir|
      append(File.join(dir, "SKILL.md"), "#{'x' * 7_000}\n")
    end

    refute_predicate status, :success?
    assert_includes stderr, "exceeds the 5000-token SKILL.md limit"
  end

  def test_rejects_reference_not_linked_from_skill
    _stdout, stderr, status = validate_with do |dir|
      File.write(File.join(dir, "references", "orphan.md"), "# Orphan\n", encoding: "UTF-8")
    end

    refute_predicate status, :success?
    assert_includes stderr, "references/orphan.md is not linked from SKILL.md"
  end

  def test_rejects_link_to_missing_reference
    _stdout, stderr, status = validate_with do |dir|
      append(File.join(dir, "SKILL.md"), "\nSee [gone](references/gone.md).\n")
    end

    refute_predicate status, :success?
    assert_includes stderr, "reference references/gone.md does not exist"
  end

  def test_rejects_nested_reference_directory
    _stdout, stderr, status = validate_with do |dir|
      FileUtils.mkdir_p(File.join(dir, "references", "deeper"))
      File.write(File.join(dir, "references", "deeper", "detail.md"), "# Detail\n")
    end

    refute_predicate status, :success?
    assert_includes stderr, "references/deeper must be a Markdown file directly under references/"
  end

  def test_rejects_reference_chaining
    _stdout, stderr, status = validate_with do |dir|
      append(File.join(dir, "references", "testing.md"),
             "\nContinue in [callbacks](persistence-lifecycle-and-callbacks.md).\n")
    end

    refute_predicate status, :success?
    assert_includes stderr, "reference files must stay one level deep"
  end

  def test_rejects_oversized_reference
    _stdout, stderr, status = validate_with do |dir|
      append(File.join(dir, "references", "testing.md"), "- item\n" * 500)
    end

    refute_predicate status, :success?
    assert_includes stderr, "exceeds the 500-line reference limit"
  end

  def test_rejects_unregistered_pattern_in_reference_index
    _stdout, stderr, status = validate_with do |dir|
      path = File.join(dir, "SKILL.md")
      text = File.read(path, encoding: "UTF-8").sub("`active-record-testing`",
                                                    "`active-record-imaginary`")
      File.write(path, text, encoding: "UTF-8")
    end

    refute_predicate status, :success?
    assert_includes stderr, "References names unregistered pattern active-record-imaginary"
  end

  def test_rejects_unexpected_skill_entry
    _stdout, stderr, status = validate_with do |dir|
      File.write(File.join(dir, "NOTES.md"), "# Notes\n", encoding: "UTF-8")
    end

    refute_predicate status, :success?
    assert_includes stderr, "unexpected skill entry NOTES.md"
  end

  def test_validator_is_registered
    validate = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validate, "scripts/validate_skills.rb"
    assert_includes validate, "test/skill_size_policy_system_test.rb"
  end
end
