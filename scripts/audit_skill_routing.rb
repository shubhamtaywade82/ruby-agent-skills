#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require "yaml"

ROOT = File.expand_path("..", __dir__)
MANIFEST_PATH = File.join(ROOT, "skill-manifest.yml")
ROUTING_PATH = File.join(ROOT, "router", "ROUTING.md")
CASES_PATH = File.join(ROOT, "router", "ROUTING_CASES.yml")

abort "missing skill-manifest.yml" unless File.file?(MANIFEST_PATH)
abort "missing router/ROUTING.md" unless File.file?(ROUTING_PATH)
abort "missing router/ROUTING_CASES.yml" unless File.file?(CASES_PATH)

manifest = YAML.safe_load(
  File.read(MANIFEST_PATH, encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
routing = File.read(ROUTING_PATH, encoding: "UTF-8")
cases = YAML.safe_load(
  File.read(CASES_PATH, encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)

skills = manifest.fetch("skills").keys.to_set
entries = Array(cases.fetch("cases"))
errors = []

errors << "routing cases must not be empty" if entries.empty?
ids = Set.new

entries.each_with_index do |entry, index|
  prefix = "case #{index}"

  unless entry.is_a?(Hash)
    errors << "#{prefix}: must be a mapping"
    next
  end

  id = entry["id"].to_s
  errors << "#{prefix}: id must be kebab-case" unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  errors << "#{prefix}: duplicate id #{id}" unless ids.add?(id)
  errors << "#{id}: prompt must not be empty" if entry["prompt"].to_s.strip.empty?

  primary = Array(entry["primary_skills"]).map(&:to_s)
  secondary = Array(entry["secondary_skills"]).map(&:to_s)

  errors << "#{id}: primary_skills must not be empty" if primary.empty?
  overlap = primary & secondary
  errors << "#{id}: primary/secondary skill overlap: #{overlap.join(", ")}" unless overlap.empty?

  (primary + secondary).uniq.each do |skill|
    errors << "#{id}: unknown skill #{skill}" unless skills.include?(skill)
  end

  errors << "#{id}: boundary must not be empty" if entry["boundary"].to_s.strip.empty?
end

required_boundaries = %w[
  authentication-vs-authorization
  authorization-vs-persistence
  authorization-vs-background-execution
  realtime-vs-authorization
  api-vs-security
  api-vs-controller
  validation-vs-database
  performance-vs-persistence
  loading-vs-runtime
  routing-vs-controller
  initialization-vs-runtime
  caching-vs-authorization
  engine-vs-host-routing
  encryption-vs-operations
]
covered_boundaries = entries.map { |entry| entry["boundary"].to_s }.to_set
missing_boundaries = required_boundaries.reject { |boundary| covered_boundaries.include?(boundary) }
errors << "routing boundary coverage missing: #{missing_boundaries.join(", ")}" unless missing_boundaries.empty?

routing_contract = manifest.fetch("routing", {})
errors << "manifest routing contract path missing" unless routing_contract["contract"].to_s == "router/ROUTING.md"
errors << "manifest routing cases path missing" unless routing_contract["cases"].to_s == "router/ROUTING_CASES.yml"
errors << "manifest routing audit path missing" unless routing_contract["audit"].to_s == "scripts/audit_skill_routing.rb"
errors << "manifest routing result schema path missing" unless routing_contract["result_schema"].to_s == "docs/ROUTING_EVAL_RESULT_SCHEMA.md"
errors << "manifest routing evaluation runner path missing" unless routing_contract["evaluation_runner"].to_s == "bin/routing-eval"
errors << "manifest routing campaign manifest path missing" unless routing_contract["campaign_manifest"].to_s == "router/ROUTING_CAMPAIGN.yml"
errors << "manifest Ollama adapter path missing" unless routing_contract["ollama_adapter"].to_s == "bin/routing-agent-ollama"

ollama_adapter_path = File.join(ROOT, routing_contract.fetch("ollama_adapter", ""))
errors << "routing Ollama adapter missing" unless File.file?(ollama_adapter_path)
errors << "manifest campaign runner path missing" unless routing_contract["campaign_runner"].to_s == "bin/routing-campaign"
errors << "manifest campaign analyzer path missing" unless routing_contract["campaign_analyzer"].to_s == "bin/routing-analyze"

campaign_runner_path = File.join(ROOT, routing_contract.fetch("campaign_runner", ""))
campaign_analyzer_path = File.join(ROOT, routing_contract.fetch("campaign_analyzer", ""))
errors << "routing campaign runner missing" unless File.file?(campaign_runner_path)
errors << "routing campaign analyzer missing" unless File.file?(campaign_analyzer_path)
errors << "manifest remediation policy path missing" unless routing_contract["remediation_policy"].to_s == "router/ROUTING_REMEDIATION.yml"
errors << "manifest remediation comparator path missing" unless routing_contract["remediation_comparator"].to_s == "bin/routing-compare"

remediation_policy_path = File.join(ROOT, routing_contract.fetch("remediation_policy", ""))
remediation_comparator_path = File.join(ROOT, routing_contract.fetch("remediation_comparator", ""))
errors << "routing remediation policy missing" unless File.file?(remediation_policy_path)
errors << "routing remediation comparator missing" unless File.file?(remediation_comparator_path)
errors << "manifest experiment runner path missing" unless routing_contract["experiment_runner"].to_s == "bin/routing-experiment"
experiment_runner_path = File.join(ROOT, routing_contract.fetch("experiment_runner", ""))
errors << "routing experiment runner missing" unless File.file?(experiment_runner_path)
errors << "manifest evidence packager path missing" unless routing_contract["evidence_packager"].to_s == "bin/routing-evidence"
evidence_packager_path = File.join(ROOT, routing_contract.fetch("evidence_packager", ""))
errors << "routing evidence packager missing" unless File.file?(evidence_packager_path)
errors << "manifest evidence verifier path missing" unless routing_contract["evidence_verifier"].to_s == "bin/routing-evidence-verify"
evidence_verifier_path = File.join(ROOT, routing_contract.fetch("evidence_verifier", ""))
errors << "routing evidence verifier missing" unless File.file?(evidence_verifier_path)
errors << "manifest evidence archiver path missing" unless routing_contract["evidence_archiver"].to_s == "bin/routing-archive"
evidence_archiver_path = File.join(ROOT, routing_contract.fetch("evidence_archiver", ""))
errors << "routing evidence archiver missing" unless File.file?(evidence_archiver_path)
errors << "manifest evidence archive schema path missing" unless routing_contract["evidence_archive_schema"].to_s == "docs/ROUTING_EVIDENCE_ARCHIVE_SCHEMA.md"
evidence_archive_schema_path = File.join(ROOT, routing_contract.fetch("evidence_archive_schema", ""))
errors << "routing evidence archive schema missing" unless File.file?(evidence_archive_schema_path)
errors << "manifest campaign verifier path missing" unless routing_contract["campaign_verifier"].to_s == "bin/routing-campaign-verify"
campaign_verifier_path = File.join(ROOT, routing_contract.fetch("campaign_verifier", ""))
errors << "routing campaign verifier missing" unless File.file?(campaign_verifier_path)
errors << "manifest campaign intake schema path missing" unless routing_contract["campaign_intake_schema"].to_s == "docs/ROUTING_CAMPAIGN_INTAKE_SCHEMA.md"
campaign_intake_schema_path = File.join(ROOT, routing_contract.fetch("campaign_intake_schema", ""))
errors << "routing campaign intake schema missing" unless File.file?(campaign_intake_schema_path)
errors << "manifest campaign evidence packager path missing" unless routing_contract["campaign_evidence_packager"].to_s == "bin/routing-campaign-evidence"
campaign_evidence_packager_path = File.join(ROOT, routing_contract.fetch("campaign_evidence_packager", ""))
errors << "routing campaign evidence packager missing" unless File.file?(campaign_evidence_packager_path)
errors << "manifest campaign evidence schema path missing" unless routing_contract["campaign_evidence_schema"].to_s == "docs/ROUTING_CAMPAIGN_EVIDENCE_SCHEMA.md"
campaign_evidence_schema_path = File.join(ROOT, routing_contract.fetch("campaign_evidence_schema", ""))
errors << "routing campaign evidence schema missing" unless File.file?(campaign_evidence_schema_path)
errors << "manifest campaign evidence verifier path missing" unless routing_contract["campaign_evidence_verifier"].to_s == "bin/routing-campaign-evidence-verify"
campaign_evidence_verifier_path = File.join(ROOT, routing_contract.fetch("campaign_evidence_verifier", ""))
errors << "routing campaign evidence verifier missing" unless File.file?(campaign_evidence_verifier_path)
errors << "manifest campaign evidence verification schema path missing" unless routing_contract["campaign_evidence_verification_schema"].to_s == "docs/ROUTING_CAMPAIGN_EVIDENCE_VERIFICATION_SCHEMA.md"
campaign_evidence_verification_schema_path = File.join(ROOT, routing_contract.fetch("campaign_evidence_verification_schema", ""))
errors << "routing campaign evidence verification schema missing" unless File.file?(campaign_evidence_verification_schema_path)
errors << "manifest campaign preflight path missing" unless routing_contract["campaign_preflight"].to_s == "bin/routing-campaign-preflight"
campaign_preflight_path = File.join(ROOT, routing_contract.fetch("campaign_preflight", ""))
errors << "routing campaign preflight missing" unless File.file?(campaign_preflight_path)
errors << "manifest campaign preflight schema path missing" unless routing_contract["campaign_preflight_schema"].to_s == "docs/ROUTING_CAMPAIGN_PREFLIGHT_SCHEMA.md"
campaign_preflight_schema_path = File.join(ROOT, routing_contract.fetch("campaign_preflight_schema", ""))
errors << "routing campaign preflight schema missing" unless File.file?(campaign_preflight_schema_path)
errors << "manifest external handoff path missing" unless routing_contract["external_handoff"].to_s == "bin/routing-campaign-handoff"
external_handoff_path = File.join(ROOT, routing_contract.fetch("external_handoff", ""))
errors << "routing external handoff missing" unless File.file?(external_handoff_path)
errors << "manifest external handoff schema path missing" unless routing_contract["external_handoff_schema"].to_s == "docs/ROUTING_EXTERNAL_CAMPAIGN_SCHEMA.md"
external_handoff_schema_path = File.join(ROOT, routing_contract.fetch("external_handoff_schema", ""))
errors << "routing external handoff schema missing" unless File.file?(external_handoff_schema_path)
errors << "manifest hidden benchmark contract path missing" unless routing_contract["hidden_benchmark_contract"].to_s == "router/ROUTING_HIDDEN_BENCHMARK.yml"
hidden_benchmark_path = File.join(ROOT, routing_contract.fetch("hidden_benchmark_contract", ""))
errors << "hidden benchmark contract missing" unless File.file?(hidden_benchmark_path)
hidden_benchmark = YAML.safe_load(File.read(hidden_benchmark_path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
errors << "hidden benchmark must be external-only" unless hidden_benchmark["source"] == "external-only"
errors << "hidden benchmark gold labels must remain external-only" unless hidden_benchmark.fetch("cases", {})["gold_labels"] == "external-only"
errors << "hidden benchmark repository storage must be forbidden" unless hidden_benchmark.fetch("cases", {})["repository_storage"] == "forbidden"
errors << "manifest model matrix path missing" unless routing_contract["model_matrix_contract"].to_s == "router/ROUTING_MODEL_MATRIX.yml"
model_matrix_path = File.join(ROOT, routing_contract.fetch("model_matrix_contract", ""))
errors << "routing model matrix contract missing" unless File.file?(model_matrix_path)
errors << "manifest model matrix schema path missing" unless routing_contract["model_matrix_schema"].to_s == "docs/ROUTING_MODEL_MATRIX_SCHEMA.md"
model_matrix_schema_path = File.join(ROOT, routing_contract.fetch("model_matrix_schema", ""))
errors << "routing model matrix schema missing" unless File.file?(model_matrix_schema_path)
model_matrix = YAML.safe_load(File.read(model_matrix_path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
errors << "model matrix must use explicit runtime configuration" unless model_matrix["source"] == "explicit-runtime-configuration"
errors << "model matrix comparison must be descriptive-only" unless model_matrix.fetch("controls", {})["descriptive_comparison_only"] == true
errors << "model matrix must reject unexecuted comparisons" unless model_matrix.fetch("controls", {})["do_not_compare_unexecuted_models"] == true
errors << "manifest campaign preflight verifier path missing" unless routing_contract["campaign_preflight_verifier"].to_s == "bin/routing-campaign-preflight-verify"
campaign_preflight_verifier_path = File.join(ROOT, routing_contract.fetch("campaign_preflight_verifier", ""))
errors << "routing campaign preflight verifier missing" unless File.file?(campaign_preflight_verifier_path)
errors << "manifest campaign intake v2 path missing" unless routing_contract["campaign_intake_v2"].to_s == "bin/routing-campaign-import"
campaign_intake_v2_path = File.join(ROOT, routing_contract.fetch("campaign_intake_v2", ""))
errors << "routing campaign intake v2 missing" unless File.file?(campaign_intake_v2_path)
errors << "manifest campaign intake v2 schema path missing" unless routing_contract["campaign_intake_v2_schema"].to_s == "docs/ROUTING_CAMPAIGN_INTAKE_V2.md"
campaign_intake_v2_schema_path = File.join(ROOT, routing_contract.fetch("campaign_intake_v2_schema", ""))
errors << "routing campaign intake v2 schema missing" unless File.file?(campaign_intake_v2_schema_path)
errors << "manifest evidence schema path missing" unless routing_contract["evidence_schema"].to_s == "docs/ROUTING_EVIDENCE_SCHEMA.md"
evidence_schema_path = File.join(ROOT, routing_contract.fetch("evidence_schema", ""))
errors << "routing evidence schema missing" unless File.file?(evidence_schema_path)

campaign_path = File.join(ROOT, routing_contract.fetch("campaign_manifest", ""))
if File.file?(campaign_path)
  campaign = YAML.safe_load(File.read(campaign_path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
  errors << "routing campaign id missing" if campaign["id"].to_s.empty?
  repetitions = campaign.fetch("execution", {}).fetch("repetitions", 0).to_i
  errors << "routing campaign repetitions must be >= 1" unless repetitions >= 1
  campaign_case_file = File.join(ROOT, campaign.fetch("cases_file", ""))
  errors << "routing campaign cases_file missing" unless campaign_case_file == CASES_PATH
else
  errors << "routing campaign manifest missing #{routing_contract["campaign_manifest"]}"
end

required_router_sections = [
  "Routing quality contract",
  "Primary skill",
  "Secondary skill",
  "routing case",
  "authentication and authorization",
  "cross-boundary"
]
required_router_sections.each do |term|
  errors << "router/ROUTING.md missing routing-quality term #{term.inspect}" unless routing.downcase.include?(term.downcase)
end

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} routing audit error(s)"
end

puts "Skill routing quality audit"
puts "  cases: #{entries.length}"
puts "  covered boundaries: #{covered_boundaries.length}"
puts "  registered skills available: #{skills.length}"
puts "Skill routing quality audit passed."
