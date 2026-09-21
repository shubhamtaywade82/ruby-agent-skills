#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"
require "open3"
require "fileutils"

ROOT = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
EVAL_FILE = ENV.fetch("RUBY_AGENT_EVAL_FILE")
WORKSPACE = Dir.pwd

evaluation = YAML.safe_load(File.read(EVAL_FILE, encoding: "UTF-8"), permitted_classes: [], aliases: false)
fixture_registry = YAML.safe_load(
  File.read(File.join(ROOT, "benchmarks/ruby-workshop/fixtures.yml"), encoding: "UTF-8"),
  permitted_classes: [], aliases: false
)
fixture = fixture_registry.fetch("fixtures").fetch(evaluation.fetch("id"))

checks = {}
declared = evaluation.fetch("checks")

def check(status, evidence = nil)
  result = { "status" => status }
  result["evidence"] = evidence if evidence
  result
end

def changed_files
  %x{git status --short}.lines.map { |line| line[3..] || line }.map(&:strip).reject(&:empty?)
end

def tests_changed?(files)
  files.any? { |path| path.start_with?("test/", "spec/") || path.match?(/(^|\/)test_/) }
end

def static_class_present?(source, name)
  source.match?(/\bclass\s+#{Regexp.escape(name)}\b/)
end

implementation = File.join(WORKSPACE, fixture.fetch("implementation_file"))
source = File.file?(implementation) ? File.read(implementation, encoding: "UTF-8") : ""

begin
  case evaluation.fetch("id")
  when "enumerable-transform"
    require implementation
    actual = Catalog.new.available_names([
      { name: "Ruby", available: true },
      { name: "Rails", available: false },
      { name: "PostgreSQL", available: true }
    ])
    checks["functional"] =
      actual == ["Ruby", "PostgreSQL"] ? check("pass") : check("fail", actual.inspect)
  when "method-contract"
    require implementation
    formatter = NotificationFormatter.new
    good = formatter.format(recipient: "Sam", channel: :email) == "email: Sam" &&
      formatter.format(recipient: "Sam", channel: :sms) == "sms: Sam"
    bad = begin
      formatter.format(recipient: "Sam", channel: :push)
      false
    rescue ArgumentError
      true
    end
    checks["functional"] = good && bad ? check("pass") : check("fail", "return/error contract mismatch")
    checks["contract"] = source.match?(/channel/) && source.match?(/ArgumentError/) ? check("pass") : check("fail", "public contract is not explicit")
  when "voting-application"
    require implementation
    machine = VotingMachine.new
    machine.vote(voter: "Alice", candidate: "Sam")
    machine.vote(voter: "Bob", candidate: "Pat")
    machine.vote(voter: "Cara", candidate: "Sam")
    checks["functional"] = machine.leaderboard == ["Sam", "Pat"] ? check("pass") : check("fail", machine.leaderboard.inspect)
    duplicate = begin
      machine.vote(voter: "Alice", candidate: "Pat")
      false
    rescue StandardError
      true
    end
    checks["contract"] = duplicate ? check("pass") : check("fail", "duplicate voter accepted")
  when "service-object"
    require File.join(WORKSPACE, "lib/application_service.rb")
    require File.join(WORKSPACE, "lib/post.rb")
    require File.join(WORKSPACE, "lib/user.rb")
    require File.join(WORKSPACE, "lib/status.rb")
    require implementation
    user = User.new
    post = Post::Creator.call(user, status_text: "Howdy")
    valid = post.is_a?(Post) && user.posts.length == 1 && post.status.text == "Howdy"
    invalid_blank = begin
      Post::Creator.call(user, status_text: "")
      user.posts.length == 1
    rescue StandardError
      user.posts.length == 1
    end
    invalid_user = begin
      Post::Creator.call(nil, status_text: "Howdy")
      true
    rescue StandardError
      true
    end
    checks["functional"] = valid && invalid_blank && invalid_user ? check("pass") : check("fail", "service behavior mismatch")
    checks["contract"] = source.match?(/def\s+call/) && source.match?(/private/) ? check("pass") : check("not_evaluated", "public/private API shape could not be fully proven")
  when "external-api-client"
    require "json"
    require implementation
    response_class = Struct.new(:status, :body)
    fake = Object.new
    fake.define_singleton_method(:get) do |_city|
      response_class.new(200, JSON.generate("city" => "Pune", "temperature" => 28))
    end
    result = WeatherClient.new(http: fake).fetch("Pune")
    good = result == { "city" => "Pune", "temperature" => 28 }
    checks["functional"] = good ? check("pass") : check("fail", result.inspect)

    failing = Object.new
    failing.define_singleton_method(:get) do |_city|
      response_class.new(503, "{}")
    end
    remote_failed = begin
      WeatherClient.new(http: failing).fetch("Pune")
      false
    rescue StandardError
      true
    end
    checks["contract"] = remote_failed && source.match?(/JSON/) ? check("pass") : check("fail", "remote error or JSON parsing boundary missing")
  when "ruby-gem-boundary"
    require implementation
    public_ok = defined?(InventoryClient) && InventoryClient::VERSION == "0.1.0"
    gemspec = File.join(WORKSPACE, "inventory_client.gemspec")
    package_ok = File.file?(gemspec) && File.read(gemspec, encoding: "UTF-8").include?("lib/**/*")
    build_ok = false
    if package_ok
      stdout, stderr, status = Open3.capture3("gem", "build", gemspec, chdir: WORKSPACE)
      build_ok = status.success? && stdout.include?("Successfully built") && stderr.empty?
      Dir.glob(File.join(WORKSPACE, "*.gem")).each { |path| FileUtils.rm_f(path) }
    end
    checks["functional"] = public_ok ? check("pass") : check("fail", "public namespace/version unavailable")
    checks["contract"] = source.match?(/module\s+InventoryClient/) ? check("pass") : check("fail", "public namespace not explicit")
    checks["packaging"] = package_ok && build_ok ? check("pass") : check("fail", "gemspec/package verification failed")
  when "rails-rest-contract"
    routes = File.read(File.join(WORKSPACE, "config/routes.rb"), encoding: "UTF-8")
    controller = File.read(implementation, encoding: "UTF-8")
    required_actions = %w[index show create update destroy]
    actions_ok = required_actions.all? { |name| controller.match?(/def\s+#{name}\b/) }
    params_ok = controller.match?(/params\.require\(:post\)/) && controller.match?(/permit\(/)
    route_ok = routes.match?(/resources\s+:posts/)
    checks["functional"] = route_ok && actions_ok ? check("pass") : check("fail", "route/actions contract incomplete")
    checks["contract"] = params_ok ? check("pass") : check("strong_parameter_contract_missing")
  when "rails-authentication-boundary"
    dashboard = File.read(implementation, encoding: "UTF-8")
    health = File.read(File.join(WORKSPACE, "app/controllers/health_controller.rb"), encoding: "UTF-8")
    protected_ok = dashboard.match?(/before_action\s+:authenticate_user!/) || dashboard.match?(/authenticate_user!/) || dashboard.match?(/before_action\s+:authenticate/)
    public_ok = !health.match?(/authenticate_user!/)
    checks["functional"] = protected_ok && public_ok ? check("pass") : check("fail", "public/private boundary incomplete")
    checks["contract"] = protected_ok ? check("pass") : check("fail", "dashboard authentication boundary missing")
  end
rescue LoadError, NameError, NoMethodError, ArgumentError, StandardError => e
  checks["functional"] ||= check("fail", "verification raised #{e.class}: #{e.message}")
end

files = changed_files
checks["oop"] = if declared.include?("oop")
  class_names = Array(fixture.fetch("classes"))
  missing = class_names.reject { |name| static_class_present?(source, name) }
  missing.empty? ? check("pass", "declared benchmark classes are present") : check("fail", "missing classes: #{missing.join(", ")}")
else
  check("not_evaluated", "OOP is not a declared dimension for this case")
end

checks["tests"] =
  if tests_changed?(files)
    check("pass", "agent changed a test/spec file")
  else
    check("fail", "no test/spec changes detected")
  end

if declared.include?("scope_control")
  allowed_prefixes = ["lib/", "app/", "config/", "test/", "spec/", "inventory_client.gemspec"]
  unexpected = files.reject { |path| allowed_prefixes.any? { |prefix| path.start_with?(prefix) || path == prefix } }
  checks["scope_control"] = unexpected.empty? ? check("pass") : check("fail", "unexpected files: #{unexpected.join(", ")}")
end

unless declared.include?("oop")
  checks.delete("oop") if checks["oop"]["status"] == "not_evaluated"
end

result = {
  "metadata" => {
    "verifier" => "scripts/verify_workshop_eval.rb",
    "fixture" => fixture,
    "changed_files" => files
  },
  "checks" => checks.select { |name, _| declared.include?(name) }
}

File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
abort "verification failed" if result["checks"].values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
