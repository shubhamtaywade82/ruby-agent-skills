class PendingState
  def shippable?
    false
  end
end

class PaidState
  def shippable?
    true
  end
end

class Order
  def initialize(state:)
    @state = state
  end

  def state
    @state
  end

  def shippable?
    @state.shippable?
  end
end
