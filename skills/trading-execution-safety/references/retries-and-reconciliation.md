# Retries and Reconciliation

## Ambiguous outcomes

The single rule that separates safe execution systems from expensive incidents: **when a submission's outcome is unknown, treat it as probably executed.**

An ambiguous outcome is any of: connection reset during the request, read timeout after the request was sent, HTTP 5xx (the venue may have processed before erroring), or a crashed process anywhere between send and response. In every one of these windows, the order may be live at the venue, and the only legitimate next action is to find out — never to try again and see.

```ruby
# Wrong: the timeout lands in the generic retry, a second order goes out.
rescue Gateway::AmbiguousOutcome
  retry_job wait: 5

# Right: park the intent, ask the venue.
rescue Gateway::AmbiguousOutcome
  intent.transition!(:outcome_unknown)
  Execution::ReconcileIntentJob.perform_later(intent.id)
```

The retry classification that makes "definitely not executed" a safe retry class:

| Error class | Evidence | Retry allowed |
|---|---|---|
| validation / rejected | venue's synchronous rejection with reason | only after fixing the reason, as a new decision |
| auth failure | 401/403 with no order effect | yes, after credential repair |
| rate limited | 429 with no order effect | yes, after backoff honoring the window |
| timeout / reset / 5xx | unknown | no — reconcile |
| crash after send | none available | no — reconcile |

## Broker reconciliation

Reconciliation is the scheduled comparison between the venue's truth and local state, and it is the mechanism that resolves every ambiguous window. The venue is the source of truth for executed quantity, order state, and position; local state is a cache of that truth plus intent.

```ruby
class Execution::ReconcileIntentJob < ApplicationJob
  queue_as :execution

  def perform(intent_id)
    intent = OrderIntent.find(intent_id)
    venue_order = gateway.order_status(client_order_id: intent.client_order_id)

    case venue_order.status
    when "not_found"
      # The submission never landed (or aged past the venue's ID horizon):
      # resolve by policy — mark never_submitted, alert if a fill is impossible.
      resolve_not_found(intent)
    when "open", "partially_filled", "filled", "cancelled"
      align_intent_with(intent, venue_order)   # applies reports and transitions
    end
  end

  private

  def align_intent_with(intent, venue_order)
    venue_order.execution_reports.each { |r| intent.apply_execution_report!(ExecutionReport.from_venue(r)) }
    intent.reconcile_state!(venue_order.status)   # audited, idempotent transition
  end
end
```

Design rules for reconciliation:

- **idempotent**: running twice against a consistent venue changes nothing (deduplication by report identity does this);
- **scheduled, not just on-error**: a periodic sweep of `outcome_unknown`, `submitted`-without-acknowledgement, and divergent positions catches the windows nobody saw open;
- **divergence to the venue**: when local and venue disagree, the venue wins for facts (executed quantity, order state); local wins only for intent and audit;
- **rate awareness**: reconciliation polls are API budget; batch and schedule within the venue's limits, and back off on 429 rather than hammering;
- **page on unresolvable divergence**: after N reconciliation attempts with `not_found` but a fill on the books elsewhere, or totals that refuse to converge, a human decides — the system's job is to present the exact evidence.

## Position reconciliation

Positions are derived state and drift silently: missed events, duplicate applications, restarts mid-stream. The position check is the invariant that catches all of them:

```
venue_position == local_position (from ledger of applied fills)
```

```
for each (account, symbol):
  venue_qty = broker.positions[account][symbol]
  local_qty = executed_buy_qty - executed_sell_qty (from execution reports ledger)
  if venue_qty != local_qty:
    record divergence (with both numbers and the report trail)
    alert (position divergence is always incident-worthy)
    propose realignment from venue_qty (audited, authorized, rate-limited)
```

Realignment is deliberate: write the correction through an audited, authorized adjustment — never a silent `update_column` on the derived cache — and rate-limit it: a position that needs daily realignment is a bug in event application being papered over, and the alert exists to force that conversation.

## The ledger connection

Execution produces money facts: fills with quantity and price, fees, and realized PnL. Those facts flow into the ledger with the same identity discipline (see the financial data integrity skill for the accounting side). Two rules live on the execution side of that boundary:

1. one fill event produces exactly one ledger posting, keyed by the report's identity — the join is the deduplication;
2. ledger postings record the evidence (intent ID, client order ID, broker exec ID) so an auditor can walk from a balance back to the venue's report.
