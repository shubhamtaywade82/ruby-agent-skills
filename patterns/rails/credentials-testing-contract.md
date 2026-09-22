---
name: credentials-testing-contract
description: Credentials and Encryption Testing Contract
family: rails
---
# Credentials and Encryption Testing Contract

## Problem
Security behavior is easily untested when tests require real secrets or assert implementation details instead of contracts.

## Use when
Adding or changing credentials/encryption behavior.

## Do not use when
Purely unrelated application tests.

## Repository inspection
Inspect test credentials, CI secret availability, fixtures, helper setup, filtering assertions, and production-like boot tests.

## Implementation procedure
Use disposable test keys/credentials, contract-level assertions, and failure-path tests; never reuse production secrets.

## Failure modes
Tests depend on developer-local keys, leak values in failures, or pass despite missing production configuration.

## Testing
Run isolated tests with synthetic secrets and verify tests fail safely when required keys are absent.

## Review checklist
[ ] synthetic secrets [ ] missing-key path [ ] filtering [ ] no value assertions

## Related skills
rails-encryption-credentials-engineering, rails-test-engineering