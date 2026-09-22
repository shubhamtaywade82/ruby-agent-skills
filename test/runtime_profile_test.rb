# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"
require_relative "../lib/ruby_agent_skills/runtime_profile"

class RuntimeProfileTest < Minitest::Test
  def with_repo(files)
    Dir.mktmpdir do |root|
      files.each do |path, content|
        full_path = File.join(root, path)
        FileUtils.mkdir_p(File.dirname(full_path))
        File.write(full_path, content)
      end
      yield root
    end
  end

  def test_prefers_lockfile_ruby_and_resolves_rails_and_bundler
    with_repo(
      ".ruby-version" => "3.3.6\n",
      "Gemfile" => <<~RUBY,
        source "https://rubygems.org"
        ruby ">= 3.2"
        gem "rails", "~> 8.1"
      RUBY
      "Gemfile.lock" => <<~LOCK
        GEM
          specs:
            rails (8.1.3.1)

        RUBY VERSION
           ruby 3.3.6p108

        BUNDLED WITH
           2.6.9
      LOCK
    ) do |root|
      profile = RubyAgentSkills::RuntimeProfile.call(root)

      assert_equal "3.3.6p108", profile.fetch("ruby").fetch("resolved")
      assert_equal "resolved", profile.fetch("ruby").fetch("status")
      assert_equal "8.1.3.1", profile.fetch("rails").fetch("resolved")
      assert_equal "2.6.9", profile.fetch("bundler").fetch("resolved")
    end
  end

  def test_reports_conflicting_exact_ruby_evidence
    with_repo(
      ".ruby-version" => "3.3.6\n",
      "Gemfile.lock" => <<~LOCK
        RUBY VERSION
           ruby 3.2.4p0

        BUNDLED WITH
           2.5.0
      LOCK
    ) do |root|
      profile = RubyAgentSkills::RuntimeProfile.call(root)

      assert_nil profile.fetch("ruby").fetch("resolved")
      assert_equal true, profile.fetch("ruby").fetch("conflict")
      assert_equal "conflict", profile.fetch("ruby").fetch("status")
    end
  end

  def test_preserves_gemfile_and_gemspec_constraints_without_claiming_resolution
    with_repo(
      "Gemfile" => <<~RUBY,
        source "https://rubygems.org"
        ruby "~> 3.3"
        gem "rails", "~> 8.1"
      RUBY
      "app.gemspec" => <<~RUBY
        Gem::Specification.new do |spec|
          spec.required_ruby_version = ">= 3.2"
        end
      RUBY
    ) do |root|
      profile = RubyAgentSkills::RuntimeProfile.call(root)

      assert_equal "constrained", profile.fetch("ruby").fetch("status")
      assert_nil profile.fetch("ruby").fetch("resolved")
      assert_equal "constrained", profile.fetch("rails").fetch("status")
      assert_nil profile.fetch("rails").fetch("resolved")
    end
  end
end
