# frozen_string_literal: true

require "minitest/autorun"

class RubyRailsMcpToolsReferenceSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def source(path)
    File.read(File.join(ROOT, path), encoding: "UTF-8")
  end

  def guide
    @guide ||= source("skills/agent-workflow/references/ruby-rails-mcp-tools.md")
  end

  def test_reference_covers_the_requested_external_servers
    %w[rails-mcp-server ruby-console-mcp ask-ruby-harness-mcp ask-rails-harness-mcp debug-mcp ActionMCP].each do |name|
      assert_includes guide, name
    end
    assert_includes guide, "@ruby-mcp/gems-mcp"
  end

  def test_rails_mcp_config_is_documented_as_an_executable_from_the_same_gem
    assert_includes guide, "`rails-mcp-config` is an executable installed by the `rails-mcp-server` gem"
    assert_includes guide, "not a separate gem"
  end

  def test_action_mcp_is_separated_from_local_stdio_servers
    assert_includes guide, "does **not** implement STDIO"
    assert_includes guide, "Ruby 3.4.8+ or 4.0.0+ and Rails 8.1.1+"
    assert_includes guide, "standalone Rack"
  end

  def test_rails_harness_is_project_root_and_bundler_scoped
    assert_includes guide, "bundle exec ask-rails-harness-mcp"
    assert_includes guide, "working directory (`cwd`)"
    assert_includes guide, "`run_command` executes shell commands"
  end

  def test_generic_and_rails_harnesses_are_not_treated_as_aliases
    assert_includes guide, "is the generic Ruby harness"
    assert_includes guide, "is the Rails-specific package"
  end

  def test_console_and_debugger_are_marked_as_arbitrary_code_execution
    assert_includes guide, "arbitrary Ruby execution with persistent state"
    assert_includes guide, "Debugger evaluation and process control can alter live application state"
  end

  def test_security_contract_covers_database_network_authorization_and_untrusted_output
    %w[Least\ privilege Environment\ isolation Database\ controls Network\ controls Application\ authorization Untrusted\ tool\ output Credential\ hygiene].each do |control|
      assert_includes guide, control
    end
  end

  def test_existing_pack_mcp_server_is_distinguished_from_application_tools
    assert_includes guide, "`bin/mcp-server`"
    assert_includes guide, "does not inspect a consuming Rails app's runtime"
  end

  def test_agent_workflow_and_routing_discover_the_reference
    assert_includes source("skills/agent-workflow/SKILL.md"), "references/ruby-rails-mcp-tools.md"
    assert_includes source("router/ROUTING.md"), "Ruby/Rails MCP developer-tool selection"
  end

  def test_documentation_entry_points_link_the_reference
    assert_includes source("README.md"), "skills/agent-workflow/references/ruby-rails-mcp-tools.md"
    assert_includes source("docs/CLAUDE_CODE_INTEGRATION.md"), "../skills/agent-workflow/references/ruby-rails-mcp-tools.md"
  end

  def test_validator_executes_this_system_test
    assert_includes source("bin/validate"), "test/ruby_rails_mcp_tools_reference_system_test.rb"
  end
end
