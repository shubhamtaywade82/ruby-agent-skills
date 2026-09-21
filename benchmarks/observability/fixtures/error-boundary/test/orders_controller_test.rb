source = File.read(File.expand_path("../app/controllers/orders_controller.rb", __dir__))
abort "missing InvalidOrderState handling" unless source.include?("InvalidOrderState")
abort "missing 409" unless source.include?("409")
abort "unexpected exceptions should not be broadly rescued" if source.match?(/rescue\s+StandardError/)
