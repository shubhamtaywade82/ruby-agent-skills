#!/usr/bin/env ruby
# frozen_string_literal: true

# Local Markdown tracker for the planning skills.
#
# Each planning item is one Markdown file directly under the tracker root,
# named NNNN-slug.md, with YAML front matter:
#
#   ---
#   id: 12
#   title: Charge partial refunds with the original tax split
#   kind: ticket            # map | decision | spec | ticket
#   status: open            # open | closed
#   labels: [ready-for-agent]
#   parent: 3               # optional: the map or spec this item belongs to
#   blocked_by: [10, 11]    # optional: items that must close first
#   assignee: alice         # optional: the session or person that claimed it
#   ---
#
# Other files under the root (README.md, notes) are ignored.
#
# Usage:
#   ruby tracker.rb validate [--root docs/planning]
#   ruby tracker.rb list     [--root DIR] [--status S] [--parent ID] [--kind KIND] [--json]
#   ruby tracker.rb frontier [--root DIR] [--parent ID] [--kind KIND] [--include-claimed] [--json]
#   ruby tracker.rb next-id  [--root DIR]
#
# Uses only the Ruby standard library.

require "json"
require "optparse"
require "yaml"

module PlanningTracker
  KINDS = %w[map decision spec ticket].freeze
  STATUSES = %w[open closed].freeze
  ITEM_FILE = /\A(\d{4,})-[a-z0-9]+(?:-[a-z0-9]+)*\.md\z/

  Item = Struct.new(:id, :title, :kind, :status, :labels, :parent, :blocked_by, :assignee, :file,
                    keyword_init: true) do
    def open? = status == "open"
  end

  # Reads an item file's YAML front matter; raises ArgumentError when it is malformed.
  module FrontMatter
    module_function

    def read(path)
      text = File.read(path, encoding: "UTF-8")
      raise ArgumentError, "missing front matter" unless text.start_with?("---\n")

      closing = text.index("\n---\n", 4) || text.index("\n---", 4)
      raise ArgumentError, "unterminated front matter" unless closing

      data = YAML.safe_load(text[4...closing], permitted_classes: [], aliases: false)
      raise ArgumentError, "front matter must be a mapping" unless data.is_a?(Hash)

      data
    rescue Psych::Exception => e
      raise ArgumentError, "invalid front matter: #{e.message}"
    end
  end

  # Checks one item's fields; returns a list of error strings.
  module ItemRules
    OPTIONAL_ID = ->(value) { value.nil? || value.is_a?(Integer) }
    OPTIONAL_TEXT = ->(value) { value.nil? || value.is_a?(String) }

    # [message, predicate that must hold]
    RULES = [
      ["title must not be empty", ->(item) { !item.title.to_s.strip.empty? }],
      ["kind must be one of #{KINDS.join(', ')}", ->(item) { KINDS.include?(item.kind) }],
      ["status must be one of #{STATUSES.join(', ')}", ->(item) { STATUSES.include?(item.status) }],
      ["labels must be a list of strings", ->(item) { item.labels.all?(String) }],
      ["blocked_by must be a list of item ids", ->(item) { item.blocked_by.all?(Integer) }],
      ["parent must be an item id", ->(item) { OPTIONAL_ID.call(item.parent) }],
      ["assignee must be text", ->(item) { OPTIONAL_TEXT.call(item.assignee) }],
      ["an item cannot block itself", ->(item) { !item.blocked_by.include?(item.id) }]
    ].freeze

    module_function

    def errors_for(item, file_number)
      errors = RULES.reject { |_message, rule| rule.call(item) }.map(&:first)
      return errors if item.id == file_number

      ["id #{item.id.inspect} does not match file number #{file_number}", *errors]
    end
  end

  # Loads every item under a tracker root and answers validation and frontier queries.
  class Store
    attr_reader :root, :load_errors

    def initialize(root)
      @root = root
      @load_errors = []
    end

    def items
      @items ||= load_items
    end

    def by_id
      @by_id ||= items.group_by(&:id)
    end

    def errors
      load_errors + duplicate_errors + link_errors + cycle_errors
    end

    # Open, non-map items whose blockers are all closed; claimed items are skipped unless requested.
    def frontier(parent: nil, kind: nil, include_claimed: false)
      items.select do |item|
        item.open? && item.kind != "map" && (include_claimed || item.assignee.nil?) &&
          matches?(item, parent: parent, kind: kind) && unblocked?(item)
      end
    end

    def list(status: nil, parent: nil, kind: nil)
      items.select do |item|
        (status.nil? || item.status == status) && matches?(item, parent: parent, kind: kind)
      end
    end

    def next_id
      (items.map(&:id).grep(Integer).max || 0) + 1
    end

    private

    def matches?(item, parent:, kind:)
      (parent.nil? || item.parent == parent) && (kind.nil? || item.kind == kind)
    end

    def unblocked?(item)
      item.blocked_by.all? { |id| Array(by_id[id]).all? { |blocker| !blocker.open? } }
    end

    def load_items
      raise ArgumentError, "tracker root not found: #{root}" unless File.directory?(root)

      Dir.children(root).sort.filter_map do |name|
        match = ITEM_FILE.match(name)
        load_item(File.join(root, name), match[1].to_i) if match
      end
    end

    def load_item(path, file_number)
      item = build_item(FrontMatter.read(path), path)
      ItemRules.errors_for(item, file_number).each do |error|
        load_errors << "#{relative(path)}: #{error}"
      end
      item
    rescue ArgumentError => e
      load_errors << "#{relative(path)}: #{e.message}"
      nil
    end

    def build_item(data, path)
      Item.new(
        id: data["id"], title: data["title"], kind: data["kind"], status: data["status"],
        labels: Array(data["labels"]), parent: data["parent"],
        blocked_by: Array(data["blocked_by"]), assignee: data["assignee"], file: relative(path)
      )
    end

    def duplicate_errors
      by_id.select { |_id, group| group.length > 1 }.map do |id, group|
        "duplicate id #{id}: #{group.map(&:file).join(', ')}"
      end
    end

    def link_errors
      items.flat_map do |item|
        links = item.blocked_by.map { |id| ["blocked_by", id] }
        links << ["parent", item.parent] if item.parent
        links.reject { |_field, id| by_id.key?(id) }.map do |field, id|
          "#{item.file}: #{field} references missing item #{id}"
        end
      end
    end

    def cycle_errors
      state = {}
      items.filter_map { |item| cycle_from(item.id, state, []) }.uniq.map do |cycle|
        "blocking cycle: #{cycle.join(' -> ')}"
      end
    end

    # Depth-first search over blocked_by edges; returns the first cycle found from id.
    def cycle_from(id, state, path)
      return path[path.index(id)..] + [id] if state[id] == :visiting
      return if state[id] == :done || !by_id.key?(id)

      state[id] = :visiting
      cycle = first_cycle_through(blockers_of(id), state, path + [id])
      state[id] = :done
      cycle
    end

    def blockers_of(id)
      by_id.fetch(id).first.blocked_by
    end

    def first_cycle_through(ids, state, path)
      ids.each do |next_id|
        cycle = cycle_from(next_id, state, path)
        return cycle if cycle
      end
      nil
    end

    def relative(path)
      path.delete_prefix("#{File.expand_path(Dir.pwd)}/")
    end
  end

  # Command-line entry point.
  class CLI
    COMMANDS = %w[validate list frontier next-id].freeze
    ROW = "%<id>04d  %<kind>-8s %<status>-6s %<title>s"
    # [switch, option key, accepted values or type]
    VALUE_OPTIONS = [
      ["--root DIR", :root, String],
      ["--status STATUS", :status, STATUSES],
      ["--parent ID", :parent, Integer],
      ["--kind KIND", :kind, KINDS]
    ].freeze
    FLAG_OPTIONS = { "--include-claimed" => :include_claimed, "--json" => :json }.freeze

    def initialize(argv, out: $stdout, err: $stderr)
      @argv = argv.dup
      @out = out
      @err = err
      @options = { root: "docs/planning" }
    end

    def run
      command = @argv.shift
      return usage unless COMMANDS.include?(command)

      parse_options
      dispatch(command, Store.new(@options.fetch(:root)))
    rescue ArgumentError, OptionParser::ParseError => e
      @err.puts("ERROR: #{e.message}")
      2
    end

    private

    def dispatch(command, store)
      case command
      when "validate" then validate(store)
      when "list" then print_items(store.list(**filters(:status, :parent, :kind)))
      when "frontier" then print_items(store.frontier(**filters(:parent, :kind, :include_claimed)))
      when "next-id" then print_next_id(store)
      end
    end

    def validate(store)
      errors = store.errors
      errors.each { |error| @err.puts("ERROR: #{error}") }
      if errors.empty?
        @out.puts("Tracker valid: #{store.items.compact.length} items under #{store.root}")
      end
      errors.empty? ? 0 : 1
    end

    def print_next_id(store)
      @out.puts(format("%04d", store.next_id))
      0
    end

    def print_items(items)
      items = items.compact.sort_by(&:id)
      lines = if @options[:json]
                [JSON.pretty_generate(items.map(&:to_h))]
              else
                items.map do |item|
                  row(item)
                end
              end
      lines.each { |line| @out.puts(line) }
      0
    end

    def row(item)
      format(ROW, id: item.id.to_i, kind: item.kind.to_s, status: item.status.to_s,
                  title: item.title.to_s)
    end

    def filters(*keys)
      keys.to_h { |key| [key, @options.fetch(key, key == :include_claimed ? false : nil)] }
    end

    def parse_options
      OptionParser.new do |opts|
        VALUE_OPTIONS.each do |switch, key, type|
          opts.on(switch, type) do |value|
            @options[key] = value
          end
        end
        FLAG_OPTIONS.each { |switch, key| opts.on(switch) { @options[key] = true } }
      end.parse!(@argv)
    end

    def usage
      @err.puts("usage: ruby tracker.rb {#{COMMANDS.join('|')}} [--root DIR] [options]")
      2
    end
  end
end

exit PlanningTracker::CLI.new(ARGV).run if $0 == __FILE__
