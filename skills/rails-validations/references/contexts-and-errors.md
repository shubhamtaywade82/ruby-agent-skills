# Validation contexts and validation errors

Reference for the `rails-validations` skill. Load it on demand when a change adds validation contexts or alters error keys, messages, or error details. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Validation contexts

Use a validation context only when the repository has a real operation/state boundary that differs from the default validation contract.

Prefer built-in create/update behavior when sufficient. Custom contexts should have explicit callers and focused tests.

For each custom context, document:

- who invokes the context;
- which rules are shared with default validation;
- which rules are context-specific;
- whether ordinary persistence still runs the required rules;
- how invalid state is reported.

Do not use custom contexts to make ordinary save silently accept invalid domain states.

## Validation errors

Treat ActiveModel::Errors as a structured contract, not merely a collection of display strings.

Relevant surfaces include error objects, errors[attribute], details, full_messages, full_messages_for, to_hash/as_json, add, base-level errors, and importing/merging errors.

Choose the representation from the consumer:

model/service tests -> error type/details
HTML form -> field association + human messages
API -> stable machine-readable field/type/details

Do not make API clients depend on human-readable prose when stable error identity can be exposed.

When changing errors, inspect locale files, form rendering, request/API serializers, client consumers, tests, and any metrics or logs that parse error keys.

Never expose secrets or internal query data through custom error messages.
