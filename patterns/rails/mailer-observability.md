---
name: mailer-observability
description: Instrument Rails email delivery with bounded, privacy-aware outcome telemetry and correlation context.
family: rails
---

# Mailer Observability

## Problem

Missing email is difficult to distinguish between enqueue, job, provider, recipient, and template failures without lifecycle telemetry.

## Use when

- diagnosing delivery failures;
- adding email telemetry;
- integrating observers/interceptors.

## Do not use when

- existing mail/job observability already answers the lifecycle questions and no contract changes.

## Repository inspection

Inspect Rails.error, ActiveSupport::Notifications, job telemetry, provider logs, correlation identifiers, and sensitive-data filtering.

## Implementation procedure

1. Define lifecycle stages: requested, enqueued, attempted, delivered, failed/unknown.
2. Capture mailer/action/provider and bounded identifiers.
3. Preserve request/job/correlation context where available.
4. Classify failures without logging sensitive payloads.
5. Add metrics for outcome, retry, latency, and fallback where useful.

## Failure modes

- full recipient lists/body logging;
- high-cardinality message IDs as metric labels;
- observer with business side effects;
- telemetry emitted only on success;
- inability to distinguish unknown provider outcome.

## Testing

Assert telemetry fields/events and secret/sensitive-field filtering at the boundary that owns them.

## Review checklist

- [ ] lifecycle coverage
- [ ] bounded dimensions
- [ ] correlation
- [ ] privacy filtering
- [ ] unknown outcomes represented

## Related skills

rails-action-mailer, rails-observability, rails-incident-engineering, rails-active-job
