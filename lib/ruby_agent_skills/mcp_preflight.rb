# frozen_string_literal: true

require "json"
require "open3"
require "net/http"
require "openssl"
require "time"
require "uri"
require "yaml"

module RubyAgentSkills
  module MCPPreflight
    MODERN_PROTOCOL = "2026-07-28"
    LEGACY_PROTOCOL = "2025-11-25"
    CLIENT_INFO = { "name" => "ruby-agent-skills-preflight", "version" => "1.0.0" }.freeze
    CLIENT_META = {
      "io.modelcontextprotocol/protocolVersion" => MODERN_PROTOCOL,
      "io.modelcontextprotocol/clientCapabilities" => {},
      "io.modelcontextprotocol/clientInfo" => CLIENT_INFO
    }.freeze
    MAX_STDOUT_BUFFER = 1_048_576
    DEFAULT_TIMEOUT = 5

    class Error < StandardError
      attr_reader :code

      def initialize(code, message)
        super(message)
        @code = code
      end
    end

    class Policy
      ENVIRONMENTS = %w[development test staging production].freeze
      HARD_DENY_CAPABILITIES = %w[production_access credential_export].freeze
      CAPABILITIES = %w[
        metadata_read source_read schema_read application_data_read test_execution
        debugger_control arbitrary_code_execution shell_execution dependency_write
        filesystem_write database_write external_network production_access credential_export
      ].freeze

      def initialize(path)
        @data = YAML.safe_load(
          File.read(path, encoding: "UTF-8"),
          permitted_classes: [],
          aliases: false
        )
        validate!
      rescue Psych::Exception => e
        raise Error.new("invalid_policy", e.message)
      rescue Errno::ENOENT => e
        raise Error.new("policy_not_found", e.message)
      end

      def evaluate(server:, tool:, profile:, environment:, isolated:)
        unless ENVIRONMENTS.include?(environment)
          raise Error.new("unknown_environment", "environment must be development, test, staging, or production")
        end
        return decision("denied", "production environment is blocked by policy") if environment == "production"

        selected = @data.fetch("profiles").fetch(profile) do
          raise Error.new("unknown_profile", "unknown MCP permission profile: #{profile}")
        end
        capability = @data.fetch("servers", {}).dig(server, "tools", tool)
        return decision("denied", "tool is unclassified; add an explicit trusted capability mapping") unless capability

        if HARD_DENY_CAPABILITIES.include?(capability)
          return decision("denied", "#{capability} is an unconditional deny")
        end

        if @data.fetch("defaults").fetch("isolated_capabilities").include?(capability) && !isolated
          return decision("denied", "#{capability} requires an isolated environment")
        end

        denied = Array(selected["deny"])
        return decision("denied", "#{capability} is denied by profile #{profile}") if denied.include?(capability)

        if Array(selected["require_approval"]).include?(capability)
          return decision(
            "approval_required",
            "#{capability} requires explicit human approval before the MCP tool is invoked",
            capability
          )
        end

        if Array(selected["allow"]).include?(capability)
          return decision("allowed", "#{capability} is allowed by profile #{profile}", capability)
        end

        decision("denied", "#{capability} is not allowed by profile #{profile}", capability)
      end

      private

      def decision(status, reason, capability = nil)
        { decision: status, capability: capability, reason: reason }
      end

      def validate!
        raise Error.new("invalid_policy", "policy root must be a mapping") unless @data.is_a?(Hash)
        raise Error.new("invalid_policy", "schema_version must be 1") unless @data["schema_version"] == 1

        defaults = @data.fetch("defaults")
        profiles = @data.fetch("profiles")
        servers = @data.fetch("servers", {})
        raise Error.new("invalid_policy", "defaults must be a mapping") unless defaults.is_a?(Hash)
        raise Error.new("invalid_policy", "production must be deny") unless defaults["production"] == "deny"
        raise Error.new("invalid_policy", "profiles must be a non-empty mapping") unless profiles.is_a?(Hash) && !profiles.empty?
        raise Error.new("invalid_policy", "servers must be a mapping") unless servers.is_a?(Hash)

        isolated = defaults.fetch("isolated_capabilities")
        unless isolated.is_a?(Array) && (isolated - CAPABILITIES).empty?
          raise Error.new("invalid_policy", "isolated_capabilities contains an unknown capability")
        end

        profiles.each do |name, profile|
          raise Error.new("invalid_policy", "profile #{name} must be a mapping") unless profile.is_a?(Hash)

          %w[allow require_approval deny].each do |field|
            values = profile.fetch(field, [])
            unless values.is_a?(Array) && (values - CAPABILITIES).empty?
              raise Error.new("invalid_policy", "profile #{name} has invalid #{field} capabilities")
            end
          end
        end

        servers.each do |server, entry|
          raise Error.new("invalid_policy", "server #{server} must be a mapping") unless entry.is_a?(Hash)

          tools = entry.fetch("tools", {})
          raise Error.new("invalid_policy", "server #{server} tools must be a mapping") unless tools.is_a?(Hash)

          tools.each do |tool, capability|
            unless tool.is_a?(String) && CAPABILITIES.include?(capability)
              raise Error.new("invalid_policy", "server #{server} has an invalid capability for #{tool}")
            end
          end
        end
      rescue KeyError => e
        raise Error.new("invalid_policy", "missing policy field: #{e.key}")
      end
    end

    class JsonLineReader
      def initialize(io)
        @io = io
        @buffer = +""
      end

      def response_for(id, timeout:)
        loop do
          message = next_message(timeout: timeout)
          next unless message["id"] == id

          if message["error"]
            return { error: message["error"] }
          end

          return { result: message["result"] }
        end
      end

      private

      def next_message(timeout:)
        deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

        loop do
          newline = @buffer.index("\n")
          if newline
            line = @buffer.slice!(0..newline).strip
            next if line.empty?

            begin
              message = JSON.parse(line)
            rescue JSON::ParserError
              raise Error.new("invalid_protocol_output", "server wrote non-JSON data to STDOUT")
            end
            raise Error.new("invalid_protocol_output", "server response must be a JSON object") unless message.is_a?(Hash)

            return message
          end

          remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
          raise Error.new("timeout", "timed out waiting for an MCP response") unless remaining.positive?

          ready = IO.select([@io], nil, nil, remaining)
          raise Error.new("timeout", "timed out waiting for an MCP response") unless ready

          chunk = @io.read_nonblock(16_384, exception: false)
          if chunk.nil?
            raise Error.new("server_exited", "MCP server exited before responding")
          elsif chunk != :wait_readable
            @buffer << chunk
            if @buffer.bytesize > MAX_STDOUT_BUFFER
              raise Error.new("response_too_large", "MCP server response exceeded the 1 MiB limit")
            end
          end
        end
      end
    end

    class StdioProbe
      INHERITED_ENV = %w[
        PATH HOME USERPROFILE TMPDIR TEMP LANG LC_ALL SYSTEMROOT WINDIR
        GEM_HOME GEM_PATH RBENV_VERSION RBENV_ROOT
      ].freeze

      def initialize(server_config, cwd:, timeout:)
        @config = server_config
        @cwd = File.expand_path(cwd || server_config.fetch("cwd", Dir.pwd))
        @timeout = timeout
      end

      def call
        validate_config!
        environment = child_environment

        Open3.popen3(environment, @config.fetch("command"), *@config.fetch("args", []),
                     chdir: @cwd, pgroup: true, err: File::NULL) do |stdin, stdout, _stderr, waiter|
          @stdin = stdin
          @reader = JsonLineReader.new(stdout)
          result = discover_or_initialize
          result.merge(status: "healthy", transport: "stdio", checked_at: Time.now.utc.iso8601)
        ensure
          stop(waiter) if waiter
          stdout.close unless stdout.closed?
          stdin.close unless stdin.closed?
        end
      rescue Errno::ENOENT
        raise Error.new("command_not_found", "configured MCP command could not be started")
      rescue Errno::EACCES
        raise Error.new("command_not_executable", "configured MCP command is not executable")
      end

      private

      def validate_config!
        command = @config["command"]
        args = @config.fetch("args", [])
        raise Error.new("invalid_server_config", "STDIO server command must be a non-empty string") unless command.is_a?(String) && !command.strip.empty?
        raise Error.new("invalid_server_config", "STDIO server args must be an array of strings") unless args.is_a?(Array) && args.all? { |arg| arg.is_a?(String) }
        raise Error.new("invalid_working_directory", "MCP server working directory does not exist") unless Dir.exist?(@cwd)
        raise Error.new("invalid_server_config", "MCP server env must be a string mapping") unless valid_env?(@config.fetch("env", {}))
        raise Error.new("invalid_server_config", "inherit_env must be an array of variable names") unless @config.fetch("inherit_env", []).is_a?(Array)
      end

      def valid_env?(env)
        env.is_a?(Hash) && env.all? do |key, value|
          key.to_s.match?(/\A[A-Za-z_][A-Za-z0-9_]*\z/) && value.is_a?(String)
        end
      end

      def child_environment
        inherited = (INHERITED_ENV + Array(@config["inherit_env"])).uniq.each_with_object({}) do |key, result|
          result[key] = ENV.fetch(key) if ENV.key?(key)
        end
        inherited.merge(@config.fetch("env", {}))
      end

      def discover_or_initialize
        discovery = request(
          1,
          "server/discover",
          { "_meta" => CLIENT_META },
          timeout: @timeout
        )

        if discovery[:error]
          return legacy_initialize if discovery[:error]["code"] == -32_601

          raise Error.new("discovery_failed", "MCP server discovery failed: #{safe_error_code(discovery[:error])}")
        end

        raise Error.new("invalid_discovery", "server/discover result must be an object") unless discovery[:result].is_a?(Hash)

        listed = request(2, "tools/list", { "_meta" => CLIENT_META }, timeout: @timeout)
        tools_result = result_or_raise(listed, "tools/list")
        normalize_tools(tools_result, MODERN_PROTOCOL, discovery[:result]["serverInfo"])
      end

      def legacy_initialize
        initialized = request(
          2,
          "initialize",
          {
            "protocolVersion" => LEGACY_PROTOCOL,
            "capabilities" => {},
            "clientInfo" => CLIENT_INFO
          },
          timeout: @timeout
        )
        result = result_or_raise(initialized, "initialize")
        version = result["protocolVersion"]
        raise Error.new("invalid_initialize", "legacy initialize response has no protocolVersion") unless version.is_a?(String)

        @stdin.write(JSON.generate("jsonrpc" => "2.0", "method" => "notifications/initialized", "params" => {}))
        @stdin.write("\n")
        @stdin.flush

        listed = request(3, "tools/list", {}, timeout: @timeout)
        normalize_tools(result_or_raise(listed, "tools/list"), version, result["serverInfo"])
      end

      def request(id, method, params, timeout:)
        @stdin.write(JSON.generate("jsonrpc" => "2.0", "id" => id, "method" => method, "params" => params))
        @stdin.write("\n")
        @stdin.flush
        @reader.response_for(id, timeout: timeout)
      rescue IOError, Errno::EPIPE
        raise Error.new("server_exited", "MCP server closed STDIN before responding")
      end

      def result_or_raise(response, method)
        error = response[:error]
        raise Error.new("request_failed", "#{method} failed: #{safe_error_code(error)}") if error

        result = response[:result]
        raise Error.new("invalid_response", "#{method} result must be an object") unless result.is_a?(Hash)

        result
      end

      def normalize_tools(result, protocol, server_info)
        tools = result["tools"]
        unless tools.is_a?(Array) && tools.all? { |tool| tool.is_a?(Hash) && tool["name"].is_a?(String) }
          raise Error.new("invalid_tools_list", "tools/list response must contain named tools")
        end

        {
          protocol_version: protocol,
          server_info: safe_server_info(server_info),
          tools: tools.map { |tool| tool["name"] }.uniq.sort
        }
      end

      def safe_server_info(info)
        return nil unless info.is_a?(Hash)

        { name: info["name"], version: info["version"] }
      end

      def safe_error_code(error)
        error.is_a?(Hash) ? error["code"].to_s : "unknown"
      end

      def stop(waiter)
        pid = waiter.pid
        Process.kill("TERM", -pid)
        return if waiter.join(0.25)

        Process.kill("KILL", -pid)
        waiter.join(0.25)
      rescue Errno::ESRCH
        waiter.join(0.25)
      end
    end

    class StreamableHttpProbe
      LOOPBACK_HOSTS = %w[localhost 127.0.0.1 ::1].freeze

      def initialize(server_config, timeout:)
        @config = server_config
        @timeout = timeout
        @uri = URI.parse(server_config.fetch("url"))
      rescue URI::InvalidURIError, KeyError, TypeError
        raise Error.new("invalid_server_config", "HTTP MCP server requires a valid url")
      end

      def call
        validate_url!
        discovery = post("server/discover", { "_meta" => CLIENT_META }, 1)
        if discovery[:error]
          raise Error.new("protocol_incompatible", "HTTP MCP server does not support modern server/discover")
        end
        raise Error.new("invalid_discovery", "server/discover result must be an object") unless discovery[:result].is_a?(Hash)

        listed = post("tools/list", { "_meta" => CLIENT_META }, 2)
        result = listed[:result]
        raise Error.new("invalid_tools_list", "tools/list result must be an object") unless result.is_a?(Hash)

        tools = result["tools"]
        unless tools.is_a?(Array) && tools.all? { |tool| tool.is_a?(Hash) && tool["name"].is_a?(String) }
          raise Error.new("invalid_tools_list", "tools/list response must contain named tools")
        end

        {
          status: "healthy",
          transport: "streamable_http",
          protocol_version: MODERN_PROTOCOL,
          server_info: safe_server_info(discovery[:result]["serverInfo"]),
          tools: tools.map { |tool| tool["name"] }.uniq.sort,
          checked_at: Time.now.utc.iso8601
        }
      end

      private

      def validate_url!
        loopback = LOOPBACK_HOSTS.include?(@uri.host)
        unless @uri.is_a?(URI::HTTPS) || (@uri.is_a?(URI::HTTP) && loopback)
          raise Error.new("unsafe_url", "remote MCP URLs must use HTTPS; plain HTTP is allowed only on loopback")
        end
        raise Error.new("unsafe_url", "MCP URL must not contain embedded credentials") if @uri.user || @uri.password
        raise Error.new("unsafe_url", "MCP URL must not contain a fragment") if @uri.fragment
        raise Error.new("invalid_server_config", "MCP URL must include a host") unless @uri.host
      end

      def post(method, params, id)
        request = Net::HTTP::Post.new(@uri)
        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json, text/event-stream"
        request["MCP-Protocol-Version"] = MODERN_PROTOCOL
        request["Mcp-Method"] = method
        request.body = JSON.generate(
          "jsonrpc" => "2.0",
          "id" => id,
          "method" => method,
          "params" => params
        )

        response = Net::HTTP.start(
          @uri.host,
          @uri.port,
          use_ssl: @uri.is_a?(URI::HTTPS),
          open_timeout: @timeout,
          read_timeout: @timeout,
          write_timeout: @timeout,
          verify_mode: OpenSSL::SSL::VERIFY_PEER
        ) { |http| http.request(request) }

        case response.code.to_i
        when 200..299
          parse_response(response)
        when 401, 403
          raise Error.new("authorization_required", "HTTP MCP server requires authorization")
        else
          raise Error.new("http_unavailable", "HTTP MCP server returned status #{response.code}")
        end
      rescue Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout
        raise Error.new("timeout", "timed out waiting for HTTP MCP server")
      rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        raise Error.new("unavailable", "HTTP MCP server could not be reached")
      end

      def parse_response(response)
        body = response.body.to_s
        if response["content-type"].to_s.include?("text/event-stream")
          body = body.lines.filter_map { |line| line.delete_prefix("data:").strip if line.start_with?("data:") }.last.to_s
        end
        parsed = JSON.parse(body)
        raise Error.new("invalid_protocol_output", "HTTP MCP response must be a JSON object") unless parsed.is_a?(Hash)

        if parsed["error"]
          { error: parsed["error"] }
        else
          { result: parsed["result"] }
        end
      rescue JSON::ParserError
        raise Error.new("invalid_protocol_output", "HTTP MCP server returned a non-JSON response")
      end

      def safe_server_info(info)
        return nil unless info.is_a?(Hash)

        { name: info["name"], version: info["version"] }
      end
    end

    class Runner
      def initialize(config_path:, policy_path:, server:, tool:, profile:, environment:, isolated:, cwd: nil,
                     timeout: DEFAULT_TIMEOUT, probe: false)
        @config_path = config_path
        @policy = Policy.new(policy_path)
        @server_name = server
        @tool_name = tool
        @profile = profile
        @environment = environment
        @isolated = isolated
        @cwd = cwd
        @timeout = timeout
        @probe = probe
      end

      def call
        raise Error.new("probe_confirmation_required", "pass --probe to start the configured MCP server or contact its URL") unless @probe

        configuration = JSON.parse(File.read(@config_path, encoding: "UTF-8"))
        servers = configuration.fetch("mcpServers")
        server_config = servers.fetch(@server_name) do
          raise Error.new("server_not_configured", "MCP server #{@server_name} is not registered in #{@config_path}")
        end
        raise Error.new("invalid_server_config", "server registration must be a mapping") unless server_config.is_a?(Hash)

        health = probe_server(server_config)
        unless health[:status] == "healthy"
          return report(health, { decision: "unavailable", reason: health[:reason] || health[:status] })
        end

        unless health[:tools].include?(@tool_name)
          return report(health, { decision: "unavailable", reason: "requested tool is not present in the live tools/list response" })
        end

        permission = @policy.evaluate(
          server: @server_name,
          tool: @tool_name,
          profile: @profile,
          environment: @environment,
          isolated: @isolated
        )
        report(health, permission)
      rescue JSON::ParserError => e
        raise Error.new("invalid_client_config", "MCP client config is not valid JSON: #{e.message}")
      rescue KeyError => e
        raise Error.new("invalid_client_config", "MCP client config is missing #{e.key}")
      end

      private

      def probe_server(config)
        if config["command"]
          StdioProbe.new(config, cwd: @cwd, timeout: @timeout).call
        elsif config["url"]
          raise Error.new("unsupported_http_auth", "preflight HTTP checks do not perform OAuth; authenticate with the MCP host first") if config["headers"]
          StreamableHttpProbe.new(config, timeout: @timeout).call
        else
          raise Error.new("unsupported_transport", "server registration must provide command (STDIO) or url (Streamable HTTP)")
        end
      rescue Error => e
        {
          status: e.code == "authorization_required" ? "authorization_required" : "unavailable",
          transport: config["command"] ? "stdio" : "streamable_http",
          reason: "#{e.code}: #{e.message}",
          tools: [],
          checked_at: Time.now.utc.iso8601
        }
      end

      def report(health, permission)
        {
          schema_version: 1,
          server: @server_name,
          tool: @tool_name,
          profile: @profile,
          environment: @environment,
          isolated: @isolated,
          health: health,
          decision: permission[:decision],
          capability: permission[:capability],
          reason: permission[:reason],
          tool_invoked: false
        }
      end
    end
  end
end
