---
name: safe-production-debugging
description: Select the narrowest read-only or reversible production diagnostic before using state-changing incident interventions.
family: rails
---

# Safe Production Debugging

## Problem
Incident pressure can turn diagnostic work into accidental production mutation, security exposure, or a larger outage.

## Use when
- running production diagnostics;
- choosing between read-only inspection and intervention;
- reviewing emergency operational tooling.

## Do not use when
- debugging only local development state;
- a task has no production access or operational side effects.

## Repository inspection
Inspect operator permissions, audit logs, admin tooling, database safety conventions, feature flags, rollback mechanisms, and security controls.

## Implementation procedure
1. State the question. 2. Prefer existing telemetry. 3. Select the narrowest read-only inspection. 4. Bound result size and time range. 5. Identify blast radius and privilege. 6. Prefer reversible mitigation. 7. Record state-changing actions.

## Failure modes
- destructive SQL;
- arbitrary production code execution;
- broad data exports;
- disabling security;
- mutation without rollback or audit trail.

## Testing
Exercise tooling with permission checks, dry-run modes where appropriate, bounded queries, and explicit failure responses.

## Review checklist
- [ ] question stated; - [ ] read-only first; - [ ] scope bounded; - [ ] privilege checked; - [ ] reversible; - [ ] audited.

## Related skills
rails-incident-engineering, rails-security, rails-security-engineering, rails-database-engineering