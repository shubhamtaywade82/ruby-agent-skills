---
name: credentials-store-contract
description: Credentials Store Contract
family: rails
---
# Credentials Store Contract

## Problem
Secret material is unsafe when storage, key ownership, and runtime access are implicit.

## Use when
Adding or changing Rails credentials.

## Do not use when
The value is non-sensitive application configuration.

## Repository inspection
Inspect credential paths, key files, deployment secret injection, environment conventions, and existing access patterns.

## Implementation procedure
Choose a supported encrypted credential store or approved runtime secret source; document owner and access path.

## Failure modes
Plaintext Git secrets, leaked key files, undocumented alternate stores.

## Testing
Test credential access using non-production values and verify missing-key behavior.

## Review checklist
[ ] store explicit [ ] key separate [ ] access path documented

## Related skills
rails-encryption-credentials-engineering, rails-security-engineering