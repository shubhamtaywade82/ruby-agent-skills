class PriceCalculator
  def initialize(base_price:, tax_rate:)
    @base_price = base_price
    @tax_rate = tax_rate
  end

  def total
    @base_price + (@base_price * @tax_rate)
  end
end
