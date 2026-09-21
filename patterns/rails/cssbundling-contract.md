---
name: cssbundling-contract
description: Define a reproducible Rails CSS compilation and delivery boundary.
family: rails
---
# CSS Bundling Contract

## Use when
CSS requires Sass/PostCSS/Tailwind or another build-time transformation.

## Do not use when
Plain CSS and the existing asset pipeline already satisfy the application's needs.

## Repository inspection
Inspect CSS entrypoints, build scripts, package manager, lockfile, browser targets, Rails asset pipeline, and production artifact path.

## Implementation procedure
Define source/output ownership, build command, dependency versions, and integration with Rails precompile/deploy.

## Failure modes
Watcher-only success, stale compiled CSS, incompatible browser targets, missing imports, and artifact mismatch.

## Testing
Run a clean production-like CSS build and verify the resulting asset is consumed by the deployed Rails path.

## Review checklist
[ ] source/output boundary explicit
[ ] build deterministic
[ ] Rails consumes compiled output
[ ] clean build passes

## Related skills
rails-asset-build-engineering, rails-action-view, rails-deployment
