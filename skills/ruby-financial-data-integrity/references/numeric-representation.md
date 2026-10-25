# Numeric Representation

## Choose exactness per concept

| Concept | Representation | Why |
|---|---|---|
| money amounts | integer minor units **or** `BigDecimal` with fixed scale | exact under +, -, *; no binary fraction error |
| prices, quantities, rates | `BigDecimal` with a stated scale | scale known; multiplication stays exact; rounding is explicit |
| counters, page sizes, quantities in whole units | `Integer` | exact, unbounded |
| nothing financial, ever | `Float` | `0.1 + 0.2 != 0.3` and the difference compounds |

Two workable systems, one rule — pick one per codebase and convert only at the edges:

**Integer minor units** (cents, paise): `1999` means 19.99. Exact, fast, constraint-checkable; every division is a rounding decision by construction. Divide only at the display/edge layer.

**Scale-fixed `BigDecimal`**: `BigDecimal("19.99")` with `BigDecimal.mode`/explicit `round`. Convenient for prices and rates with varying scales; discipline required at construction and serialization.

The defect class to eliminate: mixed representation in one expression — `price * quantity` where one side was parsed as `Float` silently poisons the `BigDecimal` product's exactness. Guard the boundary, not the arithmetic.

## Parsing boundaries

Every external surface can inject a `Float`:

```ruby
# JSON: numbers parse to Float by default — money arrives corrupted at the door.
JSON.parse('{"price": 19.99}')["price"].class  # => Float

# Exact by construction:
data = JSON.parse(payload, decimal_class: BigDecimal)          # parse straight to BigDecimal
price = BigDecimal(payload["price"].to_s)                     # or take the string form
qty   = BigDecimal(raw["quantity"], 0)
```

Boundary checklist:

- **JSON/API**: `decimal_class: BigDecimal`, or serialize money as strings;
- **query params / forms**: they arrive as strings — `BigDecimal(str)` them, never `.to_f`;
- **CSV/imports**: strings; parse once, validate scale, store exact;
- **database**: decimal columns already round-trip `BigDecimal`; integer columns hold minor units;
- **serialization out**: emit strings or scale-fixed values; never `to_json` a `Float` conversion of money.

`BigDecimal("0.1")` and `BigDecimal(0.1)` are different numbers — the second wraps the float's error. Constructor-from-string only; `BigDecimal(0.1.to_s)` is the rescue for values already polluted.

## Precision and scale

The database column is a contract — values silently round (or raise) to its scale:

```ruby
# Mismatch: application computes 8 decimals, column stores 2 — silent truncation on save.
change_column :positions, :price, :decimal, precision: 20, scale: 8

# Sizing rule: precision must hold the largest realistic SUM with headroom.
# A balance column that must sum to 10^12 units at scale 8 needs precision >= 21.
```

Sizing discipline:

- precision = max realistic aggregate magnitude + scale + margin (aggregations happen in SQL over the same column);
- scale = the domain's smallest unit (2 for display money; 4-8 for prices/rates where lots and ticks demand it);
- changing scale later is a data migration with verification: count rows where `value != round(value, new_scale)` *before* migrating — that count is the number of silent changes;
- never store money in `float`/`double` columns, and treat any that exist as a defect to migrate off.

## Rounding decisions

Rounding is a business rule wearing a math costume. Make it a named decision:

```ruby
module MoneyRounding
  FEES     = BigDecimal::ROUND_HALF_UP    # standard fee rounding, documented
  ALLOCATE = BigDecimal::ROUND_DOWN       # never over-allocate a limited pool
  DISPLAY  = BigDecimal::ROUND_HALF_EVEN  # banker's rounding for statements
end

def fee_for(notional, rate)
  (notional * rate).round(currency_scale, MoneyRounding::FEES)
end
```

The rules that keep rounding sane:

1. **round once, at the end** — intermediate rounding compounds error: `a.round(2) + b.round(2) != (a + b).round(2)` in both directions;
2. **name the mode** — `ROUND_HALF_UP`, `ROUND_DOWN` (truncation), `ROUND_CEILING` (always toward +inf) mean different business things: fees round one way, payouts the other;
3. **directional costs round against the payer** or toward the earner — decide once, document it, and keep it symmetric in tests;
4. **allocation** (splitting a total into shares) uses largest-remainder or floor-plus-remainder so the parts sum exactly to the whole:

```ruby
def allocate(total, weights)
  scale = 2
  total = BigDecimal(total)
  exact = weights.map { |w| total * w / weights.sum }
  floors = exact.map { |e| e.floor(scale) }
  remainder = total - floors.sum
  pennies = (remainder / BigDecimal("0.01")).floor     # units of the smallest step
  # distribute the remainder one step at a time to the largest fractional parts
  order = exact.each_with_index.sort_by { |e, _i| -(e - e.floor(scale)) }.map(&:last)
  order.first(pennies.to_i).each_with_index do |idx, _|
    floors[idx] += BigDecimal("0.01")
  end
  floors  # sum(floors) == total, exactly
end
```

A split that loses or invents a cent is the canonical rounding bug; the allocation routine is where "round each share" goes to die.

## Minor units and currency context

When integer minor units back the system, currency context decides the scale: most currencies use 2 decimals, several use 0 (JPY), some use 3 (KWD). The scale is a property of the currency, so:

- store the currency code beside the amount, always — an amount without its currency is a display string, not money;
- convert between currencies only through an explicit rate record (rate, timestamp, source) with rounding at the one boundary that owns it;
- never mix currencies in one arithmetic expression or one balancing journal entry.
