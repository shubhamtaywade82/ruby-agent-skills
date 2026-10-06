# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"

# rubocop:disable Metrics/ClassLength, Metrics/MethodLength
class FrameworkDriftSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  REGISTRY = <<~YAML
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
        match: '\\bupdate_attributes!?\\b'
        example: 'order.update_attributes(status: :paid)'
        replacement: update / update!
        source_url: https://guides.rubyonrails.org/v6.1.5/6_1_release_notes.html
        source_section: Active Record removals
  YAML

  def with_fixture(markdown)
    Dir.mktmpdir("ruby-agent-framework-drift-") do |root|
      FileUtils.mkdir_p(File.join(root, "skills/example"))
      write_fixture_files(root, markdown)
      yield root, File.join(root, "framework-drift.yml")
    end
  end

  def write_fixture_files(root, markdown)
    File.write(File.join(root, "skills/example/SKILL.md"), markdown, encoding: "UTF-8")
    File.write(File.join(root, "framework-drift.yml"), REGISTRY, encoding: "UTF-8")
  end

  def run_audit(root, registry)
    Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts/audit_framework_drift.rb"),
      "--root",
      root,
      "--registry",
      registry,
      chdir: ROOT
    )
  end

  def test_rejects_control_character_match_from_yaml
    registry = REGISTRY.sub(
      "match: '\\bupdate_attributes!?\\b'",
      "match: \"\\bupdate_attributes!?\\b\""
    )

    with_fixture(<<~MARKDOWN) do |root, path|
      # Example

      ```ruby
      order.update(status: :paid)
      ```
    MARKDOWN
      File.write(path, registry, encoding: "UTF-8")
      stdout, stderr, status = run_audit(root, path)

      refute_predicate status, :success?, stdout
      assert_includes stderr, "contains control characters"
    end
  end

  def test_detects_deprecated_api_inside_ruby_code_fence
    with_fixture(<<~MARKDOWN) do |root, registry|
      # Example

      ```ruby
      order.update_attributes!(status: :paid)
      ```
    MARKDOWN
      stdout, stderr, status = run_audit(root, registry)

      refute_predicate status, :success?, stdout
      assert_includes stderr, "rails-update-attributes"
      assert_includes stderr, "skills/example/SKILL.md:4"
    end
  end

  def test_detects_deprecated_api_inside_rb_code_fence
    with_fixture(<<~MARKDOWN) do |root, registry|
      # Example

      ```rb
      order.update_attributes(status: :paid)
      ```
    MARKDOWN
      stdout, stderr, status = run_audit(root, registry)

      refute_predicate status, :success?, stdout
      assert_includes stderr, "rails-update-attributes"
      assert_includes stderr, "skills/example/SKILL.md:4"
    end
  end

  def test_ignores_deprecated_api_in_prose
    with_fixture(<<~MARKDOWN) do |root, registry|
      # Example

      Historical guidance mentions update_attributes but contains no Ruby code block.
    MARKDOWN
      stdout, stderr, status = run_audit(root, registry)

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
    with_fixture(<<~MARKDOWN) do |root, registry|
      # Example

      ```ruby
      # framework-drift: allow rails-update-attributes historical migration example
      order.update_attributes!(status: :paid)
      ```
    MARKDOWN
      stdout, stderr, status = run_audit(root, registry)

      assert_predicate status, :success?, "#{stdout}\n#{stderr}"
    end
  end

  # The committed registry must detect each entry's own example inside a
  # Ruby fence. A YAML-escaping mistake (e.g. '\\b' in single quotes) once
  # made every entry match nothing while the audit still passed.
  def test_committed_registry_detects_every_entry_example
    require "yaml"
    entries = YAML.safe_load_file(File.join(ROOT, "framework-drift.yml")).fetch("entries")
    fences = entries.values.map { |entry| "```ruby\n#{entry.fetch('example')}\n```\n" }.join("\n")

    with_fixture(fences) do |root, _fixture_registry|
      stdout, stderr, status = run_audit(root, File.join(ROOT, "framework-drift.yml"))

      refute_predicate status, :success?, stdout
      entries.each_key { |id| assert_includes stderr, "framework drift #{id} " }
    end
  end

  def test_rejects_entry_whose_match_cannot_match_its_example
    # Block form: a replacement string would collapse the doubled backslash.
    registry = REGISTRY.sub("match: '\\bupdate_attributes!?\\b'") do
      "match: '\\\\bupdate_attributes!?'"
    end

    with_fixture("# Example\n") do |root, path|
      File.write(path, registry, encoding: "UTF-8")
      stdout, stderr, status = run_audit(root, path)

      refute_predicate status, :success?, stdout
      assert_includes stderr, "does not match its example"
    end
  end
end

# rubocop:enable Metrics/ClassLength, Metrics/MethodLength
