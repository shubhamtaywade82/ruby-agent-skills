# frozen_string_literal: true

require "yaml"

module RubyAgentSkills
  class FrameworkDriftRegistry
    REQUIRED_FIELDS = %w[
      framework status version symbol match
      replacement source_url source_section
    ].freeze

    def initialize(path)
      @data = YAML.safe_load(
        File.read(path, encoding: "UTF-8"),
        permitted_classes: [],
        aliases: false
      )
    end

    def entries
      @data.fetch("entries")
    end

    def roots
      @data.fetch("policy").fetch("scan_roots")
    end

    def validation_errors
      entries.flat_map { |id, entry| validate_entry(id, entry) }
    end

    private

    def validate_entry(id, entry)
      return ["entry #{id} must be a mapping"] unless entry.is_a?(Hash)

      errors = REQUIRED_FIELDS.filter_map do |field|
        "entry #{id} missing #{field}" if entry[field].to_s.strip.empty?
      end
      errors.concat(validate_match(id, entry))
      errors << "entry #{id} source_url must be HTTPS" unless entry["source_url"].to_s.start_with?("https://")
      errors
    end

    def validate_match(id, entry)
      Regexp.new(entry.fetch("match"))
      []
    rescue RegexpError => e
      ["entry #{id} has invalid match: #{e.message}"]
    end
  end

  class FrameworkDriftScanner
    RUBY_BLOCK = /^\x60\x60\x60(?:ruby|rb)\s*\n(.*?)^\x60\x60\x60\s*$/m

    def initialize(root:, entries:, scan_roots:)
      @root = root
      @entries = entries
      @scan_roots = scan_roots
    end

    def call
      @scan_roots.flat_map { |relative| scan_root(relative) }
    end

    private

    def scan_root(relative)
      path = File.join(@root, relative)
      return [] unless Dir.exist?(path)

      Dir[File.join(path, "**", "*.md")].flat_map { |file| scan_file(file) }
    end

    def scan_file(path)
      text = File.read(path, encoding: "UTF-8")
      ruby_blocks(text).flat_map { |start, lines| scan_block(path, start, lines) }
    end

    def ruby_blocks(text)
      text.enum_for(:scan, RUBY_BLOCK).map do
        match = Regexp.last_match
        [text[0...match.begin(1)].count("\n") + 1, match[1].lines]
      end
    end

    def scan_block(path, start_line, lines)
      @entries.flat_map do |id, entry|
        next [] if suppressed?(id, lines)

        matcher = Regexp.new(entry.fetch("match"))
        lines.each_with_index.filter_map do |line, offset|
          next unless matcher.match?(line)

          finding(path, start_line + offset, id, entry)
        end
      end
    end

    def suppressed?(id, lines)
      lines.any? do |line|
        line.match?(/^\s*#\s*framework-drift:\s*allow\s+#{Regexp.escape(id)}(?:\s|$)/)
      end
    end

    def finding(path, line, id, entry)
      relative = path.delete_prefix("#{@root}/")
      format(
        "%<relative>s:%<line>d: framework drift %<id>s (%<status>s Rails %<version>s) uses %<symbol>s; replace with %<replacement>s",
        relative: relative,
        line: line,
        id: id,
        status: entry.fetch("status"),
        version: entry.fetch("version"),
        symbol: entry.fetch("symbol"),
        replacement: entry.fetch("replacement")
      )
    end
  end

  class FrameworkDriftAudit
    def initialize(root:, registry_path:)
      @registry = FrameworkDriftRegistry.new(registry_path)
      @scanner = FrameworkDriftScanner.new(
        root: root,
        entries: @registry.entries,
        scan_roots: @registry.roots
      )
    end

    def call
      errors = @registry.validation_errors + @scanner.call
      return success_message if errors.empty?

      errors.each { |error| warn "ERROR: #{error}" }
      abort "#{errors.length} framework drift finding(s)"
    end

    private

    def success_message
      roots = @registry.roots.length
      [
        "Framework drift audit passed: #{@registry.entries.length} registry entries scanned",
        "across #{roots} roots."
      ].join(" ")
    end
  end
end
