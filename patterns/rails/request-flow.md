---
name: request-flow
description: Use when implementing an HTTP feature that crosses routing, controller, authorization, domain logic, persistence, and response layers.
family: rails
---

# Rails Request Flow

## Problem

A feature crosses several Rails boundaries and can easily leak responsibilities between them.

## Use when

- adding an endpoint
- changing an existing request flow
- debugging an HTTP feature
- implementing a CRUD resource

## Do not use when

- the change is isolated to one internal object and has no request contract

## Repository inspection

Trace:

~~~text
route
  -> authentication
  -> authorization
  -> params
  -> application/domain operation
  -> persistence
  -> serializer/view
  -> HTTP response
~~~

Inspect the actual repository at each boundary before changing code.

## Implementation procedure

1. Define the HTTP contract.
2. Confirm route and verb.
3. Confirm authentication/authorization.
4. Define accepted input.
5. Identify the owner of business behavior.
6. Persist through existing boundaries.
7. Define success/error response behavior.
8. Add request-level regression coverage.
9. Run focused and broader checks.

## Failure modes

- business logic in controller
- authorization only in views
- response shape changed accidentally
- persistence rules duplicated in request handling
- endpoint works only for the happy path

## Testing

At minimum, cover the meaningful success path plus invalid/unauthorized/error paths relevant to the endpoint.

## Review checklist

- [ ] route is correct
- [ ] authn/authz enforced
- [ ] params are controlled
- [ ] business logic has a clear owner
- [ ] response contract preserved
- [ ] request regression test exists

## Related skills

- rails-routing
- rails-controllers
- rails-authentication
- rails-activerecord
- rails-testing
- rails-architecture
