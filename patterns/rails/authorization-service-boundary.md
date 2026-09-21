---
name: authorization-service-boundary
description: Protect security-sensitive application services when they can be invoked outside controllers.
family: rails
---
# Authorization Service Boundary

## Problem
A service trusts controller authorization even though other callers can invoke it.

## Use when
A workflow is reusable from controllers, jobs, CLI tasks, events, or other services.

## Structure
Require an actor/capability context or authorize the application operation at the service boundary.

## Failure modes
Direct service invocation bypass, ambient current-user dependency, and conflicting duplicate checks.

## Testing
Invoke the service directly with authorized and unauthorized actors.

## Review checklist
The service security contract is explicit.
