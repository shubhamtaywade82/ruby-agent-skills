# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "shellwords"
require "tmpdir"
require "yaml"
require_relative "../lib/ruby_agent_skills/eval_runner"
require_relative "../lib/ruby_agent_skills/fixture_registry"

# Negative and positive controls for every benchmark campaign fixture.
#
# A benchmark can only show a skills effect if the unmodified fixture fails
# its verifier (otherwise a do-nothing agent scores the same as a good one)
# and a known-good implementation passes it (otherwise the verifier cannot be
# satisfied). Both controls run through EvalRunner and the campaign verifier,
# exactly as bin/benchmark campaign does.
class BenchmarkFixtureControlsSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  NOOP_AGENT = "true"
  TIMEOUT = 120

  def campaigns
    Dir[File.join(ROOT, "benchmarks", "*", "campaign.yml")].sort.map do |path|
      YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
    end
  end

  def runner
    @runner ||= RubyAgentSkills::EvalRunner.new(root: ROOT)
  end

  def run_control(campaign, eval_id, workspace, agent_command)
    verifier = File.expand_path(campaign.fetch("verifier"), ROOT)
    runner.run(
      id: eval_id,
      workspace: workspace,
      agent_command: agent_command,
      verify_command: "ruby #{Shellwords.escape(verifier)}",
      timeout: TIMEOUT
    )
  end

  def each_fixture
    campaigns.each do |campaign|
      registry = RubyAgentSkills::FixtureRegistry.for_campaign(root: ROOT, campaign: campaign)
      campaign.fetch("evaluations").each { |eval_id| yield campaign, registry, eval_id }
    end
  end

  def test_every_campaign_evaluation_resolves_to_a_fixture
    unresolved = []
    each_fixture do |campaign, registry, eval_id|
      registry.path(eval_id)
    rescue RubyAgentSkills::FixtureRegistry::Error => e
      unresolved << "#{campaign.fetch("id")}: #{e.message}"
    end

    assert_empty unresolved
  end

  def test_unmodified_fixtures_fail_unless_noop_is_declared_correct
    mismatches = []
    each_fixture do |campaign, registry, eval_id|
      expected = registry.noop_expected(eval_id) == "pass" ? "passed" : "failed"
      actual = run_control(campaign, eval_id, registry.path(eval_id), NOOP_AGENT).fetch("overall")
      mismatches << "#{campaign.fetch("id")}/#{eval_id}: no-op agent #{actual}, expected #{expected}" unless actual == expected
    end

    assert_empty mismatches, "a do-nothing agent must not pass an implementation fixture"
  end

  def test_reference_implementations_pass_their_verifier
    failures = []
    references = 0
    each_fixture do |campaign, registry, eval_id|
      next unless registry.reference?(eval_id)

      references += 1
      agent = "ruby -rfileutils -e #{Shellwords.escape('FileUtils.cp_r(File.join(ARGV[0], "."), ".")')} " \
              "#{Shellwords.escape(registry.reference_root(eval_id))}"
      result = run_control(campaign, eval_id, registry.path(eval_id), agent)
      next if result.fetch("overall") == "passed"

      failed = result.fetch("checks").reject { |_name, check| check["status"] == "pass" }.keys
      failures << "#{campaign.fetch("id")}/#{eval_id}: reference #{result.fetch("overall")} (#{failed.join(", ")})"
    end

    assert_operator references, :>, 0
    assert_empty failures
  end

  # Verifiers that grade with a registry test file must use the fixture's
  # original copy: an agent that rewrites the test to pass trivially and
  # leaves the implementation untouched must still fail.
  def test_rewritten_workspace_tests_do_not_change_the_grade
    tampered = []
    graded = 0
    each_fixture do |campaign, registry, eval_id|
      test_file = registry.entry(eval_id)["test_file"]
      next unless test_file && %w[rails design-patterns].include?(campaign.fetch("evaluation_set"))

      graded += 1
      agent = "ruby -e #{Shellwords.escape(<<~RUBY)}"
        File.write(#{test_file.inspect}, <<~TEST)
          require "minitest/autorun"
          class TamperedTest < Minitest::Test
            def test_passes = assert(true)
          end
        TEST
      RUBY
      result = run_control(campaign, eval_id, registry.path(eval_id), agent)
      functional = result.fetch("checks").fetch("functional")
      next if result.fetch("overall") == "failed" && functional.fetch("status") == "fail" && functional["evidence"].is_a?(String)

      tampered << "#{campaign.fetch("id")}/#{eval_id}: #{result.fetch("overall")} functional=#{functional.inspect[0, 200]}"
    end

    assert_operator graded, :>, 0
    assert_empty tampered
  end

  def test_agent_does_not_receive_the_benchmark_repository_root
    previous = ENV["RUBY_AGENT_EVAL_ROOT"]
    ENV["RUBY_AGENT_EVAL_ROOT"] = ROOT
    campaign = campaigns.find { |c| c.fetch("evaluation_set") == "rails" }
    registry = RubyAgentSkills::FixtureRegistry.for_campaign(root: ROOT, campaign: campaign)
    eval_id = campaign.fetch("evaluations").first

    result = run_control(campaign, eval_id, registry.path(eval_id), %(ruby -e 'exit(ENV.key?("RUBY_AGENT_EVAL_ROOT") ? 3 : 0)'))

    assert_equal 0, result.fetch("agent").fetch("exit_code"), "agent environment exposed RUBY_AGENT_EVAL_ROOT"
    refute_equal "incomplete", result.fetch("overall"), "verifier must still receive RUBY_AGENT_EVAL_ROOT"
  ensure
    previous ? ENV["RUBY_AGENT_EVAL_ROOT"] = previous : ENV.delete("RUBY_AGENT_EVAL_ROOT")
  end

  def test_agent_cannot_forge_the_verifier_result
    campaign = campaigns.find { |c| c.fetch("evaluation_set") == "rails" }
    registry = RubyAgentSkills::FixtureRegistry.for_campaign(root: ROOT, campaign: campaign)
    eval_id = campaign.fetch("evaluations").first
    forge = "ruby -rjson -e #{Shellwords.escape(
      'checks = %w[functional tests contract scope_control].to_h { |n| [n, { "status" => "pass" }] }; ' \
      'File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.generate("checks" => checks))'
    )}"

    # A verifier that exits 0 without reporting must not inherit forged checks.
    result = runner.run(id: eval_id, workspace: registry.path(eval_id), agent_command: forge, verify_command: "true", timeout: TIMEOUT)

    refute_equal "passed", result.fetch("overall")
    assert(result.fetch("checks").values.none? { |check| check["status"] == "pass" })
  end

  def test_every_fixture_has_a_positive_control
    missing = []
    each_fixture do |campaign, registry, eval_id|
      next if registry.noop_expected(eval_id) == "pass"

      missing << "#{campaign.fetch("id")}/#{eval_id}" unless registry.reference?(eval_id)
    end

    assert_empty missing, "every implementation fixture needs a reference under benchmarks/<set>/references/<id>/"
  end

  # A reference's own tests must pass against the reference. Tests that need a
  # Rails application cannot load in these workspaces and are covered by the
  # verifier's static checks instead.
  RAILS_TEST_MARKERS = [
    /require\s+"test_helper"/, /require\s+"application_system_test_case"/,
    /ActiveSupport::TestCase|ActionDispatch::IntegrationTest|ApplicationSystemTestCase/
  ].freeze

  def test_reference_tests_pass_against_the_reference
    failures = []
    ran = 0
    each_fixture do |_campaign, registry, eval_id|
      next unless registry.reference?(eval_id)

      reference = registry.reference_root(eval_id)
      tests = Dir.glob(File.join(reference, "{test,spec}", "**", "{*_test,test_*}.rb")).sort
      next if tests.empty?

      Dir.mktmpdir("reference-tests") do |workspace|
        FileUtils.cp_r(File.join(registry.path(eval_id), "."), workspace)
        FileUtils.cp_r(File.join(reference, "."), workspace)
        tests.map { |path| path.delete_prefix("#{reference}/") }.each do |relative|
          next if RAILS_TEST_MARKERS.any? { |marker| File.read(File.join(workspace, relative)).match?(marker) }

          ran += 1
          out, err, status = Open3.capture3(RbConfig.ruby, "-Ilib", relative, chdir: workspace)
          failures << "#{eval_id}/#{relative}: #{(out + err).lines.last(3).join.strip}" unless status.success?
        end
      end
    end

    assert_operator ran, :>, 0
    assert_empty failures
  end

  def test_registry_root_overrides_conventional_directory
    Dir.mktmpdir("fixture-registry") do |root|
      FileUtils.mkdir_p(File.join(root, "benchmarks", "demo", "fixtures", "short-name"))
      File.write(File.join(root, "benchmarks", "demo", "fixtures.yml"), <<~YAML)
        fixtures:
          demo-long-name:
            root: benchmarks/demo/fixtures/short-name
          missing:
            root: benchmarks/demo/fixtures/absent
          preserved:
            noop_expected: pass
      YAML
      registry = RubyAgentSkills::FixtureRegistry.new(root: root, evaluation_set: "demo", fixture_root: "benchmarks/demo/fixtures")

      assert_equal File.join(root, "benchmarks", "demo", "fixtures", "short-name"), registry.path("demo-long-name")
      assert_raises(RubyAgentSkills::FixtureRegistry::Error) { registry.path("missing") }
      FileUtils.mkdir_p(File.join(root, "benchmarks", "demo", "fixtures", "unregistered"))
      error = assert_raises(RubyAgentSkills::FixtureRegistry::Error) { registry.path("unregistered") }
      assert_includes error.message, "not registered"
      assert_raises(RubyAgentSkills::FixtureRegistry::Error) { registry.noop_expected("preserved") }
      assert_equal "fail", registry.noop_expected("demo-long-name")

      before = registry.digest("demo-long-name")
      File.write(File.join(root, "benchmarks", "demo", "fixtures", "short-name", "solution.rb"), "# start\n")

      refute_equal before, registry.digest("demo-long-name"), "starting-state changes must change the fixture digest"
    end
  end

  def test_references_never_ship_inside_agent_workspaces
    each_fixture do |_campaign, registry, eval_id|
      next unless registry.reference?(eval_id)

      refute File.expand_path(registry.reference_root(eval_id)).start_with?("#{File.expand_path(registry.path(eval_id))}/"), eval_id
    end
  end

  def test_validator_registers_this_system_test
    assert_includes File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8"),
                    "test/benchmark_fixture_controls_system_test.rb"
  end
end
