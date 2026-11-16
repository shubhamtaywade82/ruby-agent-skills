# frozen_string_literal: true

require "json"

options = JSON.parse(ENV.fetch("MCP_PREFLIGHT_FAKE_SERVER_OPTIONS"))
counter_path = ENV.fetch("MCP_PREFLIGHT_CALLS")
calls = File.exist?(counter_path) ? File.read(counter_path).to_i : 0
File.write(counter_path, (calls + 1).to_s)

if options["silence_first_discovery"] && calls.zero?
  STDIN.readline
  sleep 60
end

STDIN.each_line do |line|
  exit 0 if options["exit_early"]

  request = JSON.parse(line)
  response = build_response(request, options)
  next unless response

  STDOUT.write(JSON.generate(response))
  STDOUT.write("\n")
  STDOUT.flush
end

def build_response(request, options)
  case request["method"]
  when "server/discover"
    discovery_response(request, options)
  when "initialize"
    legacy_response(request)
  when "notifications/initialized"
    nil
  when "tools/list"
    tools_response(request, options)
  end
end

def discovery_response(request, options)
  return method_not_found(request) unless options.fetch("modern", true)

  capabilities = options.fetch("supports_tools", true) ? { "tools" => {} } : {}
  {
    "jsonrpc" => "2.0",
    "id" => request["id"],
    "result" => {
      "resultType" => "complete",
      "supportedVersions" => options.fetch("supported_versions", ["2026-07-28"]),
      "capabilities" => capabilities,
      "cacheScope" => "public",
      "ttlMs" => 30_000,
      "_meta" => {
        "io.modelcontextprotocol/serverInfo" => {
          "name" => "test-server",
          "version" => "1.0"
        }
      }
    }
  }
end

def method_not_found(request)
  {
    "jsonrpc" => "2.0",
    "id" => request["id"],
    "error" => { "code" => -32_601, "message" => "Method not found" }
  }
end

def legacy_response(request)
  {
    "jsonrpc" => "2.0",
    "id" => request["id"],
    "result" => {
      "protocolVersion" => "2025-11-25",
      "capabilities" => { "tools" => {} },
      "serverInfo" => { "name" => "legacy-test-server", "version" => "1.0" }
    }
  }
end

def tools_response(request, options)
  pages = options.fetch("tool_pages", [options.fetch("tools", [])])
  cursor = request.dig("params", "cursor")
  index = cursor ? cursor.to_i : 0
  next_cursor = (index + 1).to_s if index + 1 < pages.length
  result = { "tools" => pages.fetch(index).map { |name| { "name" => name } } }
  result["nextCursor"] = next_cursor if next_cursor
  { "jsonrpc" => "2.0", "id" => request["id"], "result" => result }
end
