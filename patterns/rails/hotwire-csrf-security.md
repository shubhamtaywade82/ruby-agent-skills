---
name: hotwire-csrf-security
description: Preserve Rails CSRF and server-side security semantics in Turbo-driven interactions.
family: rails
---
# Hotwire CSRF Security

## Problem
Client-side requests or custom JavaScript accidentally bypass Rails CSRF expectations.

## Structure
Classify browser authentication first and preserve the repository CSRF contract. Never weaken protection to make a Turbo interaction work.

## Testing
Cover non-GET requests, redirects, and rejection behavior.
