# Persistence lifecycle, background work, and search indexing

Reference for the `rails-action-text` skill. Load it on demand when a change alters rich-text persistence, background processing, or search/indexing. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Persistence and lifecycle

The owning model can have rich text persisted outside its primary table.

Review:

- creation/update lifecycle;
- transaction boundaries;
- deletion behavior;
- dependent cleanup;
- callbacks/jobs;
- migration compatibility.

Keep domain state and rich-text lifecycle behavior explicit.

Do not assume a model delete has exactly the same operational timing as embedded attachment/object deletion.

Coordinate attachment cleanup with `rails-active-storage`.

## Background work

Rich-text processing may interact with Active Storage analysis, variants, notifications, indexing, or publishing workflows.

Define:

- synchronous versus asynchronous processing;
- transaction/commit semantics;
- retry behavior;
- idempotency;
- stale content handling.

Do not make rendering depend on a background job having already completed unless that is explicit in the contract.

Compose with `rails-active-job`.

## Search/indexing

If rich text is indexed for search, define the indexed representation.

Possible choices:

- plain text extracted from RichText;
- sanitized text;
- rendered HTML stripped by a dedicated parser;
- custom normalized search document.

Do not index raw HTML as if it were canonical search content without understanding tokenization/noise.

Treat indexing as derived state and define rebuild/reconciliation behavior.

Coordinate with `rails-database-engineering` and `rails-distributed-systems` if indexing is asynchronous or external.
