---
name: production-runbook-command-contract
description: Production Runbook Command Contract
family: rails
---
# Production Runbook Command Contract

## Problem
Operators repeat unsafe manual steps when a maintenance command has no documented invocation, prerequisites, or rollback path.

## Use when
Production operational commands intended for repeated use or incident response.

## Do not use when
Temporary local experimentation with no shared operational responsibility.

## Repository inspection
Inspect runbooks, deployment access, command arguments, environment prerequisites, approvals, and rollback instructions.

## Implementation procedure
Document invocation, prechecks, dry-run, expected output, stop conditions, recovery, and verification.

## Failure modes
Wrong arguments, missing approvals, incomplete recovery, ambiguous success.

## Testing
Test the documented command sequence in a safe environment and compare evidence with the runbook.

## Review checklist
[ ] invocation [ ] prerequisites [ ] stop conditions [ ] recovery [ ] verification

## Related skills
rails-operational-tasks-maintenance, rails-incident-engineering, rails-release-engineering