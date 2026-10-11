# frozen_string_literal: true

module RubyAgentSkills
  # Pre-activation fact gate. A task-critical fact must be observed or derived
  # from evidence before implementation starts. See
  # skills/agent-workflow/references/fact-gate.md for the contract.
  module FactManifest
    CLASSES = %w[observed derived inferred unknown].freeze
    EVIDENCED = %w[observed derived].freeze

    module_function

    # "proceed" only when every task-critical fact is evidenced. A malformed
    # manifest is always "blocked" and is never partially evaluated.
    def evaluate(facts)
      errors = validation_errors(facts)
      return result("blocked", errors: errors) unless errors.empty?

      critical, optional = facts.partition { |fact| fact["task_critical"] }
      blocking = ids_of(critical.reject { |fact| evidenced?(fact) })
      unverified = ids_of(optional.reject { |fact| evidenced?(fact) })
      result(blocking.empty? ? "proceed" : "blocked", blocking: blocking, unverified: unverified)
    end

    def validation_errors(facts)
      return ["facts must be a non-empty list"] unless facts.is_a?(Array) && !facts.empty?

      errors = facts.flat_map { |fact| fact_errors(fact) }
      errors << "fact ids must be unique non-empty strings" unless unique_ids?(facts)
      errors
    end

    def fact_errors(fact)
      return ["each fact must be a mapping"] unless fact.is_a?(Hash)

      label = "fact #{fact['id'].inspect}"
      [class_error(label, fact), flag_error(label, fact), evidence_error(label, fact)].compact
    end

    def class_error(label, fact)
      return if CLASSES.include?(fact["class"])

      "#{label}: class must be one of #{CLASSES.join(', ')}"
    end

    def flag_error(label, fact)
      return if [true, false].include?(fact["task_critical"])

      "#{label}: task_critical must be true or false"
    end

    def evidence_error(label, fact)
      case fact["class"]
      when *EVIDENCED
        "#{label}: #{fact['class']} facts need a source" unless present?(fact["source"])
      when "inferred"
        "#{label}: inferred facts need a basis" unless present?(fact["basis"])
      end
    end

    def unique_ids?(facts)
      ids = facts.map { |fact| fact.is_a?(Hash) ? fact["id"] : nil }
      ids.all? { |id| present?(id) } && ids.uniq.size == ids.size
    end

    def evidenced?(fact)
      EVIDENCED.include?(fact["class"])
    end

    def ids_of(facts)
      facts.map { |fact| fact["id"] }
    end

    def present?(value)
      value.is_a?(String) && !value.strip.empty?
    end

    def result(status, errors: [], blocking: [], unverified: [])
      { "status" => status, "errors" => errors, "blocking" => blocking, "unverified" => unverified }
    end
  end
end
