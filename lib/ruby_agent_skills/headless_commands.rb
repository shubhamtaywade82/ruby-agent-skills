# frozen_string_literal: true

require "json"

module RubyAgentSkills
  # Print-mode argv for each local coding CLI. Flags match the CLI help
  # that was current when the adapter was added.
  module HeadlessCommands
    ROUTING_SCHEMA = {
      "type" => "object",
      "properties" => {
        "primary_skill" => { "type" => "string" },
        "secondary_skills" => {
          "type" => "array",
          "items" => { "type" => "string" }
        },
        "reason" => { "type" => "string" }
      },
      "required" => %w[primary_skill secondary_skills reason]
    }.freeze

    module_function

    def coding(provider, bin, model, context)
      case provider
      when :cursor then cursor_coding(bin, model)
      when :antigravity then antigravity_coding(bin, model, context)
      when :opencode then opencode_coding(bin, model, context)
      end
    end

    def routing(provider, bin, model, prompt)
      case provider
      when :cursor then cursor_routing(bin, model)
      when :antigravity then antigravity_routing(bin, model, prompt)
      when :opencode then opencode_routing(bin, model, prompt)
      end
    end

    def stdin(provider, text)
      provider == :cursor ? text : ""
    end

    def cursor_coding(bin, model)
      [
        bin, "--print", "--output-format", "json", "--model", model,
        "--force", "--trust", "--sandbox", "disabled",
        "--workspace", workspace
      ]
    end

    def cursor_routing(bin, model)
      [
        bin, "--print", "--output-format", "json", "--model", model,
        "--mode", "ask", "--trust", "--sandbox", "enabled"
      ]
    end

    def antigravity_coding(bin, model, context)
      [
        bin, "--print", "--output-format", "json", "--model", model,
        "--mode", "accept-edits", "--dangerously-skip-permissions",
        "--disable-slash-commands", "--", context
      ]
    end

    def antigravity_routing(bin, model, prompt)
      [
        bin, "--print", "--output-format", "json", "--model", model,
        "--disable-slash-commands", "--sandbox",
        "--json-schema", JSON.generate(ROUTING_SCHEMA), "--", prompt
      ]
    end

    def opencode_coding(bin, model, context)
      [
        bin, "run", "--standalone", "--format", "json",
        "--model", model, "--auto", "--", context
      ]
    end

    def opencode_routing(bin, model, prompt)
      [
        bin, "run", "--standalone", "--format", "json",
        "--model", model, "--", prompt
      ]
    end

    def workspace
      path = ENV["RUBY_AGENT_WORKSPACE"].to_s
      path.empty? ? Dir.pwd : path
    end
  end
end
