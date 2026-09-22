source = File.read(File.expand_path("../db/migrate/20260921000002_add_orders_status_index.rb", __dir__))
abort "missing disable_ddl_transaction!" unless source.include?("disable_ddl_transaction!")
abort "missing concurrent algorithm" unless source.include?("algorithm: :concurrently")
