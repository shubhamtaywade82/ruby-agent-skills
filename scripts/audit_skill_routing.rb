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
