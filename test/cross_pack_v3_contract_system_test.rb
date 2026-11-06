# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class CrossPackV3ContractSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  MANIFEST_PATH = File.join(ROOT, "skill-manifest.yml")
  NODE_SNAPSHOT_PATH = File.join(ROOT, "data", "cross-pack", "node-agent-skills.snapshot.yml")
  REACT_SNAPSHOT_PATH = File.join(ROOT, "data", "cross-pack", "react-agent-skills.snapshot.yml")

  def setup
    @manifest = YAML.safe_load(
      File.read(MANIFEST_PATH, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
  end

  def test_manifest_declares_v3_schema_and_pack_envelope
    assert_equal 3, @manifest.fetch("schema_version")
    assert_equal 2, @manifest.fetch("version")

    pack = @manifest.fetch("pack")
    assert_equal "ruby-agent-skills", pack.fetch("name")
    assert_equal "ruby", pack.fetch("language")
    refute_empty pack.fetch("runtime").to_s
  end

  def test_cross_pack_companions_are_declared_with_pinned_snapshots
    cross_pack = @manifest.fetch("cross_pack")
    companions = cross_pack.fetch("companions")

    names = companions.map { |entry| entry.fetch("pack") }
    assert_includes names, "node-agent-skills"
    assert_includes names, "react-agent-skills"

    companions.each do |entry|
      assert_match(%r{\Ahttps://github\.com/}, entry.fetch("repo"))
      refute_empty entry.fetch("pinned_ref").to_s
      refute_empty entry.fetch("language").to_s
      snapshot = File.join(ROOT, entry.fetch("snapshot"))
      assert File.file?(snapshot), "missing companion snapshot #{entry.fetch('snapshot')}"
    end
  end

  def test_name_collision_registry_matches_computed_intersections
    cross_pack = @manifest.fetch("cross_pack")
    registry = Array(cross_pack.fetch("name_collisions"))
    local_skills = @manifest.fetch("skills").keys

    { "node-agent-skills" => NODE_SNAPSHOT_PATH, "react-agent-skills" => REACT_SNAPSHOT_PATH }.each do |pack, path|
      snapshot = YAML.safe_load(
        File.read(path, encoding: "UTF-8"),
        permitted_classes: [],
        aliases: false
      )
      computed = (local_skills & Array(snapshot.fetch("skills"))).sort
      registered = registry
        .select { |entry| entry.fetch("companion_pack") == pack }
        .map { |entry| entry.fetch("skill_name") }
        .sort

      assert_equal computed, registered, "registry and computed intersection drift for #{pack}"
    end

    resolutions = registry.map { |entry| entry.fetch("resolution") }
    assert resolutions.all? { |r| %w[this_pack_wins companion_wins context_dependent split_by_language].include?(r) }
  end

  def test_seam_contract_skills_exist_on_disk_and_in_the_manifest
    cross_pack = @manifest.fetch("cross_pack")
    seams = cross_pack.fetch("seam_contracts")

    node_seam = seams.find { |entry| entry.fetch("boundary") == "rails-to-node-backend" }
    refute_nil node_seam
    assert_equal "rails-node-integration", node_seam.fetch("primary_in_this_pack")
    assert_equal "node-agent-skills", node_seam.fetch("companion_pack")
    assert_equal "node-agent-skills/skills/node-ruby-integration", node_seam.fetch("companion_side")

    seams.each do |entry|
      primary = entry.fetch("primary_in_this_pack")
      skill_file = File.join(ROOT, "skills", primary, "SKILL.md")
      assert File.file?(skill_file), "seam primary #{primary} has no SKILL.md"
      assert @manifest.fetch("skills").key?(primary), "seam primary #{primary} missing from manifest skills"
    end
  end

  def test_rails_node_routing_contract_is_documented
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")

    assert_includes routing, "## Rails and Node cross-stack routing"
    assert_includes routing, "node-agent-skills/skills/node-ruby-integration".sub("skills/", "skills/")
    assert_match(/rails-node-integration/, routing)
  end

  def test_cross_pack_verifier_is_present_and_executable
    verifier = File.join(ROOT, "bin", "cross-pack-verify")

    assert File.file?(verifier)
    assert File.executable?(verifier), "bin/cross-pack-verify must be executable"
  end

  def test_validator_invokes_this_system_test
    validate = File.read(File.join(ROOT, "bin", "validate"))

    assert_includes validate, "test/cross_pack_v3_contract_system_test.rb"
  end
end
