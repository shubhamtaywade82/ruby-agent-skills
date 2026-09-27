require "test_helper"

# Load only the helper the suite uses instead of globbing every helper file.
require_relative "test_helpers/order_helpers"

class ActiveSupport::TestCase
  # Shared helper semantics are preserved: build_order still returns an
  # unsaved order for a customer, without building the full association graph.
  def build_order
    Order.new(customer: Customer.new(name: "Customer"))
  end
end
