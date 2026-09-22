# shopping-cart

Implement the shopping-cart domain. Keep inventory and cart state separate and enforce the stated limits.

# Contract
# Mall#add_product(name, price, quantity)
# ShoppingCart.new(mall)
# cart.add_product(name, quantity)
# cart.remove_product(name, quantity)
# cart.details -> array of hashes with name, quantity, price, line_total
# cart.total -> numeric total
# Domain failures should raise StandardError with stable messages:
# product_not_available, insufficient_inventory, insufficient_cart_quantity


Do not change files outside the implementation and test/spec surfaces unless required by the task.