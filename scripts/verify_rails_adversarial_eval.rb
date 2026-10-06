#!/usr/bin/env ruby
# frozen_string_literal: true

# Verifier for the rails-adversarial benchmark family.
#
# Each fixture's visible tests describe the requested feature. A withheld test
# per fixture (benchmarks/rails-adversarial/withheld/<id>/test_withheld.rb,
# never copied into the agent workspace) exercises the production condition the
# visible tests leave out: concurrency, redelivery, retries, or an alternate
# access path. Grading is behavioral only; no check matches source text.

require "fileutils"
require "json"
require "open3"
require "tmpdir"
require "yaml"

ROOT = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
EVAL_FILE = ENV.fetch("RUBY_AGENT_EVAL_FILE")
WORKSPACE = Dir.pwd
FAMILY_ROOT = File.join(ROOT, "benchmarks", "rails-adversarial")
WITHHELD_TEST = "test/test_withheld.rb"
ALLOWED_PREFIXES = %w[lib/ test/].freeze

def load_yaml(path)
  YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
end

def check(status, evidence = nil)
  evidence ? { "status" => status, "evidence" => evidence } : { "status" => status }
end

def tail(text, limit = 2000)
  text.length > limit ? text[-limit..] : text
end

def fixture_files(fixture_root)
  Dir.glob("**/*", File::FNM_DOTMATCH, base: fixture_root).select { |path| File.file?(File.join(fixture_root, path)) }
end

# The agent's files, with every fixture file it was told not to change (and
# the visible test) restored, plus the withheld test.
def graded_copy(scratch, fixture_root, editable, withheld)
  FileUtils.cp_r(File.join(WORKSPACE, "."), scratch)
  (fixture_files(fixture_root) - editable).each do |relative|
    target = File.join(scratch, relative)
    FileUtils.mkdir_p(File.dirname(target))
    FileUtils.cp(File.join(fixture_root, relative), target)
  end
  FileUtils.cp(withheld, File.join(scratch, WITHHELD_TEST))
end

def run_test(directory, test_file)
  stdout, stderr, status = Open3.capture3("ruby", "-Ilib", test_file, chdir: directory)
  [status.success?, stdout + stderr]
end

def graded_checks(fixture_root, fixture, withheld)
  editable = Array(fixture.fetch("implementation_file"))
  Dir.mktmpdir("rails-adversarial-") do |scratch|
    graded_copy(scratch, fixture_root, editable, withheld)
    visible_ok, visible_output = run_test(scratch, fixture.fetch("test_file"))
    withheld_ok, withheld_output = run_test(scratch, WITHHELD_TEST)
    {
      "functional" => if visible_ok
                        check("pass",
                              "visible fixture tests passed")
                      else
                        check("fail",
                              tail(visible_output))
                      end,
      "adversarial" => if withheld_ok
                         check("pass",
                               "withheld production-condition tests passed")
                       else
                         check(
                           "fail", tail(withheld_output)
                         )
                       end
    }
  end
end

def workspace_tests_check(test_file)
  path = File.join(WORKSPACE, test_file)
  source = File.file?(path) ? File.read(path, encoding: "UTF-8") : ""
  passed, output = run_test(WORKSPACE, test_file)
  return check("pass", "workspace tests pass") if passed && source.match?(/assert|refute/)

  check("fail", "missing workspace tests or failing test suite: #{tail(output)}")
end

def changed_files
  stdout, = Open3.capture3("git", "status", "--short", "--untracked-files=all", chdir: WORKSPACE)
  stdout.lines.map { |line| line[3..].to_s.strip }.reject(&:empty?)
end

def scope_check(fixture_root, fixture)
  protected_files = fixture_files(fixture_root) - [fixture.fetch("implementation_file"),
                                                   fixture.fetch("test_file")]
  touched = changed_files
  outside = touched.reject { |path| ALLOWED_PREFIXES.any? { |prefix| path.start_with?(prefix) } }
  modified = touched & protected_files
  return check("pass") if outside.empty? && modified.empty?

  problems = []
  problems << "unexpected files: #{outside.join(', ')}" unless outside.empty?
  unless modified.empty?
    problems << "modified files the task says not to change: #{modified.join(', ')}"
  end
  check("fail", problems.join("; "))
end

evaluation = load_yaml(EVAL_FILE)
eval_id = evaluation.fetch("id")
fixture = load_yaml(File.join(FAMILY_ROOT, "fixtures.yml")).fetch("fixtures").fetch(eval_id)
fixture_root = File.join(ROOT, fixture.fetch("root"))
withheld = File.join(FAMILY_ROOT, "withheld", eval_id, "test_withheld.rb")

checks = graded_checks(fixture_root, fixture, withheld)
checks["tests"] = workspace_tests_check(fixture.fetch("test_file"))
checks["scope_control"] = scope_check(fixture_root, fixture)

result = {
  "metadata" => {
    "verifier" => "scripts/verify_rails_adversarial_eval.rb",
    "fixture" => fixture,
    "changed_files" => changed_files
  },
  "checks" => checks.slice(*evaluation.fetch("checks"))
}

File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), "#{JSON.pretty_generate(result)}\n",
           encoding: "UTF-8")
abort "verification failed" if result["checks"].values.any? do |value|
  value.fetch("status") == "fail"
end

puts JSON.pretty_generate(result)
