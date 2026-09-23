# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "tmpdir"
require_relative "../lib/ruby_agent_skills/skill_pack"

class SkillPackSystemTest < Minitest::Test
  def build_pack
    root = Dir.mktmpdir("skill-pack")
    FileUtils.mkdir_p(File.join(root, "skills", "demo"))
    FileUtils.mkdir_p(File.join(root, "patterns", "one"))
    FileUtils.mkdir_p(File.join(root, "patterns", "two"))

    File.write(File.join(root, "skills", "demo", "SKILL.md"), "---\nname: demo\ndescription: Demo.\n---\n\n# Demo\n")
    File.write(File.join(root, "patterns", "one", "shared.md"), "# One\n")
    File.write(File.join(root, "patterns", "two", "shared.md"), "# Two\n")
    File.write(
      File.join(root, "skill-manifest.yml"),
      <<~YAML
        version: 2
        patterns:
          ruby:
            paths:
              - patterns/one/shared.md
              - patterns/two/shared.md
        skills:
          demo:
            family: ruby
            path: skills/demo/SKILL.md
            triggers:
              - demo
        evaluations: {}
      YAML
    )
    root
  end

  def test_materialized_manifest_records_skill_manifest_digest
    root = build_pack
    workspace = Dir.mktmpdir("workspace")
    pack = RubyAgentSkills::SkillPack.new(root: root)
    result = pack.materialize(
      evaluation: {"prompt" => "Demo", "skills" => ["demo"], "patterns" => ["pattern:patterns/one/shared"]},
      workspace: workspace
    )

    manifest = JSON.parse(File.read(result.fetch("manifest"), encoding: "UTF-8"))
    assert_equal Digest::SHA256.file(File.join(root, "skill-manifest.yml")).hexdigest, manifest.fetch("skill_manifest_sha256")
    assert File.directory?(result.fetch("skills_dir"))
    assert File.directory?(result.fetch("patterns_dir"))
  end

  def test_baseline_materialization_creates_empty_skill_and_pattern_directories
    root = build_pack
    workspace = Dir.mktmpdir("workspace")
    pack = RubyAgentSkills::SkillPack.new(root: root)
    result = pack.write_baseline_context(
      evaluation: {"prompt" => "Demo"},
      workspace: workspace
    )

    assert File.directory?(result.fetch("skills_dir"))
    assert File.directory?(result.fetch("patterns_dir"))
    manifest = JSON.parse(File.read(result.fetch("manifest"), encoding: "UTF-8"))
    assert_equal false, manifest.fetch("skills_enabled")
    assert_equal Digest::SHA256.file(File.join(root, "skill-manifest.yml")).hexdigest, manifest.fetch("skill_manifest_sha256")
  end

  def test_ambiguous_basename_pattern_is_rejected
    root = build_pack
    pack = RubyAgentSkills::SkillPack.new(root: root)

    error = assert_raises(RubyAgentSkills::SkillPack::Error) do
      pack.send(:resolve_pattern, "shared")
    end
    assert_includes error.message, "ambiguous pattern"
  end
end
