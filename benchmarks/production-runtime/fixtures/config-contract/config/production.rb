required = %w[RAILS_MASTER_KEY DATABASE_URL]
missing = required.reject { |key| ENV.key?(key) }
abort "missing required configuration: #{missing.join(', ')}" unless missing.empty?
