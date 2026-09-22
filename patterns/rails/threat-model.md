---
name: threat-model
description: Map assets, actors, trust boundaries, attacker capabilities, abuse cases, controls, and residual risk for a Rails feature or architecture.
family: rails
---

# Threat Model

## Problem

Security reviews jump directly to implementation findings without identifying what must be protected, who can attack it, and where trust changes.

## Use when

A feature introduces new sensitive data, privileges, providers, services, or execution boundaries.

## Do not use when

The change is a narrow local fix whose threat boundary is already explicit and unchanged.

## Repository inspection

Inspect assets, actors, entry points, trust boundaries, authorization, dangerous sinks, external providers, jobs, queues, and existing security controls.

## Implementation procedure

1. List high-value assets.
2. Identify actors and capabilities.
3. Draw trust boundaries and data flows.
4. Mark attacker-controlled inputs.
5. Identify dangerous sinks and privilege transitions.
6. Enumerate concrete abuse cases.
7. Rank by impact and exploitability.
8. Map preventive/detective/recovery controls.
9. Add executable abuse-case tests.
10. Record residual risk and ownership.

## Failure modes

- generic threat list without repository data flow
- treating all findings as equal
- missing alternate execution paths
- controls listed without verification
- residual risk with no owner

## Testing

Each high-impact abuse case should have a focused executable regression where practical.

## Review checklist

- [ ] assets identified
- [ ] actors/capabilities identified
- [ ] trust boundaries identified
- [ ] abuse cases concrete
- [ ] controls mapped
- [ ] verification present
- [ ] residual risk owned

## Related skills

- rails-security-engineering
- rails-security
- rails-testing
