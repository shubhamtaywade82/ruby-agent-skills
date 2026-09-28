# Autosave, dependent lifecycle, counter caches, touch, callbacks, and extensions

Reference for the `rails-associations` skill. Load it on demand when a change alters autosave or nested writes, dependent behavior, counter caches or touch, association callbacks, or extensions. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Autosave and nested persistence

Understand which associated records are automatically saved as part of parent persistence.

Review:

- new versus existing associated records
- validation behavior
- autosave
- nested attributes if present
- transaction ownership
- rollback behavior.

Do not assume every associated change is persisted just because the parent is saved.

Do not introduce autosave simply to make a form work. Define which object owns the write workflow and test the failure path.

## Dependent lifecycle

dependent options are lifecycle contracts, not cleanup decorations.

Before changing dependent behavior review:

- destroy callbacks
- database ON DELETE behavior
- foreign key nullability
- storage attachments
- audit/events
- soft deletion
- tenant boundaries
- request latency or asynchronous work.

Important distinctions include destroy, delete, nullify, restrict_with_exception, restrict_with_error, and asynchronous destruction where supported by the resolved Rails version.

Do not combine database cascading and application destruction callbacks without proving their combined semantics.

For asynchronous dependent destruction, verify the queue/runtime contract and whether database foreign keys are compatible with the chosen mode. Current Rails documentation explicitly warns about combining asynchronous association destruction with foreign-key constraints.

## Counter caches and touch

counter_cache and touch create denormalized lifecycle coupling.

Before using counter_cache:

- identify the authoritative count
- define how records are added/removed
- review backfill/reconciliation requirements
- consider concurrent updates and repair strategy.

Before using touch:

- identify which timestamp drives caches or clients
- verify write amplification
- review callback/commit behavior
- avoid turning incidental child updates into broad cache invalidation storms.

Do not treat counter caches or timestamps as the sole source of truth when correctness requires querying authoritative data.

## Association callbacks

Association callbacks include before_add, after_add, before_remove, and after_remove.

Use them only for narrow collection lifecycle behavior intrinsic to the association.

For each callback review:

- which mutation methods trigger it
- whether it can halt the mutation
- transaction scope
- side effects
- retry/idempotency
- behavior during bulk or direct database operations.

Do not use association callbacks for multi-record workflows, external API calls, authorization engines, or background job orchestration.

## Association extensions

Association extensions can add domain-specific methods to the association proxy.

Use them only when the behavior is truly relationship-scoped and remains query/object-boundary behavior.

Keep extension methods deterministic and avoid hidden network/database workflows beyond the query operation they clearly represent.
