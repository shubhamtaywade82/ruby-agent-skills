---
name: jsbundling-contract
description: Define a reproducible Rails JavaScript bundling boundary.
family: rails
---
# JS Bundling Contract

## Problem

JavaScript builds can succeed locally while CI or production lacks the runtime, dependency, or generated artifact.

## Use when
JavaScript requires compilation, transformation, package processing, bundling, or code splitting.

## Do not use when
Importmap or native browser modules fully satisfy the dependency contract.

## Repository inspection
Inspect package manager, lockfile, runtime version, bundler config, entrypoints, build script, CI, and deployment.

## Implementation procedure
Pin runtime/toolchain versions, define source and output boundaries, fail builds on compiler errors, and integrate the build into CI/release.

## Failure modes
Local-only builds, lockfile drift, missing native dependencies, silent compiler warnings, and stale artifacts.

## Testing
Run clean dependency installation and a production-like one-shot build.

## Review checklist
[ ] runtime pinned
[ ] lockfile authoritative
[ ] build command reproducible
[ ] CI executes it
[ ] output consumed by Rails

## Related skills
rails-asset-build-engineering, ruby-runtime-compatibility, rails-release-engineering
