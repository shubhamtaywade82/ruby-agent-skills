# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class RubyToolchainAdvisorTest < Minitest::Test
  def setup
    @advisor = RubyToolchainAdvisor.new
  end

  def test_resolve_separates_declared_and_observed_runtime
    assert_equal(
      {
        "status" => "supported",
        "declared_ruby" => "3.3",
        "observed_ruby" => "3.3.6",
        "ruby_executable" => "/usr/local/bin/ruby",
        "bundle_executable" => "/usr/local/bin/bundle"
      },
      @advisor.resolve(
        declared_ruby: "3.3",
        observed_ruby: "3.3.6",
        ruby_executable: "/usr/local/bin/ruby",
        bundle_executable: "/usr/local/bin/bundle"
      )
    )
  end

  def test_detects_executable_provenance_conflict
    assert_equal(
      "conflict",
      @advisor.resolve(
        declared_ruby: "3.3",
        observed_ruby: "3.3.6",
        ruby_executable: "/opt/ruby/bin/ruby",
        bundle_executable: "/usr/local/bin/bundle"
      ).fetch("status")
    )
  end

  def test_detects_declared_and_observed_runtime_mismatch
    assert_equal(
      "conflict",
      @advisor.resolve(
        declared_ruby: "3.3",
        observed_ruby: "3.2.4",
        ruby_executable: "/usr/local/bin/ruby",
        bundle_executable: "/usr/local/bin/bundle"
      ).fetch("status")
    )
  end

  def test_uses_bundler_for_application_dependencies
    assert_equal "bundle check && bundle install",
                 @advisor.dependency_command(lockfile_present: true)
  end

  def test_diagnoses_native_extension_prerequisites
    assert_equal(
      "missing-ruby-header",
      @advisor.native_extension_classification(
        "fatal error: ruby.h: No such file or directory"
      )
    )
    assert_equal(
      "linker",
      @advisor.native_extension_classification("ld: library not found for -lz")
    )
  end

  def test_does_not_change_runtime_to_hide_install_failure
    refute @advisor.runtime_change_allowed?(reason: "native extension build failed")
  end
end
