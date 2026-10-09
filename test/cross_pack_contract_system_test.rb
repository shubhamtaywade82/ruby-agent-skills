# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class CrossPackContractSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  SNAPSHOT_PATH = File.join(ROOT, "data", "cross-pack", "react-agent-skills.snapshot.yml")
  MANIFEST_PATH = File.join(ROOT, "skill-manifest.yml")

  def setup
    @snapshot = YAML.safe_load(
      File.read(SNAPSHOT_PATH, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
    @manifest = YAML.safe_load(
      File.read(MANIFEST_PATH, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
  end

  def test_snapshot_is_well_formed
    assert_equal "shubhamtaywade82/react-agent-skills", @snapshot.fetch("companion_repository")
    assert_match(/\A[0-9a-f]{40}\z/, @snapshot.fetch("companion_commit"))
    assert_match(/\A\d{4}-\d{2}-\d{2}\z/, @snapshot.fetch("captured_at").to_s)
    skills = Array(@snapshot.fetch("skills"))
    refute_empty skills
    assert_equal skills, skills.uniq
    skills.each { |name| assert_match(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, name) }
  end

  def test_documented_name_collisions_match_the_companion_snapshot
    local_skills = @manifest.fetch("skills").keys
    companion_skills = Array(@snapshot.fetch("skills"))
    computed = (local_skills & companion_skills).sort
    documented = Array(@snapshot.fetch("documented_name_collisions")).sort

    assert_equal computed, documented, "refresh the snapshot and collision list together"
  end

  def test_validator_invokes_this_system_test
    validate = File.read(File.join(ROOT, "bin", "validate"))
    assert_includes validate, "test/cross_pack_contract_system_test.rb"
  end
end
