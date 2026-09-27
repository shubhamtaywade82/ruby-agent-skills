Order = Struct.new(:id, :customer)

class OrderRepository
  def initialize(store:)
    @store = store
  end

  def find(id)
    @store.fetch(id)
  end

  def save(order)
    @store[order.id] = order
  end
end
