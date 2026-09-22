---
name: serializable-hash-allowlist
description: Serializable Hash Allowlist
family: rails
---
# Serializable Hash Allowlist

## Problem
Broad attribute dumps expose fields and couple consumers to model schema.

## Use when
Using ActiveModel serialization or serializable_hash for an external representation.

## Do not use when
A trusted debugging-only representation with no consumer contract.

## Repository inspection
Inspect attributes, model columns, serialization options, and consumer expectations.

## Implementation procedure
Prefer explicit fields or only-style allowlists; use exclusions only when stable and audited.

## Failure modes
Sensitive or newly added database columns silently become serialized fields.

## Testing
Test added and removed model columns against expected output.

## Review checklist
[ ] allowlist preferred [ ] output tested [ ] schema independence

## Related skills
rails-serialization-globalid-engineering, rails-active-model