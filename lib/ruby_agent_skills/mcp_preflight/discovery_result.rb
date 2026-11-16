# frozen_string_literal: true

module RubyAgentSkills
  module MCPPreflight
    class DiscoveryResult
      CLIENT_VERSIONS = [MODERN_PROTOCOL, LEGACY_PROTOCOL].freeze
      CACHE_SCOPES = %w[public private].freeze

      attr_reader :protocol_version, :server_info, :capabilities

      def initialize(result)
        validate_shape!(result)
        @protocol_version = supported_protocol_version(result)
        @capabilities = result.fetch("capabilities")
        server_info = result.dig("_meta", "io.modelcontextprotocol/serverInfo")
        @server_info = normalized_server_info(server_info)
      end

      def supported_protocol_version(result)
        version = CLIENT_VERSIONS.find do |candidate|
          result.fetch("supportedVersions").include?(candidate)
        end
        return version if version

        message = "server advertises no protocol version supported by this client"
        raise Error.new("protocol_incompatible", message)
      end

      def modern?
        protocol_version == MODERN_PROTOCOL
      end

      def supports_tools?
        capabilities.key?("tools")
      end

      private

      def validate_shape!(result)
        validate_object!(result)
        validate_result_type!(result)
        validate_result_fields!(result)
      end

      def validate_object!(result)
        return if result.is_a?(Hash)

        raise Error.new("invalid_discovery", "server/discover result must be an object")
      end

      def validate_result_type!(result)
        type = result["resultType"]
        valid = type.is_a?(String) && !type.empty?
        raise Error.new("invalid_discovery", "server/discover resultType must be a string") unless valid
        return if type == "complete"

        raise Error.new("incomplete_discovery", "partial or cached discovery results are not supported")
      end

      def validate_result_fields!(result)
        validate_supported_versions!(result["supportedVersions"])
        validate_capabilities!(result["capabilities"])
        validate_cache_scope!(result["cacheScope"])
        validate_ttl!(result["ttlMs"])
      end

      def validate_supported_versions!(versions)
        valid = versions.is_a?(Array) && !versions.empty? &&
                versions.all? { |version| version.is_a?(String) && !version.empty? }
        return if valid

        raise Error.new(
          "invalid_discovery",
          "supportedVersions must contain protocol version strings"
        )
      end

      def validate_capabilities!(capabilities)
        return if capabilities.is_a?(Hash)

        raise Error.new("invalid_discovery", "capabilities must be an object")
      end

      def validate_cache_scope!(scope)
        return if CACHE_SCOPES.include?(scope)

        raise Error.new("invalid_discovery", "cacheScope must be public or private")
      end

      def validate_ttl!(ttl)
        return if ttl.is_a?(Integer) && ttl >= 0

        raise Error.new("invalid_discovery", "ttlMs must be a non-negative integer")
      end

      def normalized_server_info(info)
        return nil unless info.is_a?(Hash)

        { name: info["name"], version: info["version"] }
      end
    end
  end
end
