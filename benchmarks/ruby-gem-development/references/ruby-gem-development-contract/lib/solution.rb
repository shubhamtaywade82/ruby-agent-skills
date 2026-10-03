# frozen_string_literal: true

# The gemspec is part of the package contract.

class RubyGemDevelopmentAdvisor
  def skeleton_command(name)
    "bundle gem #{name}"
  end

  def dependency_groups
    { "runtime" => ["json"], "development" => ["minitest", "rake"] }
  end

  def consumer_require_command(gem_name)
    "ruby -e 'require \"#{gem_name}\"'"
  end

  def safe_package_files(files)
    Array(files).reject do |path|
      path.start_with?("test/", "spec/", ".git/") ||
        File.basename(path) == ".env"
    end
  end

  def release_allowed?(authorized:)
    authorized == true
  end
end
