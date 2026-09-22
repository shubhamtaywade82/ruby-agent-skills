migration = File.read(File.expand_path("../db/migrate/20260921000003_add_order_reference_constraint.rb", __dir__))
model = File.read(File.expand_path("../app/models/order.rb", __dir__))
abort "missing unique DB constraint" unless migration.match?(/unique:\s*true/)
abort "missing application validation" unless model.include?("uniqueness")
