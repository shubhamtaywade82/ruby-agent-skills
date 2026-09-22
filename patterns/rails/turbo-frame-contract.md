---
name: turbo-frame-contract
description: Define a stable Turbo Frame identity and server response boundary.
family: rails
---
# Turbo Frame Contract

## Problem
Frame requests receive markup that does not match the target frame contract.

## Use when
Implementing inline editing, tabs, lazy loading, or partial page updates.

## Structure
Define stable frame ID, authorized resource context, returned frame structure, error state, and fallback HTML.

## Failure modes
Wrong frame ID, cross-tenant lookup, stale partial, and frame-specific cache leakage.

## Testing
Assert frame targeting, authorization, error rendering, and returned structure.

## Do not use when
The response is a full-page navigation with no frame boundary.

## Repository inspection
Inspect frame helpers, DOM IDs, controller formats, authorization scopes, partials, and tests.

## Implementation procedure
Choose a stable frame ID, define the returned frame structure, preserve authorization, and test success/error paths.

## Failure modes
Wrong frame ID, unscoped lookup, nested-frame mismatch, and cache leakage.

## Testing
Assert frame targeting, response structure, authorization, and error rendering.

## Review checklist
Frame identity, server authorization, and returned markup are explicit.

## Related skills
rails-hotwire, rails-action-controller, rails-action-view, rails-authorization
