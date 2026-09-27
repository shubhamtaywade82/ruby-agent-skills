Order = Struct.new(:id, :customer)

class OrderRepository
  def initialize(store:)
    @store = store
  end

  def find(id)
    raise NotImplementedError
  end

  def save(order)
    raise NotImplementedError
  end
end
