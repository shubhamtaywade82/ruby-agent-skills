---
name: deterministic-encryption-query-contract
description: Deterministic Encryption Query Contract
family: rails
---
# Deterministic Encryption Query Contract

## Problem
Equality queries, uniqueness, and indexing require deterministic ciphertext, which changes the security tradeoff.

## Use when
An encrypted attribute must support equality queries or uniqueness semantics.

## Do not use when
No query against the encrypted attribute is required.

## Repository inspection
Inspect query shapes, uniqueness validations/indexes, case normalization, and threat model.

## Implementation procedure
Use deterministic encryption only when required; normalize inputs intentionally and document the privacy/security tradeoff.

## Failure modes
Unqueryable data, duplicate records, ciphertext correlation, or unnecessary deterministic exposure.

## Testing
Test expected equality queries and uniqueness behavior without asserting ciphertext details.

## Review checklist
[ ] query requirement proven [ ] deterministic justified [ ] normalization [ ] security tradeoff

## Related skills
rails-encryption-credentials-engineering, rails-database-engineering