# frozen_string_literal: true

require "yaml"

module RubyAgentSkills
  class FrameworkDriftAudit
    REQUIRED_FIELDS = %w[
      framework status version symbol match
      replacement source_url source_section
    ]
    RUBY_BLOCK = /^```(?:ruby|rb)\s*\n(.*?)^```\s*$/m

    def initialize(root:, registry_path:)
      @root = root
      @registry = YAML.safe_load(
        File.read(registry_path, encoding: "UTF-8"),
        permitted_classes: [],
        aliases: false
      )
      @errors = []
    end

    def call
      validate_registry
      scan_roots
      return success_message if @errors.empty?

      @errors.each { |error| warn "ERROR: #{error}" }
      abort "#{@errors.length} framework drift finding(s)"
    end

    private

    def entries
      @registry.fetch("entries")
    end

    def validate_registry
      entries.each { |id, entry| validate_entry(id, entry) }
    end

    def validate_entry(id, entry)
      return @errors << "entry #{id} must be a mapping" unless entry.is_a?(Hash)

      REQUIRED_FIELDS.each do |field|
        @errors << "entry #{id} missing #{field}" if entry[field].to_s.strip.empty?
      end

      Regexp.new(entry.fetch("match"))
    rescue RegexpError => e
      @errors << "entry #{id} has invalid match: #{e.message}"
    end

    def scan_roots
      @registry.fetch("policy").fetch("scan_roots").each { |root| scan_root(root) }
    end

    def scan_root(relative)
      path = File.join(@root, relative)
      return unless Dir.exist?(path)

      Dir[File.join(path, "**", "*.md")].each { |file| scan_file(file) }
    end

    def scan_file(path)
      text = File.read(path, encoding: "UTF-8")
      ruby_blocks(text).each { |start_line, lines| scan_block(path, start_line, lines) }
    end

    def ruby_blocks(text)
      text.enum_for(:scan, RUBY_BLOCK).map do
        match = Regexp.last_match
        line = text[0...match.begin(1)].count("\n") + 1
        [line, match[1].lines]
      end
    end

    def scan_block(path, start_line, lines)
      entries.each do |id, entry|
        next if suppressed?(id, lines)

        matcher = Regexp.new(entry.fetch("match"))
        lines.each_with_index do |line, offset|
          add_finding(path, start_line + offset, id, entry) if matcher.match?(line)
        end
      end
    end

    def suppressed?(id, lines)
      lines.any? do |line|
        line.match?(/^\s*#\s*framework-drift:\s*allow\s+#{Regexp.escape(id)}(?:\s|$)/)
      end
    end

    def add_finding(path, line, id, entry)
      relative = path.delete_prefix("#{@root}/")
      replacement = entry.fetch("replacement")
      details = entry.fetch("symbol")
      @errors << "#{relative}:#{line}: framework drift #{id} "                 "(#{entry.fetch('status')} Rails #{entry.fetch('version')}) "                 "uses #{details}; replace with #{replacement}"
    end

    def success_message
      roots = @registry.fetch("policy").fetch("scan_roots").length
      "Framework drift audit passed: #{entries.length} registry entries scanned across #{roots} roots."
    end
  end
end
