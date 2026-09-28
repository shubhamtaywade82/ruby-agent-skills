# Custom, associated, strict, and callback validation

Reference for the `rails-validations` skill. Load it on demand when a change adds custom validation methods or validators, validates associations, uses strict validation, or adds validation callbacks. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Custom validation methods

Use validate :method when the rule is small, local, and specific to one model.

A custom validation method should inspect state, add precise errors, avoid persistence, avoid external calls, avoid mutating unrelated records, and remain deterministic.

Use a custom validator class when the same coherent rule is genuinely reused across model types or needs a configurable contract.

ActiveModel::Validator and ActiveModel::EachValidator provide the reusable validator boundaries.

Do not create a validator class for one simple predicate merely to add indirection.

## Associated validation

Validate associated state only when the parent contract owns or requires that associated validity.

Coordinate with rails-associations for inverse, autosave, nested attributes, and lifecycle semantics.

Avoid recursively validating an unbounded object graph. Keep the graph narrow and test exact failure propagation.

## Strict validations

Use strict validation only when invalid state should raise immediately and callers explicitly expect that exception boundary.

Strict validation raises ActiveModel::StrictValidationFailed by default or a configured exception class.

Before enabling strict behavior, inspect all callers and form/API error handling. Do not convert a user-correction path into an exception-only path accidentally.

## Validation callbacks

Treat before_validation and after_validation as lifecycle hooks, not as workflow engines.

Good uses can include deterministic normalization or preparation intrinsic to validation.

Avoid callbacks that send email, publish events, call external APIs, enqueue durable work, mutate unrelated aggregates, or implement authorization.

When a callback changes a value another validator observes, test ordering and the resulting validation state.
