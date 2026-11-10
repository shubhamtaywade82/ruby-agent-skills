# frozen_string_literal: true

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
        validate_root
        validate_defaults(@data.fetch("defaults"))
        validate_profiles(@data.fetch("profiles"))
        validate_servers(@data.fetch("servers", {}))
      rescue KeyError => e
        raise Error.new("invalid_policy", "missing policy field: #{e.key}")
      end

      private

      def validate_root
        raise Error.new("invalid_policy", "policy root must be a mapping") unless @data.is_a?(Hash)
        return if @data["schema_version"] == 1

        raise Error.new("invalid_policy", "schema_version must be 1")
      end

      def validate_defaults(defaults)
        raise Error.new("invalid_policy", "defaults must be a mapping") unless defaults.is_a?(Hash)
        unless defaults["production"] == "deny" && defaults["unknown_tool"] == "deny"
          raise Error.new("invalid_policy", "production and unknown_tool must be deny")
        end

        isolated = defaults.fetch("isolated_capabilities")
        valid = isolated.is_a?(Array) && (isolated - CAPABILITIES).empty?
        raise Error.new("invalid_policy", "invalid isolated_capabilities") unless valid
      end
      def validate_profiles(profiles)
        valid = profiles.is_a?(Hash) && !profiles.empty?
        raise Error.new("invalid_policy", "profiles must be a non-empty mapping") unless valid

        profiles.each do |name, profile|
          validate_profile(name, profile)
        end
      end

      def validate_profile(name, profile)
        unless profile.is_a?(Hash)
          raise Error.new("invalid_policy", "profile #{name} must be a mapping")
        end

        %w[allow require_approval deny].each do |field|
          validate_capabilities(name, field, profile.fetch(field, []))
        end
      end

      def validate_capabilities(name, field, values)
        valid = values.is_a?(Array) && (values - CAPABILITIES).empty?
        raise Error.new("invalid_policy", "profile #{name} has invalid #{field}") unless valid
      end

      def validate_servers(servers)
        raise Error.new("invalid_policy", "servers must be a mapping") unless servers.is_a?(Hash)

        servers.each do |server, entry|
          validate_server(server, entry)
        end
      end

      def validate_server(server, entry)
        unless entry.is_a?(Hash)
          raise Error.new("invalid_policy", "server #{server} must be a mapping")
        end

        tools = entry.fetch("tools", {})
        unless tools.is_a?(Hash)
          raise Error.new("invalid_policy", "server #{server} tools must be a mapping")
        end

        tools.each do |tool, capability|
          valid = tool.is_a?(String) && CAPABILITIES.include?(capability)
          raise Error.new("invalid_policy", "invalid capability for #{server}.#{tool}") unless valid
        end
      end
    end
  end
end
