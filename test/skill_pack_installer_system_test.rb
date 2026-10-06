# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class SkillPackInstallerSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  INSTALLER = File.join(ROOT, "bin", "install")
  VERIFIER = File.join(ROOT, "bin", "skill-pack-verify")

  def git(repo, *args)
    _out, err, status = Open3.capture3("git", "-C", repo, *args)
    abort "git failed: #{err}" unless status.success?
  end

  def build_source(skill_name: "demo-skill", retired: {}, relocated: {})
    dir = Dir.mktmpdir("ruby-agent-skills-source")
    FileUtils.mkdir_p(File.join(dir, "skills", skill_name))
    FileUtils.mkdir_p(File.join(dir, "patterns", "ruby"))
    FileUtils.mkdir_p(File.join(dir, "router"))
    FileUtils.mkdir_p(File.join(dir, "docs"))
    FileUtils.mkdir_p(File.join(dir, "bin"))

    File.write(File.join(dir, "skills", skill_name, "SKILL.md"), "---\nname: #{skill_name}\ndescription: Test skill.\n---\n\n# Demo\n", encoding: "UTF-8")
    FileUtils.mkdir_p(File.join(dir, "skills", skill_name, "references"))
    File.write(File.join(dir, "skills", skill_name, "references", "detail.md"), "# Detail\n", encoding: "UTF-8")
    File.write(File.join(dir, "patterns", "ruby", "demo.md"), "# Demo pattern\n", encoding: "UTF-8")
    File.write(File.join(dir, "router", "ROUTING.md"), "# Routing\n", encoding: "UTF-8")
    File.write(File.join(dir, "docs", "SKILL_CONTRACT.md"), "# Contract\n", encoding: "UTF-8")
    File.write(File.join(dir, "AGENTS.md"), "# Agents\n", encoding: "UTF-8")
    FileUtils.cp(VERIFIER, File.join(dir, "bin", "skill-pack-verify"))
    File.write(File.join(dir, "bin", "stack-minimality"), "#!/usr/bin/env ruby\nputs \"ok\"\n", encoding: "UTF-8")
    FileUtils.cp(
      File.join(ROOT, "bin", "skill-pack-compatibility"),
      File.join(dir, "bin", "skill-pack-compatibility")
    )
    FileUtils.mkdir_p(File.join(dir, "lib", "ruby_agent_skills"))
    FileUtils.cp(File.join(ROOT, "bin", "verify-change"), File.join(dir, "bin", "verify-change"))
    %w[change_verifier runtime_profile version_constraint].each do |name|
      FileUtils.cp(File.join(ROOT, "lib", "ruby_agent_skills", "#{name}.rb"),
                   File.join(dir, "lib", "ruby_agent_skills", "#{name}.rb"))
    end
    File.write(
      File.join(dir, "skill-manifest.yml"),
      <<~YAML,
        version: 2
        name: test-pack
        #{retired.empty? ? "" : "retired_skills:\n" + retired.map { |old, new_name| "  #{old}: #{new_name}" }.join("\n")}
        #{relocated.empty? ? "" : "relocated_skills:\n" + relocated.map { |old, target| "  #{old}: #{target}" }.join("\n")}
        patterns:
          testing:
            paths: []
          ruby:
            paths:
              - patterns/ruby/demo.md
        skills:
          #{skill_name}:
            family: ruby
            path: skills/#{skill_name}/SKILL.md
            triggers:
              - demo
        evaluations: {}
      YAML
    )

    git(dir, "init", "-b", "main")
    git(dir, "config", "user.email", "test@example.com")
    git(dir, "config", "user.name", "Test")
    git(dir, "add", ".")
    git(dir, "commit", "-m", "test source")
    dir
  end

  def install(source, project, ref: "main")
    ENV["RUBY_AGENT_SKILLS_REPO"] = source
    Open3.capture3(
      "bash", INSTALLER,
      "--scope", "project",
      "--agent", "agents",
      "--project", project,
      "--ref", ref,
      chdir: ROOT
    )
  ensure
    ENV.delete("RUBY_AGENT_SKILLS_REPO")
  end

  def test_installer_copies_skills_patterns_and_provenance
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    out, err, status = install(source, project)

    assert status.success?, "#{out}\n#{err}"
    target = File.join(project, ".agents", "skills")

    assert File.file?(File.join(target, "demo-skill", "SKILL.md"))
    assert File.file?(File.join(target, ".ruby-agent-skills", "patterns", "ruby", "demo.md"))
    assert File.file?(File.join(target, ".ruby-agent-skills", "skill-manifest.yml"))
    assert File.file?(File.join(target, ".ruby-agent-skills", "skill-pack-verify"))
    assert File.file?(File.join(target, ".ruby-agent-skills", "bin", "stack-minimality"))

    verify_out, verify_err, verify_status = Open3.capture3(
      RbConfig.ruby, VERIFIER, "--root", target, chdir: ROOT
    )

    assert verify_status.success?, "#{verify_out}\n#{verify_err}"

    metadata = JSON.parse(File.read(File.join(target, ".ruby-agent-skills", "INSTALLATION.json"), encoding: "UTF-8"))

    assert_equal 1, metadata.fetch("protocol_version")
    assert_equal 1, metadata.fetch("inventory").fetch("skills")
    assert_equal 1, metadata.fetch("inventory").fetch("patterns")
    assert_equal 40, metadata.fetch("source").fetch("resolved_git_sha").length
  end

  def test_installer_accepts_a_commit_sha_ref
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    source_sha = `git -C #{source} rev-parse HEAD`.strip

    out, err, status = install(source, project, ref: source_sha)

    assert status.success?, "#{out}\n#{err}"
    target = File.join(project, ".agents", "skills")
    metadata = JSON.parse(File.read(File.join(target, ".ruby-agent-skills", "INSTALLATION.json"), encoding: "UTF-8"))

    assert_equal source_sha, metadata.fetch("source").fetch("resolved_git_sha")
  end

  def test_verifier_rejects_tampered_skill
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    out, err, status = install(source, project)

    assert status.success?, "#{out}\n#{err}"

    target = File.join(project, ".agents", "skills")
    skill_path = File.join(target, "demo-skill", "SKILL.md")
    File.open(skill_path, "a", encoding: "UTF-8") { |file| file.write("tampered\n") }

    _verify_out, verify_err, verify_status = Open3.capture3(
      RbConfig.ruby, VERIFIER, "--root", target, chdir: ROOT
    )

    refute verify_status.success?
    assert_includes verify_err, "skill"
  end

  def test_installer_records_skill_references
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    out, err, status = install(source, project)

    assert status.success?, "#{out}\n#{err}"
    target = File.join(project, ".agents", "skills")

    assert File.file?(File.join(target, "demo-skill", "references", "detail.md"))

    metadata = JSON.parse(File.read(File.join(target, ".ruby-agent-skills", "INSTALLATION.json"), encoding: "UTF-8"))
    recorded = metadata.fetch("integrity").fetch("skill_files").map { |entry| entry.fetch("path") }

    assert_equal ["demo-skill/SKILL.md", "demo-skill/references/detail.md"], recorded.sort
  end

  def test_verifier_rejects_tampered_skill_reference
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    out, err, status = install(source, project)

    assert status.success?, "#{out}\n#{err}"

    target = File.join(project, ".agents", "skills")
    File.open(File.join(target, "demo-skill", "references", "detail.md"), "a", encoding: "UTF-8") { |file| file.write("tampered\n") }

    _verify_out, verify_err, verify_status = Open3.capture3(
      RbConfig.ruby, VERIFIER, "--root", target, chdir: ROOT
    )

    refute verify_status.success?
    assert_includes verify_err, "skill file SHA-256 mismatch: demo-skill/references/detail.md"
  end

  def test_verifier_rejects_injected_skill_reference
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    out, err, status = install(source, project)

    assert status.success?, "#{out}\n#{err}"

    target = File.join(project, ".agents", "skills")
    File.write(File.join(target, "demo-skill", "references", "injected.md"), "# Injected\n", encoding: "UTF-8")

    _verify_out, verify_err, verify_status = Open3.capture3(
      RbConfig.ruby, VERIFIER, "--root", target, chdir: ROOT
    )

    refute verify_status.success?
    assert_includes verify_err, "unrecorded skill file: demo-skill/references/injected.md"
  end

  def test_verifier_rejects_tampered_minimality_tool
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    out, err, status = install(source, project)

    assert status.success?, "#{out}\n#{err}"

    target = File.join(project, ".agents", "skills")
    tool_path = File.join(target, ".ruby-agent-skills", "bin", "stack-minimality")
    File.open(tool_path, "a", encoding: "UTF-8") { |file| file.write("tampered\n") }

    _verify_out, verify_err, verify_status = Open3.capture3(
      RbConfig.ruby, VERIFIER, "--root", target, chdir: ROOT
    )

    refute verify_status.success?
    assert_includes verify_err, "tool SHA-256 mismatch"
  end

  def test_installed_verify_change_runs_from_the_pack_and_is_hash_verified
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    out, err, status = install(source, project)

    assert status.success?, "#{out}\n#{err}"

    pack = File.join(project, ".agents", "skills", ".ruby-agent-skills")
    listed, list_status = Open3.capture2(RbConfig.ruby, File.join(pack, "bin", "verify-change"), "--list-checks")
    metadata = JSON.parse(File.read(File.join(pack, "INSTALLATION.json"), encoding: "UTF-8"))
    hashed = metadata.dig("integrity", "tools").map { |tool| tool.fetch("path") }

    assert list_status.success?
    assert_includes listed.split, "rubocop"
    assert_includes hashed, "lib/ruby_agent_skills/change_verifier.rb"
    File.open(File.join(pack, "lib", "ruby_agent_skills", "change_verifier.rb"), "a") { |file| file.write("#\n") }
    _out, verify_err, verify_status = Open3.capture3(RbConfig.ruby, VERIFIER, "--root", File.dirname(pack), chdir: ROOT)

    refute verify_status.success?
    assert_includes verify_err, "tool SHA-256 mismatch"
  end

  def test_verifier_rejects_tampered_pattern
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    out, err, status = install(source, project)

    assert status.success?, "#{out}\n#{err}"

    target = File.join(project, ".agents", "skills")
    pattern_path = File.join(target, ".ruby-agent-skills", "patterns", "ruby", "demo.md")
    File.open(pattern_path, "a", encoding: "UTF-8") { |file| file.write("tampered\n") }

    _verify_out, verify_err, verify_status = Open3.capture3(
      RbConfig.ruby, VERIFIER, "--root", target, chdir: ROOT
    )

    refute verify_status.success?
    assert_includes verify_err, "pattern file SHA-256 mismatch"
  end

  def test_installer_removes_skills_missing_from_new_source
    old_source = build_source(skill_name: "old-skill")
    new_source = build_source(skill_name: "new-skill")
    project = Dir.mktmpdir("ruby-agent-skills-project")

    out, err, status = install(old_source, project)

    assert status.success?, "#{out}\n#{err}"
    out, err, status = install(new_source, project)

    assert status.success?, "#{out}\n#{err}"

    target = File.join(project, ".agents", "skills")

    refute Dir.exist?(File.join(target, "old-skill"))
    assert Dir.exist?(File.join(target, "new-skill"))
  end

  def test_installer_reports_retired_skill_replacement
    old_source = build_source(skill_name: "old-skill")
    new_source = build_source(skill_name: "new-skill", retired: { "old-skill" => "new-skill" })
    project = Dir.mktmpdir("ruby-agent-skills-project")

    out, err, status = install(old_source, project)

    assert status.success?, "#{out}\n#{err}"
    out, err, status = install(new_source, project)

    assert status.success?, "#{out}\n#{err}"

    refute Dir.exist?(File.join(project, ".agents", "skills", "old-skill"))
    assert_includes out, "Removed retired skill old-skill (merged into new-skill)."
  end

  def test_installer_reports_skill_relocated_to_another_pack
    old_source = build_source(skill_name: "old-skill")
    new_source = build_source(skill_name: "new-skill",
                              relocated: { "old-skill" => "other-pack / old-skill" })
    project = Dir.mktmpdir("ruby-agent-skills-project")

    out, err, status = install(old_source, project)

    assert status.success?, "#{out}\n#{err}"
    out, err, status = install(new_source, project)

    assert status.success?, "#{out}\n#{err}"

    refute Dir.exist?(File.join(project, ".agents", "skills", "old-skill"))
    assert_includes out, "Removed relocated skill old-skill (moved to other-pack / old-skill;"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/skill_pack_installer_system_test.rb"
    assert_includes validator, "test/skill_pack_verification_system_test.rb"
  end
end
