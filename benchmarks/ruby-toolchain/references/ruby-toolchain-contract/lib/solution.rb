# frozen_string_literal: true

class RubyToolchainAdvisor
  def resolve(declared_ruby:, observed_ruby:, ruby_executable:, bundle_executable:)
    ruby_version = Gem::Version.new(observed_ruby)
    declared_minor = declared_ruby.split(".").first(2).join(".")
    executable_roots = [
      File.dirname(ruby_executable),
      File.dirname(bundle_executable)
    ].map { |path| File.expand_path(path) }

    {
      "status" => executable_roots.uniq.length == 1 &&
                  ruby_version.to_s.start_with?("#{declared_minor}.") ?
                    "supported" : "conflict",
      "declared_ruby" => declared_ruby,
      "observed_ruby" => observed_ruby,
      "ruby_executable" => ruby_executable,
      "bundle_executable" => bundle_executable
    }
  end

  def dependency_command(lockfile_present:)
    lockfile_present ? "bundle check && bundle install" : "bundle install"
  end

  def native_extension_classification(error_output)
    case error_output
    when /ruby\.h: No such file or directory/i
      "missing-ruby-header"
    when /ld: library not found/i
      "linker"
    else
      "build-toolchain"
    end
  end

  def runtime_change_allowed?(reason:)
    false
  end
end
