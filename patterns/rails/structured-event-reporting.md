---
name: structured-event-reporting
description: Use Rails structured Event Reporting for bounded operational events with stable names, correlation fields, and secret-safe payloads.
family: rails
compatibility:
  rails: ">= 8.1"
---

# Structured Event Reporting

## Problem

Human-oriented logs are difficult to consume consistently across operational systems. Structured event reporting creates an explicit event boundary with stable names and bounded attributes.

## Use when

- the application needs structured operational events;
- event names and payloads form an observable contract;
- the repository runs a Rails version that provides `Rails.event`.

## Do not use when

- an existing instrumentation boundary already owns the signal;
- arbitrary application values would create unbounded event dimensions;
- the resolved Rails version does not satisfy the compatibility constraint.

## Repository inspection

Resolve the Rails version. Inspect existing `Rails.error`, ActiveSupport::Notifications, logging, metrics, tracing, and event conventions before adding a new event stream.

## Example

```ruby
Rails.event.notify("user.signup", user_id: user.id)
```

## Implementation procedure

1. Define a stable event name and ownership boundary.
2. Include only bounded, operationally useful fields.
3. Preserve request/job correlation where available.
4. Filter credentials and sensitive payloads.
5. Keep event emission observational and separate from domain mutation.
6. Test emitted event names and payload shape.

## Failure modes

- turning logs or events into an uncontrolled metrics dimension;
- emitting secrets or raw user payloads;
- duplicating an existing instrumentation contract;
- making event delivery a prerequisite for domain correctness;
- adopting the API on an unsupported Rails version.

## Testing

Test event emission at the owning boundary and verify name, required fields, correlation, filtering, and failure behavior.

## Review checklist

- [ ] Rails version satisfies `>= 8.1`
- [ ] event ownership is explicit
- [ ] fields are bounded
- [ ] correlation is preserved
- [ ] sensitive values are excluded
- [ ] domain correctness does not depend on reporting

## Related skills

- skills/rails-observability/SKILL.md
- skills/ruby-runtime-compatibility/SKILL.md
