Customer = Struct.new(:active, :premium)

class ActiveCustomerSpecification
  def satisfied_by?(customer)
    customer.active == true
  end
end

# Premium customers must also be active; composition reuses the active rule.
class PremiumSpecification
  def initialize(active: ActiveCustomerSpecification.new)
    @active = active
  end

  def satisfied_by?(customer)
    @active.satisfied_by?(customer) && customer.premium == true
  end
end
