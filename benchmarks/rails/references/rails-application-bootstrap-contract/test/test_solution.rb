# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class RailsApplicationBootstrapTest < Minitest::Test
  HELP = <<~TEXT
    --api
    --database
    --javascript
    --css
    --skip-active-storage
    TEXT

  def setup
    @bootstrap = RailsApplicationBootstrap.new(help_output: HELP)
  end

  def test_standard_monolith
    assert_equal "rails new store", @bootstrap.command("store")
  end

  def test_api_postgres
    assert_equal(
      "rails new store --api --database=postgresql",
      @bootstrap.command("store", api_only: true, database: "postgresql")
    )
  end

  def test_frontend_and_template
    assert_equal(
      "rails new store --javascript=esbuild --css=tailwind -m template.rb",
      @bootstrap.command(
        "store",
        javascript: "esbuild",
        css: "tailwind",
        template: "template.rb"
      )
    )
  end

  def test_version_aware_skip_option
    assert_equal(
      "rails new store --skip-active-storage",
      @bootstrap.command(
        "store",
        skip: ["--skip-active-storage", "--skip-action-text"]
      )
    )
  end

  def test_force_requires_explicit_override
    assert_raises(ArgumentError) { @bootstrap.command("store", force: true) }
  end

  def test_option_supported_uses_target_help
    assert @bootstrap.option_supported?("--skip-active-storage")
    refute @bootstrap.option_supported?("--skip-action-text")
  end
end
