# Indicators and Look-ahead

## Window and alignment conventions

An indicator is a pure function of an ordered window, and its bugs are boundary bugs:

- **window definition**: is a 20-period SMA the mean of the last 20 *completed* bars, or the last 20 including a partial one? Decide, document, and test — the classic off-by-one at the start of a series produces a warm-up full of subtly wrong values;
- **alignment**: indicators at timeframe T consume bars at timeframe T, aligned by bar-open; an indicator that mixes the 5-minute close into a 1-minute window is undefined behavior;
- **warm-up**: the first `window - 1` steps have no value — `nil`, not zeros, not a shorter window's value. Zeros in warm-up are look-ahead's quieter cousin: a moving average dragged toward zero;
- **NaN discipline**: gaps produce absent bars (see the data integrity reference); indicators must define absent-input behavior (skip, shorten the window with a note, or emit nil) rather than silently bridging.

```ruby
class SimpleMovingAverage
  def initialize(period:)
    @period = period
  end

  def call(bars)
    return nil if bars.length < @period     # warm-up: nil, never zero-padded

    window = bars.last(@period)
    window.sum(&:close) / BigDecimal(@period)
  end
end
```

Indicators are tested against **known reference values** (a published table, a second implementation, or a hand-computed case): two implementations agreeing on a random series is weak evidence; agreement on edge-shaped series (gaps, session boundaries, warm-up) is the test that catches off-by-ones.

## Look-ahead bias

Look-ahead is any use of information that did not exist at the decision time. It is the single most common reason backtests look brilliant and live trading disappoints. The recurring forms:

1. **same-bar trading**: the signal computed from bar N's close, filled at bar N's close — a trade made with the knowledge of the close itself;
2. **indicator forward-bleed**: an indicator implementation that peeks one element ahead (a `reduce` off-by-one, or a rolling implementation that includes the *next* bar);
3. **as-of violations in joins**: features joined against a table state *as of now* (current instrument metadata, current symbol mapping) rather than historical state;
4. **timestamp unit confusion**: comparing epoch-microsecond decision times against epoch-second bars — everything "looks" past when it is actually future.

The defense is structural, not vigilance: **one as-of primitive** through which every historical access passes:

```ruby
class AsOf
  def initialize(series:)
    @series = series.sort_by(&:bar_open_at)
  end

  # Data strictly before `time`: excludes the bar containing `time`.
  def before(time)
    idx = @series.bsearch_index { |bar| bar.bar_open_at >= time } || @series.length
    @series[0...idx]
  end
end
```

Rules of use:

- the strategy's `decide(as_of:)` receives only `before(T)` data; the engine passes only that;
- fills happen at `T+1`'s open (or a modeled intrabar price), never at `T`'s close;
- tests assert the property directly: step at T with the series truncated after T must produce the same signal as with the full series — that test, run in CI, is the look-ahead tripwire.

## Data leakage beyond prices

Look-ahead is not only about candles:

| Source | Leak shape |
|---|---|
| normalized features | scaler/normalizer fitted on the full series (including the future) before splitting |
| hyperparameters | tuned on the set later reported as out-of-sample |
| universe selection | symbols chosen by outcomes (today's winners, post-hoc filters) |
| corporate actions | split-adjusted history applied with future knowledge of the ratio |
| vendor backfills | a "historical" dataset patched after the fact (check as-of stamps where the vendor provides them) |

The split discipline: fit any preprocessing (scaling, feature selection, imputation) on the training slice only, apply frozen to validation/test, and keep the holdout untouched until one final evaluation. A holdout consulted repeatedly is a validation set with better marketing.

## Feature/signal boundaries

Keep the layering testable and honest:

```
raw candles (validated, gap-logged)
  -> features (pure functions of as-of windows)
  -> signals (pure functions of features)
  -> execution intents (the strategy's output, no data access)
```

- features and signals are **pure**: no database reads, no globals, no time-dependent side effects — given the same window, they return the same values, which is what makes replay trustworthy;
- the strategy never touches the ledger or the data store; it produces intents, and the simulation applies them (the same shape the live engine consumes — one interface, two runtimes);
- every feature names its inputs' as-of semantics in the interface (`feature.call(as_of:)`), so a reviewer can see leakage candidates at the signature, not in the middle of the implementation.
