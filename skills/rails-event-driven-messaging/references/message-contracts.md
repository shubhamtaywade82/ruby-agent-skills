# Message taxonomy, envelope contract, and schema evolution

Reference for the `rails-event-driven-messaging` skill. Load it on demand when a change defines a message type, alters the envelope, or evolves a message schema. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Message taxonomy

Classify the message before implementation:

### Command

An instruction for a specific consumer to perform work.

Commands normally have one intended owner.

### Event

A fact that something happened.

Events should not encode a hidden command contract such as "please do X" unless that is intentionally the model.

### Notification/integration event

A published fact intended for other systems.

The producer owns the fact; consumers own their reactions.

### Scheduled/retry message

A delivery mechanism for deferred work.

Keep retry metadata distinct from business event semantics.

Do not overload one message type to serve command, event, and internal retry roles without an explicit contract.

## Envelope contract

Use a stable envelope when the transport/application contract benefits from shared metadata.

Typical fields:

`message_id`, `message_type`, `schema_version`, `occurred_at`, `producer`, `correlation_id`, `causation_id`, `tenant/partition key`, and the typed payload.

Keep transport metadata separate from domain payload.

Message identity must remain stable across retry/replay of the same logical message.

Never generate a new logical message ID for every delivery attempt.

Use `patterns/rails/event-envelope.md`.

## Schema evolution

Consumers may run older and newer code simultaneously.

Prefer additive evolution:

- add optional fields;
- preserve existing meaning;
- tolerate unknown fields where safe;
- do not silently change field type or semantics;
- use explicit schema versions when the wire contract genuinely changes.

When a breaking change is unavoidable:

1. introduce a new version/type;
2. keep old consumers working during rollout;
3. dual-publish or translate only when justified;
4. migrate consumers;
5. drain/replay old messages as required;
6. remove the old schema only after compatibility evidence exists.

Use `patterns/rails/event-schema-evolution.md`.

Do not use a schema registry as permission to make incompatible changes.
