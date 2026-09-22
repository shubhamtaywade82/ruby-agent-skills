---
name: mailer-provider-boundary
description: Isolate SMTP or email API provider behavior behind explicit configuration and adapter/error semantics.
family: rails
---

# Mailer Provider Boundary

## Problem

Provider-specific authentication, payloads, error codes, and limits leaking into mailer/domain code make delivery behavior hard to test and change.

## Use when

- integrating an email API;
- changing SMTP/provider configuration;
- adding provider failover;
- reviewing provider-specific error handling.

## Do not use when

- the application only uses repository-standard Action Mailer configuration with no provider-specific domain behavior.

## Repository inspection

Inspect delivery method, provider gems/clients, credentials, timeout settings, provider errors, rate limits, sandbox configuration, and integration tests.

## Implementation procedure

1. Define the provider boundary.
2. Keep provider credentials/configuration outside domain code.
3. Map provider outcomes to retryable/permanent/unknown classes.
4. Bound network timeouts and retries.
5. Preserve a stable mailer-facing contract.
6. Test provider failures through a fake transport/adapter.

## Failure modes

- provider SDK types leaking across the application;
- retrying permanent failures;
- treating timeout as proof of non-delivery;
- hard-coded credentials;
- live provider tests in CI.

## Testing

Use fake/provider transport tests for success, timeout, authentication, rate-limit, invalid-recipient, and ambiguous delivery outcomes.

## Review checklist

- [ ] stable mailer boundary
- [ ] secret-safe configuration
- [ ] timeout
- [ ] failure classification
- [ ] provider tests
- [ ] no live provider dependency

## Related skills

rails-action-mailer, rails-api-integration, rails-security-engineering, ruby-dependency-injection
