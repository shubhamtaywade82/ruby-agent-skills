# frozen_string_literal: true

require "minitest/autorun"

class ValidationGateIntegritySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  VALIDATE_PATH = File.join(ROOT, "bin", "validate")

  def validate_script
    File.read(VALIDATE_PATH, encoding: "UTF-8")
  end

  def test_validation_gate_bootstraps_root_before_use
    script = validate_script
    expected = <<~BASH
      #!/usr/bin/env bash
      set -euo pipefail

      ROOT="$(cd "$(dirname "$0")/.." && pwd)"
    BASH

    assert script.start_with?(expected)
  end

  def test_validation_gate_uses_repository_root_for_all_ruby_paths
    ruby_lines = validate_script.lines.select { |line| line.start_with?("ruby ") }
    unrooted = ruby_lines.reject { |line| line.include?("$ROOT/") }

    assert_empty unrooted
  end

  def test_validation_gate_invokes_the_framework_drift_check_and_test
    script = validate_script

    assert_includes script, 'ruby "$ROOT/scripts/audit_framework_drift.rb"'
    assert_includes script, 'ruby -I"$ROOT/test" "$ROOT/test/framework_drift_system_test.rb"'
  end
end
