# frozen_string_literal: true

require "optparse"
require_relative "../lib/ruby_agent_skills/framework_drift_audit"

root = File.expand_path("..", __dir__)
options = {
  root: root,
  registry: File.join(root, "framework-drift.yml")
}

OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/audit_framework_drift.rb [--root PATH] [--registry PATH]"
  opts.on("--root PATH", "Repository root to scan") do |value|
    options[:root] = File.expand_path(value)
  end
  opts.on("--registry PATH", "Framework drift registry") do |value|
    options[:registry] = File.expand_path(value)
  end
end.parse!

abort "missing registry: #{options[:registry]}" unless File.file?(options[:registry])

RubyAgentSkills::FrameworkDriftAudit.new(
  root: options[:root],
  registry_path: options[:registry]
).call
