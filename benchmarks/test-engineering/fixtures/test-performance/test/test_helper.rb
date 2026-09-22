require "test_helper"

# Benchmark fixture intentionally begins with an expensive global helper load.
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }

class ActiveSupport::TestCase
  def build_order
    build_customer_with_all_associations.build_order
  end
end
