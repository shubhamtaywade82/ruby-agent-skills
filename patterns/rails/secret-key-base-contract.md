---
name: secret-key-base-contract
description: Secret Key Base Contract
family: rails
---
# Secret Key Base Contract

## Problem
secret_key_base is a foundational Rails secret used by cryptographic features; careless overrides can invalidate sessions and other protected data.

## Use when
Changing secret_key_base storage, generation, or rotation.

## Do not use when
Changing unrelated credentials.

## Repository inspection
Inspect credentials, deployment variables, sessions/cookies, Active Storage usage, and rotation plan.

## Implementation procedure
Prefer credentials-backed secret_key_base in environments that require it; rotate with awareness of affected protected state.

## Failure modes
Hard-coded values, accidental regeneration, mass session invalidation without plan.

## Testing
Test boot, session continuity expectations, and rollback/rotation behavior.

## Review checklist
[ ] source explicit [ ] rotation impact known [ ] rollback plan

## Related skills
rails-encryption-credentials-engineering, rails-authentication, rails-production-runtime