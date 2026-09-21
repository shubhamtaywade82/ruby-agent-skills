---
name: action-mailbox-authenticity-security
description: Separate ingress authentication, sender identity proof, recipient authorization, content safety, and tenant isolation for inbound email.
family: rails
---

# Action Mailbox Authenticity and Security

## Problem

Inbound email contains multiple identities and trust signals. Treating one header or provider credential as complete authorization creates spoofing and tenant-isolation risk.

## Use when

- mapping inbound mail to users or tenants;
- accepting provider webhooks;
- processing support/reply addresses;
- reviewing spoofing or security behavior.

## Do not use when

- the task has no inbound trust boundary.

## Repository inspection

Inspect ingress credentials/signature validation, sender normalization, recipient aliases, tenant policy, authorization code, security scanners, logging filters, and message/attachment handling.

## Implementation procedure

1. Identify ingress trust.
2. Identify sender-identity evidence.
3. Identify recipient/resource authority.
4. Validate tenant scope.
5. Validate content and attachments.
6. Redact sensitive message data.
7. Add negative tests for spoofed or cross-tenant messages.
8. Document residual risk where email authentication is advisory rather than authoritative.

## Failure modes

- From header treated as authentication;
- ingress password treated as user identity;
- Reply-To treated as authoritative;
- recipient local-part treated as tenant authorization;
- raw HTML/attachments trusted;
- raw message logged;
- provider signature bypassed for convenience.

## Testing

Cover spoofed sender, unauthorized recipient, cross-tenant target, unsafe attachment metadata, sensitive log redaction, and ingress-auth failure.

## Review checklist

- [ ] ingress trust separated from business identity
- [ ] sender proof explicit
- [ ] tenant/resource authorization explicit
- [ ] content untrusted
- [ ] logs redacted
- [ ] negative security tests exist

## Related skills

- skills/rails-action-mailbox/SKILL.md
- skills/rails-security/SKILL.md
- skills/rails-security-engineering/SKILL.md
