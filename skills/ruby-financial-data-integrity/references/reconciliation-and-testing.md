# Reconciliation and Testing

## Continuous invariant checks

Invariants that are not checked are opinions. Run them on a schedule and alert on violation:

```ruby
class LedgerIntegrityJob < ApplicationJob
  queue_as :integrity

  def perform
    broken_entries = JournalEntry.joins(:postings)
                                .group(:id)
                                .having("SUM(amount) != 0")
                                .count
    alert!("unbalanced journal entries", broken_entries) if broken_entries.positive?

    Account.find_each do |account|
      expected = account.postings.sum(:amount)
      alert!("balance drift on #{account.id}",
             { cached: account.balance, expected: expected }) if account.balance != expected
    end
  end
end
```

Rules:

- the check computes from the journal (source of truth) and compares to derived state, in both directions;
- violations alert and page — an unbalanced entry that logs-and-continues is a corrupted book with a paper trail;
- checks run after every posting in test (the transaction should make it impossible), and on a schedule in production (defense against schema drift, manual SQL, and partial restores);
- the negative-balance check (`balance >= 0`) belongs in a `CHECK` constraint so it holds even when application code is bypassed.

## External reconciliation

The internal ledger proves internal consistency; only reconciliation proves the numbers match reality (bank, broker, processor, payment provider):

```
for each account/period:
  external_total = statement.balance(as_of)
  internal_total  = ledger postings sum(as_of)
  difference      = external_total - internal_total      # exact arithmetic
  if difference == 0: consistent
  else:
    classify the difference (timing? fee you did not model? unposted event? duplicate?)
    journal an explicit adjustment entry, OR
    page a human when classification fails
```

Reconciliation discipline:

- compare **as-of a stated time** with the external statement's own cutoff — an as-of-less comparison is noise;
- differences are classified before corrected: a recurring "timing difference" is a modeling gap; a growing one is a bug;
- adjustments post through the same balancing machinery, referencing evidence (statement ID, line items) — never `update_all` the balance;
- rate-limit auto-corrections the way position reconciliation does: a reconciliation that repairs the same account daily is an unresolved defect being laundered;
- page on unclassifiable divergence, and include both numbers and the posting trail in the alert.

## Adversarial numeric tests

Financial arithmetic is tested at its boundaries, not its happy path:

```ruby
class FeeRoundingTest < ActiveSupport::TestCase
  test "fee rounds half-up at the exact boundary" do
    fee = FeeSchedule.new.brokerage_fee(BigDecimal("100.005"))

    assert_equal BigDecimal("100.01"), fee          # the boundary is the contract
  end

  test "allocation parts sum exactly to the whole" do
    parts = allocate(BigDecimal("100.00"), [BigDecimal("1"), BigDecimal("1"), BigDecimal("1")])

    assert_equal BigDecimal("100.00"), parts.sum
    assert_equal [BigDecimal("33.34"), BigDecimal("33.33"), BigDecimal("33.33")], parts
  end

  test "parsing keeps money exact at the JSON boundary" do
    payload = JSON.generate(price: "19.99", quantity: "3")
    trade   = Trade.from_json(payload)

    assert_equal BigDecimal("59.97"), trade.notional       # not 59.970000000000006
  end

  test "scale mismatch is caught before persistence" do
    assert_raises(ActiveRecord::StatementInvalid) do
      Position.create!(price: BigDecimal("10.123456789"))  # column scale 8
    end
  end
end
```

The boundary cases that find real bugs: `0` and `0.0`; the exact rounding boundary (`x.xx5`); values one scale-digit beyond the column; the largest realistic sum (precision headroom); negative amounts and negative *balances* (where allowed, else the constraint); mixed-scale inputs (`19.99 * 0.1`); concurrent postings to one account (two threads, one lock, both applied exactly once — synchronized with a barrier, never a sleep).

## Rounding regressions

Rounding changes are behavior changes for someone's statement. Pin them:

```ruby
test "fee schedule rounding stays half-up across releases" do
  # 0.005 at scale 2 is the documented boundary; changing it changes customer bills.
  assert_equal BigDecimal("0.01"), BigDecimal("0.005").round(2, MoneyRounding::FEES)
end
```

A rounding-mode change ships like a schema migration: changelog, migration note, and the affected computations re-verified (`fees recomputable to the same value` — or explicitly documented as changed, with the delta quantified).

## Proving idempotency

The posting idempotency test is a concurrency test:

```ruby
test "the same event posts exactly once under concurrency" do
  event = financial_events(:fill)
  results = 3.times.map do
    Thread.new { barrier.pop; ApplyBrokerFill.new.call(fill_fixture) }
  end
  3.times { barrier << :go }
  results.map(&:value)

  assert_equal 1, JournalEntry.where(event_id: event.id).count
  assert_equal 2, JournalEntry.find_by(event_id: event.id).postings.count   # balanced pair
  assert_equal event.amount, event.account.reload.balance
end
```

One committed posting, one no-op, balances equal their postings — the idempotency key proved, not assumed.
