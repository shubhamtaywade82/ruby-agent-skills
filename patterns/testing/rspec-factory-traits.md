---
name: rspec-factory-traits
description: "Keep factory_bot factories minimal and name test-relevant states as traits."
family: testing
---

# RSpec Factory Traits

## Problem
Factories grow into fixtures of the whole domain: every association and attribute set by default, slow `create` everywhere, and tests that pass because of hidden defaults.

## Use when
The repository uses factory_bot (check `Gemfile` for `factory_bot_rails`) and a spec needs records in a particular state.

## Do not use when
The repository uses Rails fixtures; follow `test/fixtures` or `spec/fixtures` conventions instead of adding factory_bot.

## Repository inspection
Inspect existing factories, traits, sequences, association strategies, and whether specs prefer `build`, `build_stubbed`, or `create`.

## Implementation procedure
1. Give the base factory only what validations require.
2. Use `sequence` for unique attributes.
3. Name each state a test depends on as a trait (`:paid`, `:cancelled`).
4. Prefer `build` or `build_stubbed` when persistence is not under test; use `create` when the code queries the database.

## Example

Runs green with rspec-rails 8.0 on Rails 8.0.

```ruby
FactoryBot.define do
  factory :order do
    sku { "BOOK-1" }
    quantity { 1 }
    sequence(:email) { |n| "buyer#{n}@example.com" }
    status { "pending" }

    # Traits name a state the test depends on; the base factory stays minimal.
    trait :paid do
      status { "paid" }
    end

    trait :cancelled do
      status { "cancelled" }
    end
  end
end
```

## Failure modes
Base factories that create associated records by default, tests relying on an implicit default value, `create` where `build` suffices, and traits that encode business logic instead of state.

## Testing
Assert `build(:factory)` is valid in a model spec, and keep suite runtime visible when changing factories.

## Review checklist
Does each spec state the attributes and traits its assertion depends on?

## Related skills
rails-test-engineering,rails-active-record
