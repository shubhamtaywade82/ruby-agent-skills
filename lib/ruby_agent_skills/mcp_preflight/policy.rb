# frozen_string_literal: true

require "yaml"
require_relative "policy_validator"

module RubyAgentSkills
  module MCPPreflight
    class Policy
      ENVIRONMENTS = %w[development test staging production].freeze
      HARD_DENY = %w[production_access credential_export].freeze

      def initialize(path)
        @data = YAML.safe_load(
          File.read(path, encoding: "UTF-8"),
          permitted_classes: [],
          aliases: false
        )
        PolicyValidator.new(@data).validate!
      rescue Psych::Exception => e
        raise Error.new("invalid_policy", e.message)
      rescue Errno::ENOENT => e
        raise Error.new("policy_not_found", e.message)
      end

      def evaluate(server:, tool:, profile:, environment:, isolated:)
        validate_environment(environment)
        return deny("production environment is blocked by policy") if environment == "production"

        selected = @data.fetch("profiles").fetch(profile) do
          raise Error.new("unknown_profile", "unknown MCP permission profile: #{profile}")
        end
        capability = capability_for(server, tool)
        return deny("tool is unclassified; add a trusted mapping") unless capability

        evaluate_capability(capability, selected, profile, isolated)
      end

      private

      def validate_environment(environment)
        return if ENVIRONMENTS.include?(environment)

        raise Error.new("unknown_environment", "environment must be development, test, staging, or production")
      end

      def capability_for(server, tool)
        @data.fetch("servers", {}).dig(server, "tools", tool)
      end

      def evaluate_capability(capability, profile, name, isolated)
        return deny("#{capability} is an unconditional deny") if HARD_DENY.include?(capability)
        return deny("#{capability} requires an isolated environment", capability) unless isolated?(capability, isolated)
        return deny("#{capability} is denied by profile #{name}", capability) if profile["deny"].include?(capability)
        return approval(capability) if profile["require_approval"].include?(capability)
        return allowed(capability, name) if profile["allow"].include?(capability)

        deny("#{capability} is not allowed by profile #{name}", capability)
      end

      def isolated?(capability, isolated)
        required = @data.fetch("defaults").fetch("isolated_capabilities")
        !required.include?(capability) || isolated
      end

      def deny(reason, capability = nil)
        { decision: "denied", capability: capability, reason: reason }
      end

      def approval(capability)
        {
          decision: "approval_required",
          capability: capability,
          reason: "#{capability} requires explicit human approval before invocation"
        }
      end

      def allowed(capability, profile)
        {
          decision: "allowed",
          capability: capability,
          reason: "#{capability} is allowed by profile #{profile}"
        }
      end
    end
  end
end
