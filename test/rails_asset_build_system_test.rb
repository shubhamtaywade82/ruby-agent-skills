# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsAssetBuildSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-asset-build-engineering/SKILL.md
    patterns/rails/rails-asset-pipeline-contract.md
    patterns/rails/importmap-contract.md
    patterns/rails/jsbundling-contract.md
    patterns/rails/cssbundling-contract.md
    patterns/rails/bin-dev-process-contract.md
    patterns/rails/asset-build-reproducibility.md
    patterns/rails/asset-build-production-parity.md
    patterns/rails/asset-dependency-boundary.md
    patterns/testing/asset-build-testing.md
    evals/rails/asset-build-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_asset_build_skill
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-asset-build-engineering")

    assert_equal "skills/rails-asset-build-engineering/SKILL.md", skill.fetch("path")
    %w[
      asset
      assets
      build
      asset pipeline
      Importmap
      importmap-rails
      jsbundling
      jsbundling-rails
      cssbundling
      cssbundling-rails
      Propshaft
      Sprockets
      bin/dev
      Procfile.dev
      precompile
      JavaScript build
      CSS build
    ].each { |trigger| assert_includes skill.fetch("triggers"), trigger }

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      rails-asset-pipeline-contract
      importmap-contract
      jsbundling-contract
      cssbundling-contract
      bin-dev-process-contract
      asset-build-reproducibility
      asset-build-production-parity
      asset-dependency-boundary
    ].each { |name| assert_includes rails_patterns, "patterns/rails/#{name}.md" }

    assert_includes manifest.fetch("patterns").fetch("testing").fetch("paths"),
                    "patterns/testing/asset-build-testing.md"
    assert_includes manifest.fetch("evaluations").fetch("rails-asset-build-engineering").fetch("paths"),
                    "evals/rails/asset-build-contract.yml"
  end

  def test_router_and_agent_contract_include_asset_building
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Asset and Build Infrastructure engineering"
    assert_includes routing, "rails-asset-build-engineering"

    assert_includes agents, "Rails asset/build changes"
    assert_includes agents, "production-like"
    assert_includes agents, "lockfile"
  end

  def test_evaluation_contract_is_registered
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/asset-build-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-asset-build-engineering"
    assert_includes evaluation.fetch("patterns"), "asset-build-reproducibility"
    assert_includes evaluation.fetch("patterns"), "asset-build-testing"
    assert_equal "scope_control", evaluation.fetch("checks").last
  end

  def test_skill_covers_build_boundary
    skill = File.read(File.join(ROOT, "skills/rails-asset-build-engineering/SKILL.md"), encoding: "UTF-8")

    [
      "Strategy selection",
      "Dependency and runtime contracts",
      "Development process",
      "Build determinism",
      "Development/production parity",
      "CI and deployment",
      "Security",
      "Caching and artifacts",
      "Testing strategy"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Do not claim reproducibility merely because one local build succeeded."
    assert_includes skill, "Never expose secrets through frontend environment variables"
    assert_includes skill, "Do not claim asset/build correctness without build evidence."
  end
end
