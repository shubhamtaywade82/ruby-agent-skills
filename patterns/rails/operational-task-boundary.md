---
name: operational-task-boundary
description: Operational Task Boundary
family: rails
---
# Operational Task Boundary

## Problem
Operational code becomes unsafe when command orchestration and domain behavior are mixed without an explicit boundary.

## Use when
Adding or changing a maintenance command, Rake task, or runner workflow.

## Do not use when
A normal request path or reusable domain service with no operational interface.

## Repository inspection
Inspect lib/tasks, Rakefile, runner scripts, services, jobs, and runbooks.

## Implementation procedure
Keep the task as orchestration and delegate reusable business behavior to tested Ruby objects.

## Failure modes
Unmaintainable task logic, duplicated business rules, and untestable operations.

## Testing
Test the task boundary and the delegated object separately.

## Review checklist
[ ] ownership [ ] thin orchestration [ ] reusable domain logic [ ] testable

## Related skills
rails-operational-tasks-maintenance, ruby-service-objects