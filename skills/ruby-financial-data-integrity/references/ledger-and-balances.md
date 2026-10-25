# Ledger and Balances

## Double-entry invariants

A ledger is not a `balances` table with a mutation method; it is an append-only journal whose entries obey arithmetic laws, plus derived balances that must equal the sum of their entries:

```
Invariant 1 (entry balances):    for each journal entry, sum(credits) == sum(debits)
Invariant 2 (account identity):  for each account, balance == sum of its postings
Invariant 3 (conservation):      the sum of all balances equals the sum of specific
                                 designated accounts (equity/cash) — money is neither
                                 created nor destroyed by transfers
```

The shape:

```ruby
create_table :journal_entries do |t|
  t.string :event_id, null: false   # business event identity; unique index
  t.string :description
  t.timestamps
end
add_index :journal_entries, :event_id, unique: true

create_table :journal_postings do |t|
  t.references :journal_entry, null: false, foreign_key: true
  t.references :account, null: false, foreign_key: true
  t.decimal :amount, precision: 20, scale: 8, null: false   # signed: + credit, - debit
  t.string :currency, null: false, limit: 3
  t.timestamps
end
add_index :journal_postings, [:account_id, :journal_entry_id]
```

Why the discipline pays: any total in the system becomes recomputable from raw postings, disputed numbers have an audit trail, and a corrupted `balances` row is recoverable instead of catastrophic.

## Posting transactions

A posting writes the entry and all its postings in **one database transaction**, so Invariant 1 is a commit-time property, not a later discovery:

```ruby
class PostingService
  def post(event, lines)
    raise UnbalancedEntry, "postings must sum to zero" unless lines.sum(&:amount).zero?

    ActiveRecord::Base.transaction do
      entry = JournalEntry.create!(event_id: event.id, description: event.description)
      lines.each do |line|
        entry.postings.create!(account: line.account, amount: line.amount, currency: event.currency)
      end
    end
  rescue ActiveRecord::RecordNotUnique
    :already_posted
  end
end
```

The pre-check plus the unique index on `event_id` is the idempotency pair: concurrent attempts at the same event — one commits, the other is a no-op. The `event_id` is the *business event's* identity (the fill, the refund, the charge), never a per-attempt UUID generated inside the retry.

Balances are read from postings (`Account#balance` aggregates) or cached in a balances table updated **inside the same transaction** as the postings. A balances cache without the journal is mutation without evidence; a journal without the cache is correct but slow — both, updated atomically, is the working system.

## Atomic balance updates

The concurrency rule: a balance read-modify-write must happen under a lock or a conditional update, or two concurrent posts lose one of them:

```ruby
# Wrong: classic lost update — both readers see 100, both write 110.
account.update!(balance: account.balance + 10)

# Right (row lock): serialize on the account row inside the posting transaction.
account.lock!
account.update!(balance: account.balance + posting.amount)

# Right (conditional): make the update itself carry the precondition.
Account.where(id: account.id)
       .where("balance + ? >= 0", posting.amount)     # no negative balances, enforced
       .update_all(["balance = balance + ?", posting.amount])
```

Design choices, honestly stated:

- `lock!` (pessimistic row lock) is simple and correct; contention on one hot account serializes its postings — which for a ledger is usually the *right* semantics (transfers through one cash account are naturally serialized);
- conditional `update_all` with a checked precondition catches overspend as a failed statement rather than an after-the-fact validation error;
- the strongest negative-balance guarantee is a `CHECK (balance >= 0)` constraint — the database is the last line of defense that application code cannot bypass.

## Posting idempotency

Exactly-once application of a business event is the pairing of two already-built mechanisms:

1. the **unique idempotency key** on the event identity (the journal entry's `event_id`);
2. the **balancing transaction** — entry plus postings plus balance updates commit together.

```ruby
class ApplyBrokerFill
  def call(fill)
    # fill.broker_exec_id is the venue's identity for the fill: the join is the dedup.
    event = FinancialEvent.find_or_create_by!(source: "broker", source_id: fill.broker_exec_id)
    return :duplicate if event.posted?

    PostingService.new.post(event, fill.posting_lines)
  end
end
```

The key mistake to refuse: regenerating the event identity per attempt. A retry of the *same* fill, webhook, or charge carries the *same* source identity; a genuinely new event (a second charge the customer initiated) is a new identity by definition. Idempotency keys distinguish "the same thing again" from "another one", and confusing those two is the whole bug.

## Ordering and read consistency

- Postings within one entry have no meaningful order — do not compute anything that depends on insertion order inside an entry;
- posting **time** (the transaction's commit) is processing time; if a business event time matters (the trade date), store it on the entry from the source, in UTC;
- balance reads for reporting should pin a consistent view (`transaction do account.lock! ... end` or a repeatable-read transaction) — a total assembled across two reads can be half of one posting and half of another.
