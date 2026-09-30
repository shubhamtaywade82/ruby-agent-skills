---
name: credentials-fetch-contract
description: Use the Rails command-line credential fetch boundary for deploy-time integrations when credentials must remain inside the encrypted credentials contract.
family: rails
compatibility:
  rails: ">= 8.1"
---

# Credentials Fetch Contract

## Problem

Deploy-time automation can accidentally expose encrypted credentials through ad hoc file reads, shell variables, or logs.

## Use when

- deployment automation needs a credential value through the Rails credentials boundary;
- the repository is on a Rails version providing the credential fetch command;
- output handling can be kept secret-safe.

## Do not use when

- an established secret-management integration already owns the value;
- the workflow would print or persist the credential;
- the resolved Rails version does not satisfy the compatibility constraint.

## Repository inspection

Resolve the Rails version and inspect encrypted credentials configuration, master-key delivery, deployment environment variables, secret redaction, and existing release tooling.

## Implementation procedure

1. Define the exact credential needed and its deployment owner.
2. Fetch only within the Rails credential boundary.
3. Keep the value out of command logs, generated artifacts, and process arguments where possible.
4. Ensure the master key is supplied by the existing secret-management path.
5. Test success, missing-key, and redaction behavior.

## Failure modes

- printing credential values to stdout;
- storing fetched secrets in build artifacts;
- embedding master keys in images or repositories;
- bypassing an existing secret-management contract;
- adopting the command on an unsupported Rails version.

## Testing

Cover successful lookup, unavailable credentials, missing master-key behavior, and log/artifact redaction.

## Review checklist

- [ ] Rails version satisfies `>= 8.1`
- [ ] credential owner is explicit
- [ ] master-key handling is externalized
- [ ] output is redacted
- [ ] artifacts do not contain secrets
- [ ] failure behavior is tested

## Related skills

- skills/rails-encryption-credentials-engineering/SKILL.md
- skills/ruby-runtime-compatibility/SKILL.md
