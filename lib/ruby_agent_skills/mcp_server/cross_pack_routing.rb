# frozen_string_literal: true

# Cross-pack routing helpers for the ruby-agent-skills MCP server's
# route_cross_pack tool. Extracted from Server to keep both files focused.

module RubyAgentSkills
  module MCP
    module CrossPackRouting
      module_function

      # Route one pack (own or companion) against the prompt.
      def route_pack(root, prompt, active_language)
        manifest = Manifests.load(root)
        routed = Routing.route(manifest, prompt, active_language)
        routed.merge(
          root: root,
          pack: { name: Manifests.name_for(root, manifest),
                  language: Manifests.language_for(manifest) }
        )
      end

      def overall_candidates(results)
        results.flat_map { |result| pack_candidates(result) }
               .sort_by { |candidate| [-candidate[:score], candidate[:pack], candidate[:name]] }
      end

      def pack_candidates(result)
        result[:candidates].map do |candidate|
          candidate.merge(pack: result[:pack][:name], pack_root: result[:root])
        end
      end

      def result(prompt, active, results, overall)
        {
          prompt: prompt,
          active_language: active,
          packs: results,
          primary: overall[0]&.slice(:pack, :name, :score, :language, :path),
          candidates: candidate_summary(overall),
          seam: seam_for(results, overall),
          companion_owners: []
        }
      end

      def candidate_summary(overall)
        overall.first(8).map { |candidate| candidate.slice(:pack, :name, :score, :language) }
      end

      def seam_for(results, overall)
        seam_skill = overall.find { |candidate| candidate[:name].to_s.end_with?("-integration") }
        return multi_pack_seam(results) if seam_skill.nil?

        contract = seam_contract_for(results, seam_skill)
        contract ? contract_seam(contract) : skill_seam(seam_skill)
      end

      # The seam contract is looked up in the pack that OWNS the seam skill
      # (either side of a symmetric seam declares its own contract).
      def seam_contract_for(results, seam_skill)
        owner = results.find { |result| result[:primary] == seam_skill[:name] }
        return nil if owner.nil?

        cross_pack = Manifests.load(owner[:root]).fetch("cross_pack", {})
        Array(cross_pack["seam_contracts"]).find do |contract|
          contract["primary_in_this_pack"] == seam_skill[:name]
        end
      end

      def multi_pack_seam(results)
        primaries = results.count { |r| r[:primary] }
        return { recommended: false, reason: "single-pack task" } if primaries < 2

        { recommended: true,
          reason: "top candidates span multiple packs; consult router/ROUTING.md" }
      end

      def contract_seam(contract)
        {
          recommended: true,
          boundary: contract.fetch("boundary"),
          this_pack_seam: contract.fetch("primary_in_this_pack"),
          companion_pack: contract.fetch("companion_pack"),
          companion_side: contract.fetch("companion_side"),
          reason: "task routes to a cross-pack seam skill; load the companion side with it"
        }
      end

      def skill_seam(seam_skill)
        name = seam_skill[:name]
        { recommended: true, skill: name, reason: "task routes to an integration seam skill" }
      end
    end
  end
end
