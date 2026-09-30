# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class FrameworkDriftSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  DETECT_MARKDOWN = <<~MARKDOWN
    # Example

    ```ruby
    order.update_attributes!(status: :paid)
    ```
  MARKDOWN

  PROSE_MARKDOWN = <<~MARKDOWN
    # Example

    Historical guidance mentions update_attributes but contains no Ruby code block.
  MARKDOWN

  SUPPRESSED_MARKDOWN = <<~MARKDOWN
    # Example

    ```ruby
    # framework-drift: allow rails-update-attributes historical migration example
    order.update_attributes!(status: :paid)
    ```
  MARKDOWN

  def with_fixture(markdown)
    Dir.mktmpdir("ruby-agent-framework-drift-") do |root|
      write_fixture(root, markdown)
      yield root, File.join(root, "framework-drift.yml")
    end
  end

  def write_fixture(root, markdown)
    skill_dir = File.join(root, "skills", "example")
    FileUtils.mkdir_p(skill_dir)
    File.write(File.join(skill_dir, "SKILL.md"), markdown, encoding: "UTF-8")
    File.write(File.join(root, "framework-drift.yml"), registry, encoding: "UTF-8")
  end

  def registry
    <<~YAML
      version: 1
      policy:
        scan_roots:
          - skills
        languages:
          - ruby
        default_framework: rails
      entries:
        rails-update-attributes:
          framework: rails
          status: removed
          version: "6.1"
          symbol: ActiveRecord::Base#update_attributes / #update_attributes!
          match: "\bupdate_attributes!?\b"
          replacement: update / update!
          source_url: https://guides.rubyonrails.org/v6.1.5/6_1_release_notes.html
          source_section: Active Record removals
    YAML
  end

  def run_audit(root, registry_path)
    Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts/audit_framework_drift.rb"),
      "--root",
      root,
      "--registry",
      registry_path,
      chdir: ROOT
    )
  end

  def test_detects_deprecated_api_inside_ruby_code_fence
    with_fixture(DETECT_MARKDOWN) do |root, registry_path|
      stdout, stderr, status = run_audit(root, registry_path)

      refute_predicate status, :success?, stdout
      assert_includes stderr, "rails-update-attributes"
      assert_includes stderr, "skills/example/SKILL.md:4"
    end
  end

  def test_ignores_deprecated_api_in_prose
    with_fixture(PROSE_MARKDOWN) do |root, registry_path|
      stdout, stderr, status = run_audit(root, registry_path)

      assert_predicate status, :success?, "#{stdout}\n#{stderr}"
    end
  end

  def test_validator_gate_is_registered
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    manifest = File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8")

    assert_includes validator, "scripts/audit_framework_drift.rb"
    assert_includes manifest, "framework-drift.yml"
    assert_includes manifest, "scripts/audit_framework_drift.rb"
  end

  def test_allows_explicit_in_block_suppression
    with_fixture(SUPPRESSED_MARKDOWN) do |root, registry_path|
      stdout, stderr, status = run_audit(root, registry_path)

      assert_predicate status, :success?, "#{stdout}\n#{stderr}"
    end
  end
end
