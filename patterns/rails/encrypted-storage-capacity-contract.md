---
name: encrypted-storage-capacity-contract
description: Encrypted Storage Capacity Contract
family: rails
---
# Encrypted Storage Capacity Contract

## Problem
Encryption adds ciphertext metadata and encoding overhead that can overflow columns or invalidate assumptions about storage/indexes.

## Use when
Encrypting or migrating a bounded string column.

## Do not use when
A text/blob column has ample validated capacity and no relevant index contract.

## Repository inspection
Inspect DB type, limits, encoding, indexes, generated ciphertext behavior, and largest legitimate values.

## Implementation procedure
Calculate practical headroom using representative data and choose a column size/type compatible with the encrypted representation.

## Failure modes
Truncation, validation errors, index limitations, failed migrations, or production-only oversized values.

## Testing
Test boundary values across supported encodings and verify migration/index behavior.

## Review checklist
[ ] size modeled [ ] encoding considered [ ] index reviewed [ ] boundary test

## Related skills
rails-encryption-credentials-engineering, rails-database-engineering