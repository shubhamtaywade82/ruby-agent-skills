---
name: middleware-security-boundary
description: Use middleware for transport/infrastructure security controls without moving resource authorization into the stack.
family: rails
---
# Middleware Security Boundary

## Problem
Security checks can be duplicated or misplaced when generic middleware starts deciding business permissions.

## Use when
Trusted-host, HTTPS/security headers, proxy normalization, CORS, request-size, or infrastructure-level controls are being changed.

## Do not use when
The decision requires authenticated resource ownership, tenant membership, or business policy.

## Repository inspection
Inspect trust boundaries, proxy configuration, authentication/authorization ownership, security headers, and deployment topology.

## Implementation procedure
Define the untrusted input, authoritative infrastructure boundary, failure response, and interaction with controller authorization.

## Failure modes
Header spoofing, CORS drift, proxy trust abuse, authorization bypass, and inconsistent security policy.

## Testing
Test trusted/untrusted proxy inputs, required headers, rejection paths, and controller authorization separately.

## Review checklist
[ ] trust boundary explicit
[ ] proxy assumptions verified
[ ] authz remains at resource boundary
[ ] abuse regression covered

## Related skills
rails-rack-middleware-engineering, rails-security-engineering, rails-authorization
