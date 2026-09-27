class StandardShipping
  def calculate
    10
  end
end

class ExpressShipping
  def calculate
    25
  end
end

class ShippingCost
  def initialize(strategy:)
    @strategy = strategy
  end

  def calculate
    @strategy.calculate
  end
end
