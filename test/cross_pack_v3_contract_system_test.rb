# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

# Contract tests for the v3 cross-pack manifest, the Rails-Node seam, and the
# wiring of the cross-pack verifier. Companion snapshots live in data/cross-pack/.
module CrossPackV3Support
  ROOT = File.expand_path("..", __dir__)
  MANIFEST_PATH = File.join(ROOT, "skill-manifest.yml")
  SNAPSHOT_DIR = File.join(ROOT, "data", "cross-pack")
  SNAPSHOT_PATHS = {
    "node-agent-skills" => File.join(SNAPSHOT_DIR, "node-agent-skills.snapshot.yml"),
    "react-agent-skills" => File.join(SNAPSHOT_DIR, "react-agent-skills.snapshot.yml")
  }.freeze
  RESOLUTIONS = %w[this_pack_wins companion_wins context_dependent split_by_language].freeze

  private

  def load_manifest
    YAML.safe_load(
      File.read(MANIFEST_PATH, encoding: "UTF-8"), permitted_classes: [], aliases: false
    )
  end

  def cross_pack
    @manifest.fetch("cross_pack")
  end

  def companions
    cross_pack.fetch("companions")
  end

  def name_collisions
    Array(cross_pack.fetch("name_collisions"))
  end

  def seam_contracts
    cross_pack.fetch("seam_contracts")
  end

  def rails_node_seam
    seam_contracts.find { |entry| entry.fetch("boundary") == "rails-to-node-backend" }
  end
end

class CrossPackV3ManifestContractTest < Minitest::Test
  include CrossPackV3Support

  def setup
    @manifest = load_manifest
  end

  def test_manifest_declares_v3_schema
    assert_equal 3, @manifest.fetch("schema_version")
    assert_equal 2, @manifest.fetch("version")
  end

  def test_manifest_pack_envelope_names_the_pack
    pack = @manifest.fetch("pack")

    assert_equal "ruby-agent-skills", pack.fetch("name")
    assert_equal "ruby", pack.fetch("language")
    refute_empty pack.fetch("runtime").to_s
  end

  def test_cross_pack_declares_both_companions
    names = companions.map { |entry| entry.fetch("pack") }

    assert_includes names, "node-agent-skills"
    assert_includes names, "react-agent-skills"
  end

  def test_each_companion_is_pinned_to_a_repo_ref_and_snapshot
    companions.each { |entry| assert_companion_pinned(entry) }
  end

  def test_name_collision_registry_matches_computed_intersections
    local_skills = @manifest.fetch("skills").keys

    SNAPSHOT_PATHS.each do |pack, path|
      assert_registry_matches_intersection(pack, path, local_skills)
    end
  end

  def test_name_collision_resolutions_are_known_values
    resolutions = name_collisions.map { |entry| entry.fetch("resolution") }

    assert_empty resolutions - RESOLUTIONS, "unknown name-collision resolution"
  end

  private

  def assert_companion_pinned(entry)
    assert_match(%r{\Ahttps://github\.com/}, entry.fetch("repo"))
    refute_empty entry.fetch("pinned_ref").to_s
    refute_empty entry.fetch("language").to_s
    snapshot = File.join(ROOT, entry.fetch("snapshot"))

    assert File.file?(snapshot), "missing companion snapshot #{entry.fetch('snapshot')}"
  end

  def assert_registry_matches_intersection(pack, path, local_skills)
    snapshot = YAML.safe_load(
      File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false
    )
    computed = (local_skills & Array(snapshot.fetch("skills"))).sort
    registered = name_collisions
                 .select { |entry| entry.fetch("companion_pack") == pack }
                 .map { |entry| entry.fetch("skill_name") }
                 .sort

    assert_equal computed, registered, "registry and computed intersection drift for #{pack}"
  end
end

class CrossPackV3SeamAndWiringTest < Minitest::Test
  include CrossPackV3Support

  def setup
    @manifest = load_manifest
  end

  def test_rails_node_seam_is_declared_with_primary_skill
    node_seam = rails_node_seam

    refute_nil node_seam
    assert_equal "rails-node-integration", node_seam.fetch("primary_in_this_pack")
  end

  def test_rails_node_seam_points_at_the_node_companion
    node_seam = rails_node_seam

    refute_nil node_seam
    assert_equal "node-agent-skills", node_seam.fetch("companion_pack")
    assert_equal "node-agent-skills/skills/node-ruby-integration",
                 node_seam.fetch("companion_side")
  end

  def test_every_seam_primary_skill_exists_on_disk_and_in_manifest
    seam_contracts.each do |entry|
      assert_seam_primary_present(entry.fetch("primary_in_this_pack"))
    end
  end

  def test_rails_node_routing_contract_is_documented
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")

    assert_includes routing, "## Rails and Node cross-stack routing"
    assert_includes routing, "node-agent-skills/skills/node-ruby-integration"
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

  private

  def assert_seam_primary_present(primary)
    skill_file = File.join(ROOT, "skills", primary, "SKILL.md")

    assert File.file?(skill_file), "seam primary #{primary} has no SKILL.md"
    assert @manifest.fetch("skills").key?(primary),
           "seam primary #{primary} missing from manifest skills"
  end
end
