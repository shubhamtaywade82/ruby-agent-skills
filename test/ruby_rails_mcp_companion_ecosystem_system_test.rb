# frozen_string_literal: true

require "minitest/autorun"

# System tests for the companion MCP ecosystem catalogue in
# skills/agent-workflow/references/ruby-rails-mcp-tools.md and the
# extended capability vocabulary in mcp-governance-and-preflight.md.
# The original seven-server surface lives in
# test/ruby_rails_mcp_tools_reference_system_test.rb; this file owns the
# broader companion ecosystem (rails-ai-context, coatepec, hitch-rails, etc.)
# so the original class stays within its size budget.
class RubyRailsMcpCompanionEcosystemSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def source(path)
    File.read(File.join(ROOT, path), encoding: "UTF-8")
  end

  def guide
    @guide ||= source("skills/agent-workflow/references/ruby-rails-mcp-tools.md")
  end

  def test_security_contract_covers_companion_ecosystem_categories
    controls = [
      "Database administration", "Browser automation",
      "Version-control writes", "Error-monitoring reads", "External context"
    ]

    controls.each { |control| assert_includes guide, control }
  end

  def test_reference_catalogues_rails_context_introspection_alternatives
    %w[rails-ai-context rails-ai-bridge active_mcp rails-ai-agents].each do |name|
      assert_includes guide, name
    end
  end

  def test_reference_catalogues_runtime_interaction_alternatives
    assert_includes guide, "mcp_on_ruby"
  end

  def test_reference_catalogues_testing_and_verification_mcps
    assert_includes guide, "coatepec"
    assert_includes guide, "Task Completion Verifier MCP"
    assert_includes guide, "rails-agent-skills (Testing MCP)"
  end

  def test_reference_catalogues_external_rails_skills_packs
    %w[37signals-skills rails-skills majestic-rails rails-cto superpowers-ruby].each do |name|
      assert_includes guide, name
    end
  end

  def test_reference_catalogues_cross_stack_infrastructure_mcps
    %w[DevDb Context7].each do |name|
      assert_includes guide, name
    end
    %w[Postgres MCP Pro Playwright MCP GitHub MCP
       Sentry MCP Sequential Thinking web-dev-mcp-gateway
       ruby-postgres-mcp-server].each do |name|
      assert_includes guide, name
    end
  end

  def test_reference_catalogues_custom_mcp_server_libraries
    %w[fast-mcp ruby_llm-mcp mcp_rails_template].each do |name|
      assert_includes guide, name
    end
    assert_includes guide, "mcp (Official Ruby SDK)"
  end

  def test_reference_catalogues_authentication_security_libraries
    assert_includes guide, "hitch-rails"
  end

  def test_reference_documents_recommended_agent_native_stack
    layers = [
      "Routing & conventions", "Context", "Conventions", "Runtime",
      "Verification", "Production integration", "Security"
    ]

    layers.each { |layer| assert_includes guide, "**#{layer}" }
  end

  def test_install_scope_table_includes_companion_servers
    %w[rails-ai-context active_mcp mcp_on_ruby coatepec hitch-rails].each do |name|
      assert_includes guide, name
    end
  end

  def test_governance_reference_extends_capability_vocabulary
    governance = source("skills/agent-workflow/references/mcp-governance-and-preflight.md")

    %w[database_admin browser_automation version_control_write
       external_context_fetch].each do |capability|
      assert_includes governance, capability
    end
  end

  def test_governance_reference_documents_new_profiles
    governance = source("skills/agent-workflow/references/mcp-governance-and-preflight.md")

    %w[database_admin browser_automation version_control external_context].each do |profile|
      assert_includes governance, "`#{profile}`"
    end
  end

  def test_permissions_policy_classifies_companion_ecosystem_tools
    policy = source("mcp/permissions.yml")

    %w[postgres-mcp-pro devdb ruby-postgres-mcp-server playwright
       web-dev-mcp-gateway github sentry context7 sequential-thinking].each do |server|
      assert_includes policy, server
    end
  end

  def test_permissions_policy_extends_isolated_capabilities
    policy = source("mcp/permissions.yml")

    %w[database_admin_write browser_automation_write version_control_write
       external_context_fetch].each do |capability|
      assert_includes policy, capability
    end
  end

  def test_validator_executes_this_system_test
    assert_includes source("bin/validate"),
                    "test/ruby_rails_mcp_companion_ecosystem_system_test.rb"
  end
end
