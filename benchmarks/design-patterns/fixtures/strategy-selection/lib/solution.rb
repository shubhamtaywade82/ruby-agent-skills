class StandardShipping
  def calculate
    raise NotImplementedError
  end
end

class ExpressShipping
  def calculate
    raise NotImplementedError
  end
end

class ShippingCost
  def initialize(strategy:)
    @strategy = strategy
  end

  def calculate
    raise NotImplementedError
  end
end
