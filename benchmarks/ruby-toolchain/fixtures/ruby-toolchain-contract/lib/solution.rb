# frozen_string_literal: true

class RubyToolchainAdvisor
  def resolve(declared_ruby:, observed_ruby:, ruby_executable:, bundle_executable:)
    nil
  end

  def dependency_command(lockfile_present:)
    nil
  end

  def native_extension_classification(error_output)
    nil
  end

  def runtime_change_allowed?(reason:)
    nil
  end
end
