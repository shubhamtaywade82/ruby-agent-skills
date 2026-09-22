---
name: active-record-encryption-contract
description: Active Record Encryption Contract
family: rails
---
# Active Record Encryption Contract

## Problem
Persisted sensitive data remains exposed when encryption declarations, keys, columns, and model behavior are inconsistent.

## Use when
Encrypting an Active Record attribute.

## Do not use when
The field is intentionally public or hashing is sufficient for one-way verification.

## Repository inspection
Inspect model declarations, encryption configuration, key source, column type/size, validations, serializers, and consumers.

## Implementation procedure
Declare encrypted attributes explicitly, provision keys securely, and preserve normal application semantics through the encryption boundary.

## Failure modes
Missing keys, ciphertext exposed in unexpected places, incompatible types, or silently unencrypted paths.

## Testing
Test round-trip persistence, reads/writes, filtering, and missing-key failure.

## Review checklist
[ ] attribute explicit [ ] keys secure [ ] column reviewed [ ] round trip

## Related skills
rails-encryption-credentials-engineering, rails-active-record