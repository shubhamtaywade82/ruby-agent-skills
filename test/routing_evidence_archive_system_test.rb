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
    Dir.mktmpdir("routing-campaign-archive") do |dir|
      artifact_names = %w[
        campaign routing_report routing_contract skill_manifest campaign_manifest
        routing_cases result_schema campaign_intake_schema preflight
      ]
      artifacts = {}
      artifact_names.each do |name|
        path = File.join(dir, "#{name}.txt")
        File.write(path, name)
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
        "campaign_metrics" => {"primary_accuracy" => 1.0},
        "analysis" => {"primary_mismatch_count" => 0},
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

  def test_validator_executes_this_system_test
    validator=File.read(File.join(ROOT,"bin","validate"),encoding:"UTF-8")
    assert_includes validator,"test/routing_evidence_archive_system_test.rb"
  end
end
