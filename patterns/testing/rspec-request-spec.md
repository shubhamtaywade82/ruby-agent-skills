---
name: rspec-request-spec
description: "Test an HTTP endpoint through the Rails stack with an RSpec request spec."
family: testing
---

# RSpec Request Spec

## Problem
RSpec suites often still use controller specs (`type: :controller`), which skip routing and middleware and are no longer recommended by rspec-rails, or they assert on instance variables instead of the HTTP contract.

## Use when
The repository uses RSpec and the change affects an endpoint's status, body, headers, redirects, or side effects.

## Do not use when
The repository uses Minitest; use the `request-contract` pattern with `ActionDispatch::IntegrationTest` instead.

## Repository inspection
Inspect `spec/rails_helper.rb`, `spec/support`, existing `spec/requests` conventions, authentication helpers, and the endpoint's JSON or HTML contract.

## Implementation procedure
1. Write the spec under `spec/requests` with `type: :request`.
2. Drive the real route helper (`post orders_path, params:, headers:`).
3. Assert status with `have_http_status` and the body with `response.parsed_body`.
4. Assert persistence with `change(Model, :count)` and side effects with block-form enqueue matchers.
5. Cover the invalid and malformed-parameter paths, not only success.

## Example

Runs green with rspec-rails 8.0 on Rails 8.0.

```ruby
require "rails_helper"

RSpec.describe "POST /orders", type: :request do
  let(:headers) { { "ACCEPT" => "application/json" } }

  context "with valid params" do
    let(:params) { { order: { sku: "BOOK-1", quantity: 2, email: "a@example.com" } } }

    it "creates the order and returns its id and status" do
      expect { post orders_path, params: params, headers: headers }.to change(Order, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to eq("id" => Order.last.id, "status" => "pending")
    end

    it "enqueues fulfilment and the confirmation email" do
      # Block form: have_enqueued_mail only works with a block.
      expect { post orders_path, params: params, headers: headers }
        .to have_enqueued_job(FulfilOrderJob).with(an_instance_of(Order)).on_queue("fulfilment")
        .and have_enqueued_mail(OrderMailer, :confirmation).with(an_instance_of(Order))
    end
  end

  context "with a non-positive quantity" do
    subject(:make_request) do
      post orders_path, params: { order: { sku: "BOOK-1", quantity: 0, email: "a@example.com" } }, headers: headers
    end

    it_behaves_like "a rejected JSON write", attribute: "quantity", type: "greater_than"
  end

  context "without the order key" do
    it "responds 400 instead of raising" do
      post orders_path, params: { sku: "BOOK-1" }, headers: headers

      expect(response).to have_http_status(:bad_request)
    end
  end
end
```

## Failure modes
Controller specs asserting `assigns`, asserting only the status code, testing the happy path only, and a 400 for a missing parameter left untested so a regression surfaces as a 500.

## Testing
Run the spec file alone and in the full suite; mutate the controller (drop a side effect or change a status) and confirm a failure.

## Review checklist
Does the spec assert the status, the response body, and each side effect the endpoint promises?

## Related skills
rails-test-engineering,rails-action-controller,rails-api-integration
