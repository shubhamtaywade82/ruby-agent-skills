#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "shellwords"
require "tmpdir"
require_relative "../lib/ruby_agent_skills/eval_runner"

root = File.expand_path("..", __dir__)
runner = RubyAgentSkills::EvalRunner.new(root: root)
fixture = File.join(root, "benchmarks/ruby-training/fixtures/selection-sort")
verifier = "ruby #{Shellwords.escape(File.join(root, "scripts/verify_training_eval.rb"))}"

agent_script = <<~RUBY
  require "fileutils"
  require "json"

  actual_enabled = ENV.fetch("RUBY_AGENT_SKILLS_ENABLED") == "true"

  context = File.read(ENV.fetch("RUBY_AGENT_CONTEXT_FILE"), encoding: "UTF-8")
  abort "task context missing" unless context.include?("Implement selection sort")
  if actual_enabled
    manifest = JSON.parse(File.read(ENV.fetch("RUBY_AGENT_SKILL_MANIFEST"), encoding: "UTF-8"))
    abort "skill pack empty" if manifest.fetch("skills").empty?
    abort "skill context missing ruby-oop" unless context.include?("ruby-oop")
  end

  File.write("lib/solution.rb", <<~'CODE')
    # frozen_string_literal: true

    class SelectionSorter
      def sort(values)
        values.length.times do |index|
          minimum = index
          ((index + 1)...values.length).each do |candidate|
            minimum = candidate if values[candidate] < values[minimum]
          end
          values[index], values[minimum] = values[minimum], values[index]
        end
        values
      end

      def recursive_sort(values, start_index = 0)
        return values if start_index >= values.length - 1

        minimum = start_index
        ((start_index + 1)...values.length).each do |candidate|
          minimum = candidate if values[candidate] < values[minimum]
        end
        values[start_index], values[minimum] = values[minimum], values[start_index]
        recursive_sort(values, start_index + 1)
      end
    end
  CODE

  FileUtils.mkdir_p("test")
  File.write("test/selection_sort_test.rb", "SelectionSorter smoke coverage\n")
RUBY

run_case = lambda do |skills_enabled|
  command = "ruby -e #{Shellwords.escape(agent_script)}"
  runner.run(
    id: "selection-sort",
    workspace: fixture,
    agent_command: command,
    verify_command: verifier,
    timeout: 30,
    skills_enabled: skills_enabled
  )
end

baseline = run_case.call(false)
skills = run_case.call(true)

[baseline, skills].each do |result|
  next if result.fetch("overall") == "passed"

  warn JSON.pretty_generate(result)
  abort "benchmark smoke failed: #{result.fetch("overall")}"
end

abort "baseline did not disable skills" if baseline.fetch("configuration").fetch("skills_enabled")
abort "skills run did not enable skills" unless skills.fetch("configuration").fetch("skills_enabled")
abort "skills were not materialized" if skills.fetch("agent").fetch("exit_code") != 0

Dir.mktmpdir("ruby-agent-campaign-smoke-") do |dir|
  campaign_command = [
    "ruby", File.join(root, "bin", "benchmark"), "campaign",
    "--agent-command", agent_command,
    "--evaluation", "selection-sort",
    "--runs", "1",
    "--output", dir
  ]
  abort "campaign command failed" unless system(*campaign_command)
  campaign_path = File.join(dir, "campaign.json")
  abort "campaign result missing" unless File.file?(campaign_path)
  campaign = JSON.parse(File.read(campaign_path, encoding: "UTF-8"))
  evaluation = campaign.fetch("evaluations").fetch("selection-sort")
  abort "campaign baseline result missing" if evaluation.fetch("baseline_results").empty?
  abort "campaign skills result missing" if evaluation.fetch("skills_results").empty?
end

puts "Benchmark runner + skill isolation + verifier smoke test passed."
