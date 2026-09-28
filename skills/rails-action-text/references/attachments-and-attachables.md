# Attachments, Signed Global ID attachables, and rendering attachables

Reference for the `rails-action-text` skill. Load it on demand when a change embeds attachments or custom attachables, resolves signed identifiers, or handles missing attachables. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Attachments

Action Text can embed Active Storage attachments.

Composition boundary:

```text
Action Text content
      |
attachment reference
      |
Active Storage / blob
      |
object storage
```

Use `rails-active-storage` for:

- upload policy;
- storage services;
- direct uploads;
- object access;
- variants;
- purge;
- storage migration.

This skill owns how embedded attachments participate in rich-text content and rendering.

Do not duplicate Active Storage provider/storage guidance here.

## Signed Global ID attachables

Action Text can embed attachables resolved through Signed Global IDs.

Treat an SGID as a signed reference, not as an unconditional authorization grant.

Before allowing an object to be embedded verify:

- the caller may reference the object;
- the object belongs to the appropriate tenant/context;
- the object exposes only intended presentation data;
- the object has a safe attachable partial;
- missing/deleted records have deterministic fallback behavior.

Never let a user embed arbitrary privileged objects merely because they can construct or obtain a signed identifier.

Review SGID purpose, expiry, and application-specific verifier configuration where applicable.

## Attachables and rendering

An attachable may render through a domain-owned partial.

Define:

- partial path;
- local variable contract;
- public/private presentation;
- missing-object fallback;
- N+1 behavior;
- authorization assumptions.

The attachable partial is part of the rich-text output boundary.

Do not render sensitive model attributes merely because the attachable object contains them.

Prefer a purpose-built presentation shape over exposing a full domain model.

## Missing attachables

Records referenced by rich text can later be deleted or become unavailable.

Define the contract for unresolved attachables:

- placeholder;
- omitted content;
- fallback partial;
- broken-reference marker;
- error/reporting behavior.

Do not let deleted records cause uncontrolled rendering exceptions across every document containing an old reference.

Test both existing and missing attachables.
