#!/usr/bin/env ruby
# frozen_string_literal: true

# Provider-neutral replay adapter for the agent adapter protocol
# (docs/AGENT_ADAPTER_PROTOCOL.md). Instead of invoking a live coding
# agent, it materializes a RECORDED agent session: the exact files a real
# model wrote while responding to the same materialized task context.
# The recording is captured out of band (the model never receives the
# benchmark repository root, the verifiers, or the pristine references),
# and this adapter replays it inside the disposable benchmark workspace
# so the campaign runner can grade it through the real verifier.
#
# The adapter refuses to replay a recording against a different task:
# it verifies the prompt digest and the complete workspace file manifest
# against the fingerprints stored in the recording, and for skills-enabled
# runs it verifies that the materialized skill/pattern selection matches
# the selection the recording was captured with.

require "digest"
require "fileutils"
require "json"
require "optparse"
require_relative "../lib/ruby_agent_skills/agent_adapter"

RECORDING_SCHEMA_VERSION = 1
RESERVED_WORKSPACE_ENTRIES = [".git", ".ruby-agent-eval"].freeze

def workspace_manifest(workspace)
  Dir.glob(File.join(workspace, "**", "*")).sort.each_with_object({}) do |path, manifest|
    next unless File.file?(path)

    relative = path.delete_prefix(workspace + File::SEPARATOR)
    next if RESERVED_WORKSPACE_ENTRIES.include?(relative.split(File::SEPARATOR).first)

    manifest[relative] = Digest::SHA256.file(path).hexdigest
  end
end

def materialized_selection(skill_manifest_path)
  manifest = JSON.parse(File.read(skill_manifest_path, encoding: "UTF-8"))
  [
    manifest.fetch("skills", []).map { |entry| entry.fetch("id") }.sort,
    manifest.fetch("patterns", []).map { |entry| entry.fetch("id") }.sort
  ]
end

def verified_skill_selection?(fingerprint, skill_manifest_path)
  skills, patterns = materialized_selection(skill_manifest_path)
  skills == Array(fingerprint.fetch("skills")).map(&:to_s).sort &&
    patterns == Array(fingerprint.fetch("patterns")).map(&:to_s).sort
end

def workspace_mismatch(workspace, recorded_workspace)
  details = manifest_differences(workspace_manifest(workspace), recorded_workspace)
  <<~ERROR
    workspace does not match the recorded fixture manifest:
      missing files: #{details[:missing]}
      unexpected files: #{details[:extra]}
      changed files: #{details[:changed]}
  ERROR
end

def manifest_differences(actual, recorded)
  changed = recorded.select { |_path, digest| actual[_path] != digest }

  {
    missing: (recorded.keys - actual.keys).sort.join(", "),
    extra: (actual.keys - recorded.keys).sort.join(", "),
    changed: changed.keys.sort.join(", ")
  }
end

def safe_destination(workspace, relative)
  if relative.start_with?("/", "\\")
    abort "recorded file path must be relative: #{relative.inspect}"
  end
  segments = relative.split(File::SEPARATOR)
  if segments.include?("..") || segments.first.to_s.empty?
    abort "recorded file path escapes the workspace: #{relative.inspect}"
  end
  return nil if RESERVED_WORKSPACE_ENTRIES.include?(segments.first)
  File.join(workspace, relative)
end

recordings_root = File.expand_path("../agent-recordings", __dir__)

OptionParser.new do |opts|
  opts.banner = "usage: ruby adapters/recorded_agent.rb RECORDING_SET_ID [--recordings-dir DIR]"

  opts.on("--recordings-dir DIR", "Directory holding recording sets") do |value|
    recordings_root = File.expand_path(value)
  end
end.parse!

recording_set = ARGV.shift
if recording_set.to_s.empty?
  abort "usage: ruby adapters/recorded_agent.rb RECORDING_SET_ID [--recordings-dir DIR]"
end
abort "recordings directory not found: #{recordings_root}" unless Dir.exist?(recordings_root)

evaluation_id = ENV.fetch("RUBY_AGENT_EVAL_ID", nil)
workspace = ENV.fetch("RUBY_AGENT_WORKSPACE", nil)
prompt_path = ENV.fetch("RUBY_AGENT_EVAL_PROMPT", nil)
metadata_file = ENV.fetch("RUBY_AGENT_METADATA_FILE", nil)
skill_manifest_path = ENV.fetch("RUBY_AGENT_SKILL_MANIFEST", nil)
skills_enabled = ENV.fetch("RUBY_AGENT_SKILLS_ENABLED", "false") == "true"

abort "RUBY_AGENT_EVAL_ID is required" if evaluation_id.to_s.empty?
abort "RUBY_AGENT_WORKSPACE is required" if workspace.to_s.empty? || !Dir.exist?(workspace)
abort "RUBY_AGENT_EVAL_PROMPT is required" if prompt_path.to_s.empty? || !File.file?(prompt_path)
abort "RUBY_AGENT_SKILL_MANIFEST is required" if skill_manifest_path.to_s.empty?

workspace = File.expand_path(workspace)
configuration = skills_enabled ? "skills" : "baseline"
recording_name = File.join(evaluation_id, configuration, "recording.json")
recording_path = File.join(recordings_root, recording_set, recording_name)
unless File.file?(recording_path)
  abort "no #{configuration} recording for #{evaluation_id} in set #{recording_set}"
end

begin
  recording = JSON.parse(File.read(recording_path, encoding: "UTF-8"))
rescue JSON::ParserError => e
  abort "invalid recording JSON #{recording_path}: #{e.message}"
end

unless recording["recording_schema_version"] == RECORDING_SCHEMA_VERSION
  abort "unsupported recording schema: #{recording["recording_schema_version"].inspect}"
end
abort "recording evaluation mismatch" unless recording["evaluation"] == evaluation_id
abort "recording configuration mismatch" unless recording["configuration"] == configuration

fingerprint = recording.fetch("context_fingerprint")
prompt_digest = Digest::SHA256.file(prompt_path).hexdigest
abort "recording prompt digest mismatch" unless prompt_digest == fingerprint.fetch("prompt_sha256")

abort workspace_mismatch(workspace, fingerprint.fetch("workspace")) unless
  workspace_manifest(workspace) == fingerprint.fetch("workspace")

if skills_enabled && !verified_skill_selection?(fingerprint, skill_manifest_path)
  abort "materialized skills/patterns do not match the recorded selection"
end

files = recording.fetch("files")
abort "recording contains no files" unless files.is_a?(Hash) && !files.empty?

files.sort.each do |relative, content|
  destination = safe_destination(workspace, relative)
  next if destination.nil?

  FileUtils.mkdir_p(File.dirname(destination))
  File.write(destination, content.to_s, encoding: "UTF-8")
end

if metadata_file && !metadata_file.empty?
  agent = recording.fetch("agent")
  RubyAgentSkills::AgentAdapter.write_metadata(
    metadata_file,
    "provider" => agent["provider"],
    "model" => agent["model"],
    "model_version" => agent["model_version"],
    "tool_mode" => agent["tool_mode"],
    "recorded_agent" => {
      "recording_set" => recording_set,
      "recording_schema_version" => RECORDING_SCHEMA_VERSION,
      "recorded_at" => recording["recorded_at"],
      "integrity" => {
        "prompt_digest_verified" => true,
        "workspace_manifest_verified" => true,
        "skill_selection_verified" => skills_enabled
      },
      "files_written" => files.keys.sort
    }
  )
end

puts "recorded agent: replayed #{files.length} file(s) for #{evaluation_id} (#{configuration})"
