# frozen_string_literal: true

# Tool implementations for the ruby-agent-skills MCP server.

module RubyAgentSkills
  module MCP
    class Server
      def initialize(root: MCP.default_root)
        @root = root
        @manifest = Manifests.load(root)
      end

      def tool_definitions
        # Each spec is already the wire shape (name/description/inputSchema).
        TOOL_SPECS
      end

      def call_tool(name, args)
        case name
        when "list_skills" then list_skills
        when "get_skill" then get_skill(args)
        when "route_prompt" then route_prompt(args)
        when "list_companions" then list_companions
        when "route_cross_pack" then route_cross_pack(args)
        else raise ToolError, "unknown tool: #{name}"
        end
      end

      private

      def pack_info
        pack = @manifest["pack"].to_h
        { name: pack["name"] || @manifest["name"], language: pack["language"] || "ruby",
          runtime: pack["runtime"] }
      end

      def list_skills
        {
          pack: pack_info,
          schema_version: @manifest["schema_version"],
          skills: @manifest.fetch("skills").map { |name, entry| skill_summary(name, entry) },
          skills_root: File.join(@root, "skills")
        }
      end

      def skill_summary(name, entry)
        {
          name: name, family: entry["family"], path: entry["path"],
          language: entry.fetch("language", "ruby"), version: entry["version"],
          category: entry["category"], schema_version: entry["schema_version"],
          companion_owners: entry["companion_owners"],
          trigger_count: Array(entry["triggers"]).length
        }
      end

      def get_skill(args)
        name = args.fetch("name").to_s
        entry = @manifest.fetch("skills")[name]
        raise ToolError, "skill not found: #{name}" unless entry

        path = File.join(@root, entry.fetch("path"))
        raise ToolError, "skill file missing: #{entry.fetch('path')}" unless File.file?(path)

        { name: name, path: entry.fetch("path"), family: entry["family"],
          text: File.read(path, encoding: "UTF-8") }
      end

      def route_prompt(args)
        prompt = args.fetch("prompt").to_s
        active = Languages.for_file(args["file"])
        routed = Routing.route(@manifest, prompt, active)
        routed.merge(
          prompt: prompt,
          active_language: active,
          secondaries: Routing.secondaries_for(@root, routed[:primary]),
          skills_root: File.join(@root, "skills")
        )
      end

      def list_companions
        {
          pack: pack_info,
          companions: cross_pack["companions"] || [],
          name_collisions: cross_pack["name_collisions"] || [],
          seam_contracts: cross_pack["seam_contracts"] || [],
          snapshots_root: File.join(@root, "data", "cross-pack")
        }
      end

      def cross_pack
        @manifest.fetch("cross_pack", {})
      end

      def route_cross_pack(args)
        prompt = args.fetch("prompt").to_s
        active = Languages.for_file(args["file"])
        results = pack_results(prompt, active, args["packs"])
        overall = CrossPackRouting.overall_candidates(results)
        result = CrossPackRouting.result(prompt, active, results, overall)
        result.merge(companion_owners: companion_owners_for(overall[0]))
      end

      def pack_results(prompt, active, explicit_packs)
        results = [CrossPackRouting.route_pack(@root, prompt, active)]
        CompanionRoots.discover(@root, @manifest, explicit_packs).each do |root|
          results << CrossPackRouting.route_pack(root, prompt, active)
        end
        results
      end

      def companion_owners_for(candidate)
        entry = candidate ? @manifest.fetch("skills")[candidate[:name]] : nil
        entry ? Array(entry["companion_owners"]) : []
      end
    end
  end
end
