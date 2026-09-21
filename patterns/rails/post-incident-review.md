---
name: post-incident-review
description: Convert incident evidence into a small set of owned, testable engineering improvements without turning the review into blame or vague action items.
family: rails
---

# Post-Incident Review

## Problem
Incident reviews become low-value when they are narratives without evidence or produce many unowned follow-ups.

## Use when
- closing a material incident;
- reviewing recurring failures;
- turning an operational finding into engineering work.

## Do not use when
- the event is only a local development defect with no operational learning.

## Repository inspection
Inspect incident records, existing tests, telemetry, alerts, runbooks, reliability objectives, security controls, and previous action items.

## Implementation procedure
1. State the affected contract. 2. Build the evidence-backed timeline. 3. Describe causal chain with uncertainty. 4. Identify control gaps. 5. Select a small number of high-leverage actions. 6. Assign owners. 7. Define verification. 8. Update runbooks/tests/telemetry/design.

## Failure modes
- blame-focused conclusions;
- unverified root cause;
- dozens of vague tasks;
- actions without ownership;
- actions without proof of completion.

## Testing
Each technical action should map to an executable test, telemetry assertion, runbook check, or design verification where practical.

## Review checklist
- [ ] evidence-backed timeline; - [ ] causal uncertainty labeled; - [ ] control gaps; - [ ] owner; - [ ] verification; - [ ] durable artifact updated.

## Related skills
rails-incident-engineering, rails-reliability-engineering, rails-observability, rails-test-engineering