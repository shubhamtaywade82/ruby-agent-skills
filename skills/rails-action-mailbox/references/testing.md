# Local development and testing

Reference for the `rails-action-mailbox` skill. Load it on demand when exercising mailboxes locally or choosing and writing Action Mailbox tests. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Local development and testing

Use ActionMailbox::TestHelper for deterministic inbound email construction and routing. Test helpers support fixtures, Mail options, and raw RFC822 source creation.

Test at the smallest owning boundary:

- ingress authentication contract;
- route selection;
- unmatched route behavior;
- mailbox processing;
- sender/resource authorization;
- tenant isolation;
- duplicate/idempotency behavior;
- bounce behavior;
- transient failure/retry;
- poison-message quarantine;
- attachment limits and storage;
- domain transaction boundaries;
- job enqueue semantics;
- retention/incineration policy;
- observability/redaction.

Ordinary CI should use deterministic local adapters/storage and fake provider boundaries.

Do not use a live email provider to prove ordinary mailbox business logic.
