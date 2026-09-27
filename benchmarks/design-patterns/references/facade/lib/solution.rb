class Inventory
  def reserve(sku)
    sku == "BOOK"
  end
end

class Pricing
  def price(sku)
    sku == "BOOK" ? 100 : 0
  end
end

class Payment
  def capture(amount)
    amount > 0
  end
end

class Storefront
  def initialize(inventory:, pricing:, payment:)
    @inventory = inventory
    @pricing = pricing
    @payment = payment
  end

  def purchase(sku:)
    return :out_of_stock unless @inventory.reserve(sku)

    amount = @pricing.price(sku)
    @payment.capture(amount) ? :completed : :payment_failed
  end
end
