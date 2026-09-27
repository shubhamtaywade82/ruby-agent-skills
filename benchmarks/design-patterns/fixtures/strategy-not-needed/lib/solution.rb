class ShippingCost
  def initialize(weight_grams:)
    @weight_grams = weight_grams
  end

  def cents
    raise NotImplementedError
  end
end
