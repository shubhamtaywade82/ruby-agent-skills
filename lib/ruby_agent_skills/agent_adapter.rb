# frozen_string_literal: true

require "json"

module RubyAgentSkills
  module AgentAdapter
    PROTOCOL_VERSION = 1
    ADAPTER_VERSION = "1.0.0"

    class Error < StandardError; end

    module_function

    def metadata_from_env
      metadata = {
        "protocol_version" => PROTOCOL_VERSION,
        "adapter_version" => ENV.fetch("RUBY_AGENT_ADAPTER_VERSION", ADAPTER_VERSION)
      }

      {
        "provider" => "RUBY_AGENT_PROVIDER",
        "model" => "RUBY_AGENT_MODEL",
        "model_version" => "RUBY_AGENT_MODEL_VERSION",
        "tool_mode" => "RUBY_AGENT_TOOL_MODE",
        "temperature" => "RUBY_AGENT_TEMPERATURE"
      }.each do |key, env_name|
        value = ENV[env_name]
        next if value.nil? || value.empty?

        metadata[key] = value
      end

      metadata["temperature"] = metadata["temperature"].to_f if metadata["temperature"]
      metadata
    end

    def write_metadata(path, extra = {})
      payload = metadata_from_env.merge(extra)
      File.write(path, JSON.pretty_generate(payload) + "\n", encoding: "UTF-8")
    end
  end
end
