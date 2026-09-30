# frozen_string_literal: true

require "optparse"
require "yaml"

class FrameworkDriftAudit
  REQUIRED_FIELDS = %w[framework status version symbol match replacement source_url source_section].freeze
  RUBY_FENCE = /^\x60\x60\x60(?:ruby|rb)\s*$/.freeze
  END_FENCE = /^\x60\x60\x60\s*$/.freeze

  def initialize(root:, registry_path:)
    @root = root
    @registry_path = registry_path
    @registry = YAML.safe_load(
      File.read(@registry_path, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
    @errors = []
  end

  def call
    validate_registry
    scan_roots
    report
  end

  private

  def validate_registry
    entries.each { |id, entry| validate_entry(id, entry) }
  end

  def validate_entry(id, entry)
    unless entry.is_a?(Hash)
      return @errors << "entry #{id} must be a mapping"
    end

    REQUIRED_FIELDS.each do |field|
      @errors << "entry #{id} missing #{field}" if entry[field].to_s.strip.empty?
    end
    validate_match(id, entry)
    @errors << "entry #{id} source_url must be HTTPS" unless entry["source_url"].to_s.start_with?("https://")
  end

  def validate_match(id, entry)
    Regexp.new(entry.fetch("match"))
  rescue RegexpError => e
    @errors << "entry #{id} has invalid match: #{e.message}"
  end

  def scan_roots
    registry.fetch("policy").fetch("scan_roots").each { |relative| scan_root(relative) }
  end

  def scan_root(relative)
    path = File.join(@root, relative)
    return unless Dir.exist?(path)

    Dir[File.join(path, "**", "*.md")].each { |file| scan_file(file) }
  end

  def scan_file(path)
    ruby_blocks(File.readlines(path, encoding: "UTF-8")).each do |start_line, block|
      scan_block(path, start_line, block)
    end
  end

  def ruby_blocks(lines)
    blocks = []
    start_line = nil
    block = []

    lines.each_with_index do |line, index|
      if start_line.nil? && line.match?(RUBY_FENCE)
        start_line = index + 2
        block = []
      elsif start_line && line.match?(END_FENCE)
        blocks << [start_line, block]
        start_line = nil
      elsif start_line
        block << line
      end
    end

    blocks
  end

  def scan_block(path, start_line, block)
    entries.each do |id, entry|
      next if suppressed?(id, block)

      matcher = Regexp.new(entry.fetch("match"))
      block.each_with_index do |line, offset|
        next unless matcher.match?(line)

        add_finding(path, start_line + offset, id, entry)
      end
    end
  end

  def suppressed?(id, block)
    block.any? do |line|
      line.match?(/^\s*#\s*framework-drift:\s*allow\s+#{Regexp.escape(id)}(?:\s|$)/)
    end
  end

  def add_finding(path, line, id, entry)
    relative = path.delete_prefix("#{@root}/")
    details = "#{entry.fetch('symbol')}; replace with #{entry.fetch('replacement')}"
    @errors << "#{relative}:#{line}: framework drift #{id} "               "(#{entry.fetch('status')} Rails #{entry.fetch('version')}) "               "uses #{details}"
  end

  def report
    abort_with_errors unless @errors.empty?
    puts "Framework drift audit passed: #{entries.length} registry entries "         "scanned across #{registry.fetch('policy').fetch('scan_roots').length} roots."
  end

  def abort_with_errors
    @errors.each { |error| warn "ERROR: #{error}" }
    abort "#{@errors.length} framework drift finding(s)"
  end

  def registry
    @registry
  end

  def entries
    registry.fetch("entries")
  end
end

root = File.expand_path("..", __dir__)
options = { root: root, registry: File.join(root, "framework-drift.yml") }

OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/audit_framework_drift.rb [--root PATH] [--registry PATH]"
  opts.on("--root PATH", "Repository root to scan") { |value| options[:root] = File.expand_path(value) }
  opts.on("--registry PATH", "Framework drift registry") { |value| options[:registry] = File.expand_path(value) }
end.parse!

abort "missing registry: #{options[:registry]}" unless File.file?(options[:registry])

FrameworkDriftAudit.new(
  root: options[:root],
  registry_path: options[:registry]
).call
