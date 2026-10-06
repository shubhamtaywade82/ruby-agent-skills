# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

# Publish readiness must never turn a missing tool into a pass, and every
# skill must carry the metadata external directories read.
class PublishReadinessSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  # Only what the scripts themselves need. System dirs like /usr/bin can hold
  # npx or uvx, so PATH points at a directory of links to these tools alone.
  REQUIRED_TOOLS = %w[bash dirname git].freeze

  def setup
    @tool_dir = Dir.mktmpdir("toolless-path")
    REQUIRED_TOOLS.each do |tool|
      path = ENV.fetch("PATH").split(File::PATH_SEPARATOR).map { |dir| File.join(dir, tool) }
                .find { |candidate| File.executable?(candidate) }
      File.symlink(path, File.join(@tool_dir, tool))
    end
  end

  def teardown
    FileUtils.remove_entry(@tool_dir)
  end

  def test_spec_check_reports_unavailable_without_skills_ref
    _out, err, status = Open3.capture3({ "PATH" => @tool_dir },
                                       File.join(ROOT, "bin", "skills-spec-check"))

    assert_equal 3, status.exitstatus
    assert_includes err, "skills-ref unavailable"
  end

  def test_readiness_never_reports_missing_tools_as_ready
    out, _err, status = Open3.capture3({ "PATH" => @tool_dir }, RbConfig.ruby,
                                       File.join(ROOT, "bin", "publish-readiness"),
                                       "--only", "spec,cli_list,cli_install")

    refute_predicate status, :success?
    assert_includes out, "| spec | unavailable |"
    assert_match(/\| cli_list \| unavailable \| npx not found \|.*Result: NOT READY/m, out)
  end

  def test_readiness_rejects_unknown_checks
    _out, err, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "bin", "publish-readiness"),
                                       "--only", "publish")

    refute_predicate status, :success?
    assert_includes err, "unknown checks: publish"
  end

  def test_every_skill_declares_the_repository_license
    assert_match(/\AMIT License/, File.read(File.join(ROOT, "LICENSE"), encoding: "UTF-8"))

    Dir[File.join(ROOT, "skills", "*", "SKILL.md")].each do |path|
      frontmatter = File.read(path, encoding: "UTF-8")[/\A---\n(.*?)\n---\n/m, 1]

      assert_equal "MIT", YAML.safe_load(frontmatter)["license"], path
    end
  end

  def test_ci_runs_the_official_specification_check
    workflow = File.read(File.join(ROOT, ".github", "workflows", "validate.yml"), encoding: "UTF-8")

    assert_includes workflow, "bin/skills-spec-check"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/publish_readiness_system_test.rb"
  end
end
