---
name: environment-parity
description: Identify deliberate environment differences that can invalidate release evidence and make them explicit release concerns.
family: rails
---

# Environment Parity

## Problem
Staging and production differences can make otherwise strong test evidence misleading.

## Use when
- debugging staging-only or production-only failures;
- reviewing release pipelines;
- changing runtime infrastructure.

## Do not use when
- environments are already equivalent for the behavior under review and no relevant drift exists.

## Repository inspection
Compare runtime versions, dependency lock state, databases, queue/broker, providers, flags, limits, process topology, and proxy behavior.

## Implementation procedure
1. Enumerate differences. 2. Classify which can affect the release. 3. Reproduce relevant production behavior or use production-like staging. 4. Document deliberate exceptions. 5. Add a gate/test for material drift.

## Failure modes
- assuming staging proves production;
- undocumented provider differences;
- different resource limits;
- different feature flags or database capabilities.

## Testing
Use a parity report or targeted integration checks to assert material configuration/runtime equivalence.

## Review checklist
- [ ] runtime parity; - [ ] dependency parity; - [ ] data/DB behavior; - [ ] provider parity; - [ ] resource parity; - [ ] deliberate exceptions.

## Related skills
rails-release-engineering, rails-deployment, rails-production-runtime, rails-api-integration