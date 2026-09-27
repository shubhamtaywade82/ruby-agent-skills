#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require_relative "../lib/ruby_agent_skills/agent_adapter"

command = ENV["RUBY_AGENT_COMMAND"].to_s
abort "RUBY_AGENT_COMMAND is required" if command.empty?

workspace = ENV["RUBY_AGENT_WORKSPACE"].to_s
abort "RUBY_AGENT_WORKSPACE is required" if workspace.empty? || !Dir.exist?(workspace)

metadata_file = ENV["RUBY_AGENT_METADATA_FILE"].to_s
context_file = ENV["RUBY_AGENT_CONTEXT_FILE"].to_s

abort "RUBY_AGENT_CONTEXT_FILE is required" if context_file.empty? || !File.file?(context_file)

started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
success = system(command, chdir: workspace)
status = $?

if metadata_file && !metadata_file.empty?
  RubyAgentSkills::AgentAdapter.write_metadata(
    metadata_file,
    "command_adapter" => {
      "command_fingerprint" => Digest::SHA256.hexdigest(command),
      "context_file_present" => File.file?(context_file),
      "skills_enabled" => ENV.fetch("RUBY_AGENT_SKILLS_ENABLED", "false") == "true"
    },
    "duration_seconds" => (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).round(3)
  )
end

exit(success && status ? status.exitstatus.to_i : 1)
