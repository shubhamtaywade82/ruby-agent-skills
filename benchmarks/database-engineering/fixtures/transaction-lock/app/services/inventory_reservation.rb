class InventoryReservation
  def self.call(item)
    raise "unavailable" if item.quantity.zero?

    item.update!(quantity: item.quantity.pred)
  end
end
