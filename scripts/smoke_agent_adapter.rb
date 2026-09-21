#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "shellwords"
require "tmpdir"

root = File.expand_path("..", __dir__)

agent_script = <<~RUBY
  require "json"
  enabled = ENV.fetch("RUBY_AGENT_SKILLS_ENABLED") == "true"
  context = File.read(ENV.fetch("RUBY_AGENT_CONTEXT_FILE"), encoding: "UTF-8")
  abort "context missing" unless context.include?("Implement selection sort")

  if enabled
    manifest = JSON.parse(File.read(ENV.fetch("RUBY_AGENT_SKILL_MANIFEST"), encoding: "UTF-8"))
    abort "skills missing" if manifest.fetch("skills").empty?
  end

  File.write(
    "lib/solution.rb",
    <<~CODE
      class SelectionSorter
        def sort(values)
          values.sort
        end
      end
    CODE
  )

  FileUtils.mkdir_p("test") if defined?(FileUtils)
RUBY

command = "ruby -e #{Shellwords.escape(agent_script)}"
output = Dir.mktmpdir("ruby-agent-adapter-smoke-")
cmd = [
  "ruby", File.join(root, "bin", "agent-benchmark"),
  "--command", command,
  "--provider", "fake",
  "--model", "fake-model",
  "--model-version", "1",
  "--tool-mode", "filesystem",
  "--evaluation", "selection-sort",
  "--runs", "1",
  "--output", output
]

abort "agent-benchmark smoke command failed" unless system(*cmd)

campaign_path = File.join(output, "campaign.json")
abort "campaign result missing" unless File.file?(campaign_path)

campaign = JSON.parse(File.read(campaign_path, encoding: "UTF-8"))
eval_result = campaign.fetch("evaluations").fetch("selection-sort")
baseline = JSON.parse(File.read(eval_result.fetch("baseline_results").first, encoding: "UTF-8"))
skills = JSON.parse(File.read(eval_result.fetch("skills_results").first, encoding: "UTF-8"))

abort "baseline metadata missing" unless baseline.dig("agent", "metadata", "provider") == "fake"
abort "skills metadata missing" unless skills.dig("agent", "metadata", "model") == "fake-model"
abort "baseline unexpectedly enabled skills" if baseline.dig("configuration", "skills_enabled")
abort "skills run did not enable skills" unless skills.dig("configuration", "skills_enabled")

puts "Command agent adapter smoke test passed."
