class Inventory
  def initialize(items:)
    @items = items
  end

  def available?(sku:)
    @items.any? { |item| item.fetch(:sku) == sku && item.fetch(:quantity) > 0 }
  end
end
