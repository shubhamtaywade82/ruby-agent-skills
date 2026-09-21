Customer = Struct.new(:active, :premium)

class ActiveCustomerSpecification
  def satisfied_by?(customer)
    false
  end
end

class PremiumSpecification
  def satisfied_by?(customer)
    false
  end
end
