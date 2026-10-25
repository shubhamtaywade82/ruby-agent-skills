---
name: state-transition-guard
description: Guard a durable state change with an explicit transition table, a single guarded entry point, and loud rejection of illegal transitions.
family: rails
---

# State Transition Guard

## Problem

Durable workflow state (orders, payments, approvals, imports) accumulates writers, and each writer decides for itself whether a change is legal. Illegal or double transitions slip through as silent no-ops or corrupt data, and nobody can answer "how did this record reach this state?".

## Use when

A model has a state column with legal-transition semantics, and you need one place that owns what may change and under which conditions.

## Do not use when

The column is a display label with no transition semantics, when Rails enums plus validations genuinely suffice, or when state lives in another service entirely (use a saga/compensation boundary instead).

## Repository inspection

Inspect every writer of the state column, the states and transitions that actually occur in production data, existing guards and where they live, locking strategy, event sources that mutate state, and any existing audit history.

## Implementation procedure

1. Write the transition table: states, events, legal edges, terminal states.
2. Derive the table from the code that writes state, then reconcile with tests and documentation; report disagreement.
3. Route every write through one entry point (`apply_event!` / `transition!`) on the model.
4. Re-read state inside the transition's lock (or use optimistic locking) before deciding the edge.
5. Raise or return an explicit failure for illegal transitions — never a silent no-op.
6. Record an audit row (from, to, event, actor, timestamp) in the same transaction.
7. Keep transactional side effects inside the transition transaction; sequence remote side effects after commit.
8. Replace scattered `if state ==` checks with queries on the table (legal next states for an actor).

## Example

```ruby
class Order < ApplicationRecord
  TRANSITIONS = {
    "pending"   => { "place" => "placed", "cancel" => "cancelled" },
    "placed"    => { "fill" => "filled", "cancel" => "cancelled" },
    "filled"    => { "return" => "returned" },
    "cancelled" => {},
    "returned"  => {}
  }.freeze

  class IllegalTransition < StandardError; end

  def apply_event!(event, actor: nil)
    with_lock do
      target = TRANSITIONS.fetch(state, {})[event] or
        raise IllegalTransition, "#{state} + #{event} is not a legal transition"

      prior = state
      update!(state: target)
      state_audits.create!(from_state: prior, to_state: target, event: event, actor: actor)
    end
  end

  def next_states = TRANSITIONS.fetch(state, {}).keys
end
```

## Failure modes

- Direct assignment to the state column bypassing the guard (audit and grep for writers).
- Guards that return silently, leaving callers believing the transition happened.
- Transition tables that describe intent, not the code — derive from writers, not wishes.
- Remote calls inside the lock, holding the row lock across the network.
- Renaming states without migrating data, leaving records in states the table does not know.

## Testing

Test the full matrix: every state-event pair classifies as legal, illegal, or unknown; terminal states accept no events; concurrent double-transition attempts produce exactly one success and one explicit failure; audit rows exist for every applied transition. Assert rejection messages, not just raised classes.

## Review checklist

- [ ] transition table written before the writers changed
- [ ] single entry point; no direct column writes remain
- [ ] illegal transitions loud and tested
- [ ] audit trail inside the transaction
- [ ] locking strategy justified by contention
- [ ] terminal states final and reachable

## Related skills

rails-state-machine-engineering, rails-active-record, rails-database-engineering
