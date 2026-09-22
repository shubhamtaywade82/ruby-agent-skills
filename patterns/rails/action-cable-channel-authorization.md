---
name: action-cable-channel-authorization
description: Authorize every Rails Action Cable subscription against the owning resource and tenant boundary.
family: rails
---

# Action Cable Channel Authorization

## Problem

Authenticated clients can subscribe to unauthorized resources unless channel-level authorization is explicit.

## Use when

- adding channel subscriptions;
- changing channel parameters or tenant scoping.

## Do not use when

- the channel intentionally has public access.

## Repository inspection

Inspect connection identity, resource ownership, tenant policy, parameter schema, and existing policy/authentication code.

## Implementation procedure

1. Validate parameters.
2. Resolve the resource through the authenticated context.
3. Authorize resource access.
4. Reject unauthorized subscriptions.
5. Open only the authorized stream.
6. Test cross-tenant and missing-resource cases.

## Failure modes

- authentication treated as authorization;
- direct find(id) without tenant scope;
- client-controlled stream namespace;
- global channel used for private data.

## Testing

Test authorized, unauthorized, cross-tenant, missing, and malformed subscriptions.

## Review checklist

- [ ] parameter validation
- [ ] tenant/resource scope
- [ ] authorization
- [ ] stream isolation
- [ ] negative tests

## Related skills

rails-action-cable, rails-security, rails-security-engineering, rails-authentication
