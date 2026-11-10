# frozen_string_literal: true

require "yaml"

module RubyAgentSkills
  module MCPPreflight
    class PolicyValidator
      CAPABILITIES = %w[
        metadata_read source_read schema_read application_data_read test_execution
        debugger_control arbitrary_code_execution shell_execution dependency_write
        filesystem_write database_write external_network production_access credential_export
      ].freeze

      def initialize(data)
        @data = data
      end

      def validate!
        raise Error.new("invalid_policy", "policy root must be a mapping") unless @data.is_a?(Hash)
        raise Error.new("invalid_policy", "schema_version must be 1") unless @data["schema_version"] == 1

        defaults = @data.fetch("defaults")
        profiles = @data.fetch("profiles")
        servers = @data.fetch("servers", {})
        validate_defaults(defaults)
        validate_profiles(profiles)
        validate_servers(servers)
      rescue KeyError => e
        raise Error.new("invalid_policy", "missing policy field: #{e.key}")
      end

      private

      def validate_defaults(defaults)
        raise Error.new("invalid_policy", "defaults must be a mapping") unless defaults.is_a?(Hash)
        raise Error.new("invalid_policy", "production must be deny") unless defaults["production"] == "deny"

        isolated = defaults.fetch("isolated_capabilities")
        valid = isolated.is_a?(Array) && (isolated - CAPABILITIES).empty?
        raise Error.new("invalid_policy", "isolated_capabilities contains an unknown capability") unless valid
      end

      def validate_profiles(profiles)
        valid = profiles.is_a?(Hash) && !profiles.empty?
        raise Error.new("invalid_policy", "profiles must be a non-empty mapping") unless valid

        profiles.each do |name, profile|
          raise Error.new("invalid_policy", "profile #{name} must be a mapping") unless profile.is_a?(Hash)
          validate_profile_fields(name, profile)
        end
      end

      def validate_profile_fields(name, profile)
        %w[allow require_approval deny].each do |field|
          values = profile.fetch(field, [])
          valid = values.is_a?(Array) && (values - CAPABILITIES).empty?
          raise Error.new("invalid_policy", "profile #{name} has invalid #{field} capabilities") unless valid
        end
      end

      def validate_servers(servers)
        raise Error.new("invalid_policy", "servers must be a mapping") unless servers.is_a?(Hash)

        servers.each do |server, entry|
          raise Error.new("invalid_policy", "server #{server} must be a mapping") unless entry.is_a?(Hash)
          validate_server_tools(server, entry.fetch("tools", {}))
        end
      end

      def validate_server_tools(server, tools)
        raise Error.new("invalid_policy", "server #{server} tools must be a mapping") unless tools.is_a?(Hash)

        tools.each do |tool, capability|
          valid = tool.is_a?(String) && CAPABILITIES.include?(capability)
          raise Error.new("invalid_policy", "server #{server} has an invalid capability for #{tool}") unless valid
        end
      end
    end

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
        unless ENVIRONMENTS.include?(environment)
          raise Error.new("unknown_environment", "environment must be development, test, staging, or production")
        end
        return deny("production environment is blocked by policy") if environment == "production"

        selected = @data.fetch("profiles").fetch(profile) do
          raise Error.new("unknown_profile", "unknown MCP permission profile: #{profile}")
        end
        capability = @data.fetch("servers", {}).dig(server, "tools", tool)
        return deny("tool is unclassified; add an explicit trusted capability mapping") unless capability
        return deny("#{capability} is an unconditional deny") if HARD_DENY.include?(capability)

        isolated_capabilities = @data.fetch("defaults").fetch("isolated_capabilities")
        if isolated_capabilities.include?(capability) && !isolated
          return deny("#{capability} requires an isolated environment", capability)
        end

        return deny("#{capability} is denied by profile #{profile}", capability) if Array(selected["deny"]).include?(capability)
        return approval(capability) if Array(selected["require_approval"]).include?(capability)
        return allowed(capability, profile) if Array(selected["allow"]).include?(capability)

        deny("#{capability} is not allowed by profile #{profile}", capability)
      end

      private

      def deny(reason, capability = nil)
        { decision: "denied", capability: capability, reason: reason }
      end

      def approval(capability)
        {
          decision: "approval_required",
          capability: capability,
          reason: "#{capability} requires explicit human approval before the MCP tool is invoked"
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
