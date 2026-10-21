# frozen_string_literal: true

require "json"
require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

module CodeReviewToolFixtures
  FINDING = {
    "id" => "F-001",
    "severity" => "P1",
    "classification" => "authorization",
    "file" => "app/controllers/orders_controller.rb",
    "line" => 18,
    "title" => "Order lookup is not tenant-scoped",
    "scenario" => "A user supplies another tenant's order ID.",
    "impact" => "Another tenant's order may be disclosed.",
    "violated_contract" => "Users access only orders owned by their tenant.",
    "evidence" => "Order.find(params[:id]) has no later policy check.",
    "action" => "Scope the lookup and add a cross-tenant request test.",
    "status" => "confirmed"
  }.freeze
  METADATA = {
    "scope" => "PR #123",
    "standards_assessment" => "One confirmed standards violation.",
    "specification_assessment" => "Acceptance criteria are met.",
    "remaining_uncertainty" => ["Production database was unavailable."],
    "commands_executed" => [{ "command" => "bundle exec rails test", "output" => "passed" }]
  }.freeze
end

class AiCodeReviewToolsSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  SCRIPTS = File.join(ROOT, "skills", "ai-code-review", "scripts")
  FINDING = CodeReviewToolFixtures::FINDING
  METADATA = CodeReviewToolFixtures::METADATA

  def setup
    @python = ENV.fetch("PYTHON", "python3")
    _out, _err, status = Open3.capture3(@python, "--version")
    skip "python3 is required for report tool tests" unless status.success?

    @tmpdir = Dir.mktmpdir("ai-review")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir) if @tmpdir && File.directory?(@tmpdir)
  end

  def write_json(name, value)
    path = File.join(@tmpdir, name)
    File.write(path, JSON.pretty_generate(value))
    path
  end

  def invoke(tool, *args)
    command = [@python, File.join(SCRIPTS, tool), *args]
    Open3.capture3(*command, chdir: ROOT)
  end

  def format_report(findings, metadata = METADATA)
    input = write_json("findings.json", findings)
    meta = write_json("metadata.json", metadata)
    output = File.join(@tmpdir, "report")
    stdout, stderr, status = invoke(
      "format_findings.py", input, "--output-dir", output, "--metadata", meta
    )
    raise "#{stdout}\n#{stderr}" unless status.success?

    output
  end

  def test_formatter_writes_findings_and_review_evidence
    output = format_report([FINDING])
    data = JSON.parse(File.read(File.join(output, "findings.json")))
    report = File.read(File.join(output, "report.md"))

    assert_equal ["F-001", true, true, true, true], [
      data.fetch("findings").first.fetch("id"),
      report.include?("Standards assessment"),
      report.include?("Specification assessment"),
      report.include?("Production database was unavailable."),
      report.include?("Order lookup is not tenant-scoped")
    ]
  end

  def test_formatter_rejects_duplicate_ids_and_invalid_values
    invalid = FINDING.merge("severity" => "P4", "status" => "unknown")
    input = write_json("findings.json", [FINDING, invalid])
    _out, err, status = invoke(
      "format_findings.py", input, "--output-dir", File.join(@tmpdir, "out")
    )

    assert_equal [false, true, true, true], [
      status.success?, err.include?("invalid severity"),
      err.include?("invalid status"), err.include?("duplicate id")
    ]
  end

  def test_audit_rejects_systemic_claim_with_fewer_than_three_instances
    item = FINDING.merge("zone" => "authorization", "systemic" => true, "instances" => %w[a b])
    input = write_json("audit.json", [item])
    _out, err, status = invoke(
      "audit_findings.py", input, "--output-dir", File.join(@tmpdir, "out")
    )

    assert_equal [false, true], [status.success?, err.include?("at least three concrete instances")]
  end

  def audit_report(item, zones)
    input = write_json("audit.json", [item])
    meta = write_json("metadata.json", { "zones_audited" => zones })
    output = File.join(@tmpdir, "audit")
    stdout, stderr, status = invoke(
      "audit_findings.py", input, "--output-dir", output, "--metadata", meta
    )
    raise "#{stdout}\n#{stderr}" unless status.success?

    File.read(File.join(output, "report.md"))
  end

  def test_audit_report_lists_risk_zones_and_instances
    item = FINDING.merge("zone" => "authorization", "systemic" => true, "instances" => %w[a b c])
    report = audit_report(item, %w[authorization persistence])

    assert_equal [true, true, true], [
      report.include?("Risk-zone coverage"),
      report.include?("authorization"),
      report.include?("Instances")
    ]
  end

  def test_helper_shell_scripts_have_valid_bash_syntax
    results = %w[git_context.sh repo_inventory.sh run_focused_tests.sh].map do |name|
      _out, err, status = Open3.capture3("bash", "-n", File.join(SCRIPTS, name))
      [status.success?, name, err]
    end

    assert_equal [true, true, true], results.map(&:first)
  end
end
