class Order
  attr_reader :status, :owner
  def initialize(status:, owner:)
    @status = status
    @owner = owner
  end
end

class OrderPolicy
  def initialize(actor:)
    @actor = actor
  end

  def can_cancel?(order)
    false
  end
end
