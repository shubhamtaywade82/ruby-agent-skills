#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "shellwords"
require_relative "../lib/ruby_agent_skills/eval_runner"

root = File.expand_path("..", __dir__)
runner = RubyAgentSkills::EvalRunner.new(root: root)
fixture = File.join(root, "benchmarks/ruby-training/fixtures/selection-sort")
verifier = "ruby #{Shellwords.escape(File.join(root, "scripts/verify_training_eval.rb"))}"

agent_script = <<~RUBY
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

agent_command = "ruby -e #{Shellwords.escape(agent_script)}"
result = runner.run(
  id: "selection-sort",
  workspace: fixture,
  agent_command: agent_command,
  verify_command: verifier,
  timeout: 30
)

unless result.fetch("overall") == "passed"
  warn JSON.pretty_generate(result)
  abort "benchmark smoke failed: #{result.fetch("overall")}"
end

puts "Benchmark runner + verifier smoke test passed."
