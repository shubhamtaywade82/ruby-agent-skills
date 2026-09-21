---
name: authorization-audit-contract
description: Record bounded authorization outcomes without leaking sensitive policy inputs.
family: rails
---
# Authorization Audit Contract

## Problem
Security decisions are not explainable or observable, or logs expose sensitive data.

## Structure
Record actor, tenant, action, resource type/id, decision, bounded reason code, and correlation identifier as appropriate.

## Failure modes
Passwords/tokens in logs, arbitrary policy internals, and unbounded resource data.

## Testing
Assert audit events exist for security-critical decisions and contain no credential material.
