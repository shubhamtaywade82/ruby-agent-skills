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

  def build_source(skill_name: "demo-skill")
    dir = Dir.mktmpdir("ruby-agent-skills-source")
    FileUtils.mkdir_p(File.join(dir, "skills", skill_name))
    FileUtils.mkdir_p(File.join(dir, "patterns", "ruby"))
    FileUtils.mkdir_p(File.join(dir, "router"))
    FileUtils.mkdir_p(File.join(dir, "docs"))
    FileUtils.mkdir_p(File.join(dir, "bin"))

    File.write(File.join(dir, "skills", skill_name, "SKILL.md"), "---\nname: #{skill_name}\ndescription: Test skill.\n---\n\n# Demo\n", encoding: "UTF-8")
    File.write(File.join(dir, "patterns", "ruby", "demo.md"), "# Demo pattern\n", encoding: "UTF-8")
    File.write(File.join(dir, "router", "ROUTING.md"), "# Routing\n", encoding: "UTF-8")
    File.write(File.join(dir, "docs", "SKILL_CONTRACT.md"), "# Contract\n", encoding: "UTF-8")
    File.write(File.join(dir, "AGENTS.md"), "# Agents\n", encoding: "UTF-8")
    FileUtils.cp(VERIFIER, File.join(dir, "bin", "skill-pack-verify"))
    File.write(
      File.join(dir, "skill-manifest.yml"),
      <<~YAML,
        version: 2
        name: test-pack
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

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/skill_pack_installer_system_test.rb"
    assert_includes validator, "test/skill_pack_verification_system_test.rb"
  end
end
