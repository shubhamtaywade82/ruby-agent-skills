# frozen_string_literal: true

require "yaml"

module RubyAgentSkills
  # Resolves benchmark evaluation IDs to fixture workspaces.
  #
  # A campaign's `benchmarks/<evaluation_set>/fixtures.yml` registry is
  # authoritative: an entry's `root` overrides the conventional
  # `<fixture_root>/<evaluation_id>` directory. The campaign runner and the
  # benchmark-quality audit both resolve through this class so the audit
  # checks the same paths the runner executes.
  #
  # Known-good reference implementations live outside the fixture root, at
  # `benchmarks/<evaluation_set>/references/<evaluation_id>/`, so they are
  # never copied into an agent workspace. They are positive controls for the
  # verifier; the unmodified fixture is the negative control and must fail
  # unless its registry entry declares `noop_expected: pass` with a
  # `noop_rationale` (review/preserve tasks where no change is correct).
  class FixtureRegistry
    class Error < StandardError; end

    NOOP_EXPECTATIONS = %w[fail pass].freeze

    attr_reader :root, :evaluation_set, :fixture_root, :registry_path

    def self.for_campaign(root:, campaign:)
      new(
        root: root,
        evaluation_set: campaign.fetch("evaluation_set"),
        fixture_root: File.expand_path(campaign.fetch("fixture_root"), root)
      )
    end

    def initialize(root:, evaluation_set:, fixture_root:)
      @root = File.expand_path(root)
      @evaluation_set = evaluation_set.to_s
      @fixture_root = File.expand_path(fixture_root, @root)
      @registry_path = File.join(@root, "benchmarks", @evaluation_set, "fixtures.yml")
      @fixtures = load_fixtures
    end

    def registered?
      File.file?(registry_path)
    end

    def ids
      @fixtures.keys
    end

    def entry(eval_id)
      value = @fixtures.fetch(eval_id.to_s, {})
      raise Error, "fixture #{eval_id} must be a mapping" unless value.is_a?(Hash)

      value
    end

    def declared_root(eval_id)
      configured = entry(eval_id)["root"].to_s
      configured.empty? ? File.join(fixture_root, eval_id.to_s) : File.expand_path(configured, root)
    end

    def path(eval_id)
      resolved = declared_root(eval_id)
      raise Error, "fixture not found: #{eval_id} (#{resolved.delete_prefix("#{root}/")})" unless Dir.exist?(resolved)

      resolved
    end

    def reference_root(eval_id)
      File.join(root, "benchmarks", evaluation_set, "references", eval_id.to_s)
    end

    def reference?(eval_id)
      Dir.exist?(reference_root(eval_id))
    end

    def noop_expected(eval_id)
      value = entry(eval_id).fetch("noop_expected", "fail").to_s
      raise Error, "fixture #{eval_id}: noop_expected must be one of #{NOOP_EXPECTATIONS.join(", ")}" unless NOOP_EXPECTATIONS.include?(value)
      if value == "pass" && entry(eval_id)["noop_rationale"].to_s.strip.empty?
        raise Error, "fixture #{eval_id}: noop_expected: pass requires a noop_rationale"
      end

      value
    end

    def implementation_files(eval_id)
      fixture = entry(eval_id)
      files = Array(fixture["implementation_files"])
      files = [fixture["implementation_file"]] if files.empty? && fixture["implementation_file"]
      files.compact.map(&:to_s)
    end

    private

    def load_fixtures
      return {} unless registered?

      data = YAML.safe_load(File.read(registry_path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
      fixtures = data.is_a?(Hash) ? data.fetch("fixtures", {}) : {}
      raise Error, "#{registry_path}: fixtures must be a mapping" unless fixtures.is_a?(Hash)

      fixtures.transform_keys(&:to_s)
    end
  end
end
