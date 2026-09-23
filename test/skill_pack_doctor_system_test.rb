# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class SkillPackDoctorSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  INSTALLER = File.join(ROOT, "bin", "install")
  DOCTOR = File.join(ROOT, "bin", "skill-pack-doctor")
  VERIFIER = File.join(ROOT, "bin", "skill-pack-verify")

  def build_source
    dir = Dir.mktmpdir("ruby-agent-skills-source")
    FileUtils.mkdir_p(File.join(dir, "skills", "demo"))
    FileUtils.mkdir_p(File.join(dir, "patterns", "ruby"))
    FileUtils.mkdir_p(File.join(dir, "router"))
    FileUtils.mkdir_p(File.join(dir, "docs"))
    FileUtils.mkdir_p(File.join(dir, "bin"))

    File.write(File.join(dir, "skills", "demo", "SKILL.md"), <<~MARKDOWN, encoding: "UTF-8")
      ---
      name: demo
      description: Demo skill.
      family: test
      ---

      # Demo
      MARKDOWN
    File.write(File.join(dir, "patterns", "ruby", "demo.md"), <<~MARKDOWN, encoding: "UTF-8")
      ---
      name: demo
      description: Demo pattern.
      family: test
      ---

      # Demo
      ## Problem
      A test boundary.
      ## Use when
      Testing.
      ## Do not use when
      Not testing.
      ## Repository inspection
      Inspect.
      ## Implementation procedure
      Implement.
      ## Failure modes
      Fail.
      ## Testing
      Test.
      ## Review checklist
      Review.
      ## Related skills
      demo
      MARKDOWN
    File.write(File.join(dir, "router", "ROUTING.md"), "# Routing
", encoding: "UTF-8")
    File.write(File.join(dir, "docs", "SKILL_CONTRACT.md"), "# Contract
", encoding: "UTF-8")
    File.write(File.join(dir, "AGENTS.md"), "# Agents
", encoding: "UTF-8")
    FileUtils.cp(VERIFIER, File.join(dir, "bin", "skill-pack-verify"))

    File.write(File.join(dir, "skill-manifest.yml"), <<~YAML, encoding: "UTF-8")
      version: 2
      name: test-pack
      patterns:
        ruby:
          paths:
            - patterns/ruby/demo.md
      skills:
        demo:
          family: test
          path: skills/demo/SKILL.md
          triggers:
            - demo
      evaluations: {}
    YAML

    Open3.capture3("git", "-C", dir, "init", "-b", "main")
    Open3.capture3("git", "-C", dir, "config", "user.email", "test@example.com")
    Open3.capture3("git", "-C", dir, "config", "user.name", "Test")
    Open3.capture3("git", "-C", dir, "add", ".")
    stdout, stderr, status = Open3.capture3("git", "-C", dir, "commit", "-m", "test source")
    abort "git commit failed: #{stdout}
#{stderr}" unless status.success?
    dir
  end

  def install(source, project)
    previous = ENV["RUBY_AGENT_SKILLS_REPO"]
    ENV["RUBY_AGENT_SKILLS_REPO"] = source
    Open3.capture3(
      "bash", INSTALLER,
      "--scope", "project",
      "--agent", "agents",
      "--project", project
    )
  ensure
    previous ? ENV["RUBY_AGENT_SKILLS_REPO"] = previous : ENV.delete("RUBY_AGENT_SKILLS_REPO")
  end

  def test_doctor_passes_for_a_verified_installation
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    out, err, status = install(source, project)
    assert status.success?, "#{out}
#{err}"

    target = File.join(project, ".agents", "skills")
    stdout, stderr, doctor_status = Open3.capture3(
      RbConfig.ruby, DOCTOR, "--root", target, chdir: ROOT
    )

    assert doctor_status.success?, "#{stdout}
#{stderr}"
    assert_includes stdout, "Ruby Agent Skills doctor passed"
    assert_includes stdout, "content verification: passed"
  end

  def test_doctor_fails_for_a_tampered_installation
    source = build_source
    project = Dir.mktmpdir("ruby-agent-skills-project")
    out, err, status = install(source, project)
    assert status.success?, "#{out}
#{err}"

    target = File.join(project, ".agents", "skills")
    File.open(File.join(target, "demo", "SKILL.md"), "a", encoding: "UTF-8") do |file|
      file.write("tampered
")
    end

    _stdout, stderr, doctor_status = Open3.capture3(
      RbConfig.ruby, DOCTOR, "--root", target, chdir: ROOT
    )

    refute doctor_status.success?
    assert_includes stderr, "skill"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/skill_pack_doctor_system_test.rb"
  end
end
