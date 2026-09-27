class PendingState
  def shippable?
    raise NotImplementedError
  end
end

class PaidState
  def shippable?
    raise NotImplementedError
  end
end

class Order
  def initialize(state:)
    @state = state
  end

  def state
    raise NotImplementedError
  end

  def shippable?
    raise NotImplementedError
  end
end
