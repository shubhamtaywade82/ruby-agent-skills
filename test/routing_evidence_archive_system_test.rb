# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingEvidenceArchiveSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_archive_copies_verified_evidence_and_artifacts_without_overwrite
    Dir.mktmpdir("routing-archive") do |dir|
      router = File.join(dir, "ROUTING.md")
      File.write(router, "# Test routing contract\n")
      baseline = {"protocol_version"=>1,"campaign"=>"skill-routing-public-v1","campaign_version"=>1,"routing_case_count"=>1,"requested_repetitions"=>1,"complete"=>true,"routing_contract"=>router,"agent"=>{"provider"=>"test","model"=>"test-model","model_version"=>nil,"tool_mode"=>"test"},"metrics"=>{"primary_accuracy"=>1.0,"secondary_recall"=>1.0,"average_unexpected_secondary_count"=>0.0}}
      candidate = baseline.dup
      comparison = {"deltas"=>{"primary_accuracy"=>0.0,"secondary_recall"=>0.0,"average_unexpected_secondary_count"=>0.0},"gate"=>{"passed"=>true,"errors"=>[]}}
      File.write(File.join(dir,"baseline.json"),JSON.pretty_generate(baseline))
      File.write(File.join(dir,"candidate.json"),JSON.pretty_generate(candidate))
      File.write(File.join(dir,"comparison.json"),JSON.pretty_generate(comparison))
      evidence_path=File.join(dir,"evidence.json")
      _out,err,status=Open3.capture3(RbConfig.ruby,File.join(ROOT,"bin","routing-evidence"),dir,"--output",evidence_path,chdir:ROOT)
      assert status.success?, err
      archive_root=File.join(dir,"archive")
      out,err,status=Open3.capture3(RbConfig.ruby,File.join(ROOT,"bin","routing-archive"),evidence_path,"--destination",archive_root,chdir:ROOT)
      assert status.success?, "#{out}\n#{err}"
      manifests=Dir[File.join(archive_root,"**","ARCHIVE_MANIFEST.json")]
      assert_equal 1, manifests.length
      manifest=JSON.parse(File.read(manifests.first,encoding:"UTF-8"))
      assert_equal "skill-routing-evidence-archive-v1",manifest.fetch("archive")
      assert_equal 10,manifest.fetch("artifacts").length
      assert_equal true,manifest.fetch("gate").fetch("passed")
      assert File.file?(File.join(File.dirname(manifests.first),"evidence.json"))
      _out,err,status=Open3.capture3(RbConfig.ruby,File.join(ROOT,"bin","routing-archive"),evidence_path,"--destination",archive_root,chdir:ROOT)
      refute status.success?
      assert_includes err,"archive already exists"
    end
  end

  def test_archive_accepts_verified_single_campaign_evidence
    require "digest"
    require "yaml"

    Dir.mktmpdir("routing-campaign-archive") do |dir|
      campaign_path = File.join(dir, "campaign.json")
      report_path = File.join(dir, "routing-report.json")
      campaign = build_complete_campaign(dir)
      File.write(campaign_path, JSON.pretty_generate(campaign) + "\n", encoding: "UTF-8")

      out, err, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-analyze"),
        campaign_path,
        "--output", report_path,
        chdir: ROOT
      )
      assert status.success?, "#{out}\n#{err}"

      artifact_names = %w[
        campaign routing_report routing_contract skill_manifest campaign_manifest
        routing_cases result_schema campaign_intake_schema preflight
      ]
      artifacts = {}
      artifact_names.each do |name|
        path = case name
        when "campaign" then campaign_path
        when "routing_report" then report_path
        else
          path = File.join(dir, "#{name}.txt")
          File.write(path, name)
          path
        end
        artifacts[name] = {
          "path" => path,
          "sha256" => Digest::SHA256.file(path).hexdigest,
          "bytes" => File.size(path)
        }
      end

      42.times do |index|
        path = File.join(dir, "raw-#{index + 1}.json")
        File.write(path, "{}")
        artifacts["raw_case_#{index + 1}"] = {
          "path" => path,
          "sha256" => Digest::SHA256.file(path).hexdigest,
          "bytes" => File.size(path)
        }
      end

      report = JSON.parse(File.read(report_path, encoding: "UTF-8"))
      evidence = {
        "protocol_version" => 1,
        "evidence" => "skill-routing-campaign-v1",
        "campaign" => "skill-routing-public-v1",
        "campaign_version" => 1,
        "routing_case_count" => 14,
        "requested_repetitions" => 3,
        "requested_runs" => 42,
        "completed_runs" => 42,
        "repository" => {"git_sha" => "abc123", "worktree_clean" => true},
        "agent" => {"provider" => "ollama", "model" => "test-model"},
        "campaign_metrics" => campaign.fetch("metrics"),
        "analysis" => report.fetch("summary"),
        "artifacts" => artifacts,
        "intake" => {"verified" => true},
        "replay" => {"campaign_runner" => "bin/routing-campaign"}
      }
      evidence_path = File.join(dir, "evidence.json")
      File.write(evidence_path, JSON.pretty_generate(evidence))
      archive_root = File.join(dir, "archive")
      out, err, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-archive"),
        evidence_path,
        "--destination", archive_root,
        chdir: ROOT
      )
      assert status.success?, "#{out}\n#{err}"
      manifest_path = Dir[File.join(archive_root, "**", "ARCHIVE_MANIFEST.json")].first
      manifest = JSON.parse(File.read(manifest_path, encoding: "UTF-8"))
      assert_equal "skill-routing-campaign-v1", manifest.fetch("evidence_type")
      assert_equal true, manifest.fetch("intake").fetch("verified")
      assert_equal 42, manifest.fetch("completed_runs")
    end
  end

  private

  def build_complete_campaign(dir)
    cases = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_CASES.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    ).fetch("cases")
    campaign = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_CAMPAIGN.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )

    runs = {}
    cases.each do |entry|
      primary = entry.fetch("primary_skills").first
      case_runs = 3.times.map do |index|
        run_dir = File.join(dir, entry.fetch("id"), "run-#{index + 1}")
        FileUtils.mkdir_p(run_dir)
        raw_path = File.join(run_dir, "result.json")
        File.write(
          raw_path,
          JSON.pretty_generate(
            "primary_skill" => primary,
            "secondary_skills" => [],
            "reason" => "fixture"
          ) + "\n",
          encoding: "UTF-8"
        )
        {
          "run_number" => index + 1,
          "status" => "completed",
          "expected" => {"primary_skill" => primary, "secondary_skills" => [], "boundary" => entry.fetch("boundary")},
          "observed" => {"primary_skill" => primary, "secondary_skills" => [], "reason" => "fixture"},
          "scoring" => {"primary_accuracy" => true, "secondary_recall" => 1.0, "unexpected_secondary_count" => 0},
          "validation_errors" => [],
          "raw_result_file" => raw_path
        }
      end
      runs[entry.fetch("id")] = {
        "case_id" => entry.fetch("id"),
        "requested_repetitions" => 3,
        "completed_repetitions" => 3,
        "complete" => true,
        "expected_primary_skill" => primary,
        "runs" => case_runs
      }
    end

    {
      "protocol_version" => 1,
      "evaluation" => "skill-routing-v1",
      "campaign" => campaign.fetch("id"),
      "campaign_version" => campaign.fetch("version"),
      "routing_contract" => File.join(ROOT, "router", "ROUTING.md"),
      "agent" => {"provider" => "ollama", "model" => "fixture-model", "model_version" => "fixture-digest", "tool_mode" => "local-filesystem"},
      "routing_case_count" => cases.length,
      "requested_repetitions" => 3,
      "requested_runs" => 42,
      "completed_runs" => 42,
      "complete" => true,
      "execution" => {"checkpointed" => true, "mode" => "fixture"},
      "routing_inputs" => {},
      "metrics" => {"primary_accuracy" => 1.0, "secondary_recall" => 1.0, "average_unexpected_secondary_count" => 0.0},
      "confusion_matrix" => {},
      "cases" => runs
    }
  end

  def test_validator_executes_this_system_test
    validator=File.read(File.join(ROOT,"bin","validate"),encoding:"UTF-8")
    assert_includes validator,"test/routing_evidence_archive_system_test.rb"
  end
end
