# frozen_string_literal: true

module RubyAgentSkills
  module MCPPreflight
    class DiscoveryResult
      CLIENT_VERSIONS = [MODERN_PROTOCOL, LEGACY_PROTOCOL].freeze
      CACHE_SCOPES = %w[public private].freeze

      attr_reader :protocol_version, :server_info, :capabilities

      def initialize(result)
        validate_shape!(result)
        @protocol_version = CLIENT_VERSIONS.find do |version|
          result.fetch("supportedVersions").include?(version)
        end
        unless @protocol_version
          raise Error.new("protocol_incompatible", "server advertises no protocol version supported by this client")
        end

        @capabilities = result.fetch("capabilities")
        @server_info = normalized_server_info(result.dig("_meta", "io.modelcontextprotocol/serverInfo"))
      end

      def modern?
        protocol_version == MODERN_PROTOCOL
      end

      def supports_tools?
        capabilities.key?("tools")
      end

      private

      def validate_shape!(result)
        raise Error.new("invalid_discovery", "server/discover result must be an object") unless result.is_a?(Hash)

        unless result["resultType"].is_a?(String) && !result["resultType"].empty?
          raise Error.new("invalid_discovery", "server/discover resultType must be a non-empty string")
        end
        return unless result["resultType"] != "complete"

        raise Error.new("incomplete_discovery", "partial or cached discovery results are not supported")
      end

      def validate_result_fields!(result)
        versions = result["supportedVersions"]
        valid_versions = versions.is_a?(Array) && !versions.empty? &&
                         versions.all? { |version| version.is_a?(String) && !version.empty? }
        raise Error.new("invalid_discovery", "supportedVersions must contain protocol version strings") unless valid_versions

        raise Error.new("invalid_discovery", "capabilities must be an object") unless result["capabilities"].is_a?(Hash)
        unless CACHE_SCOPES.include?(result["cacheScope"])
          raise Error.new("invalid_discovery", "cacheScope must be public or private")
        end
        unless result["ttlMs"].is_a?(Integer) && result["ttlMs"] >= 0
          raise Error.new("invalid_discovery", "ttlMs must be a non-negative integer")
        end
      end

      def normalized_server_info(info)
        return nil unless info.is_a?(Hash)

        { name: info["name"], version: info["version"] }
      end
    end
  end
end
