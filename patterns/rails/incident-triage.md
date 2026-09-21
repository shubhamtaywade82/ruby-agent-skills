---
name: incident-triage
description: Structure production incident triage around user impact, scope, onset, evidence, hypotheses, and next safe actions.
family: rails
---

# Incident Triage

## Problem
Production failures often generate many noisy signals. An agent needs a repeatable way to establish what is actually affected before selecting a mitigation.

## Use when
- a production alert or symptom needs initial classification;
- scope, onset, or severity is unclear;
- several plausible causes exist.

## Do not use when
- the task is ordinary local debugging with no operational impact;
- the root cause is already proven and the task is only implementation.

## Repository inspection
Inspect existing SLOs, severity conventions, alert definitions, request/job/message identifiers, deployment markers, dashboards, and ownership metadata.

## Implementation procedure
1. Name the affected user or system contract. 2. Establish onset and baseline. 3. Determine scope. 4. Correlate recent changes and dependency/resource signals. 5. State a leading hypothesis and one falsifying observation. 6. Choose the next bounded diagnostic action.

## Failure modes
- treating the loudest log as root cause;
- declaring severity without user impact;
- running broad queries before narrowing scope;
- starting mitigation without ownership.

## Testing
Incident drills should provide deterministic symptoms and verify that the agent produces contract, scope, hypothesis, and next-action evidence.

## Review checklist
- [ ] user impact named; - [ ] onset evidence; - [ ] scope bounded; - [ ] hypothesis falsifiable; - [ ] next action safe;

## Related skills
rails-incident-engineering, rails-observability, rails-reliability-engineering, ruby-debugging