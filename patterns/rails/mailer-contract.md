---
name: mailer-contract
description: Define the recipient, sender, subject, content, attachment, and delivery-mode contract for a Rails mailer action.
family: rails
---

# Mailer Contract

## Problem

Email becomes difficult to test and change when the message contract is implicit across controllers, templates, callbacks, and provider configuration.

## Use when

- adding or changing a mailer action;
- reviewing recipients, headers, or templates;
- separating business eligibility from email rendering.

## Do not use when

- no Action Mailer message boundary exists;
- an existing repository contract already defines the message completely.

## Repository inspection

Inspect ApplicationMailer, existing mailer actions/views/layouts, recipient rules, locale conventions, URL configuration, attachments, and tests.

## Implementation procedure

1. Define the business notification.
2. Define eligible recipients.
3. Define sender/reply-to/subject.
4. Define HTML/text representation.
5. Define attachment semantics.
6. Define delivery mode.
7. Keep business state transitions outside the template.
8. Test the rendered message contract.

## Failure modes

- hidden recipient logic;
- template queries;
- missing text alternative;
- accidental sender overrides;
- attachment behavior coupled to request state.

## Testing

Assert headers, recipients, content type/body, and attachments through deterministic mailer tests.

## Review checklist

- [ ] message purpose explicit
- [ ] recipient eligibility explicit
- [ ] headers explicit
- [ ] content formats explicit
- [ ] delivery mode explicit
- [ ] tests cover contract

## Related skills

rails-action-mailer, rails-active-job, rails-security, rails-test-engineering
