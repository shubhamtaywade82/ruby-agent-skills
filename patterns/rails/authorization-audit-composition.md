---
name: authorization-audit-composition
description: Authorization Audit Composition Contract
family: security
---
# Authorization Audit Composition Contract

## Problem
Security decisions are difficult to investigate when audit evidence exists only at one execution surface.

## Use when
Sensitive authorization decisions require investigation or compliance evidence.

## Do not use when
The decision is low-risk and ordinary application telemetry is sufficient.

## Repository inspection
Inspect audit events, actor identity, resource/action context, redaction policy, event destinations, and duplication risk.

## Implementation procedure
Emit audit evidence at the authoritative decision boundary with sufficient context and without secrets.

## Failure modes
Missing audit trails, duplicated events, sensitive payload leakage, ambiguous actor identity.

## Testing
Test allow/deny events and ensure redaction and correlation work across entry points.

## Review checklist
[ ] authoritative boundary [ ] actor/action/resource [ ] redaction [ ] correlation

## Related skills
rails-cross-boundary-authorization-security, rails-observability