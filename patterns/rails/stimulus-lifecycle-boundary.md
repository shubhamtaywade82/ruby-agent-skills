---
name: stimulus-lifecycle-boundary
description: Make Stimulus connect/disconnect behavior safe across Turbo DOM replacement.
family: rails
---
# Stimulus Lifecycle Boundary

## Problem
Turbo reconnection duplicates listeners, timers, observers, or subscriptions.

## Structure
Allocate resources in connect and release them in disconnect; make repeated lifecycle transitions safe.

## Testing
Exercise repeated lifecycle transitions and cleanup.
