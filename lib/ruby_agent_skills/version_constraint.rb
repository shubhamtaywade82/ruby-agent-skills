# frozen_string_literal: true

require "rubygems/requirement"
require "rubygems/version"

module RubyAgentSkills
  module VersionConstraint
    class InvalidRequirement < ArgumentError; end
    class InvalidVersion < ArgumentError; end

    module_function

    def satisfies?(version, requirement)
      Gem::Requirement.new(requirement.to_s).satisfied_by?(normalized_version(version))
    rescue ArgumentError => e
      raise InvalidRequirement, e.message
    end

    def evaluate(requirements, runtime_profile)
      requirements = requirements.to_h
      results = {}

      requirements.each do |runtime, requirement|
        result = evaluate_requirement(runtime.to_s, requirement.to_s, runtime_profile)
        results[runtime.to_s] = result
      end

      {
        "status" => aggregate_status(results),
        "requirements" => results
      }
    end

    def validate(requirement)
      Gem::Requirement.new(requirement.to_s)
    rescue ArgumentError => e
      raise InvalidRequirement, e.message
    end

    def normalized_version(value)
      raw = value.to_s.strip.sub(/^ruby-/, "").sub(/p\d+.*$/, "")
      raise InvalidVersion, "version must be a non-empty string" if raw.empty?

      Gem::Version.new(raw)
    rescue ArgumentError => e
      raise InvalidVersion, e.message
    end

    def evaluate_requirement(runtime, requirement, profile)
      entry = profile.fetch(runtime, {})
      actual = entry["resolved"]
      state = entry["status"].to_s

      return base_result("unspecified", requirement) if requirement.empty?
      validate(requirement)

      return base_result("conflict", requirement) if state == "conflict"
      return base_result("unknown", requirement) if actual.to_s.empty?

      result_status = satisfies?(actual, requirement) ? "supported" : "unsupported"
      base_result(result_status, requirement, actual)
    end

    def base_result(status, requirement, version = nil)
      {
        "status" => status,
        "constraint" => requirement,
        "version" => version
      }.compact
    end

    def aggregate_status(results)
      statuses = results.values.map { |value| value.fetch("status") }
      return "unsupported" if statuses.include?("unsupported")
      return "conflict" if statuses.include?("conflict")
      return "unknown" if statuses.include?("unknown")
      return "supported" if statuses.include?("supported")

      "unspecified"
    end

    private_class_method :evaluate_requirement, :base_result, :aggregate_status
  end
end
