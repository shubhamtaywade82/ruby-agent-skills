class VendorGateway
  def make_charge(amount_cents)
    { "ok" => true, "amount" => amount_cents }
  end
end

class StripeAdapter
  def initialize(client:)
    @client = client
  end

  def charge(amount:)
    raise NotImplementedError
  end
end
