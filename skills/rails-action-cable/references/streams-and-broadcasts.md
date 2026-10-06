# Stream naming and broadcast contracts

Reference for the `rails-action-cable` skill. Load it on demand when a change names streams, shapes broadcast payloads, or broadcasts after state changes. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Stream naming

Stream names are part of the authorization contract.

Prefer repository/framework primitives such as:

- `stream_for resource`;
- `broadcast_to resource, payload`;
- stable names derived from canonical resource identity.

When explicit strings are required, define a namespace and identity format.

For tenant/private streams include every identity boundary needed to prevent collisions.

Avoid raw user input in broadcast names.

Never let a client select a broadcast namespace that it could not otherwise authorize.

Use the `action-cable-stream-contract` pattern.

## Broadcast contract

Broadcast payloads are wire contracts even when they remain inside one Rails application.

Define:

- event/message type;
- schema/version;
- resource identity;
- payload fields;
- nullability/omission;
- client handling expectations;
- authorization assumptions;
- compatibility behavior during rolling deploy.

Prefer small purpose-built payloads over serializing entire Active Record objects.

Do not broadcast sensitive model attributes merely because they are convenient to serialize.

Do not depend on a database query occurring in the client callback to reconstruct authorization-sensitive state.

When payloads are persisted/replayed elsewhere, compose with `rails-event-driven-messaging` and `rails-distributed-systems`.

## Broadcasting after state changes

Broadcast from the authoritative domain/application boundary.

When a message represents committed database state, ensure the broadcast is coordinated with transaction semantics.

Inspect:

- transaction boundary;
- after-commit behavior;
- queued broadcast behavior;
- old/new process compatibility;
- failure between database commit and broadcast;
- reconciliation behavior.

A broadcast should not announce state that later rolled back.

When durable correctness is required, use an outbox/event boundary rather than treating an in-memory broadcast call as atomic with the database transaction.

Compose with `rails-distributed-systems` and `rails-event-driven-messaging`.
