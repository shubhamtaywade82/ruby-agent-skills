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
        run_protocol(force_legacy: false)
      rescue Error => e
        raise unless e.code == "legacy_probe_required"

        run_protocol(force_legacy: true)
      rescue Errno::ENOENT
        raise Error.new("command_not_found", "configured MCP command could not be started")
      rescue Errno::EACCES
        raise Error.new("command_not_executable", "configured MCP command is not executable")
      end

      private

      def run_protocol(force_legacy:)
        Open3.popen3(
          child_environment,
          @config.fetch("command"),
          *@config.fetch("args", []),
          chdir: @cwd,
          pgroup: true,
          err: File::NULL
        ) do |stdin, stdout, _stderr, waiter|
          run_session(stdin, stdout, force_legacy)
        ensure
          cleanup_process(stdin, stdout, waiter)
        end
      end

      def run_session(stdin, stdout, force_legacy)
        protocol = StdioProtocol.new(stdin, JsonLineReader.new(stdout), timeout: @timeout)
        result = force_legacy ? protocol.legacy_call : protocol.call
        result.merge(
          status: "healthy",
          configured: true,
          transport: "stdio",
          checked_at: Time.now.utc.iso8601
        )
      end

      def cleanup_process(stdin, stdout, waiter)
        stop(waiter) if waiter
        stdout.close unless stdout.closed?
        stdin.close unless stdin.closed?
      end

      def validate_config!
        validate_command!
        validate_arguments!
        validate_working_directory!
        validate_environment!
        validate_inherited_environment!
      end

      def validate_command!
        command = @config["command"]
        valid = command.is_a?(String) && !command.strip.empty?
        return if valid

        raise Error.new("invalid_server_config", "STDIO command must be a non-empty string")
      end

      def validate_arguments!
        return if valid_args?(@config.fetch("args", []))

        raise Error.new("invalid_server_config", "STDIO args must be an array of strings")
      end

      def validate_working_directory!
        return if Dir.exist?(@cwd)

        raise Error.new("invalid_working_directory", "MCP working directory does not exist")
      end

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

      def valid_args?(args)
        args.is_a?(Array) && args.all?(String)
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
