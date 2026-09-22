source = File.read(File.expand_path("../app/services/inventory_reservation.rb", __dir__))
abort "missing with_lock" unless source.include?("with_lock")
abort "must guard quantity" unless source.match?(/quantity\s*<=\s*0/)
abort "must decrement" unless source.match?(/quantity\s*-\s*1/)
