class VendorGateway
  def make_charge(amount_cents)
    { "ok" => true, "amount" => amount_cents }
  end
end

class StripeAdapter
  def initialize(client:)
    @client = client
  end

  # Application-facing contract; the vendor method name and response shape
  # stay inside the adapter.
  def charge(amount:)
    response = @client.make_charge(amount)
    { "ok" => response.fetch("ok") == true, "amount" => response.fetch("amount") }
  end
end
