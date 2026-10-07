# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

# The rails-adversarial verifier grades behavior only: visible tests plus a
# withheld production-condition test. Its value rests on two properties this
# test pins for every fixture: a reference solution passes every check, and
# each negative control passes the visible tests but fails the withheld one.
class RailsAdversarialBenchmarkSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  FAMILY = File.join(ROOT, "benchmarks", "rails-adversarial")
  VERIFIER = File.join(ROOT, "scripts", "verify_rails_adversarial_eval.rb")
  FIXTURE_IDS = YAML.safe_load_file(File.join(FAMILY, "fixtures.yml")).fetch("fixtures").keys.sort

  def test_every_fixture_has_reference_withheld_test_and_evaluation
    required = FIXTURE_IDS.flat_map do |id|
      [File.join(FAMILY, "references", id, "lib"),
       File.join(FAMILY, "withheld", id, "test_withheld.rb"),
       File.join(ROOT, "evals", "rails-adversarial", "#{id}.yml")]
    end

    refute_empty FIXTURE_IDS
    assert_empty(required.reject { |path| File.exist?(path) })
  end

  def test_reference_solutions_pass_every_check
    FIXTURE_IDS.each do |id|
      checks = grade(id, File.join(FAMILY, "references", id))

      checks.each { |name, result| assert_equal "pass", result.fetch("status"), "#{id} #{name}" }
    end
  end

  def test_negative_controls_pass_visible_tests_but_fail_withheld
    controls = Dir[File.join(FAMILY, "controls", "*", "*")].select { |dir| File.directory?(dir) }

    refute_empty controls
    controls.each do |control|
      checks = grade(File.basename(control), control)
      label = control.delete_prefix("#{FAMILY}/")

      assert_equal "pass", checks.dig("functional", "status"), "#{label} functional"
      assert_equal "fail", checks.dig("adversarial", "status"), "#{label} adversarial"
    end
  end

  def test_changes_outside_lib_and_test_fail_scope_control
    id = FIXTURE_IDS.first
    checks = grade(id, File.join(FAMILY, "references", id)) do |workspace|
      File.write(File.join(workspace, "notes.txt"), "stray\n")
    end

    assert_equal "fail", checks.dig("scope_control", "status")
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/rails_adversarial_benchmark_system_test.rb"
  end

  private

  # Fixture committed as the baseline, the solution overlaid on top, an
  # optional extra change, then the verifier's checks.
  def grade(id, solution_dir)
    Dir.mktmpdir("rails-adversarial-test") do |dir|
      workspace = File.join(dir, "workspace")
      FileUtils.cp_r(File.join(FAMILY, "fixtures", id), workspace)
      commit_baseline(workspace)
      FileUtils.cp_r("#{solution_dir}/.", workspace)
      yield workspace if block_given?

      run_verifier(workspace, id, File.join(dir, "result.json"))
    end
  end

  def commit_baseline(workspace)
    git(workspace, "init", "-q")
    git(workspace, "add", "-A")
    git(workspace, "-c", "user.email=t@example.com", "-c", "user.name=t", "commit", "-qm", "base")
  end

  # The verifier exits non-zero when any check fails; the result file is the contract.
  def run_verifier(workspace, id, result_file)
    env = { "RUBY_AGENT_EVAL_ROOT" => ROOT, "RUBY_AGENT_EVAL_RESULT_FILE" => result_file,
            "RUBY_AGENT_EVAL_FILE" => File.join(ROOT, "evals", "rails-adversarial", "#{id}.yml") }
    _out, err, _status = Open3.capture3(env, RbConfig.ruby, VERIFIER, chdir: workspace)

    assert_path_exists result_file, err
    JSON.parse(File.read(result_file)).fetch("checks")
  end

  def git(workspace, *)
    _out, err, status = Open3.capture3("git", "-C", workspace, *)

    assert_predicate status, :success?, err
  end
end
