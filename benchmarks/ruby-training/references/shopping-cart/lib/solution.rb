# frozen_string_literal: true

class Mall
  Product = Struct.new(:name, :price, :quantity)

  def initialize
    @products = {}
  end

  def add_product(name, price, quantity)
    raise ArgumentError, "price must be non-negative" if price.negative?
    raise ArgumentError, "quantity must be positive" unless quantity.positive?

    existing = @products[name]
    @products[name] = Product.new(name, price, (existing&.quantity || 0) + quantity)
  end

  def product(name)
    @products[name]
  end
end

class ShoppingCart
  class ProductNotAvailable < StandardError; end
  class InsufficientInventory < StandardError; end
  class InsufficientCartQuantity < StandardError; end

  def initialize(mall)
    @mall = mall
    @lines = Hash.new(0)
  end

  def add_product(name, quantity)
    product = @mall.product(name)
    raise ProductNotAvailable, "product_not_available: #{name}" unless product
    if @lines[name] + quantity > product.quantity
      raise InsufficientInventory, "insufficient_inventory: only #{product.quantity} #{name} available"
    end

    @lines[name] += quantity
  end

  def remove_product(name, quantity)
    if quantity > @lines[name]
      raise InsufficientCartQuantity, "insufficient_cart_quantity: cart holds #{@lines[name]} #{name}"
    end

    @lines[name] -= quantity
    @lines.delete(name) if @lines[name].zero?
  end

  def details
    @lines.map do |name, quantity|
      price = @mall.product(name).price
      { "name" => name, "quantity" => quantity, "price" => price, "line_total" => price * quantity }
    end
  end

  def total
    details.sum { |row| row.fetch("line_total") }
  end
end
