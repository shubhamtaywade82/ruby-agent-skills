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
      ruby_blocks(text).flat_map { |start, block| scan_block(path, start, block) }
    end

    def ruby_blocks(text)
      blocks = []
      state = { start: nil, lines: [] }

      text.each_line.with_index do |line, index|
        state, block = advance_ruby_block(state, line, index)
        blocks << block if block
      end

      blocks
    end

    def advance_ruby_block(state, line, index)
      return open_ruby_block(index) if state[:start].nil? && line.match?(RUBY_FENCE)
      return close_ruby_block(state) if state[:start] && line.match?(END_FENCE)

      state[:lines] << line if state[:start]
      [state, nil]
    end

    def open_ruby_block(index)
      [{ start: index + 2, lines: [] }, nil]
    end

    def close_ruby_block(state)
      [{ start: nil, lines: [] }, [state[:start], state[:lines]]]
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
      format(
        FINDING_FORMAT.join,
        relative: path.delete_prefix("#{@root}/"),
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
