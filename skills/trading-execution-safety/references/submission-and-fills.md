# Submission and Fills

## Submission semantics

Submitting an order is one remote call with at least three distinguishable outcomes, and conflating them is the classic execution defect:

| Outcome | Meaning | Correct next state |
|---|---|---|
| accepted with order ID | venue acknowledged the order | `acknowledged` |
| rejected (synchronous) | venue refused; nothing executes | `rejected` with reason |
| timeout / disconnect / 5xx | unknown — the request may or may not have landed | `outcome_unknown` |

The third row is the one teams mishandle: "no response" is not "no order". A gateway wrapper that maps timeouts to `nil` and lets callers treat it as failure invites resubmission and double execution. The wrapper's contract must distinguish *known failure* from *unknown outcome*:

```ruby
module Gateway
  class Live
    class AmbiguousOutcome < StandardError; end  # caller MUST reconcile
    class Rejected < StandardError; end          # caller may not retry as-is

    def place_order(client_order_id:, **attrs)
      response = post("/orders", body: attrs.merge(client_order_id: client_order_id))
      handle(response)
    rescue Net::OpenTimeout, Errno::ECONNRESET, Net::ReadTimeout
      raise AmbiguousOutcome, "submission outcome unknown for #{client_order_id}"
    end
  end
end
```

## Acknowledgement versus fill

Acknowledgement and fill are different facts from different subsystems at different times:

- **acknowledged**: the venue's order-management system accepted the order; it may still be cancelled or expire unfilled;
- **fill / execution report**: the matching engine executed (part of) the quantity; each report is an increment, not a state;
- **terminal**: filled (quantity complete), cancelled, rejected, expired.

Model them separately in the machine — `submitted -> acknowledged -> (partially_filled)* -> filled | cancelled | rejected | expired` — and treat fill events as **accumulating increments**:

```ruby
class OrderIntent < ApplicationRecord
  def apply_execution_report!(report)
    # idempotent by report identity: venue (broker) order id + exec id
    return :duplicate if execution_reports.exists?(broker_exec_id: report.exec_id)

    ActiveRecord::Base.transaction do
      execution_reports.create!(
        broker_exec_id: report.exec_id,
        quantity: report.filled_quantity,      # increment, not total
        price: report.fill_price
      )
      transition!(event_for(report))          # partial_fill | fill | ...
    end
  end

  def executed_quantity
    execution_reports.sum(:quantity)
  end
end
```

The invariant that catches most accounting bugs: `executed_quantity == sum of applied reports`, and the machine only reaches `filled` when that sum equals `quantity`. Never store "the fill" as a single field on the intent when the venue can (and will) fill in pieces.

## Partial fills

Partial fills are normal, not exceptional, and they break naive code in specific ways:

- **over-counting**: applying "total filled so far" as if it were an increment — the position becomes double-counted after the second report. If the venue sends totals, store totals and derive increments by difference under lock; if it sends increments, store increments;
- **cancel races**: a cancel request can be confirmed after a fill that arrived in the same window. The machine's transition table must allow `partially_filled -> cancelled` with `cancelled_quantity < order quantity`, or the record sticks forever;
- **average price**: compute the fill-weighted average from reports, never trust a rounded venue-provided average for ledger math — the ledger's arithmetic rules own money (see the financial data integrity skill).

```ruby
def fill_weighted_average_price
  reports = execution_reports.where.not(price: nil)
  total_value = reports.sum { |r| r.quantity * r.price }
  return BigDecimal("0") if executed_quantity.zero?
  total_value / executed_quantity
end
```

## Exit requests

Exit logic (stop-loss, target, EOD flat) submits *orders*, and inherits every rule above — plus one temptation of its own: bypassing the intent table to "get out fast". An exit that skips identity and audit is how a panic path places unbounded orders: the fast path and the normal path must share the same gateway, the same intent table, and the same gates. If exits need priority, implement it as queue priority on the submission path, not as a second submission path.

Exit design rules:

- an exit intent references the position it closes, with its own client order ID;
- "flatten position" computes quantity from the reconciled position, not from a locally cached one;
- exit policies that need "at any price" still pass risk gates sized for that intent — market-order urgency is not an authorization bypass.

## Event application discipline

Execution events arrive from streams and polls, possibly duplicated and out of order. The application seam is one place, and it is the same discipline as any external stream:

1. **identity**: deduplicate on the venue's execution identity (`broker_order_id + exec_id`, or sequence number);
2. **ordering**: apply by venue sequence/timestamp where provided; late events for superseded states are absorbed with audit;
3. **totaling**: distinguish increment fields from total fields per the venue's contract, and reconcile the sum against the venue's order state;
4. **audit**: every applied or absorbed event is recorded — a position nobody can explain is an outage.

```ruby
class ExecutionEventConsumer
  def call(envelope)
    report = ExecutionReport.from_envelope(envelope)
    intent = OrderIntent.lock.find_by!(client_order_id: report.client_order_id)
    intent.apply_execution_report!(report)
    :ack
  rescue ActiveRecord::RecordNotUnique
    :ack   # duplicate report identity — already applied
  end
end
```

The poll that many venues offer alongside the stream is not redundant code: it is the reconciliation input that makes the stream's gaps discoverable (see the retries-and-reconciliation reference).
