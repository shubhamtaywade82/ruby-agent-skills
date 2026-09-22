---
name: active-record-model-boundary
description: Use when deciding what behavior belongs on an Active Record model versus a service, policy, or plain object.
family: rails
---

# Active Record Model Boundary

## Problem

Active Record models can accumulate persistence, business workflows, integrations, authorization, and presentation responsibilities until the record becomes a service container.

## Use when

- adding methods to a persisted model
- moving logic into or out of a model
- reviewing a growing model.

## Do not use when

- the task is only schema migration mechanics
- the behavior clearly belongs to a request, external provider, or application workflow.

## Repository inspection

Inspect the model, callbacks, associations, validations, services, policies, and consumers before moving responsibility.

## Implementation procedure

1. Identify whether the behavior requires persisted record state.
2. Keep record-local predicates/invariants close to the record.
3. Move multi-record orchestration to a service/domain boundary.
4. Move authorization decisions to a policy/security boundary.
5. Move external I/O to an explicit adapter/integration boundary.
6. Add regression tests around the public consumer.

## Failure modes

- model as service container
- network calls from ordinary persistence methods
- authorization hidden in scopes
- presentation formatting embedded in persistence.

## Testing

Test persisted behavior at the model boundary and orchestrated workflows at their owning application boundary.

## Review checklist

- [ ] behavior needs Active Record state
- [ ] responsibility is record-local
- [ ] no unnecessary external I/O
- [ ] authorization remains explicit
- [ ] tests follow the owning boundary

## Related skills

rails-active-record, ruby-domain-modeling, ruby-service-objects, rails-security, rails-testing
