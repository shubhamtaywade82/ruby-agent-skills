# frozen_string_literal: true

module RubyAgentSkills
  module MCPPreflight
    class StdioEnvironment
      INHERITED_ENV = %w[
        PATH HOME USERPROFILE TMPDIR TEMP LANG LC_ALL SYSTEMROOT WINDIR
        GEM_HOME GEM_PATH RBENV_VERSION RBENV_ROOT
      ].freeze

      def initialize(config)
        @config = config
      end

      def validate!
        validate_environment!
        validate_inherited_environment!
      end

      def child_environment
        inherited_keys = INHERITED_ENV + @config.fetch("inherit_env", [])
        inherited = inherited_keys.uniq.each_with_object({}) do |key, result|
          result[key] = ENV.fetch(key) if ENV.key?(key)
        end
        inherited.merge(@config.fetch("env", {}))
      end

      private

      def validate_environment!
        return if valid_env?(@config.fetch("env", {}))

        raise Error.new("invalid_server_config", "MCP env must be a string mapping")
      end

      def validate_inherited_environment!
        return if valid_inherit_env?(@config.fetch("inherit_env", []))

        raise Error.new("invalid_server_config", "inherit_env must contain valid environment names")
      end

      def valid_inherit_env?(keys)
        keys.is_a?(Array) && keys.all? do |key|
          key.is_a?(String) && key.match?(/\A[A-Za-z_][A-Za-z0-9_]*\z/)
        end
      end

      def valid_env?(env)
        env.is_a?(Hash) && env.all? do |key, value|
          key.to_s.match?(/\A[A-Za-z_][A-Za-z0-9_]*\z/) && value.is_a?(String)
        end
      end
    end
  end
end
