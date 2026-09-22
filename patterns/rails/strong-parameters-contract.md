---
name: strong-parameters-contract
description: Use when an action mutates or forwards request parameters and the permitted shape must be explicit.
family: rails
---

# Strong Parameters Contract

## Problem

Mass-assignment and parameter-shape bugs occur when controllers permit more data than the action contract requires or rely on unverified nested structures.

## Use when

- creating or updating records from request data
- forwarding structured input to an application service
- accepting nested hashes or arrays
- changing a public input contract.

## Do not use when

- no request parameters are accepted
- a validated request object already owns the input boundary.

## Repository inspection

Resolve the Rails version and inspect existing expect, require, permit, unpermitted-parameter policy, and request tests.

## Implementation procedure

1. Define the action's allowed fields.
2. Use params.expect where supported and locally adopted; otherwise use require plus permit.
3. Declare nested arrays/hashes explicitly.
4. Keep transport normalization separate from semantic validation.
5. Test extra, omitted, and malformed fields.
6. Audit callers when the permitted shape changes.

## Failure modes

- permit! as a shortcut
- permitting fields because the model exposes them
- arbitrary nested hashes without justification
- treating permitted input as authorized input.

## Testing

Assert accepted keys, rejected keys, nested structure behavior, and the failure status/exception contract.

## Review checklist

- [ ] Rails version supports the chosen API
- [ ] allowed keys are minimal
- [ ] nested structures are explicit
- [ ] authorization is separate
- [ ] negative inputs are tested

## Related skills

rails-action-controller, rails-security, rails-validations, rails-activerecord
