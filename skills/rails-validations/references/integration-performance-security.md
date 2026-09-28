# API, form, and controller integration, performance, and tenant isolation

Reference for the `rails-validations` skill. Load it on demand when validation errors cross an API/form/controller boundary, or a validation has performance or tenant-isolation impact. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## API, form, and controller integration

Keep request parsing outside model validation:

request boundary
  -> permitted/typed input
  -> model/domain validation
  -> application operation
  -> stable error representation

Controllers should not duplicate every model rule.

For APIs, map validation errors to the repository's stable schema and preserve machine-readable identity. For HTML forms, preserve field-level error associations and translation behavior.

## Performance

Validation can perform database queries and traverse associated objects.

Before optimizing:

1. measure query count and latency;
2. identify repeated or graph-wide validation;
3. measure representative inputs;
4. reduce unnecessary work without weakening the contract.

Do not memoize mutable validation state across persistence attempts unless lifecycle/reset semantics are explicit.

## Security and tenant isolation

Validation does not establish authorization.

Review:

- tenant keys in uniqueness scopes;
- resource authorization before validation of private records;
- user-controlled values used in validator queries;
- dynamic constantization in custom validators;
- error-message disclosure;
- existence-check behavior for sensitive resources;
- API error representation across tenants.

Never turn “record exists” or “value is unique” into an authorization decision.
