#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require "yaml"

ROOT = File.expand_path("..", __dir__)
BENCHMARK_ROOT = File.join(ROOT, "benchmarks")
EVAL_ROOT = File.join(ROOT, "evals")

errors = []
warnings = []
campaign_ids = Set.new

campaign_files = Dir[File.join(BENCHMARK_ROOT, "*", "campaign.yml")].sort
abort "no benchmark campaigns found" if campaign_files.empty?

campaign_files.each do |campaign_path|
  family = File.basename(File.dirname(campaign_path))
  relative_campaign = campaign_path.delete_prefix(ROOT + "/")

  begin
    campaign = YAML.safe_load(
      File.read(campaign_path, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
  rescue Psych::Exception => e
    errors << "#{relative_campaign}: invalid YAML: #{e.message}"
    next
  end

  required = %w[id version evaluation_set source fixture_root verifier evaluations execution controls]
  required.each { |key| errors << "#{relative_campaign}: missing #{key}" unless campaign.key?(key) }

  id = campaign["id"].to_s
  if id.empty?
    errors << "#{relative_campaign}: empty campaign id"
  elsif !campaign_ids.add?(id)
    errors << "#{relative_campaign}: duplicate campaign id #{id}"
  end

  errors << "#{relative_campaign}: evaluation_set #{campaign["evaluation_set"].inspect} != #{family.inspect}" unless campaign["evaluation_set"].to_s == family

  execution = campaign["execution"].is_a?(Hash) ? campaign["execution"] : {}
  controls = campaign["controls"].is_a?(Hash) ? campaign["controls"] : {}
  errors << "#{relative_campaign}: repetitions must be >= 3" unless execution.fetch("repetitions", 0).to_i >= 3
  %w[paired fresh_workspace_per_run same_fixture_for_pair require_same_agent_command_when_using_agent_command].each do |key|
    errors << "#{relative_campaign}: execution.#{key} must be true" unless execution[key] == true
  end
  errors << "#{relative_campaign}: controls.hidden_cases must be external-only" unless controls["hidden_cases"].to_s == "external-only"

  fixture_registry = File.join(ROOT, "benchmarks", family, "fixtures.yml")
  errors << "#{relative_campaign}: missing fixture registry #{fixture_registry.delete_prefix(ROOT + "/")}" unless File.file?(fixture_registry)
  unless File.file?(fixture_registry)
    next
  end

  registry = YAML.safe_load(
    File.read(fixture_registry, encoding: "UTF-8"),
    permitted_classes: [],
    aliases: false
  )
  fixtures = registry.fetch("fixtures", {})
  campaign_evals = Array(campaign["evaluations"]).map(&:to_s)
  errors << "#{relative_campaign}: campaign evaluations must be unique" unless campaign_evals.uniq.length == campaign_evals.length
  errors << "#{relative_campaign}: fixture ids do not match campaign evaluations" unless fixtures.keys.map(&:to_s).to_set == campaign_evals.to_set

  verifier = File.join(ROOT, campaign["verifier"].to_s)
  errors << "#{relative_campaign}: missing verifier #{campaign["verifier"]}" unless File.file?(verifier)

  fixtures.each do |eval_id, fixture|
    unless fixture.is_a?(Hash)
      errors << "#{relative_campaign}: fixture #{eval_id} must be a mapping"
      next
    end

    root = fixture["root"].to_s
    root = File.join(BENCHMARK_ROOT, family, "fixtures", eval_id) if root.empty?
    fixture_root = File.expand_path(root, ROOT)
    errors << "#{relative_campaign}: fixture #{eval_id} missing root #{root}" unless Dir.exist?(fixture_root)

    implementation_files = Array(fixture["implementation_files"])
    implementation_files = [fixture["implementation_file"]] if implementation_files.empty? && fixture["implementation_file"]
    errors << "#{relative_campaign}: fixture #{eval_id} has no implementation seam" if implementation_files.empty?

    implementation_files.each do |relative|
      errors << "#{relative_campaign}: fixture #{eval_id} missing implementation file #{relative}" unless File.file?(File.join(fixture_root, relative.to_s))
    end

    Array(fixture["test_files"]).concat(Array(fixture["test_file"])).each do |relative|
      errors << "#{relative_campaign}: fixture #{eval_id} missing test file #{relative}" unless File.file?(File.join(fixture_root, relative.to_s))
    end

    all_eval_paths = Dir[File.join(EVAL_ROOT, "**", "*.yml")].sort
    eval_path = all_eval_paths.find do |path|
      YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false).fetch("id").to_s == eval_id.to_s
    end

    errors << "#{relative_campaign}: fixture #{eval_id} has no matching public evaluation" unless eval_path

    if eval_path
      evaluation = YAML.safe_load(File.read(eval_path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
      errors << "#{relative_campaign}: evaluation #{eval_id} source is empty" if evaluation["source"].to_s.empty?
    end
  end
end

all_public_eval_paths = Dir[File.join(EVAL_ROOT, "**", "*.yml")].sort
benchmarked_eval_ids = campaign_files.flat_map do |campaign_path|
  data = YAML.safe_load(File.read(campaign_path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
  Array(data["evaluations"]).map(&:to_s)
end.to_set

unbenchmarked_paths = all_public_eval_paths.reject do |path|
  id = YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false).fetch("id").to_s
  benchmarked_eval_ids.include?(id)
end

rails_eval_paths = Dir[File.join(EVAL_ROOT, "rails", "*.yml")].sort
rails_eval_ids = rails_eval_paths.map do |path|
  YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false).fetch("id").to_s
end.to_set
rails_campaign = campaign_files.find { |path| File.basename(File.dirname(path)) == "rails" }
rails_campaign_data = rails_campaign ? YAML.safe_load(File.read(rails_campaign, encoding: "UTF-8"), permitted_classes: [], aliases: false) : {}
rails_benchmarked_ids = Set.new(Array(rails_campaign_data["evaluations"]).map(&:to_s))
rails_unbenchmarked_ids = rails_eval_ids - rails_benchmarked_ids

if rails_campaign_data.dig("controls", "require_all_public_evaluations") == true && !rails_unbenchmarked_ids.empty?
  errors << "rails campaign does not cover all public Rails evaluations: #{rails_unbenchmarked_ids.to_a.sort.join(", ")}"
end

unless unbenchmarked_paths.empty?
  unbenchmarked_cases = unbenchmarked_paths.sum do |path|
    data = YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
    Array(data["cases"]).length
  end
  warnings << "public evaluations without a benchmark campaign: #{unbenchmarked_paths.length} files (#{unbenchmarked_cases} cases)"
end
puts "Benchmark quality audit"
puts "  campaigns: #{campaign_files.length}"
puts "  campaign evaluations: #{campaign_files.sum { |path| YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false).fetch("evaluations").length }}"
puts "  unbenchmarked evaluations: #{unbenchmarked_paths.length}"
warnings.each { |warning| puts "WARN: #{warning}" }

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} benchmark quality error(s)"
end

puts "Benchmark quality audit passed."
