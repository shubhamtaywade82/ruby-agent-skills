---
name: railtie-initialization-boundary
description: Railtie Initialization Boundary
family: rails
---
# Railtie Initialization Boundary

## Problem
Railtie hooks can create hidden boot dependencies when lifecycle ownership is unclear.

## Use when
A plugin needs Rails configuration or initialization hooks without a full Engine.

## Do not use when
The extension needs routes/controllers/models/views as a packaged application boundary.

## Repository inspection
Inspect Railtie hooks, host initialization order, reload behavior, and required frameworks.

## Implementation procedure
Keep Railtie hooks narrow, idempotent when needed, and limited to extension setup.

## Failure modes
Duplicate initialization, partial boot, hidden ordering, business workflow execution during boot.

## Testing
Test registration, initialization, and repeated preparation where applicable.

## Review checklist
[ ] scope justified [ ] lifecycle explicit [ ] idempotence [ ] no business workflow

## Related skills
rails-engines-railties-engineering, rails-initialization-configuration-engineering