#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"
require "open3"

root = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
eval_file = ENV.fetch("RUBY_AGENT_EVAL_FILE")
workspace = Dir.pwd
evaluation = YAML.safe_load(File.read(eval_file, encoding: "UTF-8"), permitted_classes: [], aliases: false)

implementation = {
  "expand-contract" => "db/migrate/20260921000001_expand_customer_name.rb",
  "concurrent-index" => "db/migrate/20260921000002_add_orders_status_index.rb",
  "database-constraint" => "db/migrate/20260921000003_add_order_reference_constraint.rb",
  "batched-backfill" => "lib/backfill_normalized_email.rb",
  "transaction-lock" => "app/services/inventory_reservation.rb"
}.fetch(evaluation.fetch("id"))

source_path = File.join(workspace, implementation)
source = File.file?(source_path) ? File.read(source_path, encoding: "UTF-8") : ""
checks = {}

ruby_files = Dir.glob(File.join(workspace, "**/*.rb"))
syntax = ruby_files.filter_map do |file|
  _out, err, status = Open3.capture3("ruby", "-c", file)
  status.success? ? nil : { "file" => file, "error" => err }
end
checks["functional"] = syntax.empty? ?
  { "status" => "pass", "evidence" => "Ruby files compile" } :
  { "status" => "fail", "evidence" => syntax }

case evaluation.fetch("id")
when "expand-contract"
  expand = source.match?(/add_columns+:customers,s*:display_name/)
  destructive = source.match?(/remove_column|remove_index|drop_table|change_column.*name/)
  checks["functional"] = expand && !destructive ?
    { "status" => "pass", "evidence" => "expand-only schema change detected" } :
    { "status" => "fail", "evidence" => "breaking change detected during expand phase" }
  checks["contract"] = !destructive ?
    { "status" => "pass" } :
    { "status" => "fail", "evidence" => "contract operation mixed into expand phase" }

when "concurrent-index"
  disable_tx = source.match?(/disable_ddl_transaction!/)
  concurrent = source.match?(/algorithm:s*:concurrently/)
  checks["functional"] = disable_tx && concurrent ?
    { "status" => "pass", "evidence" => "concurrent PostgreSQL index strategy detected" } :
    { "status" => "fail", "evidence" => "missing concurrent index/transaction configuration" }
  checks["contract"] = !source.match?(/create_table|drop_table|add_column|remove_column/) ?
    { "status" => "pass" } :
    { "status" => "fail", "evidence" => "unrelated schema changes mixed into index migration" }

when "database-constraint"
  unique = source.match?(/unique:s*true/)
  pair = source.match?(/tenant_id.*external_reference|external_reference.*tenant_id/m)
  checks["functional"] = unique && pair ?
    { "status" => "pass", "evidence" => "composite unique constraint detected" } :
    { "status" => "fail", "evidence" => "required composite uniqueness not detected" }
  checks["contract"] = pair ?
    { "status" => "pass" } :
    { "status" => "fail", "evidence" => "tenant/reference key not detected" }

when "batched-backfill"
  batch = source.match?(/in_batches|find_each|find_in_batches/)
  bounded = source.match?(/BATCH_SIZEs*=s*d+|of:s*d+/)
  unbounded = source.match?(/User.all.each|User.all.to_a/)
  checks["functional"] = batch && bounded && !unbounded ?
    { "status" => "pass", "evidence" => "bounded batch traversal detected" } :
    { "status" => "fail", "evidence" => "backfill is not demonstrably bounded" }
  checks["contract"] = source.match?(/normalized_email/) ?
    { "status" => "pass" } :
    { "status" => "fail", "evidence" => "target backfill attribute missing" }

when "transaction-lock"
  with_lock = source.match?(/with_lock/)
  guard = source.match?(/quantitys*<=s*0/)
  decrement = source.match?(/quantitys*-s*1/)
  checks["functional"] = with_lock && guard && decrement ?
    { "status" => "pass", "evidence" => "minimal row-lock state transition detected" } :
    { "status" => "fail", "evidence" => "required lock and inventory invariant not detected" }
  checks["contract"] = source.match?(/InventoryReservation/) ?
    { "status" => "pass" } :
    { "status" => "fail", "evidence" => "reservation service missing" }
end

test_files = Dir.glob(File.join(workspace, "{test,spec}/**/*.rb"))
if test_files.empty?
  checks["tests"] = { "status" => "fail", "evidence" => "no test/spec files found" }
else
  results = test_files.map do |file|
    out, err, status = Open3.capture3("ruby", file, chdir: workspace)
    { "file" => file, "status" => status.success? ? "pass" : "fail", "stdout" => out, "stderr" => err }
  end
  checks["tests"] = results.all? { |r| r["status"] == "pass" } ?
    { "status" => "pass", "evidence" => results } :
    { "status" => "fail", "evidence" => results }
end

changed_files = %x{git status --short}.lines.map { |line| (line[3..] || line).strip }.reject(&:empty?)
checks["scope_control"] = { "status" => "pass", "evidence" => "recorded #{changed_files.length} changed paths" }
checks.select! { |name, _| Array(evaluation.fetch("checks")).include?(name) }

result = {
  "metadata" => {
    "verifier" => "scripts/verify_database_engineering_eval.rb",
    "evaluation" => evaluation.fetch("id"),
    "implementation_file" => implementation,
    "changed_files" => changed_files
  },
  "checks" => checks
}
File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "
", encoding: "UTF-8")
abort "verification failed" if checks.values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
