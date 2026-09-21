source = File.read(File.expand_path("../app/services/order_checkout.rb", __dir__))
abort "missing instrumentation" unless source.include?("ActiveSupport::Notifications.instrument")
abort "wrong event" unless source.include?("checkout.completed")
abort "missing order_id payload" unless source.match?(/order_id/)
