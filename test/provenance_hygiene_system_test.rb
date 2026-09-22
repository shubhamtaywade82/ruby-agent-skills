# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"

class ProvenanceHygieneSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  AUDIT = File.join(ROOT, "scripts", "audit_provenance_hygiene.rb")

  def test_repository_passes_provenance_hygiene_audit
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, AUDIT, chdir: ROOT)

    assert status.success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "Provenance hygiene audit passed."
  end

  def test_audit_rejects_invisible_unicode_citation_tokens
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "SKILL.md"), "guide. \uE200cite\uE202turn0search0\uE201 done\n")

      _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, AUDIT, dir, chdir: ROOT)

      refute status.success?, "wrapped citation token must fail the audit"
    end
  end

  def test_audit_rejects_escaped_backticks_and_literal_newlines
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "SKILL.md"), "use \`Mutex\` here\n| a | b |\n| c | d \\n| e |\n")

      _stdout, _stderr, status = Open3.capture3(RbConfig.ruby, AUDIT, dir, chdir: ROOT)

      refute status.success?, "escaped backtick and literal \\n must fail the audit"
    end
  end

  def test_audit_allows_legitimate_escapes_inside_code_fences
    Dir.mktmpdir do |dir|
      File.write(
        File.join(dir, "check.rb"),
        "lines = text.split(\"\\n\")\nputs lines\n"
      )
      File.write(
        File.join(dir, "doc.md"),
        "```ruby\nsplit(\"\\n\") if s.include?(\"\\t\")\n```\n"
      )

      stdout, _stderr, status = Open3.capture3(RbConfig.ruby, AUDIT, dir, chdir: ROOT)

      assert status.success?, stdout
      assert_includes stdout, "Provenance hygiene audit passed."
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/provenance_hygiene_system_test.rb"
  end
end
