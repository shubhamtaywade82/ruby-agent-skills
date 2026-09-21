#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "tmpdir"
require_relative "../lib/ruby_agent_skills/eval_runner"

root = File.expand_path("..", __dir__)
runner = RubyAgentSkills::EvalRunner.new(root: root)

selection = runner.find("selection-sort")
abort "wrong evaluation" unless selection.fetch("category") == "ruby-training"
abort "missing cases" if selection.fetch("cases").empty?

Dir.mktmpdir("ruby-agent-eval-smoke-") do |dir|
  packet = File.join(dir, "packet.json")
  runner.write_packet("selection-sort", output: packet)
  parsed = JSON.parse(File.read(packet, encoding: "UTF-8"))
  abort "packet evaluation mismatch" unless parsed.fetch("evaluation") == "selection-sort"

  verifier = File.join(dir, "verifier.rb")
  File.write(verifier, <<~RUBY, encoding: "UTF-8")
    require "json"
    require "yaml"
    evaluation = YAML.safe_load(File.read(ENV.fetch("RUBY_AGENT_EVAL_FILE")), permitted_classes: [], aliases: false)
    checks = evaluation.fetch("checks").to_h { |name| [name, "pass"] }
    File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.generate("checks" => checks))
  RUBY

  result = runner.run(
    id: "selection-sort",
    workspace: root,
    agent_command: "ruby -e 'exit 0'",
    verify_command: "ruby #{verifier}",
    output: File.join(dir, "result.json"),
    timeout: 30
  )

  abort JSON.pretty_generate(result) unless result.fetch("overall") == "passed"
  abort "git evidence missing" unless result.fetch("patch").fetch("git_repository")
end

puts "Evaluation runner smoke test passed."
