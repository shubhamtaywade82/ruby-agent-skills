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
