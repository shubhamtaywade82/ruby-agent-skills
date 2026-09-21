---
name: rollback-rollforward
description: Decide and execute rollback or roll-forward based on durable-state compatibility, external side effects, and recoverability.
family: rails
---

# Rollback or Roll-Forward

## Problem
Rollback is unsafe when the current durable state or external contracts are incompatible with the previous application version.

## Use when
- defining failed-release recovery;
- introducing irreversible migrations;
- choosing recovery direction during a release incident.

## Do not use when
- release recovery semantics are already fixed by an external platform contract and no application decision exists.

## Repository inspection
Inspect current/previous artifacts, migration state, queued jobs, external side effects, data reconciliation, feature flags, and incident/runbook controls.

## Implementation procedure
1. Determine current durable state. 2. Check previous artifact compatibility. 3. Identify irreversible/external effects. 4. Select rollback or forward fix. 5. Define verification. 6. Record recovery evidence.

## Failure modes
- assuming application rollback undoes schema/data changes;
- ignoring already-emitted external messages or charges;
- no reconciliation plan;
- no recovery verification.

## Testing
Test recovery against representative expand/contract and partially-applied release scenarios.

## Review checklist
- [ ] compatibility; - [ ] external effects; - [ ] data state; - [ ] recovery direction; - [ ] verification.

## Related skills
rails-release-engineering, rails-production-runtime, rails-database-engineering, rails-incident-engineering, rails-distributed-systems