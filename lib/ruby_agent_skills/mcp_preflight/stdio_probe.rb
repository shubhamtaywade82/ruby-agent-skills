# frozen_string_literal: true

require "open3"

module RubyAgentSkills
  module MCPPreflight
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
        Open3.popen3(
          child_environment,
          @config.fetch("command"),
          *@config.fetch("args", []),
          chdir: @cwd,
          pgroup: true,
          err: File::NULL
        ) do |stdin, stdout, _stderr, waiter|
          protocol = StdioProtocol.new(stdin, JsonLineReader.new(stdout), timeout: @timeout)
          protocol.call.merge(
            status: "healthy",
            transport: "stdio",
            checked_at: Time.now.utc.iso8601
          )
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
        valid_command = command.is_a?(String) && !command.strip.empty?
        unless valid_command
          raise Error.new("invalid_server_config", "STDIO command must be a non-empty string")
        end
        unless valid_args?(args)
          raise Error.new("invalid_server_config", "STDIO args must be an array of strings")
        end
        unless Dir.exist?(@cwd)
          raise Error.new("invalid_working_directory", "MCP working directory does not exist")
        end
        unless valid_env?(@config.fetch("env", {}))
          raise Error.new("invalid_server_config", "MCP env must be a string mapping")
        end
        unless @config.fetch("inherit_env", []).is_a?(Array)
          raise Error.new("invalid_server_config", "inherit_env must be an array")
        end
      end

      def valid_args?(args)
        args.is_a?(Array) && args.all? { |arg| arg.is_a?(String) }
      end

      def valid_env?(env)
        env.is_a?(Hash) && env.all? do |key, value|
          key.to_s.match?(/\A[A-Za-z_][A-Za-z0-9_]*\z/) && value.is_a?(String)
        end
      end

      def child_environment
        inherited_keys = INHERITED_ENV + Array(@config["inherit_env"])
        inherited = inherited_keys.uniq.each_with_object({}) do |key, result|
          result[key] = ENV.fetch(key) if ENV.key?(key)
        end
        inherited.merge(@config.fetch("env", {}))
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
  end
end
