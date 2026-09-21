---
name: active-storage-testing
description: Test Rails Active Storage deterministically across attachment contracts, access control, direct uploads, processing, and cleanup without ordinary CI dependence on cloud storage.
family: testing
---

# Active Storage Testing

## Problem

File features can pass model tests while failing at access, storage, processing, or cleanup boundaries.

## Use when

- adding or changing Active Storage behavior;
- reviewing file security regressions;
- testing direct uploads or variants.

## Do not use when

- no Active Storage behavior is involved.

## Repository inspection

Inspect test framework, Active Storage test service, fixture strategy, Active Job helpers, routes, authentication helpers, and provider integration-test conventions.

## Implementation procedure

1. Test attachment association.
2. Test validation and authorization.
3. Test direct-upload attachment ownership.
4. Test serving/access contract.
5. Test variant/analysis behavior.
6. Test purge and orphan cleanup.
7. Use fake/local test storage for normal CI.
8. Isolate real provider tests to explicit integration environments.

## Failure modes

- live cloud dependency;
- asserting only attachment presence;
- missing unauthorized access test;
- missing cleanup tests;
- brittle binary snapshots.

## Testing

Prefer focused assertions on attachment names, blob metadata, access behavior, job enqueues, and lifecycle transitions.

## Review checklist

- [ ] isolated storage
- [ ] auth negative cases
- [ ] direct upload lifecycle
- [ ] processing
- [ ] purge
- [ ] deterministic tests

## Related skills

rails-active-storage, rails-test-engineering, rails-testing, rails-security
