# frozen_string_literal: true

require "json"

class McpPreflightFakeServer
  def initialize
    @options = JSON.parse(ENV.fetch("MCP_PREFLIGHT_FAKE_SERVER_OPTIONS"))
    counter_path = ENV.fetch("MCP_PREFLIGHT_CALLS")
    @calls = File.exist?(counter_path) ? File.read(counter_path).to_i : 0
    File.write(counter_path, (@calls + 1).to_s)
  end

  def run
    pause_first_discovery if @options["silence_first_discovery"] && @calls.zero?
    $stdin.each_line { |line| write_response(JSON.parse(line)) }
  end

  private

  def pause_first_discovery
    $stdin.readline
    sleep 60
  end

  def write_response(request)
    exit 0 if @options["exit_early"]

    response = response_for(request)
    return unless response

    $stdout.puts("#{JSON.generate(response)}")
    $stdout.flush
  end

  def response_for(request)
    case request["method"]
    when "server/discover" then discovery_response(request)
    when "initialize" then legacy_response(request)
    when "tools/list" then tools_response(request)
    end
  end

  def discovery_response(request)
    return method_not_found(request) unless @options.fetch("modern", true)

    { "jsonrpc" => "2.0", "id" => request["id"], "result" => discovery_result }
  end

  def discovery_result
    {
      "resultType" => "complete",
      "supportedVersions" => @options.fetch("supported_versions", ["2026-07-28"]),
      "capabilities" => tool_capabilities,
      "cacheScope" => "public",
      "ttlMs" => 30_000,
      "_meta" => { "io.modelcontextprotocol/serverInfo" => server_info }
    }
  end

  def tool_capabilities
    @options.fetch("supports_tools", true) ? { "tools" => {} } : {}
  end

  def server_info
    { "name" => "test-server", "version" => "1.0" }
  end

  def method_not_found(request)
    {
      "jsonrpc" => "2.0",
      "id" => request["id"],
      "error" => { "code" => -32_601, "message" => "Method not found" }
    }
  end

  def legacy_response(request)
    result = {
      "protocolVersion" => "2025-11-25",
      "capabilities" => { "tools" => {} },
      "serverInfo" => { "name" => "legacy-test-server", "version" => "1.0" }
    }
    { "jsonrpc" => "2.0", "id" => request["id"], "result" => result }
  end

  def tools_response(request)
    pages = @options.fetch("tool_pages", [@options.fetch("tools", [])])
    cursor = request.dig("params", "cursor")
    index = cursor ? cursor.to_i : 0
    result = { "tools" => pages.fetch(index).map { |name| { "name" => name } } }
    add_next_cursor(result, pages, index)
    { "jsonrpc" => "2.0", "id" => request["id"], "result" => result }
  end

  def add_next_cursor(result, pages, index)
    result["nextCursor"] = (index + 1).to_s if index + 1 < pages.length
  end
end

McpPreflightFakeServer.new.run
