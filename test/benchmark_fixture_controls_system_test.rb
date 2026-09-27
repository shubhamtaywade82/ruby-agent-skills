# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
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
      assert_raises(RubyAgentSkills::FixtureRegistry::Error) { registry.noop_expected("preserved") }
      assert_equal "fail", registry.noop_expected("demo-long-name")
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
