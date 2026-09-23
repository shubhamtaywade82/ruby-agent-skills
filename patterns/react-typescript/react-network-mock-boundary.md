---
name: react-network-mock-boundary
description: Mock network behavior at the HTTP boundary when isolating UI integration.
family: react-typescript
---

# React Network Mock Boundary

## Problem
A component depends on remote data and the test should remain independent of real services.

## Use when
The test is specifically validating the network client implementation itself.

## Do not use when
Do not activate simply when The test is specifically validating the network client implementation itself. 

## Repository inspection
Inspect existing request mocks, fixtures, and request identity.

## Implementation procedure
Mock stable request/response behavior including failures and delays without mocking React internals.

## Failure modes
Mocking every child, hard-coded fetch spies scattered across tests, and leaking fixture state.

## Testing
Test success, error, cancellation, and relevant response variants.

## Review checklist
Is the mock preserving the contract shape consumers actually receive?

## Related skills
react-testing-engineering,react-data-fetching
