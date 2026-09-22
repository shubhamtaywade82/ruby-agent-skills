class InventoryReservation
  def self.call(item)
    item.with_lock do
      raise "unavailable" if item.quantity <= 0

      item.update!(quantity: item.quantity - 1)
    end
  end
end
