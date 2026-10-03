# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class RubyGemDevelopmentAdvisorTest < Minitest::Test
  def setup
    @advisor = RubyGemDevelopmentAdvisor.new
  end

  def test_uses_bundle_gem_for_skeleton
    assert_equal "bundle gem fixture_gem",
                 @advisor.skeleton_command("fixture_gem")
  end

  def test_separates_runtime_and_development_dependencies
    assert_equal(
      { "runtime" => ["json"], "development" => ["minitest", "rake"] },
      @advisor.dependency_groups
    )
  end

  def test_tests_consumer_require_path_outside_application_boot
    assert_equal(
      "ruby -e 'require \"fixture_gem\"'",
      @advisor.consumer_require_command("fixture_gem")
    )
  end

  def test_excludes_secrets_and_test_artifacts_from_package
    assert_equal(
      [
        "Gemfile",
        "fixture_gem.gemspec",
        "lib/fixture_gem.rb",
        "lib/fixture_gem/version.rb"
      ],
      @advisor.safe_package_files(
        [
          "Gemfile",
          "fixture_gem.gemspec",
          "lib/fixture_gem.rb",
          "lib/fixture_gem/version.rb",
          "test/test_fixture_gem.rb",
          ".env",
          ".git/config"
        ]
      )
    )
  end

  def test_release_requires_explicit_authorization
    refute @advisor.release_allowed?(authorized: false)
    assert @advisor.release_allowed?(authorized: true)
  end
end
