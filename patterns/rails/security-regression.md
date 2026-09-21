---
name: security-regression
description: Turn a concrete security boundary failure into an executable abuse-case regression that preserves the security property.
family: rails
---

# Security Regression

## Problem

A security fix can regress later if tests only verify the implementation detail instead of the attacker's capability being blocked.

## Use when

Fixing authorization, injection, SSRF, tenant isolation, secret exposure, webhook, session, or privilege-escalation issues.

## Do not use when

The security property is already covered by a stronger existing boundary test.

## Repository inspection

Inspect the vulnerable entry point, attacker-controlled input, asset/resource, sink, existing tests, scanner coverage, and alternate execution paths.

## Implementation procedure

1. Describe the attacker capability.
2. Reproduce the unsafe behavior where safe.
3. Assert the intended security property, not internal method calls.
4. Cover the narrowest owning boundary.
5. Add alternate-path coverage when the same invariant is reachable elsewhere.
6. Run focused and repository-wide security verification.
7. Keep the regression deterministic.

## Failure modes

- test only covers a helper method
- expected denial is not asserted
- production exploit path differs from test path
- scanner suppression replaces a regression
- alternate path remains vulnerable

## Testing

Prefer request/policy/job/message boundary tests that prove unauthorized access, injection prevention, tenant isolation, secret redaction, or unsafe-network prevention.

## Review checklist

- [ ] attacker capability explicit
- [ ] owning boundary tested
- [ ] security property asserted
- [ ] alternate paths considered
- [ ] scanner/test verification run

## Related skills

- rails-security-engineering
- rails-security
- rails-testing
- ruby-tdd-refactoring
