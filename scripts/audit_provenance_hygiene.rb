#!/usr/bin/env ruby
# frozen_string_literal: true

# Byte-level provenance hygiene audit.
#
# Rejects textual content that could not have been authored intentionally:
#   - Private Use Area or invisible/format Unicode (zero-width, bidi, BOM-like);
#   - LLM citation-token residue (citeturn / turnNsearchN / turnNviewN);
#   - escaped backticks and literal "\n" artifacts outside code context.
#
# Code context (``` fences and indented blocks) is exempt for the corruption
# checks, because Ruby strings and shell snippets legitimately escape both.
#
# Usage:
#   ruby scripts/audit_provenance_hygiene.rb             # audit the repository
#   ruby scripts/audit_provenance_hygiene.rb PATH ...    # audit explicit paths

require "set"

TEXT_SUFFIXES = Set.new(%w[.md .json .yaml .yml .txt .rb .sh .js .html .css])
# Escapes like \n and \` are legitimate inside source code; they are corruption
# only in prose-oriented formats.
PROSE_SUFFIXES = Set.new(%w[.md .txt .html .css])

ROOT = File.expand_path("..", __dir__)
TARGETS = ARGV.empty? ? [ROOT] : ARGV.map { |a| File.expand_path(a, Dir.pwd) }

INVISIBLE = /[\uE000-\uF8FF\u200B-\u200F\u202A-\u202E\u2060-\u206F\uFEFF\uFFF9-\uFFFB]/
CITATION = /citeturn\d*|turn\d+search\d*|turn\d+view\d*/i
ESCAPED_BACKTICK = /\\`/
LITERAL_NEWLINE = /\\n/

errors = []
checked = 0

def each_text_file(targets, &block)
  targets.each do |root|
    stack = [root]
    until stack.empty?
      current = stack.pop
      next unless File.exist?(current)

      if File.directory?(current)
        Dir.children(current).sort.reverse_each do |child|
          next if child == ".git" || child == "node_modules"

          stack.push(File.join(current, child))
        end
      elsif TEXT_SUFFIXES.include?(File.extname(current))
        yield current
      end
    end
  end
end

each_text_file(TARGETS) do |path|
  # The audit's own pattern definitions would match themselves.
  next if File.expand_path(path) == File.expand_path(__FILE__)

  text = begin
    File.read(path, encoding: "UTF-8")
  rescue StandardError
    errors << "#{path}: not valid UTF-8"
    next
  end

  checked += 1
  relative = path.delete_prefix(ROOT + "/")
  in_fence = false
  prose = PROSE_SUFFIXES.include?(File.extname(path))

  text.each_line.with_index(1) do |line, index|
    in_fence = !in_fence if line.strip.start_with?("```")

    next if in_fence || line.start_with?("    ", "\t")

    prefix = "#{relative}:#{index}"
    reasons = []
    reasons << "invisible/private-use Unicode" if INVISIBLE.match?(line)
    reasons << "citation-token residue" if CITATION.match?(line)
    if prose
      reasons << "escaped backtick" if ESCAPED_BACKTICK.match?(line)
      reasons << 'literal \n artifact' if LITERAL_NEWLINE.match?(line)
    end
    errors << "#{prefix}: #{reasons.uniq.join(', ')}" unless reasons.empty?
  end
end

puts "Provenance hygiene audit"
puts "  textual files checked: #{checked}"

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} provenance hygiene error(s)"
end

puts "Provenance hygiene audit passed."
