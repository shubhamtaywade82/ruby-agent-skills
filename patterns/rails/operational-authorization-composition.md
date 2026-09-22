---
name: operational-authorization-composition
description: Operational Authorization Composition Contract
family: security
---
# Operational Authorization Composition Contract

## Problem
Operational commands often bypass web authentication entirely.

## Use when
A Rake task, runner command, or maintenance workflow changes security-sensitive data or behavior.

## Do not use when
A harmless diagnostic task with no privileged side effect.

## Repository inspection
Inspect operator identity, execution environment, deployment access controls, audit requirements, and runbook.

## Implementation procedure
Require explicit operator/capability context where needed and enforce environment gates before side effects.

## Failure modes
Anyone with shell access can execute a sensitive mutation, unclear audit trail, unsafe production execution.

## Testing
Test approved and rejected invocation contexts plus audit evidence where applicable.

## Review checklist
[ ] operator boundary [ ] environment gate [ ] capability [ ] audit

## Related skills
rails-cross-boundary-authorization-security, rails-operational-tasks-maintenance