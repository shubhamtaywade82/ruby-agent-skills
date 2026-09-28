# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../lib/ruby_agent_skills/skill_pack"

# A pattern can be legitimately registered under two manifest families at
# once (for example, also under "testing"; see
# scripts/audit_repository_completeness.rb's "dual-registers" check). That
# must resolve to one pattern, not raise an ambiguous-pattern error.
class SkillPackDualRegisteredPatternSystemTest < Minitest::Test
  MANIFEST = <<~YAML
    version: 2
    patterns:
      ruby:
        paths:
          - patterns/one/cross-listed.md
      testing:
        paths:
          - patterns/one/cross-listed.md
    skills:
      demo:
        family: ruby
        path: skills/demo/SKILL.md
        triggers:
          - demo
    evaluations: {}
  YAML

  def build_pack
    root = Dir.mktmpdir("skill-pack-dual")
    FileUtils.mkdir_p(File.join(root, "skills", "demo"))
    FileUtils.mkdir_p(File.join(root, "patterns", "one"))
    File.write(File.join(root, "skills", "demo", "SKILL.md"),
               "---\nname: demo\ndescription: Demo.\n---\n\n# Demo\n")
    File.write(File.join(root, "patterns", "one", "cross-listed.md"), "# Cross-listed\n")
    File.write(File.join(root, "skill-manifest.yml"), MANIFEST)
    root
  end

  def test_resolves_without_ambiguity
    pack = RubyAgentSkills::SkillPack.new(root: build_pack)

    assert_equal "patterns/one/cross-listed.md", pack.send(:resolve_pattern, "cross-listed")
  end

  def test_materialize_succeeds
    root = build_pack
    pack = RubyAgentSkills::SkillPack.new(root: root)
    result = pack.materialize(
      evaluation: { "prompt" => "Demo", "skills" => ["demo"],
                    "patterns" => ["pattern:cross-listed"] },
      workspace: Dir.mktmpdir("workspace")
    )

    assert_equal "# Cross-listed\n",
                 File.read(File.join(result.fetch("patterns_dir"), "one", "cross-listed.md"),
                           encoding: "UTF-8")
  end
end
