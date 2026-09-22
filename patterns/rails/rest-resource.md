---
name: rest-resource
description: Use when designing or changing a conventional Rails CRUD resource and its HTTP contract.
family: rails
---

# Rails REST Resource

## Problem

A Rails feature needs a coherent resource route, controller action set, parameter contract, and response behavior.

## Use when

- creating a conventional CRUD resource
- converting custom endpoint paths to resource routes
- reviewing REST semantics
- adding a versioned API resource

## Do not use when

- the operation is not naturally resource-oriented
- an established domain action has a clearer command-style endpoint
- the repository deliberately uses a different protocol

## Repository inspection

Inspect routes, controller conventions, serializers/views, authentication/authorization, request tests, and existing resource naming.

## Implementation procedure

1. define the resource and supported operations
2. use resources or resource when appropriate
3. map verbs to semantics intentionally
4. keep controller actions thin and explicit
5. enforce authentication/authorization at the boundary
6. filter parameters
7. define success and error status/body contracts
8. add request-level coverage
9. inspect generated helpers and route ordering

## Failure modes

- custom routes that duplicate REST resources
- wrong HTTP verbs
- authorization enforced only in the UI
- route exists but response contract is undefined
- controller action becomes a business-logic container

## Testing

Cover each supported verb/action, invalid input, authorization, not-found behavior when relevant, and response format/status.

## Review checklist

- [ ] resource name is coherent
- [ ] routes are conventional where appropriate
- [ ] verbs match operation semantics
- [ ] params are controlled
- [ ] authn/authz is enforced
- [ ] request tests cover the contract

## Related skills

- rails-routing
- rails-controllers
- rails-authentication
- rails-architecture
- rails-testing
