# frozen_string_literal: true

require "minitest/autorun"

class RoutingCampaignFinalizationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def source(path)
    File.read(File.join(ROOT, path), encoding: "UTF-8")
  end

  def test_import_runs_analysis_before_packaging_evidence
    script = source("bin/routing-campaign-import")
    assert_includes script, 'ANALYZER = File.join(ROOT, "bin", "routing-analyze")'
    assert_includes script, 'report_path = File.join(campaign_dir, "routing-report.json")'
    assert_includes script, "routing-analyze"
    assert_operator script.index("ANALYZER"), :<, script.index("EVIDENCE_PACKAGER")
  end

  def test_import_verifies_analysis_report_after_generation
    script = source("bin/routing-campaign-import")
    assert_includes script, "routing analysis generation failed"
    assert_includes script, "routing-report.json"
    assert_includes script, "EVIDENCE_VERIFIER"
  end

  def test_handoff_runner_finalizes_campaign_without_manual_follow_up
    script = source("bin/routing-campaign-handoff")
    assert_includes script, "routing-campaign-import"
    assert_includes script, "--archive"
    assert_includes script, "campaign-evidence.json"
  end
end
