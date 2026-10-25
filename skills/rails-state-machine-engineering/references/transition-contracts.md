# Transition Contracts

## The transition table

The contract of a durable state machine is a table, and it belongs in code as a single constant (or an AASM declaration) that everything else consults:

```ruby
class Import < ApplicationRecord
  TRANSITIONS = {
    "draft"     => { "submit" => "submitted", "discard" => "discarded" },
    "submitted" => { "start" => "running", "reject" => "rejected" },
    "running"   => { "complete" => "completed", "fail" => "failed" },
    "failed"    => { "retry" => "running" },
    "completed" => {},   # terminal
    "rejected"  => {},   # terminal
    "discarded" => {}    # terminal
  }.freeze
end
```

Writing the table first changes the conversation: states that cannot be reached, events with no source, and missing terminal states become visible before code depends on them.

Rules for the table:

- derive it from the code that actually writes state, then reconcile with tests and documentation — when they disagree, the disagreement is a finding, not a footnote;
- every state appears, including states that exist only in production data (they are the hardest ones);
- terminal states are explicit and empty, so "can anything more happen?" is answerable;
- one canonical machine per record type; two tables driving one column is two machines fighting.

Representation choices, honestly compared:

| Representation | Strengths | Costs |
|---|---|---|
| string column + constant table | greppable, portable, no migration to rename states carefully | no database-level domain enforcement by itself |
| Rails `enum` | scoping helpers, `_prefix`/`_suffix` | assignments still bypass guards unless the enum is wrapped; integer-backed enums reorder catastrophically |
| AASM gem | table, guards, events, audit hooks as first-class | another dependency; its callbacks need the same transaction discipline |

Whatever the representation, the guard must be the only writer. An `enum` that everything assigns directly is a state column, not a state machine.

## Guards and exit actions

A guard decides whether a legal edge may fire *this time* (preconditions), and an exit action runs *because* the edge fired (post-transition effects). Keep them separate:

```ruby
def apply_event!(event, actor: nil)
  with_lock do
    edge = self.class::TRANSITIONS.fetch(state, {})[event]
    raise IllegalTransition, "#{state} + #{event} is not legal" if edge.nil?

    check_guards!(event)          # raises GuardFailed with reasons
    prior = state
    update!(state: edge)
    run_exit_actions!(event)      # transactional effects only
    record_transition!(from: prior, to: edge, event: event, actor: actor)
  end
  after_commit_effects(event)     # remote/non-transactional work
end
```

Guard rules:

- guards are predicates with reasons: `"cannot cancel after fill: settlement owns the record"` beats a bare `false`;
- guards read only locked, current state — a guard evaluated on stale data is a race, not a guard;
- exit actions inside the transition transaction are limited to transactional work (database writes, publishes via outbox);
- `after_commit` callbacks carry the non-transactional work, and must be idempotent because after-commit code can run during recovery replays.

## Transition authorization

Every transition has an authorized actor set, checked at the transition boundary — identity establishment (who the caller is) proves nothing about permission (what they may do to this record):

```ruby
AUTHORIZED = {
  "submit"  => %w[owner],
  "approve" => %w[reviewer],
  "discard" => %w[owner admin],
  "fail"    => %w[system]      # only the pipeline may declare failure
}.freeze

def apply_event!(event, actor:)
  authorize!(event, actor)
  # ... guarded transition under lock
end
```

Record the actor with the audit row. When transitions are triggered by events rather than users, the actor is the event source (webhook identifier, consumer name, daemon component), so the audit trail answers "which integration did this?".

## Audit history

The audit trail is evidence, not decoration. It lives in its own append-only table, written in the same transaction as the transition:

```ruby
create_table :state_audits do |t|
  t.references :auditable, polymorphic: true, null: false, index: true
  t.string :from_state, null: false
  t.string :to_state, null: false
  t.string :event, null: false
  t.string :actor_type
  t.bigint :actor_id
  t.jsonb :context, default: {}
  t.timestamps
end
add_index :state_audits, [:auditable_type, :auditable_id, :created_at]
```

Audit rules:

- append-only: corrections are new rows (with a reference to the row they correct), never edits;
- never log payloads with credentials or secrets in `context`;
- the audit row records what the guard saw, not what the caller hoped;
- terminal states are reachable in the audit trail — a record whose audit history skips states was written outside the guard (grep for the writers).
