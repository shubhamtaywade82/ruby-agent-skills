#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "ripper"
require "yaml"

ROOT = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
EVAL_FILE = ENV.fetch("RUBY_AGENT_EVAL_FILE")
WORKSPACE = Dir.pwd
evaluation = YAML.safe_load(File.read(EVAL_FILE, encoding: "UTF-8"), permitted_classes: [], aliases: false)
fixture_registry = YAML.safe_load(
  File.read(File.join(ROOT, "benchmarks/ruby-training/fixtures.yml"), encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
fixture = fixture_registry.fetch("fixtures").fetch(evaluation.fetch("id"))
implementation = File.join(WORKSPACE, fixture.fetch("implementation_file"))
source = File.read(implementation, encoding: "UTF-8")

checks = {}
failures = []

def check(status, evidence = nil)
  result = { "status" => status }
  result["evidence"] = evidence if evidence
  result
end

def normalize_details(details)
  Array(details).map do |row|
    row.transform_keys(&:to_s).then do |value|
      value["line_total"] = value["line_total"].to_i if value.key?("line_total")
      value["quantity"] = value["quantity"].to_i if value.key?("quantity")
      value["price"] = value["price"].to_i if value.key?("price")
      value
    end
  end.sort_by { |row| row.fetch("name").to_s }
end

begin
  require implementation
rescue StandardError => e
  checks["functional"] = check("fail", "implementation failed to load: #{e.class}: #{e.message}")
  failures << "functional"
end

unless checks.key?("functional")
  case evaluation.fetch("id")
  when "selection-sort"
    sorter = SelectionSorter.new
    bad = evaluation.fetch("cases").reject do |test_case|
      values = test_case.fetch("input")
      expected = test_case.fetch("expected")
      sorter.sort(values.dup) == expected && sorter.recursive_sort(values.dup) == expected
    end
    checks["functional"] = bad.empty? ? check("pass", "both implementations matched all deterministic cases") : check("fail", bad.map { |c| c.fetch("name") }.join(", "))
  when "recursive-selection-sort"
    object = RecursiveSelectionSorter.new
    bad = evaluation.fetch("cases").reject { |c| object.sort(c.fetch("input").dup) == c.fetch("expected") }
    checks["functional"] = bad.empty? ? check("pass") : check("fail", bad.map { |c| c.fetch("name") }.join(", "))
  when "smallest-missing"
    object = SmallestMissing.new
    bad = evaluation.fetch("cases").reject { |c| object.find(c.fetch("input")) == c.fetch("expected") }
    checks["functional"] = bad.empty? ? check("pass") : check("fail", bad.map { |c| c.fetch("name") }.join(", "))
  when "triplet-sum"
    object = TripletSum.new
    bad = evaluation.fetch("cases").reject do |c|
      actual = object.find(c.fetch("input"), c.fetch("target"))
      expected = c.fetch("expected")
      expected.nil? ? actual.nil? : actual == expected
    end
    checks["functional"] = bad.empty? ? check("pass") : check("fail", bad.map { |c| c.fetch("name") }.join(", "))
  when "majority-element"
    object = MajorityElement.new
    bad = evaluation.fetch("cases").reject { |c| object.find(c.fetch("input")) == c.fetch("expected") }
    checks["functional"] = bad.empty? ? check("pass") : check("fail", bad.map { |c| c.fetch("name") }.join(", "))
  when "distinct-elements"
    object = DistinctElements.new
    bad = evaluation.fetch("cases").reject { |c| object.find(c.fetch("input")) == c.fetch("expected") }
    checks["functional"] = bad.empty? ? check("pass") : check("fail", bad.map { |c| c.fetch("name") }.join(", "))
  when "power-of-two"
    object = PowerOfTwo.new
    bad = evaluation.fetch("cases").reject { |c| object.check?(c.fetch("input")) == c.fetch("expected") }
    checks["functional"] = bad.empty? ? check("pass") : check("fail", bad.map { |c| c.fetch("name") }.join(", "))
  when "chocolate-feast"
    object = ChocolateFeast.new
    bad = evaluation.fetch("cases").reject do |c|
      input = c.fetch("input")
      object.call(input.fetch("money"), input.fetch("cost"), input.fetch("wrappers")) == c.fetch("expected")
    end
    checks["functional"] = bad.empty? ? check("pass") : check("fail", bad.map { |c| c.fetch("name") }.join(", "))
  when "shopping-cart"
    begin
      mall = Mall.new
      cart = ShoppingCart.new(mall)
      mall.add_product("Fruity", 12, 2)
      cart.add_product("Fruity", 2)
      expected = [{ "name" => "Fruity", "quantity" => 2, "price" => 12, "line_total" => 24 }]
      raise "details mismatch" unless normalize_details(cart.details) == expected
      raise "total mismatch" unless cart.total.to_i == 24
      cart.remove_product("Fruity", 1)
      expected_after_remove = [{ "name" => "Fruity", "quantity" => 1, "price" => 12, "line_total" => 12 }]
      raise "remove mismatch" unless normalize_details(cart.details) == expected_after_remove
      raise "remove total mismatch" unless cart.total.to_i == 12

      begin
        cart.add_product("Slice", 1)
        raise "unavailable product was accepted"
      rescue StandardError => e
        raise unless e.message.downcase.include?("product_not_available") || e.message.downcase.include?("not available")
      end

      begin
        cart.add_product("Fruity", 2)
        raise "inventory limit was accepted"
      rescue StandardError => e
        raise unless e.message.downcase.include?("insufficient_inventory") || e.message.downcase.include?("available")
      end

      begin
        cart.remove_product("Fruity", 2)
        raise "cart quantity limit was accepted"
      rescue StandardError => e
        raise unless e.message.downcase.include?("insufficient_cart_quantity") || e.message.downcase.include?("cart")
      end

      checks["functional"] = check("pass")
      checks["contract"] = check("pass", "shopping-cart fixture API and domain failures are executable")
    rescue StandardError => e
      checks["functional"] = check("fail", "#{e.class}: #{e.message}")
      checks["contract"] = check("fail", "#{e.class}: #{e.message}")
      failures.concat(%w[functional contract])
    end
  end
end

class_names = Array(fixture.fetch("classes"))
missing_classes = class_names.reject { |name| source.match?(/\bclass\s+#{Regexp.escape(name)}\b/) }
checks["oop"] = missing_classes.empty? ? check("pass", "declared benchmark classes are present") : check("fail", "missing class definitions: #{missing_classes.join(", ")}")

changed_files = %x{git status --short}.lines.map { |line| line[3..] || line }.map(&:strip)
test_changes = changed_files.any? { |path| path.start_with?("test/", "spec/") || path.match?(/(^|\/)test_/) }
checks["tests"] = test_changes ? check("pass", "agent changed a test/spec file") : check("fail", "no test/spec changes detected")

if evaluation.fetch("checks").include?("edge_cases")
  checks["edge_cases"] = failures.empty? ? check("pass", "public deterministic cases including boundaries passed") : check("fail", "functional/contract failures prevent complete edge-case verification")
end

if evaluation.fetch("checks").include?("forbidden_constructs")
  operators = Ripper.lex(source).select { |(_, event, _, _)| event == :on_op }.map { |(_, _, token, _)| token }
  forbidden = operators & ["/", "%"]
  has_bitwise_and = operators.include?("&")
  checks["forbidden_constructs"] =
    if forbidden.empty? && has_bitwise_and
      check("pass", "no division/modulo operators detected and bitwise AND is present")
    elsif forbidden.any?
      check("fail", "forbidden operators detected: #{forbidden.uniq.join(", ")}")
    else
      check("fail", "required bitwise AND operator not detected")
    end
end

if evaluation.fetch("checks").include?("complexity")
  case evaluation.fetch("id")
  when "selection-sort", "recursive-selection-sort"
    if source.match?(/\.sort(?:\b|\s*\()/)
      checks["complexity"] = check("fail", "built-in sort detected")
    elsif evaluation.fetch("id") == "recursive-selection-sort" && !source.match?(/def\s+sort.*?sort\s*\(/m)
      checks["complexity"] = check("not_evaluated", "could not prove recursive self-call with static heuristic")
    else
      checks["complexity"] = check("pass", "static heuristic found no built-in sort and required recursive structure")
    end
  when "triplet-sum"
    checks["complexity"] =
      if source.match?(/\.sort(?:\b|\s*\()/) && source.match?(/while\b/) && source.match?(/left|right/)
        check("pass", "static heuristic found sort plus loop and two-pointer variables")
      else
        check("not_evaluated", "static heuristic could not establish the required O(n^2), O(1) shape")
      end
  when "majority-element"
    obvious_violation = source.match?(/\.sort(?:\b|\s*\()/) || source.match?(/\.tally\b/) || source.match?(/group_by/) || source.match?(/Hash(?:\.new)?\b/)
    checks["complexity"] = obvious_violation ? check("fail", "obvious sort/counting structure detected") : check("pass", "no obvious sort/counting structure detected")
    checks["auxiliary_space"] = checks["complexity"].dup if evaluation.fetch("checks").include?("auxiliary_space")
  when "power-of-two"
    checks["complexity"] = source.match?(/&/) ? check("pass", "bitwise constant-time shape detected") : check("not_evaluated", "bitwise expression not proven")
  else
    checks["complexity"] = check("not_evaluated", "no deterministic static heuristic registered")
  end
end

if evaluation.fetch("checks").include?("auxiliary_space") && !checks.key?("auxiliary_space")
  checks["auxiliary_space"] = check("not_evaluated", "no deterministic static heuristic registered")
end

declared = evaluation.fetch("checks")
result = {
  "metadata" => {
    "verifier" => "scripts/verify_training_eval.rb",
    "fixture" => fixture,
    "changed_files" => changed_files
  },
  "checks" => checks.select { |name, _| declared.include?(name) }
}

File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
abort "verification failed" if result["checks"].values.any? { |value| value.fetch("status") == "fail" }

puts JSON.pretty_generate(result)
