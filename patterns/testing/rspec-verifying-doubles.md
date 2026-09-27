---
name: rspec-verifying-doubles
description: "Stub collaborators with RSpec verifying doubles so tests fail when the real interface changes."
family: testing
---

# RSpec Verifying Doubles

## Problem
Plain `double` and `allow_any_instance_of` keep passing after the real collaborator's method is renamed or its keywords change, so the suite is green while production breaks.

## Use when
A spec isolates a collaborator at a boundary you own (a gateway, client, or service) and injects it.

## Do not use when
The collaborator is cheap and deterministic; use the real object. For HTTP boundaries, prefer a fake transport or recorded response over stubbing the client.

## Repository inspection
Inspect how the collaborator is injected, its public method signatures, and whether `verify_partial_doubles` is enabled in `spec_helper.rb`.

## Implementation procedure
1. Inject the collaborator (argument or constructor) instead of stubbing globally.
2. Use `instance_double(Class)` or `class_double(Class)`.
3. Stub with `allow(...).to receive(...)` and assert with `have_received`.
4. Cover the failure result as well as success.

## Example

Runs green with rspec-rails 8.0 on Rails 8.0.

```ruby
require "rails_helper"

RSpec.describe Order, type: :model do
  describe "validations" do
    it "requires a positive integer quantity" do
      order = build(:order, quantity: 0)

      expect(order).not_to be_valid
      # of_kind? ignores the error's options (value:, count:); added? would need them all.
      expect(order.errors.of_kind?(:quantity, :greater_than)).to be(true)
    end

    it "is valid with the factory defaults" do
      expect(build(:order)).to be_valid
    end
  end

  describe "#pay!" do
    # A verifying double fails if PaymentGateway#charge is renamed or its
    # keywords change; a plain double would keep passing.
    let(:gateway) { instance_double(PaymentGateway) }
    let(:order) { create(:order, quantity: 3) }

    it "charges the amount and marks the order paid" do
      allow(gateway).to receive(:charge).and_return(PaymentGateway::Result.new(success?: true, error: nil))

      order.pay!(gateway: gateway)

      expect(gateway).to have_received(:charge).with(order_id: order.id, amount_cents: 3_000)
      expect(order.reload.status).to eq("paid")
    end

    it "raises and leaves the order pending when the charge fails" do
      allow(gateway).to receive(:charge).and_return(PaymentGateway::Result.new(success?: false, error: "declined"))

      expect { order.pay!(gateway: gateway) }.to raise_error(Order::PaymentFailed, "declined")
      expect(order.reload.status).to eq("pending")
    end
  end
end
```

## Failure modes
`double` with unverified messages, `allow_any_instance_of`, stubbing the object under test, and asserting call order that is not part of the contract.

## Testing
Rename a keyword on the real collaborator and confirm the doubled specs fail.

## Review checklist
Would a signature change in the real collaborator fail this spec?

## Related skills
rails-test-engineering,ruby-dependency-injection
