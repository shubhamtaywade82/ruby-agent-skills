class Inventory
  def initialize(items:)
    @items = items
  end

  def available?(sku:)
    raise NotImplementedError
  end
end
