#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "shellwords"
require "tmpdir"

root = File.expand_path("..", __dir__)

agent_script = <<~'RUBY'
  require "fileutils"

  case ENV.fetch("RUBY_AGENT_EVAL_ID")
  when "enumerable-transform"
    File.write("lib/solution.rb", <<~'CODE')
      class Catalog
        def available_names(products)
          products.select { |product| product[:available] }
                  .map { |product| product[:name] }
        end
      end
    CODE
    File.write("test/catalog_test.rb", "Catalog test coverage
")
  when "method-contract"
    File.write("lib/solution.rb", <<~'CODE')
      class NotificationFormatter
        def format(recipient:, channel:)
          channel = channel.to_sym
          raise ArgumentError unless %i[email sms].include?(channel)
          "#{channel}: #{recipient}"
        end
      end
    CODE
    File.write("test/notification_formatter_test.rb", "NotificationFormatter test coverage
")
  else
    abort "unsupported smoke evaluation"
  end
RUBY

command = "ruby -e #{Shellwords.escape(agent_script)}"

Dir.mktmpdir("ruby-workshop-smoke-") do |dir|
  %w[enumerable-transform method-contract].each do |evaluation|
    args = [
      "ruby", File.join(root, "bin", "benchmark"), "campaign",
      "--manifest", File.join(root, "benchmarks/ruby-workshop/campaign.yml"),
      "--agent-command", command,
      "--evaluation", evaluation,
      "--runs", "1",
      "--output", File.join(dir, evaluation)
    ]
    abort "campaign failed for #{evaluation}" unless system(*args)

    campaign = File.join(dir, evaluation, "campaign.json")
    abort "missing campaign output for #{evaluation}" unless File.file?(campaign)

    result = JSON.parse(File.read(campaign, encoding: "UTF-8"))
    entry = result.fetch("evaluations").fetch(evaluation)
    abort "missing baseline result for #{evaluation}" if entry.fetch("baseline_results").empty?
    abort "missing skills result for #{evaluation}" if entry.fetch("skills_results").empty?

    baseline = JSON.parse(File.read(entry.fetch("baseline_results").first, encoding: "UTF-8"))
    skills = JSON.parse(File.read(entry.fetch("skills_results").first, encoding: "UTF-8"))
    abort "baseline was not isolated" if baseline.dig("configuration", "skills_enabled")
    abort "skills run was not enabled" unless skills.dig("configuration", "skills_enabled")
  end
end

puts "Ruby workshop benchmark campaign smoke test passed."
