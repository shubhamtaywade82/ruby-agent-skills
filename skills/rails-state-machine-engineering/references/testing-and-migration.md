# Testing and Migration

## The transition test matrix

The contract is a matrix: every (state, event) pair classifies as legal, illegal, or unknown. Generate the tests from the table so a new state or event breaks the suite before it breaks data:

```ruby
class ImportStateMachineMatrixTest < ActiveSupport::TestCase
  IMPORT_EVENTS = %w[submit discard start reject complete fail retry].freeze

  test "every state-event pair is classified by the table" do
    Import::TRANSITIONS.each_key do |state|
      IMPORT_EVENTS.each do |event|
        import = Import.create!(state: state)

        if Import::TRANSITIONS.fetch(state).key?(event)
          assert_transition_applies(import, event)
        else
          assert_transition_rejected(import, event)
        end
      end
    end
  end

  test "terminal states accept no events and stay final" do
    %w[completed rejected discarded].each do |state|
      import = Import.create!(state: state)

      IMPORT_EVENTS.each do |event|
        assert_raises(Import::IllegalTransition) { import.apply_event!(event, actor: users(:admin)) }
        assert_equal state, import.reload.state
      end
    end
  end
end
```

Edge tests assert three things together — state changed, audit row written, effects fired — because they must agree:

```ruby
def assert_transition_applies(record, event)
  before = record.state
  record.apply_event!(event, actor: users(:admin))

  expected = Import::TRANSITIONS.fetch(before).fetch(event)
  assert_equal expected, record.reload.state
  audit = record.state_audits.last
  assert_equal [before, expected, event], [audit.from_state, audit.to_state, audit.event]
end

def assert_transition_rejected(record, event)
  before = record.state
  error = assert_raises(Import::IllegalTransition) { record.apply_event!(event, actor: users(:admin)) }

  assert_match(/not a legal transition/, error.message)   # loud, with reasons
  assert_equal before, record.reload.state
  assert record.state_audits.where(event: event).none?
end
```

Also test authorization per event (the reviewer may `approve`, the owner may not), because a matrix that skips it tests the table, not the machine.

## Race and recovery tests

Concurrency tests must force the race; a test that happens to serialize proves nothing:

```ruby
test "double transition attempts succeed exactly once" do
  import = Import.create!(state: "submitted")
  start = Queue.new
  attempts = 3.times.map do
    Thread.new do
      start.pop
      import.reload.apply_event!("start", actor: users(:pipeline))
      :applied
    rescue Import::IllegalTransition
      :rejected
    end
  end
  attempts.size.times { start << :go }
  results = attempts.map(&:value)

  assert_equal 1, results.count(:applied)
  assert_equal 2, results.count(:rejected)
  assert_equal "running", import.reload.state
  assert_equal 1, import.state_audits.where(event: "start").count
end
```

Rules for honest race tests:

- synchronize release with a queue or barrier — never `sleep`, which tests the scheduler's mood;
- `reload` inside each thread: threads sharing one model instance test Ruby's instance state, not the database;
- assert both the winner's outcome and the losers' *explicit* outcomes;
- assert the audit trail count, which catches double-application even when state looks fine.

Recovery tests simulate the crash windows by name:

```ruby
test "intent pending after a provider timeout reconciles by idempotency key" do
  intent = external_effects(:capture_pending)             # crashed before completion recorded
  PaymentGateway::TestAPI.prepare_lookup(request_id: intent.request_id, status: :succeeded)

  PendingEffectReconciliationJob.perform_now

  assert_equal "succeeded", intent.reload.status
  assert_equal "paid", intent.subject.reload.state
end
```

Out-of-order tests drive the sequencing seam: deliver `complete` before `start` and assert the configured policy (rejected loudly, parked, or reconciled) rather than an incidental outcome.

## Migrating existing data into the machine

A state machine retrofitted onto a live table must first face the data it inherits:

1. **inventory reality**: `group(:state).count` in production (read-only) — every state with rows must exist in the new table, including the states nobody remembers creating;
2. **validate before enforcing**: run the new guard in report mode (log instead of raise) over real traffic or a replayed event log; every surprise is a new edge or a legacy writer still unconverted;
3. **convert writers in one coordinated change**: the guard ships with every caller routed through it — a partial rollout leaves direct assignments and the machine lies about some rows;
4. **backfill audits**: existing records get a baseline audit row (`from: nil, to: <current>, event: :backfill`), so the trail starts honestly instead of implying transitions never happened;
5. **rename states through aliases**: string states rename by two-step migration (new values for new writes, backfill old values), never by editing the constant and hoping;
6. **lock the door behind you**: after cutover, a unique constraint or a trigger-level check on the column (or a code review grep for direct assignment) keeps future writers honest.

```ruby
class BackfillImportStateAudits < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      INSERT INTO state_audits (auditable_type, auditable_id, from_state, to_state, event, actor_type, created_at, updated_at)
      SELECT 'Import', id, NULL, state, 'backfill', 'system', updated_at, updated_at FROM imports
    SQL
  end
end
```

Migration tests assert the invariants after backfill: every row's state exists in the table, every row has a baseline audit, and the matrix suite passes against production-shaped data (a fixture or sanitized copy), not just factory-fresh records.
