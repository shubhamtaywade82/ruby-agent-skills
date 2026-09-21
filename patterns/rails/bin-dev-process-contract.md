---
name: bin-dev-process-contract
description: Define deterministic Rails development process orchestration for web and asset watchers.
family: rails
---
# bin/dev Process Contract

## Problem

Development orchestration can hide failed asset watchers or leave processes running with inconsistent environments.

## Use when
Changing bin/dev, Procfile.dev, watcher processes, or local development orchestration.

## Do not use when
Changing only production process topology.

## Repository inspection
Inspect bin/dev, Procfile.dev, process runner, ports, environment, signals, logs, and README development commands.

## Implementation procedure
Define process ownership, startup command, environment, dependencies, shutdown, restart, and failure propagation.

## Failure modes
Orphan watchers, hidden build failures, port collisions, incorrect environment propagation, and false healthy state.

## Testing
Run the complete development command and verify each process starts and terminates predictably.

## Review checklist
[ ] processes explicit
[ ] failure propagates
[ ] shutdown is bounded
[ ] documented command matches implementation

## Related skills
rails-asset-build-engineering, rails-production-runtime, rails-reliability-engineering
