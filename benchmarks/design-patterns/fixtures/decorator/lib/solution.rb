class BasePrice
  def initialize(amount)
    @amount = amount
  end

  def total
    @amount
  end
end

class TaxedPrice
  def initialize(price:, tax_rate:)
    @price = price
    @tax_rate = tax_rate
  end

  def total
    raise NotImplementedError
  end
end
