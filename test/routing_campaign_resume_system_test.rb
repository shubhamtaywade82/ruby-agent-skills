# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingCampaignResumeSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  EVALUATOR = File.join(ROOT, "bin", "routing-eval")
  CASE_ID = "password-recovery-not-authorization"

  def write_agent(dir, exit_on_run_two:)
    path = File.join(dir, exit_on_run_two ? "agent_interrupt.rb" : "agent_success.rb")
    code = <<~RUBY
      require "json"
      result = {
        "protocol_version" => 1,
        "case_id" => ENV.fetch("RUBY_AGENT_ROUTING_CASE_ID"),
        "primary_skill" => "rails-authentication",
        "secondary_skills" => ["rails-security-engineering", "rails-test-engineering"],
        "reason" => "Authentication owns password recovery; security and testing are dependent constraints."
      }
      File.write(ENV.fetch("RUBY_AGENT_ROUTING_RESULT_FILE"), JSON.generate(result))
      exit 1 if #{exit_on_run_two.inspect} && ENV.fetch("RUBY_AGENT_ROUTING_RUN_NUMBER") == "2"
    RUBY
    File.write(path, code, encoding: "UTF-8")
    path
  end

  def run_eval(agent_path, output, resume: false)
    command = "#{RbConfig.ruby} #{agent_path}"
    args = [
      RbConfig.ruby,
      EVALUATOR,
      "--command", command,
      "--case", CASE_ID,
      "--runs", "2",
      "--provider", "ollama",
      "--model", "test-model",
      "--model-version", "test-digest",
      "--tool-mode", "test",
      "--output", File.join(output, "campaign.json")
    ]
    args << "--resume" if resume

    Open3.capture3(*args, chdir: ROOT)
  end

  def test_interrupted_campaign_can_resume_without_rerunning_completed_runs
    Dir.mktmpdir("routing-resume") do |dir|
      interrupt_agent = write_agent(dir, exit_on_run_two: true)
      stdout, stderr, status = run_eval(interrupt_agent, dir)

      refute status.success?, "#{stdout}\n#{stderr}"
      checkpoint = JSON.parse(File.read(File.join(dir, "campaign.json"), encoding: "UTF-8"))
      assert_equal 1, checkpoint.fetch("completed_runs")
      refute checkpoint.fetch("complete")
      assert File.file?(File.join(dir, CASE_ID, "run-1", "run.json"))

      success_agent = write_agent(dir, exit_on_run_two: false)
      stdout, stderr, status = run_eval(success_agent, dir, resume: true)

      assert status.success?, "#{stdout}\n#{stderr}"
      final_campaign = JSON.parse(File.read(File.join(dir, "campaign.json"), encoding: "UTF-8"))
      assert_equal 2, final_campaign.fetch("completed_runs")
      assert final_campaign.fetch("complete")

      first_run = final_campaign.fetch("cases").fetch(CASE_ID).fetch("runs").first
      second_run = final_campaign.fetch("cases").fetch(CASE_ID).fetch("runs").last
      assert_equal true, first_run.fetch("resumed")
      refute second_run.key?("resumed")
      assert_includes stdout, "Resumed #{CASE_ID} run 1"
    end
  end

  def test_resume_rejects_incompatible_campaign_configuration
    Dir.mktmpdir("routing-resume") do |dir|
      success_agent = write_agent(dir, exit_on_run_two: false)
      _stdout, _stderr, status = run_eval(success_agent, dir)
      assert status.success?

      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        EVALUATOR,
        "--command", "#{RbConfig.ruby} #{success_agent}",
        "--case", CASE_ID,
        "--runs", "3",
        "--provider", "ollama",
        "--model", "test-model",
        "--model-version", "test-digest",
        "--tool-mode", "test",
        "--output", File.join(dir, "campaign.json"),
        "--resume",
        chdir: ROOT
      )

      refute status.success?
      assert_includes stderr, "repetition count mismatch"
    end
  end

  def test_resume_rejects_model_version_change
    Dir.mktmpdir("routing-resume") do |dir|
      success_agent = write_agent(dir, exit_on_run_two: false)
      _stdout, _stderr, status = run_eval(success_agent, dir)
      assert status.success?

      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        EVALUATOR,
        "--command", "#{RbConfig.ruby} #{success_agent}",
        "--case", CASE_ID,
        "--runs", "2",
        "--provider", "ollama",
        "--model", "test-model",
        "--model-version", "different-digest",
        "--tool-mode", "test",
        "--output", File.join(dir, "campaign.json"),
        "--resume",
        chdir: ROOT
      )

      refute status.success?
      assert_includes stderr, "model version mismatch"
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_campaign_resume_system_test.rb"
  end
end
