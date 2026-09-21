---
name: rails-asset-pipeline-contract
description: Define the Rails static asset resolution, fingerprinting, and delivery boundary.
family: rails
---
# Rails Asset Pipeline Contract

## Use when
Changing static asset delivery, fingerprinting, manifests, or the Rails asset pipeline.

## Do not use when
Only changing application JavaScript/CSS source with no asset pipeline behavior change.

## Repository inspection
Inspect Rails version, Propshaft/Sprockets, manifests, precompile tasks, public assets, deployment scripts, and cache headers.

## Implementation procedure
Define source-to-artifact ownership, fingerprinting, precompile behavior, and delivery/cache semantics before changing configuration.

## Failure modes
Missing manifests, stale assets, digest mismatch, deployment artifact drift, and unsafe cache reuse.

## Testing
Run clean asset precompile and verify expected fingerprinted outputs.

## Review checklist
[ ] pipeline identified
[ ] artifact contract explicit
[ ] digest/cache behavior verified
[ ] deployment path tested

## Related skills
rails-asset-build-engineering, rails-deployment, rails-production-runtime, rails-caching
