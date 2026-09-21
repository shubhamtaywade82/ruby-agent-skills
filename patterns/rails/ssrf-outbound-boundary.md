---
name: ssrf-outbound-boundary
description: Constrain application-controlled outbound URLs against SSRF, redirect, DNS, credential-forwarding, and resource-exhaustion risks.
family: rails
---

# SSRF Outbound Boundary

## Problem

An application accepts a URL or endpoint influenced by an attacker and then makes a server-side network request.

## Use when

User/provider data can influence HTTP destinations, redirects, callback URLs, import sources, image/document fetches, or webhook targets.

## Do not use when

Outbound destinations are fixed and fully controlled by deployment configuration.

## Repository inspection

Inspect URL parsing, scheme/host allowlists, DNS resolution, redirect handling, IP filtering, HTTP client timeout/size limits, proxy settings, and credential forwarding.

## Implementation procedure

1. Prefer fixed destination allowlists.
2. Validate allowed schemes.
3. Resolve and validate destination host/IP.
4. Reject loopback/private/link-local/metadata destinations when not required.
5. Revalidate redirects.
6. Do not forward ambient credentials to untrusted hosts.
7. Bound connect/read/response size/time.
8. Log safe destination metadata.
9. Test forbidden and allowed destinations.

## Failure modes

- validating only the input hostname
- redirect bypass
- private-IP access
- DNS rebinding/TOCTOU assumptions
- credential leakage
- unbounded response/resource usage

## Testing

Test loopback/private/link-local destinations, redirects, unsupported schemes, oversized responses, timeout behavior, and approved external destinations.

## Review checklist

- [ ] destination allowlist
- [ ] scheme validation
- [ ] IP/private-range protection
- [ ] redirect validation
- [ ] credential forwarding constrained
- [ ] timeout/size limits
- [ ] abuse tests

## Related skills

- rails-security-engineering
- rails-security
- rails-api-integration
- ruby-gems-io-services
