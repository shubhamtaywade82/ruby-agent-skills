# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"

class CorpusQualitySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  AUDIT = File.join(ROOT, "scripts", "audit_corpus_quality.rb")

  def run_audit
    Open3.capture3(RbConfig.ruby, AUDIT, chdir: ROOT)
  end

  def test_corpus_quality_audit_passes_and_reports_exact_measurements
    stdout, stderr, status = run_audit

    assert status.success?, "#{stdout}
#{stderr}"

    %w[
      Corpus quality audit passed.
      Skills:
      Patterns:
      Evaluations:
      Benchmark coverage:
      Routing:
    ].each { |marker| assert_includes stdout, marker }
    assert_match(/skills: \d+\/\d+ with reference examples/, stdout)
    assert_match(/patterns: \d+\/\d+ with implementation anchors/, stdout)
    assert_match(/evaluations: \d+\/\d+ with non-empty cases/, stdout)
    assert_match(/unbenchmarked: 0 files \(0 cases\)/, stdout)
  end

  def test_audit_classifies_non_empirical_public_evaluations_explicitly
    paths = Dir[File.join(ROOT, "evals", "react-typescript", "*.yml")] +
            Dir[File.join(ROOT, "evals", "rails-react-integration", "*.yml")] +
            Dir[File.join(ROOT, "evals", "stack-minimality", "*.yml")]

    refute_empty paths

    paths.each do |path|
      text = File.read(path, encoding: "UTF-8")

      assert_match(/^coverage: static-only$/, text, "#{path} must declare its non-campaign coverage")
    end
  end

  def test_release_archive_system_test_uses_manifest_derived_skill_count
    test = File.read(File.join(ROOT, "test", "release_archive_system_test.rb"), encoding: "UTF-8")

    refute_match(/assert_equal 91, release\.fetch\("skills"\)/, test)
    assert_includes test, "skill-manifest.yml"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/corpus_quality_system_test.rb"
  end
end
