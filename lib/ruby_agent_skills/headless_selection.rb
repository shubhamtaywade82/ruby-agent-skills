# frozen_string_literal: true

module RubyAgentSkills
  # Shape checks for one routing decision, applied before it is normalized into
  # a result. Array(...) and to_s would turn a bare string or a missing reason
  # into an apparently valid result, so each field is checked as it arrives.
  module HeadlessSelection
    module_function

    def validate(selected)
      abort "routing response must be a JSON object" unless selected.is_a?(Hash)

      primary = selected["primary_skill"]
      abort "primary_skill must be a non-empty string" unless non_empty_string?(primary)

      secondary = selected["secondary_skills"]
      abort "secondary_skills must be an array of strings" unless string_array?(secondary)

      reason = selected["reason"]
      abort "reason must be a non-empty string" unless non_empty_string?(reason)

      [primary, secondary.uniq, reason]
    end

    def string_array?(value)
      value.is_a?(Array) && value.all?(String)
    end

    def non_empty_string?(value)
      value.is_a?(String) && !value.strip.empty?
    end
  end
end
