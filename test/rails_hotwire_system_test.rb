# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsHotwireSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-hotwire/SKILL.md
    patterns/rails/turbo-drive-navigation-contract.md
    patterns/rails/turbo-frame-contract.md
    patterns/rails/turbo-stream-response-contract.md
    patterns/rails/turbo-stream-broadcast-contract.md
    patterns/rails/turbo-morph-identity.md
    patterns/rails/turbo-form-contract.md
    patterns/rails/stimulus-controller-boundary.md
    patterns/rails/stimulus-target-value-contract.md
    patterns/rails/stimulus-lifecycle-boundary.md
    patterns/rails/hotwire-progressive-enhancement.md
    patterns/rails/hotwire-csrf-security.md
    patterns/testing/hotwire-testing.md
    evals/rails/hotwire-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_hotwire
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-hotwire")

    assert_equal "skills/rails-hotwire/SKILL.md", skill.fetch("path")
    [
      "Turbo",
      "Hotwire",
      "Turbo Drive",
      "Turbo Frames",
      "Turbo Streams",
      "Stimulus",
      "morphing",
      "progressive enhancement",
      "turbo-rails"
    ].each { |trigger| assert_includes skill.fetch("triggers"), trigger }

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      turbo-drive-navigation-contract
      turbo-frame-contract
      turbo-stream-response-contract
      turbo-stream-broadcast-contract
      turbo-morph-identity
      turbo-form-contract
      stimulus-controller-boundary
      stimulus-target-value-contract
      stimulus-lifecycle-boundary
      hotwire-progressive-enhancement
      hotwire-csrf-security
    ].each { |name| assert_includes rails_patterns, "patterns/rails/#{name}.md" }

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/testing/hotwire-testing.md"

    eval_paths = manifest.fetch("evaluations").fetch("rails-hotwire").fetch("paths")
    assert_includes eval_paths, "evals/rails/hotwire-contract.yml"
  end

  def test_router_and_agent_contract_include_hotwire
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Hotwire engineering"
    assert_includes routing, "rails-hotwire"
    assert_includes routing, "turbo-frame-contract"

    assert_includes agents, "Rails Hotwire changes"
    assert_includes agents, "Turbo Frames"
    assert_includes agents, "Stimulus"
    assert_includes agents, "CSRF"
  end

  def test_evaluation_activates_expected_contracts
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/hotwire-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-hotwire"
    assert_includes evaluation.fetch("skills"), "rails-authorization"
    assert_includes evaluation.fetch("skills"), "rails-action-cable"
    assert_includes evaluation.fetch("patterns"), "turbo-frame-contract"
    assert_includes evaluation.fetch("patterns"), "stimulus-lifecycle-boundary"
    assert_includes evaluation.fetch("patterns"), "hotwire-testing"
  end

  def test_skill_covers_hotwire_boundary
    skill = File.read(File.join(ROOT, "skills/rails-hotwire/SKILL.md"), encoding: "UTF-8")

    [
      "Turbo Drive navigation",
      "Turbo Frames",
      "Turbo Streams",
      "Turbo morphing and refresh",
      "Forms and response contracts",
      "Stimulus controller boundaries",
      "Stimulus lifecycle",
      "Security and CSRF",
      "Authentication and authorization composition",
      "Accessibility and progressive enhancement",
      "Caching and DOM identity",
      "Realtime Turbo Streams",
      "Testing strategy"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "A Turbo Frame establishes a DOM replacement boundary."
    assert_includes skill, "Never treat a frame ID, DOM ID, or stream target as permission."
    assert_includes skill, "Do not claim Hotwire correctness merely because the page appears to work manually."
  end
end
