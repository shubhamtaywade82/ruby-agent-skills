# Quantities, Fees, and PnL

## Quantity and lot constraints

Quantities are money's siblings: exact, constrained, and validated before they reach arithmetic:

| Constraint | Where enforced |
|---|---|
| lot size / step size (multiples of 5, 0.001 lots) | validation before execution; venue rejects otherwise — know it first |
| tick size (price increments) | same |
| minimum/maximum quantity | same |
| remaining quantity (partial fills) | derived from applied execution reports |

Validate with exact arithmetic — a modulo on a `Float` is a rounding decision in disguise:

```ruby
def valid_quantity?(quantity, lot_size)
  quantity = BigDecimal(quantity)
  (quantity % BigDecimal(lot_size)).zero? && quantity.positive?
end
```

The remaining-quantity rule that prevents over-fills: `remaining = order.quantity - sum(applied reports)`; a report that exceeds `remaining` is either a duplicate mislabeled or an incident — reconcile, do not apply blind.

## Fee arithmetic

Fees are rounding-sensitive money paths with a direction:

```ruby
class FeeSchedule
  def brokerage_fee(notional)
    (notional * rate_for(notional)).round(SCALE, MoneyRounding::FEES)
  end

  def total_charges(trade)
    components = [brokerage_fee(trade.notional),
                 exchange_fee(trade),
                 statutory_fee(trade)]
    components.sum.round(SCALE, MoneyRounding::FEES)   # round the sum, not each part
  end
end
```

Rules that keep fees auditable:

- compute from exact inputs (`BigDecimal` notional from the fill price and quantity), never from display-rounded values;
- round once at the end of the fee computation, with the named mode from the rounding policy;
- keep each fee component separate in the ledger (brokerage, exchange, tax post to different accounts) and only round the individual component when it is *itself* the posted amount;
- document the direction: fees round **up** for the payer here, and the test suite pins that exact half-case (`1.005` with `ROUND_HALF_UP` is `1.01`, and the test says so);
- recomputability: given the trade's raw inputs, the fee must be recomputable to the same value — if it is not, some input was rounded upstream and the audit is broken.

## PnL and weighted averages

Realized PnL is computed from postings (or fills), with exact average-price logic:

```ruby
class Position
  def average_entry_price
    return BigDecimal("0") if total_quantity.zero?

    total_cost / total_quantity          # BigDecimal division with enough scale
  end

  def realized_pnl(exit_quantity, exit_price)
    exit_qty = BigDecimal(exit_quantity)
    exit_px  = BigDecimal(exit_price)

    (exit_px - average_entry_price).mult(exit_qty, POSITION_SCALE)
  end

  def unrealized_pnl(mark_price)
    (BigDecimal(mark_price) - average_entry_price).mult(open_quantity, POSITION_SCALE)
  end
end
```

The correctness rules:

- **average price accumulates**: on a new same-direction entry, `total_cost += qty * price; total_quantity += qty`; on an exit, realized PnL books against the current average, then `total_cost -= avg * exit_qty; total_quantity -= exit_qty` — exact under `BigDecimal` at a fixed scale;
- **mark-to-market uses one price source and a timestamp**: unrealized PnL with yesterday's mark is a lie with a number attached; record which mark produced it;
- **sign conventions written down once**: long PnL up when price up; shorts invert; fees are always negative to the account. Every formula in one place defines its convention — discoverability of "which sign is which" mid-debugging is how sign bugs ship;
- **fees belong in PnL**: realized PnL net of fees is a different number than gross; the ledger separates them, and reports state which they show;
- **currency consistency**: PnL across mixed-currency legs converts through a recorded rate at one boundary, never implicitly.

## Sign conventions and the posting layer

Money math gets its signs from the accounting model: `+` for credit (source of funds), `-` for debit (use of funds). Trade events post symmetrically:

| Event | Cash account | Position/PnL accounts |
|---|---|---|
| buy fill | `- notional - fees` | position cost `+ notional`, fees `+` as expense |
| sell fill | `+ notional - fees` | position cost `- notional` (at average), realized PnL as the balancing difference |
| corporate action | per contract | always balanced by an equity adjustment |

The property that makes it safe: whatever the event, `sum(postings) == 0` within the entry (Invariant 1), so a sign-convention error becomes a visible imbalance in a specific entry rather than an invisible balance drift. A sign bug caught by the balancing check is a five-minute fix; the same bug in a free-floating formula is a month-end discrepancy.
