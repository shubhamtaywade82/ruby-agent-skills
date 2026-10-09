# frozen_string_literal: true

require "json"
require "yaml"

module RubyAgentSkills
  # Turns each CLI's print-mode stdout into the routing result contract.
  module HeadlessOutput
    INSTRUCTIONS = <<~TEXT
      You are the skill-routing agent for a Ruby/Rails engineering repository.
      Route the task to the smallest set of applicable skills.
      Select exactly one primary_skill from the registry.
      Select secondary_skills only for real dependent constraints.
      Do not invent skill names or treat keyword overlap as ownership.
      Keep authentication, authorization, security, persistence, and execution boundaries distinct.
      Do not call tools. Return JSON only:
      {"primary_skill":"registered-skill","secondary_skills":["registered-skill"],"reason":"brief ownership rationale"}
      The expected routing answer is not provided.

      Registered skills:
      %<skills>s

      Routing contract:
      %<router>s

      Task:
      %<task>s
    TEXT

    module_function

    def prompt(task, router, skills)
      format(INSTRUCTIONS, skills: skills.join(", "), router: router, task: task)
    end

    def payload
      task = File.read(ENV.fetch("RUBY_AGENT_ROUTING_PROMPT_FILE"), encoding: "UTF-8")
      router = File.read(ENV.fetch("RUBY_AGENT_ROUTING_ROUTER_FILE"), encoding: "UTF-8")
      manifest = load_manifest
      skills = manifest.fetch("skills").keys
      { prompt: prompt(task, router, skills), skills: skills }
    end

    def write_result(payload, content, provider, model)
      selected = JSON.parse(strip_fence(content))
      primary = selected.fetch("primary_skill").to_s
      secondary = Array(selected.fetch("secondary_skills")).map(&:to_s).uniq
      check_skills(payload.fetch(:skills), primary, secondary)
      File.write(result_path, document(primary, secondary, selected, provider, model))
    end

    def routing_text(provider, stdout)
      case provider
      when :cursor then cursor_text(stdout)
      when :antigravity then antigravity_text(stdout)
      when :opencode then opencode_text(stdout)
      end
    end

    def cursor_text(stdout)
      envelope = JSON.parse(utf8(stdout))
      abort "cursor routing request errored: #{envelope}" if envelope["is_error"]

      envelope.fetch("result").to_s
    end

    def antigravity_text(stdout)
      envelope = JSON.parse(utf8(stdout))
      failed = envelope["status"] != "SUCCESS"
      if failed
        abort "antigravity routing request errored: #{envelope['error'] || envelope['status']}"
      end
      return JSON.generate(envelope.fetch("structured_output")) if envelope["structured_output"]

      envelope.fetch("response").to_s
    end

    def opencode_text(stdout)
      events = json_lines(stdout)
      errors = events.select { |event| event["type"] == "error" }
      abort "opencode routing request errored: #{errors}" unless errors.empty?

      events.filter_map { |event| event.dig("part", "text") if event["type"] == "text" }.join
    end

    def check_skills(registry, primary, secondary)
      abort "primary_skill must be registered" unless registry.include?(primary)
      unknown = (secondary - registry).empty?
      abort "secondary_skills contains unknown skill" unless unknown
      abort "secondary_skills contains primary_skill" if secondary.include?(primary)
    end

    def document(primary, secondary, selected, provider, model)
      body = {
        "protocol_version" => ENV.fetch("RUBY_AGENT_ROUTING_PROTOCOL_VERSION", "1").to_i,
        "case_id" => ENV.fetch("RUBY_AGENT_ROUTING_CASE_ID"),
        "primary_skill" => primary,
        "secondary_skills" => secondary,
        "reason" => selected["reason"].to_s,
        "metadata" => { "provider" => provider.to_s, "model" => model }
      }
      "#{JSON.pretty_generate(body)}\n"
    end

    def load_manifest
      YAML.safe_load(
        File.read(ENV.fetch("RUBY_AGENT_ROUTING_MANIFEST_FILE"), encoding: "UTF-8"),
        permitted_classes: [],
        aliases: false
      )
    end

    def result_path
      ENV.fetch("RUBY_AGENT_ROUTING_RESULT_FILE")
    end

    def json_lines(stdout)
      utf8(stdout).lines.filter_map { |line| JSON.parse(line) unless line.strip.empty? }
    end

    def strip_fence(content)
      content.to_s.strip.sub(/\A```(?:json)?\n/, "").delete_suffix("\n```")
    end

    def utf8(string)
      retagged = string.to_s.dup.force_encoding("UTF-8")
      retagged.valid_encoding? ? retagged : retagged.scrub
    end
  end
end
