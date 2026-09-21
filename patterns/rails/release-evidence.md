---
name: release-evidence
description: Preserve a machine-readable record of release identity, gate outcomes, exposure stages, recovery actions, and final state.
family: rails
---

# Release Evidence

## Problem
Without durable release evidence, operators cannot reconstruct what was tested, promoted, deployed, or recovered.

## Use when
- building release records;
- reviewing auditability;
- debugging deployment outcomes.

## Do not use when
- the existing release platform already captures equivalent immutable evidence.

## Repository inspection
Inspect deployment logs, artifact metadata, approvals, migration records, gate outputs, and incident links.

## Implementation procedure
1. Record source and artifact. 2. Record environment and timestamps. 3. Record gate outcomes. 4. Record exposure stage. 5. Record recovery actions. 6. Record final state. 7. Exclude secrets and sensitive payloads.

## Failure modes
- mutable release records;
- missing artifact digest;
- missing failed-deployment evidence;
- sensitive values in logs.

## Testing
Verify that successful and failed release cases produce complete evidence records without secrets.

## Review checklist
- [ ] source; - [ ] artifact; - [ ] environment; - [ ] gates; - [ ] stage; - [ ] recovery; - [ ] final state; - [ ] secret-safe.

## Related skills
rails-release-engineering, rails-incident-engineering, rails-security-engineering