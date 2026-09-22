---
name: security-boundary-review
description: Review a security-sensitive Ruby/Rails boundary from attacker-controlled input through authorization, dangerous sinks, and observable tests.
family: rails-quality
---

# Security Boundary Review

## Problem
A security-sensitive change crosses an HTTP, persistence, file, network, command, or privileged authorization boundary.

## Use when
Authentication/authorization, untrusted input, SQL/HTML/shell, redirects, files, webhooks, SSRF, tenant isolation, or security scanner findings are involved.

## Do not use when
The change has no meaningful trust boundary or security-sensitive side effect.

## Repository inspection
Inspect runtime/version, routes, auth, authorization, input contracts, persistence, rendering, outbound calls, secrets, security configuration, tests, and security scanners.

## Implementation procedure
1. Identify protected asset. 2. Identify trust boundary. 3. Mark attacker-controlled inputs. 4. Trace data to dangerous sinks. 5. Identify the control. 6. Verify authorization separately from authentication. 7. Add an abuse-case test. 8. Run security tooling when available. 9. Review residual risk and final diff.

## Failure modes
- authorization only in UI
- trusting resource IDs without authorization
- disabling CSRF broadly
- suppressing scanner findings without analysis
- logging secrets
- assuming validation proves output safety
- relying on process-local controls for cross-process security

## Testing
Test unauthorized access, malicious input, and the relevant exploit boundary. Prefer request/integration/system tests for web boundaries.

## Review checklist
- [ ] trust boundary explicit
- [ ] attacker input explicit
- [ ] authorization verified
- [ ] dangerous sink identified
- [ ] framework control appropriate
- [ ] abuse case tested
- [ ] scanner findings investigated
- [ ] no unjustified suppression

## Related skills
- rails-security
- rails-authentication
- rails-controllers
- rails-activerecord
- rails-testing
- ruby-debugging