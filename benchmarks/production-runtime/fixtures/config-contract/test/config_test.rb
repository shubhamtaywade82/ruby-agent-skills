source = File.read(File.expand_path("../config/production.rb", __dir__))
abort "missing master key contract" unless source.include?("RAILS_MASTER_KEY")
abort "missing database url contract" unless source.include?("DATABASE_URL")
abort "must not print secret" if source.match?(/puts\s+ENV\[|p\s+ENV\[/)
