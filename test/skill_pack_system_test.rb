# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "tmpdir"
require "yaml"
require_relative "../lib/ruby_agent_skills/skill_pack"

class SkillPackSystemTest < Minitest::Test
  # Compatibility scenarios intentionally share one integration boundary.
  # rubocop:disable Metrics/ClassLength
  def set_skill_compatibility(manifest, requirement)
    data = YAML.safe_load(
      File.read(manifest, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
    data.fetch("skills").fetch("demo")["compatibility"] = { "ruby" => requirement }
    File.write(manifest, YAML.dump(data), encoding: "UTF-8")
  end

  def build_pack
    root = Dir.mktmpdir("skill-pack")
    FileUtils.mkdir_p(File.join(root, "skills", "demo"))
    FileUtils.mkdir_p(File.join(root, "patterns", "one"))
    FileUtils.mkdir_p(File.join(root, "patterns", "two"))

    File.write(File.join(root, "skills", "demo", "SKILL.md"), "---\nname: demo\ndescription: Demo.\n---\n\n# Demo\n")
    FileUtils.mkdir_p(File.join(root, "skills", "demo", "references"))
    File.write(File.join(root, "skills", "demo", "references", "detail.md"), "# Detail\n")
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
      evaluation: { "prompt" => "Demo", "skills" => ["demo"], "patterns" => ["pattern:patterns/one/shared"] },
      workspace: workspace
    )

    manifest = JSON.parse(File.read(result.fetch("manifest"), encoding: "UTF-8"))

    assert_equal Digest::SHA256.file(File.join(root, "skill-manifest.yml")).hexdigest, manifest.fetch("skill_manifest_sha256")
    assert File.directory?(result.fetch("skills_dir"))
    assert File.directory?(result.fetch("patterns_dir"))
  end

  def test_materialized_skill_carries_its_references
    root = build_pack
    workspace = Dir.mktmpdir("workspace")
    pack = RubyAgentSkills::SkillPack.new(root: root)
    result = pack.materialize(evaluation: { "prompt" => "Demo", "skills" => ["demo"], "patterns" => [] }, workspace: workspace)

    reference = File.join(result.fetch("skills_dir"), "demo", "references", "detail.md")

    assert_equal "# Detail\n", File.read(reference, encoding: "UTF-8")

    entry = JSON.parse(File.read(result.fetch("manifest"), encoding: "UTF-8")).fetch("skills").first

    assert_equal([".ruby-agent-eval/skill-pack/skills/demo/references/detail.md"], entry.fetch("references").map { |ref| ref.fetch("path") })
    assert_equal Digest::SHA256.file(File.join(root, "skills", "demo", "references", "detail.md")).hexdigest,
                 entry.fetch("references").first.fetch("sha256")
    assert_includes File.read(result.fetch("context"), encoding: "UTF-8"), "References for demo load on demand"
  end

  def test_materialized_patterns_preserve_relative_paths
    root = build_pack
    workspace = Dir.mktmpdir("workspace")
    pack = RubyAgentSkills::SkillPack.new(root: root)

    result = pack.materialize(
      evaluation: {
        "prompt" => "Demo",
        "skills" => ["demo"],
        "patterns" => [
          "pattern:patterns/one/shared",
          "pattern:patterns/two/shared"
        ]
      },
      workspace: workspace
    )

    one = File.join(result.fetch("patterns_dir"), "one", "shared.md")
    two = File.join(result.fetch("patterns_dir"), "two", "shared.md")

    assert_equal "# One\n", File.read(one, encoding: "UTF-8")
    assert_equal "# Two\n", File.read(two, encoding: "UTF-8")
  end

  def test_baseline_materialization_creates_empty_skill_and_pattern_directories
    root = build_pack
    workspace = Dir.mktmpdir("workspace")
    pack = RubyAgentSkills::SkillPack.new(root: root)
    result = pack.write_baseline_context(
      evaluation: { "prompt" => "Demo" },
      workspace: workspace
    )

    assert File.directory?(result.fetch("skills_dir"))
    assert File.directory?(result.fetch("patterns_dir"))
    manifest = JSON.parse(File.read(result.fetch("manifest"), encoding: "UTF-8"))

    assert_equal false, manifest.fetch("skills_enabled")
    assert_equal Digest::SHA256.file(File.join(root, "skill-manifest.yml")).hexdigest, manifest.fetch("skill_manifest_sha256")
  end

  def test_materialize_rejects_known_incompatible_skill
    root = build_pack
    manifest = File.join(root, "skill-manifest.yml")
    set_skill_compatibility(manifest, ">= 4.0")

    workspace = Dir.mktmpdir("workspace")
    pack = RubyAgentSkills::SkillPack.new(root: root)
    runtime_profile = {
      "ruby" => { "resolved" => "3.3.12", "status" => "resolved" }
    }

    error = assert_raises(RubyAgentSkills::SkillPack::IncompatibleError) do
      pack.materialize(
        evaluation: { "prompt" => "Demo", "skills" => ["demo"], "patterns" => [] },
        workspace: workspace,
        runtime_profile: runtime_profile
      )
    end

    assert_includes error.message, "demo"
    assert_includes error.message, "Ruby"
  end

  def test_materialize_allows_unknown_runtime_without_strict_mode
    root = build_pack
    manifest = File.join(root, "skill-manifest.yml")
    set_skill_compatibility(manifest, ">= 4.0")

    workspace = Dir.mktmpdir("workspace")
    pack = RubyAgentSkills::SkillPack.new(root: root)
    result = pack.materialize(
      evaluation: { "prompt" => "Demo", "skills" => ["demo"], "patterns" => [] },
      workspace: workspace,
      runtime_profile: { "ruby" => { "resolved" => nil, "status" => "unknown" } }
    )

    assert_equal "unknown", JSON.parse(File.read(result.fetch("manifest"), encoding: "UTF-8")).dig("compatibility", "requirements", "ruby", "status")
  end

  def test_strict_materialize_rejects_unknown_runtime
    root = build_pack
    manifest = File.join(root, "skill-manifest.yml")
    set_skill_compatibility(manifest, ">= 4.0")

    workspace = Dir.mktmpdir("workspace")
    pack = RubyAgentSkills::SkillPack.new(root: root)

    assert_raises(RubyAgentSkills::SkillPack::IncompatibleError) do
      pack.materialize(
        evaluation: { "prompt" => "Demo", "skills" => ["demo"], "patterns" => [] },
        workspace: workspace,
        runtime_profile: { "ruby" => { "resolved" => nil, "status" => "unknown" } },
        strict_compatibility: true
      )
    end
  end

  def test_compatibility_report_is_available_without_materializing
    root = build_pack
    manifest = File.join(root, "skill-manifest.yml")
    set_skill_compatibility(manifest, ">= 3.2")

    workspace = Dir.mktmpdir("workspace")
    pack = RubyAgentSkills::SkillPack.new(root: root)
    evaluation = { "prompt" => "Demo", "skills" => [], "patterns" => ["patterns/one/shared"] }

    report = pack.compatibility_report(
      evaluation: evaluation,
      runtime_profile: { "rails" => { "resolved" => "8.0.4", "status" => "resolved" } }
    )

    assert_equal "unsupported", report.fetch("status")
    assert_equal "unsupported",
                 report.dig("requirements", "patterns/one/shared", "requirements", "rails", "status")

    assert_raises(RubyAgentSkills::SkillPack::IncompatibleError) do
      pack.materialize(evaluation: evaluation, workspace: workspace, runtime_profile: {
                         "rails" => { "resolved" => "8.0.4", "status" => "resolved" }
                       })
    end
  end

  def test_compatible_version_bound_pattern_materializes
    root = build_pack
    pattern = File.join(root, "patterns/one/shared.md")
    File.write(
      pattern,
      File.read(pattern, encoding: "UTF-8").sub("# One", <<~MARKDOWN.chomp)
        ---
        name: shared
        description: Version-bound pattern
        family: rails
        compatibility:
          rails: ">= 8.1"
        ---
        # One
      MARKDOWN
    )

    workspace = Dir.mktmpdir("workspace")
    pack = RubyAgentSkills::SkillPack.new(root: root)
    result = pack.materialize(
      evaluation: { "prompt" => "Demo", "skills" => [], "patterns" => ["patterns/one/shared"] },
      workspace: workspace,
      runtime_profile: { "rails" => { "resolved" => "8.1.4", "status" => "resolved" } }
    )

    manifest = JSON.parse(File.read(result.fetch("manifest"), encoding: "UTF-8"))

    assert_equal "supported", manifest.dig("compatibility", "status")
  end

  def test_ambiguous_basename_pattern_is_rejected
    root = build_pack
    pack = RubyAgentSkills::SkillPack.new(root: root)

    error = assert_raises(RubyAgentSkills::SkillPack::Error) do
      pack.send(:resolve_pattern, "shared")
    end
    assert_includes error.message, "ambiguous pattern"
  end
  # rubocop:enable Metrics/ClassLength
end
