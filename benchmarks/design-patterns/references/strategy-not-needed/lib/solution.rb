class ShippingCost
  def initialize(weight_grams:)
    @weight_grams = weight_grams
  end

  def cents
    500 + (@weight_grams * 2)
  end
end
