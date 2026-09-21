---
name: asset-build-reproducibility
description: Ensure frontend asset builds are reproducible from declared dependencies and source.
family: rails
---
# Asset Build Reproducibility

## Problem

A local asset build can succeed because of undeclared runtimes, caches, or dependency state.

## Use when
Changing lockfiles, package runtimes, build tooling, CI caches, or release asset compilation.

## Do not use when
No dependency or build input changes.

## Repository inspection
Inspect lockfiles, runtime declarations, package manager version, CI cache keys, Docker layers, and build environment.

## Implementation procedure
Pin inputs, use deterministic installs, invalidate caches on relevant changes, and compare clean builds.

## Failure modes
Environment-dependent output, cache poisoning, lockfile drift, and hidden network dependencies.

## Testing
Perform at least one clean build without developer-local caches.

## Review checklist
[ ] inputs declared
[ ] cache identity correct
[ ] clean build passes
[ ] network assumptions explicit

## Related skills
rails-asset-build-engineering, rails-release-engineering, rails-security-engineering
