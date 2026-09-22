---
name: reload-safe-initializer
description: Reload-Safe Initializer
family: rails
---
# Reload-Safe Initializer

## Problem
Reloads can duplicate registrations or retain stale class references.

## Use when
Initializers touch reloadable classes, subscribers, callbacks, or registries.

## Do not use when
Boot-only immutable configuration.

## Repository inspection
Inspect autoload paths, to_prepare hooks, registrations, and development reload.

## Implementation procedure
Make reload-sensitive setup idempotent and avoid retaining reloadable objects.

## Failure modes
Duplicate subscriptions, stale constants, memory growth.

## Testing
Exercise repeated preparation/reload behavior.

## Review checklist
[ ] reload boundary [ ] idempotent [ ] stale refs avoided

## Related skills
rails-initialization-configuration-engineering, zeitwerk
