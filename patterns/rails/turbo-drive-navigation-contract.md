---
name: turbo-drive-navigation-contract
description: Define page navigation behavior, persistent shell state, and Turbo lifecycle cleanup.
family: rails
---
# Turbo Drive Navigation Contract

## Problem
Turbo navigation changes page lifecycle and can expose duplicate listeners or stale client state.

## Use when
A page or layout relies on navigation events, persistent DOM, page-specific scripts, or browser history.

## Structure
Keep persistent shell state separate from page state and initialize and cleanup behavior explicitly.

## Testing
Verify visit, back/forward, redirect, and revisit behavior where material.
