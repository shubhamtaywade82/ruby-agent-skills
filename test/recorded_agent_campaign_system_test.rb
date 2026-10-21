# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "rbconfig"
require "tmpdir"
require "yaml"

# The recorded model campaign replays real model recordings through the
# ordinary campaign runner and grades them with the real verifiers. This
# test pins the properties that make the evidence trustworthy: the
# recording set is registered and structurally sound, the replay
# completes paired runs through the actual runner machinery in more than
# one campaign family, the result files carry the recorded agent
# metadata plus the workspace patch evidence, and the replay adapter
# refuses a workspace that does not match the recorded fixture manifest.
class RecordedAgentCampaignSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  SET_ID = "recorded-model-campaign-v1"
  SET_DIR = File.join(ROOT, "agent-recordings", SET_ID)
  ENTRIES = YAML.safe_load_file(File.join(SET_DIR, "recording-set.yml")).fetch("recordings")

  def test_recording_set_registration_matches_its_recordings
    registered = ENTRIES.map { |entry| entry.fetch("evaluation") }

    assert_equal registered.uniq.sort, Dir.children(SET_DIR).grep_v(/\.yml\z/).sort
    assert_empty(registered.tally.select { |_evaluation, count| count > 1 })
    assert_empty(ENTRIES.reject { |entry| File.file?(File.join(ROOT, entry.fetch("manifest"))) })
  end

  def test_every_recording_is_structurally_sound
    ENTRIES.each do |entry|
      evaluation = entry.fetch("evaluation")

      assert_empty recording_errors(File.join(SET_DIR, evaluation), evaluation)
    end
  end

  def test_toolchain_recording_completes_a_paired_run
    Dir.mktmpdir("recorded-campaign") do |output|
      assert_predicate run_set(output, "ruby-toolchain-contract"), :success?
      assert(campaign_result(output, "ruby-toolchain-contract").fetch("complete"))
    end
  end

  def test_database_recording_completes_a_paired_run
    Dir.mktmpdir("recorded-campaign") do |output|
      assert_predicate run_set(output, "transaction-lock"), :success?
      assert(campaign_result(output, "transaction-lock").fetch("complete"))
    end
  end

  def test_gem_recording_writes_solution_and_extended_tests
    Dir.mktmpdir("recorded-campaign") do |output|
      assert_predicate run_set(output, "ruby-gem-development-contract"), :success?
      baseline, = pair_results(output, "ruby-gem-development-contract")
      written = baseline.dig("agent", "metadata", "recorded_agent", "files_written")

      assert_includes written, "test/test_solution.rb"
      assert_includes written, "lib/solution.rb"
    end
  end

  def test_result_files_carry_agent_evidence_and_patch
    Dir.mktmpdir("recorded-campaign") do |output|
      run_set(output, "ruby-toolchain-contract")
      baseline, skills = pair_results(output, "ruby-toolchain-contract")

      assert_equal "z.ai", baseline.dig("agent", "metadata", "provider")
      integrity = skills.dig("agent", "metadata", "recorded_agent", "integrity")

      assert integrity.fetch("skill_selection_verified")
      refute_empty baseline.dig("patch", "diff")
    end
  end

  def test_replay_adapter_refuses_a_tampered_workspace
    Dir.mktmpdir("recorded-adapter") do |sandbox|
      workspace = tampered_workspace(sandbox)
      _out, err, status = replay(sandbox, workspace)

      refute_predicate status, :success?
      assert_match(/workspace does not match/, err)
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/recorded_agent_campaign_system_test.rb"
  end

  private

  def run_set(output, evaluation)
    command = [RbConfig.ruby, File.join(ROOT, "bin", "recorded-agent-benchmark"),
               "--recordings", SET_ID, "--evaluation", evaluation,
               "--runs", "1", "--output", output]
    _out, _err, status = Open3.capture3(*command, chdir: ROOT)

    status
  end

  def campaign_result(output, evaluation)
    path = File.join(output, evaluation, "campaign.json")
    JSON.parse(File.read(path, encoding: "UTF-8")).fetch("evaluations").fetch(evaluation)
  end

  def pair_results(output, evaluation)
    result = campaign_result(output, evaluation)
    baseline = JSON.parse(File.read(result.fetch("baseline_results").first, encoding: "UTF-8"))
    skills = JSON.parse(File.read(result.fetch("skills_results").first, encoding: "UTF-8"))
    [baseline, skills]
  end

  def recording_errors(recording_dir, evaluation)
    %w[baseline skills].flat_map do |config|
      configuration_errors(recording_dir, evaluation, config)
    end
  end

  def configuration_errors(recording_dir, evaluation, configuration)
    path = File.join(recording_dir, configuration, "recording.json")
    return ["missing recording: #{path}"] unless File.file?(path)

    recording = JSON.parse(File.read(path, encoding: "UTF-8"))
    recording_file_errors(recording, evaluation, configuration)
  end

  def recording_file_errors(recording, evaluation, configuration)
    errors = []
    errors << "evaluation mismatch" unless recording["evaluation"] == evaluation
    errors << "configuration mismatch" unless recording["configuration"] == configuration
    errors << "schema version" unless recording["recording_schema_version"] == 1
    files = recording["files"]
    errors << "no recorded files" unless files.is_a?(Hash) && !files.empty?
    errors.concat(path_errors((files || {}).keys))
    errors.concat(fingerprint_errors(recording["context_fingerprint"]))
    errors
  end

  def path_errors(paths)
    paths.select { |relative| relative.start_with?("/") || relative.split("/").include?("..") }
         .map { |relative| "unsafe recorded path: #{relative}" }
  end

  def fingerprint_errors(fingerprint)
    workspace = fingerprint.is_a?(Hash) ? fingerprint.fetch("workspace", {}) : {}
    prompt_digest = fingerprint.is_a?(Hash) ? fingerprint["prompt_sha256"] : nil
    digests = [prompt_digest] + workspace.values
    digests.compact.reject { |digest| digest.to_s.match?(/\A[0-9a-f]{64}\z/) }
           .map { |digest| "malformed digest: #{digest}" }
  end

  def tampered_workspace(sandbox)
    fixture = File.join(ROOT, "benchmarks", "ruby-toolchain", "fixtures", "ruby-toolchain-contract")
    workspace = File.join(sandbox, "workspace")
    FileUtils.cp_r(fixture, workspace)
    solution = File.join(workspace, "lib", "solution.rb")
    File.write(solution, "class Tampered; end\n", encoding: "UTF-8")
    workspace
  end

  def replay(sandbox, workspace)
    evaluation = YAML.safe_load_file(File.join(ROOT, "evals", "ruby-toolchain", "contract.yml"))
    prompt_path = File.join(sandbox, "prompt.md")
    File.write(prompt_path, evaluation.fetch("prompt"), encoding: "UTF-8")
    write_baseline_manifest(sandbox)

    Open3.capture3(adapter_env(sandbox, workspace, prompt_path), RbConfig.ruby,
                   File.join(ROOT, "adapters", "recorded_agent.rb"), SET_ID)
  end

  def write_baseline_manifest(sandbox)
    manifest = File.join(sandbox, "manifest.json")
    payload = "#{JSON.pretty_generate('skills' => [], 'patterns' => [])}\n"
    File.write(manifest, payload, encoding: "UTF-8")
  end

  def adapter_env(sandbox, workspace, prompt_path)
    {
      "RUBY_AGENT_EVAL_ID" => "ruby-toolchain-contract",
      "RUBY_AGENT_WORKSPACE" => workspace,
      "RUBY_AGENT_EVAL_PROMPT" => prompt_path,
      "RUBY_AGENT_SKILL_MANIFEST" => File.join(sandbox, "manifest.json"),
      "RUBY_AGENT_SKILLS_ENABLED" => "false",
      "RUBY_AGENT_METADATA_FILE" => File.join(sandbox, "metadata.json")
    }
  end
end
