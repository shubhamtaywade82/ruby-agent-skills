# frozen_string_literal: true

require "minitest/autorun"

class ValidationGateIntegritySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  VALIDATE_PATH = File.join(ROOT, "bin", "validate")

  def validate_script
    File.read(VALIDATE_PATH, encoding: "UTF-8")
  end

  def test_validation_gate_bootstraps_root_before_using_it
    script = validate_script

    pattern = %r{A#!\/usr\/bin\/env bash\nset -euo pipefail\n\nROOT="\$\(cd "\$\(dirname "\$0"\)\/\.\." && pwd\)"\n}
    assert_match(pattern, script)
  end

  def test_validation_gate_uses_repository_root_for_all_repo_paths
    script = validate_script

    refute_match(%r{(?:^|\n)ruby "(?:scripts|test)/}, script)
    refute_match(
      %r{(?:^|\n)ruby -I"\$ROOT/test" "(?:/test|/scripts)/},
      script
    )
  end

  def test_validation_gate_invokes_the_framework_drift_check_and_test
    script = validate_script

    assert_includes script, 'ruby "$ROOT/scripts/audit_framework_drift.rb"'
    assert_includes script, 'ruby -I"$ROOT/test" "$ROOT/test/framework_drift_system_test.rb"'
  end
end