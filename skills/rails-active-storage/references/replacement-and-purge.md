# Replacement, deletion, purge, and orphaned uploads

Reference for the `rails-active-storage` skill. Load it on demand when a change replaces, detaches, deletes, or purges attachments or cleans up unattached blobs. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Replacement and deletion semantics

For `has_one_attached`, distinguish:

- replacing the attachment relationship;
- deleting the attachment;
- purging the blob;
- deleting the underlying object.

For `has_many_attached`, distinguish:

- adding attachments;
- replacing the collection;
- removing selected attachments;
- purging old files.

Define whether old files must be retained for audit/history or deleted immediately.

Do not call destructive purge operations from a request path unless latency, failure, and retry behavior are explicitly acceptable.

## Purge lifecycle

Purge can remove the object and associated Active Storage records.

Define:

- who is allowed to purge;
- when purge happens;
- whether purge is immediate or asynchronous;
- what happens when storage deletion fails;
- orphan/unattached cleanup policy;
- retention windows.

For user-facing deletes, consider durable domain state first and asynchronous cleanup second when appropriate.

Do not assume attachment deletion and physical object deletion have identical timing.

## Unattached and orphaned uploads

Direct uploads and interrupted workflows can create unattached blobs.

Define:

- maximum allowed unattached age;
- cleanup schedule;
- safe exceptions;
- dry-run/reconciliation procedure;
- metrics for orphan count/age;
- authorization for destructive cleanup.

Never purge unattached blobs merely because they are not currently attached without considering legitimate staged-upload workflows.
