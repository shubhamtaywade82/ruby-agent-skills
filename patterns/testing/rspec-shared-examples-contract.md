---
name: rspec-shared-examples-contract
description: "Use RSpec shared examples to enforce one contract across several endpoints or objects."
family: testing
---

# RSpec Shared Examples Contract

## Problem
Duplicated contract assertions drift between endpoints, while shared examples used merely to remove repetition hide what each spec tests.

## Use when
Several endpoints or objects must honour the same contract (for example the same 422 error shape or the same authorization behaviour).

## Do not use when
The repeated assertions describe different behaviour that happens to look similar; keep them explicit.

## Repository inspection
Inspect existing `spec/support` shared examples, their parameters, and how `rails_helper.rb` loads support files.

## Implementation procedure
1. Name the shared example after the contract ("a rejected JSON write").
2. Pass what varies as parameters and require the including spec to define the action (`subject(:make_request)`).
3. Load `spec/support` from `rails_helper.rb`.
4. Include it with `it_behaves_like` at each endpoint that owns the contract.

## Example

Runs green with rspec-rails 8.0 on Rails 8.0.

```ruby
# Shared examples document a contract several endpoints must honour; they are
# not a way to deduplicate unrelated assertions.
RSpec.shared_examples "a rejected JSON write" do |attribute:, type:|
  it "returns 422 with the Rails validation error shape" do
    make_request

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body.fetch("errors")).to include(
      a_hash_including("attribute" => attribute, "type" => type)
    )
  end

  it "does not persist anything" do
    expect { make_request }.not_to change(Order, :count)
  end
end

# Used from spec/requests/orders_spec.rb:
#   subject(:make_request) { post orders_path, params: { order: { quantity: 0 } } }
#   it_behaves_like "a rejected JSON write", attribute: "quantity", type: "greater_than"
```

## Failure modes
Shared examples that depend on undocumented `let` names, deeply nested shared contexts, and shared examples used for unrelated assertions.

## Testing
Run every including spec; break the contract in one endpoint and confirm only that endpoint's examples fail.

## Review checklist
Does the shared example state one contract, with its inputs passed explicitly?

## Related skills
rails-test-engineering,rails-api-integration
