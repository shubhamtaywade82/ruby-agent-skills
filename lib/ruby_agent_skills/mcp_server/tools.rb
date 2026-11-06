# frozen_string_literal: true

# Tool specs (names, descriptions, JSON schemas) for the ruby-agent-skills
# MCP server. Kept as data so Server#tool_definitions stays a one-liner.

module RubyAgentSkills
  module MCP
    EMPTY_SCHEMA = { type: "object", properties: {}, additionalProperties: false }.freeze

    NAME_SCHEMA = {
      type: "object",
      properties: { name: { type: "string",
                            description: "kebab-case skill name, e.g. rails-active-record" } },
      required: ["name"],
      additionalProperties: false
    }.freeze

    ROUTE_SCHEMA = {
      type: "object",
      properties: {
        prompt: { type: "string" },
        file: { type: "string",
                description: "active file path; boosts skills matching its language" }
      },
      required: ["prompt"],
      additionalProperties: false
    }.freeze

    CROSS_ROUTE_SCHEMA = {
      type: "object",
      properties: {
        prompt: { type: "string" },
        file: { type: "string",
                description: "active file path; boosts skills matching its language" },
        packs: { type: "array", items: { type: "string" },
                 description: "companion pack roots to consult" }
      },
      required: ["prompt"],
      additionalProperties: false
    }.freeze

    TOOLS_DESCRIPTIONS = {
      list_skills: "List every skill in ruby-agent-skills with family, path, language, version, " \
                   "and companion owners.",
      get_skill: "Load one SKILL.md by skill name.",
      route_prompt: "Route a task prompt to the primary ruby/rails skill plus " \
                    "secondaries and candidates.",
      list_companions: "List declared companion packs, name collisions, and seam contracts " \
                       "from the cross_pack manifest section.",
      route_cross_pack: "Route a prompt across this pack and any installed companion packs " \
                        "(node-agent-skills, react-agent-skills), with language boosting " \
                        "and seam recommendations."
    }.freeze

    class Server
      def self.tool_spec(name, description_key, schema)
        {
          name: name,
          description: TOOLS_DESCRIPTIONS.fetch(description_key),
          inputSchema: schema
        }
      end

      TOOL_SPECS = [
        tool_spec("list_skills", :list_skills, EMPTY_SCHEMA),
        tool_spec("get_skill", :get_skill, NAME_SCHEMA),
        tool_spec("route_prompt", :route_prompt, ROUTE_SCHEMA),
        tool_spec("list_companions", :list_companions, EMPTY_SCHEMA),
        tool_spec("route_cross_pack", :route_cross_pack, CROSS_ROUTE_SCHEMA)
      ].freeze
    end
  end
end
