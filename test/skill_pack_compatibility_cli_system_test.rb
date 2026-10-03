# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"

class SkillPackCompatibilityCliSystemTest < Minitest::Test
  # The CLI tests exercise the complete external boundary.
  # rubocop:disable Metrics/MethodLength
  ROOT = File.expand_path("..", __dir__)

  def build_project
    root = Dir.mktmpdir("runtime-compatibility-project-")
    FileUtils.mkdir_p(File.join(root, "skills", "fixture"))
    root
  end

  def run_cli(project, *)
    Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "bin", "skill-pack-compatibility"),
      project,
      *,
      chdir: ROOT
    )
  end

  def test_cli_reports_supported_pattern_for_matching_runtime
    project = build_project
    File.write(
      File.join(project, "Gemfile.lock"),
      <<~LOCK
        GEM
          specs:
            rails (8.1.4)

        RUBY VERSION
           ruby 3.3.12p0
      LOCK
    )

    stdout, stderr, status = run_cli(
      project,
      "--pattern",
      "patterns/rails/active-job-continuation-contract",
      "--json"
    )

    assert_predicate status, :success?, "#{stdout}
#{stderr}"

    report = JSON.parse(stdout)

    assert_equal "supported", report.fetch("status")

    assert_equal(
      "supported",
      report.dig(
        "requirements",
        "patterns/rails/active-job-continuation-contract",
        "requirements",
        "rails",
        "status"
      )
    )
  end

  def test_cli_fails_for_known_incompatible_runtime
    project = build_project
    File.write(
      File.join(project, "Gemfile.lock"),
      <<~LOCK
        GEM
          specs:
            rails (8.0.4)
      LOCK
    )

    stdout, stderr, status = run_cli(
      project,
      "--pattern",
      "patterns/rails/active-job-continuation-contract"
    )

    refute_predicate status, :success?
    assert_equal "", stderr
    assert_includes stdout, "status: unsupported"
  end

  def test_cli_strict_mode_fails_when_runtime_is_unknown
    project = build_project

    _stdout, _stderr, status = run_cli(
      project,
      "--pattern", "patterns/rails/active-job-continuation-contract",
      "--strict"
    )

    refute_predicate status, :success?
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/skill_pack_compatibility_cli_system_test.rb"
  end
  # rubocop:enable Metrics/MethodLength
end
