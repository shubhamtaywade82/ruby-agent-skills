# frozen_string_literal: true

require "open3"
require_relative "headless_commands"
require_relative "headless_coding_warnings"
require_relative "headless_output"

module RubyAgentSkills
  # Headless routing and coding adapters. Antigravity can disable skill
  # expansion. Cursor and OpenCode still load skills installed for the user.
  module HeadlessAdapters
    PROVIDERS = {
      cursor: {
        bin_env: "CURSOR_AGENT_BIN",
        default_bin: "agent",
        model_env: "CURSOR_AGENT_MODEL",
        label: "Cursor agent"
      },
      antigravity: {
        bin_env: "AGY_BIN",
        default_bin: "agy",
        model_env: "AGY_MODEL",
        label: "Antigravity"
      },
      opencode: {
        bin_env: "OPENCODE_BIN",
        default_bin: "opencode",
        model_env: "OPENCODE_MODEL",
        label: "OpenCode"
      }
    }.freeze

    module_function

    def coding(provider)
      spec = provider_spec(provider)
      model = required_model(spec)
      context = File.read(ENV.fetch("RUBY_AGENT_CONTEXT_FILE"), encoding: "UTF-8")
      command = HeadlessCommands.coding(provider, binary(spec), model, context)
      stdout, stderr, status = run(command, HeadlessCommands.stdin(provider, context))
      warn stderr unless stderr.to_s.empty?
      HeadlessCodingWarnings.warn_for(provider, stdout)
      exit(status.exitstatus || 1)
    end

    def routing(provider)
      spec = provider_spec(provider)
      model = required_model(spec)
      loaded = HeadlessOutput.payload
      command = HeadlessCommands.routing(provider, binary(spec), model, loaded.fetch(:prompt))
      prompt = loaded.fetch(:prompt)
      stdout, stderr, status = run(command, HeadlessCommands.stdin(provider, prompt))
      fail_routing(spec, status, stderr) unless status.success?
      text = HeadlessOutput.routing_text(provider, stdout)
      HeadlessOutput.write_result(loaded, text, provider, model)
    end

    def provider_spec(provider)
      PROVIDERS.fetch(provider) { raise ArgumentError, "unknown headless provider #{provider}" }
    end

    def required_model(spec)
      model = ENV[spec[:model_env]].to_s.strip
      abort "#{spec[:model_env]} must be set to a #{spec[:label]} model id" if model.empty?

      model
    end

    def binary(spec)
      ENV.fetch(spec[:bin_env], spec[:default_bin])
    end

    def fail_routing(spec, status, stderr)
      abort "#{spec[:label]} routing request failed: #{status.exitstatus}: #{stderr}"
    end

    def run(command, stdin)
      Open3.capture3(*command, stdin_data: stdin)
    end
  end
end
