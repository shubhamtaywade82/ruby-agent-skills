---
name: importmap-contract
description: Define browser-native JavaScript module resolution through Rails-managed import maps.
family: rails
---
# Importmap Contract

## Problem

Browser module resolution can drift or fail when pins, module formats, or delivery paths are implicit.

## Use when
The application uses or is evaluating importmap-rails and browser-native ES modules.

## Do not use when
The dependency graph requires a transformation/bundling capability unavailable to import maps.

## Repository inspection
Inspect importmap.rb, pins, package metadata, browser targets, JavaScript entrypoints, and CI asset verification.

## Implementation procedure
Pin exact or repository-consistent versions, define local/vendor versus remote resolution, and verify module loading in production-like output.

## Failure modes
Unpinned drift, unsupported packages, wrong module format, CDN dependency failure, and cache mismatch.

## Testing
Verify clean pin installation/resolution and system-test module loading.

## Review checklist
[ ] pin ownership explicit
[ ] module format supported
[ ] production loading verified
[ ] no unnecessary bundler introduced

## Related skills
rails-asset-build-engineering, rails-hotwire, rails-security-engineering
