class PriceCalculator
  def initialize(subtotal_cents:, discount_percent:)
    @subtotal_cents = subtotal_cents
    @discount_percent = discount_percent
  end

  def total_cents
    @subtotal_cents * (100 - @discount_percent) / 100
  end
end
