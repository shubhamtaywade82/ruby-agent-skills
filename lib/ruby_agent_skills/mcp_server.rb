# frozen_string_literal: true

# MCP (Model Context Protocol) server for ruby-agent-skills.
#
# JSON-RPC 2.0 over stdio, stdlib only (json + yaml). Mirrors the companion
# node-agent-skills MCP server's tool surface so an agent runtime can wire
# both packs with the same client code. See docs/CLAUDE_CODE_INTEGRATION.md.
#
# Environment:
#   RUBY_AGENT_SKILLS_ROOT  override the pack root (default: this repo)
#   AGENT_SKILLS_PACKS      colon- or comma-separated companion pack roots,
#                           consulted by route_cross_pack in addition to
#                           sibling directories of this pack's root.

require "json"
require "yaml"

module RubyAgentSkills
  module MCP
    PROTOCOL_VERSION = "2024-11-05"
    SERVER_NAME = "ruby-agent-skills"
    SERVER_VERSION = "1.0.0"

    class ToolError < StandardError; end

    module_function

    def default_root
      env = ENV.fetch("RUBY_AGENT_SKILLS_ROOT", "")
      return File.expand_path(env) unless env.strip.empty?

      File.expand_path("../..", __dir__)
    end

    # ------------------------------------------------------- languages ----

    module Languages
      JS_FAMILY = %w[typescript javascript].freeze
      EXT_LANGUAGE = {
        "rb" => "ruby", "erb" => "ruby", "gemspec" => "ruby", "rake" => "ruby",
        "ts" => "typescript", "tsx" => "typescript", "mts" => "typescript", "cts" => "typescript",
        "js" => "javascript", "jsx" => "javascript", "mjs" => "javascript", "cjs" => "javascript"
      }.freeze
      FILE_LANGUAGE = {
        "Gemfile" => "ruby", "Rakefile" => "ruby", "config.ru" => "ruby",
        "package.json" => "javascript"
      }.freeze

      module_function

      def for_file(file)
        return nil if file.nil? || file.to_s.strip.empty?

        basename = File.basename(file.to_s)
        return FILE_LANGUAGE.fetch(basename) if FILE_LANGUAGE.key?(basename)

        EXT_LANGUAGE.fetch(File.extname(basename).delete_prefix("."), nil)
      end

      def match?(active, skill_language)
        return false if active.nil? || skill_language.nil?

        family?(active) && family?(skill_language) ? true : active.to_s == skill_language.to_s
      end

      # Matching languages are boosted (x2) and non-matching demoted (x0.5).
      # Boost-only would leave ties that alphabetical pack order resolves.
      def adjusted_score(base, active, skill_language)
        return base if active.nil?

        match?(active, skill_language) ? base * 2 : base * 0.5
      end

      def family?(language)
        JS_FAMILY.include?(language.to_s)
      end
    end

    # --------------------------------------------------------- scoring ----

    module Scoring
      module_function

      def score(triggers, prompt)
        text = " #{normalize(prompt)} "
        triggers.sum { |trigger| trigger_score(trigger, text) }
      end

      def normalize(prompt)
        prompt.downcase.split(/[^a-z0-9-]+/).reject(&:empty?).uniq.join(" ")
      end

      def trigger_score(trigger, text)
        # YAML may type bare values (1.3 -> Float, 5 -> Integer); normalize.
        term = trigger.to_s.downcase
        if text.include?(" #{term} ") || text.include?(" #{term},")
          term.include?(" ") ? 2 : 1
        elsif text.include?(term)
          0.5
        else
          0
        end
      end
    end

    # ------------------------------------------------------- manifests ----

    module Manifests
      PACK_SECTIONS = %w[skills adapter_skills].freeze
      SCALAR_FIELDS = %w[family category language version].freeze

      module_function

      def load(root)
        path = File.join(root, "skill-manifest.yml")
        YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
      end

      def name_for(root, manifest)
        manifest["pack"].to_h["name"] || manifest["name"] || File.basename(root)
      end

      def language_for(manifest)
        manifest["pack"].to_h["language"] || "unknown"
      end

      # Parse any v3 pack manifest's skills section (mapping form like this
      # pack, or sequence form like node-agent-skills), scoped to the
      # skills:/adapter_skills: sections only.
      def pack_skills(root)
        path = File.join(root, "skill-manifest.yml")
        return [] unless File.file?(path)

        parser = SkillsParser.new
        parser.parse(path)
      end

      # Stateful line parser for the scoped skills section of a manifest.
      class SkillsParser
        def initialize
          @section = nil
          @current = nil
          @in_owners = false
          @skills = []
        end

        def parse(path)
          File.foreach(path, encoding: "UTF-8") { |raw| consume(raw.chomp) }
          @skills.each { |skill| skill[:path] ||= "skills/#{skill[:name]}/SKILL.md" }
        end

        private

        def consume(line)
          header = section_header(line)
          if header == :other
            @section = nil
          elsif header
            @section = header
            @current = nil
          elsif @section
            consume_field(line)
          end
        end

        # :other marks a top-level key outside skills:/adapter_skills:.
        def section_header(line)
          match = line.match(/\A([a-z_][a-z0-9_]*):\z/)
          return nil if match.nil?

          Manifests::PACK_SECTIONS.include?(match[1]) ? match[1] : :other
        end

        def consume_field(line)
          name = entry_name(line)
          if name
            @current = { name: name, triggers: [] }
            @skills << @current
            @in_owners = false
          elsif @current
            apply_field(line)
          end
        end

        def entry_name(line)
          mapping = line.match(/\A  ([a-z0-9-]+):\z/)
          return mapping[1] if mapping

          sequence = line.match(/\A  - name: ([a-z0-9-]+)\z/)
          sequence && sequence[1]
        end

        def apply_field(line)
          item = owner_item(line)
          return if record_owner?(item)

          @in_owners = false
          field = line.match(/\A    ([a-z_]+):(.*)\z/)
          return if field.nil?

          assign(field[1], field[2].strip)
        end

        def owner_item(line)
          @in_owners ? line.match(/\A      - (.+)\z/) : nil
        end

        def record_owner?(item)
          return false if item.nil?

          append_owner(item)
          true
        end

        def append_owner(item)
          @current[:companion_owners] << item[1].strip
        end

        def assign(key, value)
          if key == "triggers"
            @current[:triggers] = split_triggers(value)
          elsif key == "companion_owners"
            @current[:companion_owners] = []
            @in_owners = true
          elsif Manifests::SCALAR_FIELDS.include?(key) || key == "path"
            @current[key.to_sym] = value
          end
        end

        def split_triggers(value)
          value.delete_prefix("[").delete_suffix("]").split(",").map(&:strip).reject(&:empty?)
        end
      end
    end

    # ---------------------------------------------------- companions ------

    module CompanionRoots
      module_function

      def discover(base_root, manifest, explicit)
        roots = Array(explicit).flat_map { |entry| split_roots(entry) }
        roots.concat(split_roots(ENV.fetch("AGENT_SKILLS_PACKS", "")))
        roots.concat(sibling_roots(base_root, manifest))
        roots.uniq.reject { |root| root == base_root }.select { |root| manifest?(root) }
      end

      def split_roots(value)
        value.to_s.split(/[,:]/).map(&:strip).reject(&:empty?).map { |path| File.expand_path(path) }
      end

      def sibling_roots(base_root, manifest)
        companions = Array(manifest.fetch("cross_pack", {})["companions"])
        companions.map do |companion|
          File.expand_path(File.join(base_root, "..", companion.fetch("pack")))
        end
      end

      def manifest?(root)
        File.file?(File.join(root, "skill-manifest.yml"))
      end
    end

    # --------------------------------------------------------- routing ----

    module Routing
      module_function

      def route(manifest, prompt, active_language)
        pack_language = manifest["pack"].to_h["language"] || "ruby"
        scored = scored_candidates(manifest, prompt, active_language, pack_language)
        top = top_candidates(scored)
        { primary: top[0]&.fetch(:name), candidates: top.first(5) }
      end

      def scored_candidates(manifest, prompt, active_language, pack_language)
        skills_entries(manifest).map do |name, entry|
          candidate(name, entry, prompt, active_language, pack_language)
        end
      end

      def top_candidates(scored)
        scored.select { |s| s[:score] >= 1 }.sort_by { |s| [-s[:score], s[:name]] }
      end

      # Normalize both manifest entry shapes to [name, entry] pairs:
      # mapping form (ruby: skills: name: {...}) and sequence form
      # (node: skills: - name: ...). The skills: and adapter_skills:
      # sections both contribute entries.
      def skills_entries(manifest)
        entries = []
        Manifests::PACK_SECTIONS.each do |section|
          entries.concat(section_entries(manifest[section]))
        end
        entries
      end

      def section_entries(value)
        return [] if value.nil?

        if value.is_a?(Hash)
          value.to_a
        else
          Array(value).filter_map do |entry|
            [entry["name"], entry] if entry.is_a?(Hash) && entry["name"]
          end
        end
      end

      def candidate(name, entry, prompt, active_language, pack_language)
        base = Scoring.score(Array(entry["triggers"]), prompt)
        language = entry.fetch("language", pack_language)
        {
          name: name,
          family: entry["family"],
          language: language,
          score: Languages.adjusted_score(base, active_language, language).round(2),
          base_score: base.round(2)
        }
      end

      def route_pack(root, prompt, active_language)
        manifest = Manifests.load(root)
        routed = route(manifest, prompt, active_language)
        routed.merge(
          root: root,
          pack: { name: Manifests.name_for(root, manifest),
                  language: Manifests.language_for(manifest) }
        )
      end

      def secondaries_for(manifest_root, primary)
        return [] if primary.nil?

        path = File.join(manifest_root, "router", "ROUTING_CASES.yml")
        return [] unless File.file?(path)

        cases = YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [],
                                                                   aliases: false)
        match = Array(cases["cases"]).find do |routing_case|
          Array(routing_case["primary_skills"]).include?(primary)
        end
        match ? Array(match["secondary_skills"]) : []
      end
    end
  end
end

# The Server class, tool specs, and stdio protocol live in sibling files;
# they are required after the MCP module above so the constants resolve.
require_relative "mcp_server/server"
require_relative "mcp_server/tools"
require_relative "mcp_server/cross_pack_routing"
require_relative "mcp_server/protocol"
