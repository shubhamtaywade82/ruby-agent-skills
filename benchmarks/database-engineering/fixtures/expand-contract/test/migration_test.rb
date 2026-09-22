source = File.read(File.expand_path("../db/migrate/20260921000001_expand_customer_name.rb", __dir__))
abort "must add display_name" unless source.include?("display_name")
abort "must not remove old name during expand" if source.match?(/remove_column.*name/)
