# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require "json"
require "fileutils"
require "tmpdir"
require "open3"

class TestEngineeringSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-test-engineering/SKILL.md
    patterns/testing/test-boundary-selection.md
    patterns/testing/deterministic-async-test.md
    patterns/testing/parallel-safe-test.md
    patterns/testing/flaky-test-diagnosis.md
    patterns/testing/test-performance-budget.md
    patterns/testing/system-test-contract.md
    patterns/testing/request-contract.md
    patterns/testing/parallel-database-test.md
    data/test-engineering/tools.yml
    evals/test-engineering/boundary-selection.yml
    evals/test-engineering/deterministic-job.yml
    evals/test-engineering/parallel-safety.yml
    evals/test-engineering/flaky-diagnosis.yml
    evals/test-engineering/system-contract.yml
    evals/test-engineering/test-performance.yml
    evals/test-engineering/rspec-request-contract.yml
    benchmarks/test-engineering/fixtures/rspec-request-contract/spec/requests/orders_spec.rb
    benchmarks/test-engineering/fixtures.yml
    benchmarks/test-engineering/campaign.yml
    scripts/verify_test_engineering_eval.rb
  ].freeze

  RSPEC_REFERENCE_RULES = [
    'describe "#instance_method"',
    'describe ".class_method"',
    "RSpec/DescribeMethod",
    ":aggregate_failures",
    "RSpec/MultipleExpectations",
    "WebMock.disable_net_connect!(allow_localhost: true)",
    "filter_sensitive_data",
    "Do not add WebMock or VCR to a suite that isolates HTTP another way"
  ].freeze

  def test_all_test_engineering_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_evaluations_reference_registered_skills
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml")))
    registered = manifest.fetch("skills").keys

    Dir[File.join(ROOT, "evals/test-engineering/*.yml")].each do |file|
      evaluation = YAML.safe_load(File.read(file))

      evaluation.fetch("skills").each { |skill| assert_includes registered, skill }
    end
  end

  def test_rspec_reference_keeps_method_naming_aggregate_failures_and_http_stubbing_rules
    reference = File.read(File.join(ROOT, "skills/rails-test-engineering/references/rspec.md"),
                          encoding: "UTF-8")

    RSPEC_REFERENCE_RULES.each { |rule| assert_includes reference, rule }
  end

  # The consumer lint snippet in the RSpec reference must not drift from the
  # policy this repository configures and documents in .rubocop.yml.
  def test_rspec_reference_lint_snippet_matches_repository_policy
    reference = File.read(File.join(ROOT, "skills/rails-test-engineering/references/rspec.md"),
                          encoding: "UTF-8")
    snippet = reference[/^## Lint enforcement.*?```yaml\n(.*?)```/m, 1]

    refute_nil snippet, "RSpec reference must contain the consumer lint snippet"

    consumer = YAML.safe_load(snippet)
    policy = YAML.safe_load_file(File.join(ROOT, ".rubocop.yml"))

    assert_includes consumer.fetch("plugins"), "rubocop-rspec"
    consumer.except("plugins").each do |cop, settings|
      assert_equal policy.fetch(cop), settings, "#{cop} differs from .rubocop.yml"
    end
  end
end

# Runs the real verifier against fixture + reference workspaces.
class TestEngineeringScopeControlTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  BENCHMARK = File.join(ROOT, "benchmarks/test-engineering")
  VERIFIER = File.join(ROOT, "scripts/verify_test_engineering_eval.rb")

  # scope_control: a reference solution stays inside the test suite and
  # passes; any change outside test/ or spec/ fails.
  def test_scope_control_passes_references_and_rejects_out_of_suite_changes
    %w[boundary-selection rspec-request-contract].each do |eval_id|
      assert_equal "pass", verify_scope(eval_id).fetch("status"), "#{eval_id} reference scope"

      stray = verify_scope(eval_id) do |workspace|
        File.write(File.join(workspace, "app.rb"), "1\n")
      end

      assert_equal "fail", stray.fetch("status")
      assert_equal ["app.rb"], stray.dig("evidence", "outside_test_suite")
    end
  end

  private

  # Fixture committed as the baseline, reference applied on top, optional
  # extra change from the block, then the verifier's scope_control result.
  def verify_scope(eval_id)
    Dir.mktmpdir("te-scope-") do |dir|
      workspace = File.join(dir, "workspace")
      FileUtils.cp_r(File.join(BENCHMARK, "fixtures", eval_id), workspace)
      commit_baseline(workspace)
      FileUtils.cp_r("#{File.join(BENCHMARK, 'references', eval_id)}/.", workspace)
      yield workspace if block_given?

      run_verifier(workspace, eval_id, File.join(dir, "result.json"))
    end
  end

  def commit_baseline(workspace)
    git(workspace, "init", "-q")
    git(workspace, "add", "-A")
    git(workspace, "-c", "user.email=t@example.com", "-c", "user.name=t", "commit", "-qm", "base")
  end

  # The verifier exits non-zero when any check fails; the result file is the contract.
  def run_verifier(workspace, eval_id, result_file)
    env = { "RUBY_AGENT_EVAL_ROOT" => ROOT, "RUBY_AGENT_EVAL_RESULT_FILE" => result_file,
            "RUBY_AGENT_EVAL_FILE" => File.join(ROOT, "evals/test-engineering/#{eval_id}.yml") }
    _out, err, _status = Open3.capture3(env, RbConfig.ruby, VERIFIER, chdir: workspace)

    assert_path_exists result_file, err
    JSON.parse(File.read(result_file)).fetch("checks").fetch("scope_control")
  end

  def git(workspace, *)
    _out, err, status = Open3.capture3("git", "-C", workspace, *)

    assert_predicate status, :success?, err
  end
end
