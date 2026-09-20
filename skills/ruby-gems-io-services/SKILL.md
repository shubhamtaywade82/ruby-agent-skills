---
name: ruby-gems-io-services
description: Use for RubyGems/dependency decisions, filesystem and CSV I/O, HTTP integrations, external boundaries, and focused service objects.
---

# Ruby Gems, I/O and Services

## Purpose

Keep external boundaries and multi-step workflows isolated so the rest of the application can remain explicit, testable, and easy to change.

## Activate when

- adding or changing a gem dependency
- reading/writing files or CSV
- calling an HTTP/REST API
- parsing external data
- introducing or refactoring a service object
- coordinating several steps across domain/external boundaries

## Repository inspection

Before adding or changing an external dependency, inspect:


Before adding a gem:

1. inspect Gemfile and lockfile
2. resolve supported Ruby/Rails versions
3. check whether the standard library or existing dependency already provides the capability
4. inspect project policy/security constraints
5. keep the new dependency's responsibility narrow

Do not add a dependency merely to save a few lines.

## I/O boundaries

Separate:

```text
read
  -> parse
  -> validate
  -> transform
  -> persist/use
```

This allows tests to replace the boundary without reproducing the entire external environment.

### Files

Use explicit paths and encoding where relevant. Handle missing files, permission errors, malformed input, and resource lifecycle correctly.

### CSV

Define:

- header expectations
- field mapping
- encoding
- malformed-row behavior
- type conversion
- duplicate handling

Do not mix CSV parsing with domain persistence in one large method.

## HTTP / REST

An HTTP client boundary should make these concerns visible:

- base URL
- authentication
- timeout
- headers
- request body
- serialization
- response status handling
- parsing
- error mapping
- retries/backoff when justified

Do not scatter raw HTTP calls through controllers/models.

Never log credentials, tokens, secrets, or sensitive payloads unnecessarily.

## Service objects

Use a service when the operation is a coherent workflow involving multiple concepts, side effects, or boundaries.

Prefer a meaningful API such as:

```ruby
CheckoutOrder.new(order, payment_gateway).call
```

Do not create a service object for every method or use generic `Manager`/`Processor` names without a defined role.

Keep the service focused and preserve domain ownership.

## Failure semantics

Decide whether failure is represented by:

- exception
- result object
- false/nil
- domain error

Follow repository conventions. Do not silently swallow failures.

## Testing boundaries

Use fakes/stubs at external boundaries according to the test stack. Keep parsing/transformation logic testable without network/filesystem access when practical.

## Agent review checklist

- [ ] dependency is necessary
- [ ] version compatibility checked
- [ ] external boundary isolated
- [ ] input parsing separated from domain logic
- [ ] timeout/error behavior defined
- [ ] secrets protected
- [ ] service responsibility is coherent
- [ ] external behavior is testable

## Verification

Run focused unit tests with external boundaries isolated. Add integration tests for important contract behavior. Exercise malformed input and external failure paths where they are part of the application's reliability requirements.

## Source foundation

Derived from the RubyGems, filesystem, CSV, HTTP, and service-class material in *The Ruby Workshop*. The service-boundary and responsibility guidance is reinforced by *Clean Ruby*.
