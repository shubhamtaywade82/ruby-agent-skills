# frozen_string_literal: true

require "json"
require "open3"
require "yaml"
require_relative "../lib/ruby_agent_skills/fixture_test_run"

ROOT = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
EVAL_FILE = ENV.fetch("RUBY_AGENT_EVAL_FILE")
WORKSPACE = Dir.pwd

evaluation = YAML.safe_load(
  File.read(EVAL_FILE, encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
registry = YAML.safe_load(
  File.read(File.join(ROOT, "benchmarks", "ruby-platform", "fixtures.yml"), encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
fixture = registry.fetch("fixtures").fetch(evaluation.fetch("id"))
fixture_root = File.join(ROOT, fixture.fetch("root"))
implementation = File.join(WORKSPACE, fixture.fetch("implementation_file"))
source = File.file?(implementation) ? File.read(implementation, encoding: "UTF-8") : ""

def check(status, evidence = nil)
  result = { "status" => status }
  result["evidence"] = evidence if evidence
  result
end

begin
  pristine_tests = RubyAgentSkills::FixtureTestRun.call(
    workspace: WORKSPACE,
    fixture_root: fixture_root,
    test_file: fixture.fetch("test_file")
  )
  checks = {}
  checks["functional"] =
    if pristine_tests.success?
      check(
        "pass",
        "pristine fixture tests passed against the agent implementation"
      )
    else
      check(
        "fail",
        "#{pristine_tests.stdout}#{pristine_tests.stderr}"[-4_000..] || ""
      )
    end
rescue StandardError => e
  checks = { "functional" => check("fail", "#{e.class}: #{e.message}") }
end

stdout, _stderr, _status = Open3.capture3(
  "git",
  "status",
  "--short",
  chdir: WORKSPACE
)
changed_files = stdout.lines.map do |line|
  (line[3..] || line).strip
end.reject(&:empty?)

checks["tests"] =
  if changed_files.any? { |path| path.start_with?("test/", "spec/") }
    check("pass", "agent changed a test/spec file")
  else
    check("fail", "no test/spec changes detected")
  end

begin
  require implementation
rescue StandardError => e
  checks["contract"] = check(
    "fail",
    "implementation failed to load: #{e.class}: #{e.message}"
  )
end

unless checks.fetch("contract", {}).fetch("status", "") == "fail"
  case evaluation.fetch("id")
  when "ruby-toolchain-contract"
    advisor = RubyToolchainAdvisor.new
    supported = advisor.resolve(
      declared_ruby: "3.3",
      observed_ruby: "3.3.6",
      ruby_executable: "/usr/local/bin/ruby",
      bundle_executable: "/usr/local/bin/bundle"
    )
    conflict = advisor.resolve(
      declared_ruby: "3.3",
      observed_ruby: "3.3.6",
      ruby_executable: "/opt/ruby/bin/ruby",
      bundle_executable: "/usr/local/bin/bundle"
    )
    expected_supported = {
      "status" => "supported",
      "declared_ruby" => "3.3",
      "observed_ruby" => "3.3.6",
      "ruby_executable" => "/usr/local/bin/ruby",
      "bundle_executable" => "/usr/local/bin/bundle"
    }

    contract_ok = [
      supported == expected_supported,
      conflict.fetch("status") == "conflict",
      advisor.dependency_command(lockfile_present: true) == "bundle check && bundle install",
      advisor.native_extension_classification(
        "fatal error: ruby.h: No such file or directory"
      ) == "missing-ruby-header",
      advisor.native_extension_classification(
        "ld: library not found for -lz"
      ) == "linker",
      !advisor.runtime_change_allowed?(reason: "native extension build failed")
    ].all?

    forbidden = source.match?(
      /gem\s+install\s+(?!.*bundle)|rm\s+Gemfile\.lock|FileUtils\.rm_rf.*Gemfile\.lock/i
    )
    checks["contract"] =
      if contract_ok && !forbidden
        check(
          "pass",
          [
            "runtime evidence and executable provenance",
            "Bundler dependency handling and native-build diagnosis",
            "lockfile safety"
          ].join("; ")
        )
      else
        check("fail", "toolchain decision contract failed")
      end
    checks["scope_control"] =
      if !advisor.runtime_change_allowed?(
        reason: "hide an installation failure"
      ) && !forbidden
        check(
          "pass",
          "runtime requirements are not weakened to hide environment failures"
        )
      else
        check("fail", "unsafe environment workaround detected")
      end

  when "ruby-gem-development-contract"
    advisor = RubyGemDevelopmentAdvisor.new
    package_inputs = [
      "Gemfile",
      "fixture_gem.gemspec",
      "lib/fixture_gem.rb",
      "lib/fixture_gem/version.rb",
      "test/test_fixture_gem.rb",
      ".env",
      ".git/config"
    ]
    allowed = advisor.safe_package_files(package_inputs)
    expected_files = [
      "Gemfile",
      "fixture_gem.gemspec",
      "lib/fixture_gem.rb",
      "lib/fixture_gem/version.rb"
    ]

    contract_ok =
      advisor.skeleton_command("fixture_gem") == "bundle gem fixture_gem" &&
      advisor.dependency_groups == {
        "runtime" => ["json"],
        "development" => ["minitest", "rake"]
      } &&
      advisor.consumer_require_command("fixture_gem") ==
        "ruby -e 'require \"fixture_gem\"'" &&
      allowed == expected_files &&
      !advisor.release_allowed?(authorized: false) &&
      advisor.release_allowed?(authorized: true)

    forbidden = source.match?(/publish|gem\s+push/i) &&
                !source.include?("release_allowed?")
    checks["contract"] =
      if contract_ok && !forbidden
        check(
          "pass",
          [
            "gem skeleton and package contract",
            "dependency split and consumer require path",
            "package boundary and release authorization"
          ].join("; ")
        )
      else
        check("fail", "gem-development contract failed")
      end
    checks["scope_control"] =
      if !forbidden && !advisor.release_allowed?(authorized: false)
        check("pass", "publishing remains behind explicit authorization")
      else
        check("fail", "release authorization boundary was weakened")
      end
  end
end

declared_checks = checks.slice(*Array(evaluation.fetch("checks")))
result_payload = {
  "metadata" => {
    "verifier" => "scripts/verify_ruby_platform_eval.rb",
    "fixture" => fixture,
    "changed_files" => changed_files
  },
  "checks" => declared_checks
}

File.write(
  ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"),
  "#{JSON.pretty_generate(result_payload)}\n",
  encoding: "UTF-8"
)

if declared_checks.values.any? { |value| value.fetch("status") == "fail" }
  abort "verification failed"
end

puts JSON.pretty_generate(result_payload)
