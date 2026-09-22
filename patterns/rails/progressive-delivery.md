---
name: progressive-delivery
description: Expose a release incrementally and gate expansion on user-impact and resource evidence.
family: rails
---

# Progressive Delivery

## Problem
All-at-once production exposure increases blast radius when a release is defective.

## Use when
- implementing canary/staged releases;
- using traffic or feature-flag based exposure;
- reviewing rollout safety.

## Do not use when
- the platform cannot provide controlled exposure or no meaningful decision gate exists.

## Repository inspection
Inspect deployment topology, traffic routing, feature flags, health/SLI dashboards, abort controls, and exposure ownership.

## Implementation procedure
1. Choose the smallest useful exposure. 2. Define observation window. 3. Select user-impact/resource gates. 4. Expand only after evidence passes. 5. Abort or roll back on defined regression. 6. Record each stage.

## Failure modes
- false canary with no reduced exposure;
- process-health-only gate;
- exposure too small to produce signal;
- no abort path;
- human expansion with no evidence.

## Testing
Exercise staged rollout logic with deterministic regression signals and abort/expand cases.

## Review checklist
- [ ] reduced exposure; - [ ] useful signal; - [ ] window; - [ ] abort; - [ ] stage record.

## Related skills
rails-release-engineering, rails-reliability-engineering, rails-incident-engineering, rails-production-runtime