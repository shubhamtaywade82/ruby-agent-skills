# Market Data Integrity

## The OHLCV contract

A candle is a contract, and every field has ambiguity to pin down:

| Field | Ambiguities to resolve |
|---|---|
| timestamp | bar **open** or bar **close** time? epoch seconds or milliseconds? UTC or exchange-local? |
| open/high/low/close | exchange official values or vendor-computed from ticks? |
| volume | traded volume for the period only (no cumulative carry-over)? |
| symbol/instrument | as-of which date? symbols change and expire |

The contract, written down and enforced:

```ruby
create_table :candles do |t|
  t.string :symbol, null: false
  t.integer :timeframe_seconds, null: false    # 60, 300, 900, 3600, 86400 — explicit
  t.datetime :bar_open_at, null: false         # UTC, bar-OPEN convention, documented
  t.decimal :open, precision: 20, scale: 8, null: false
  t.decimal :high, precision: 20, scale: 8, null: false
  t.decimal :low, precision: 20, scale: 8, null: false
  t.decimal :close, precision: 20, scale: 8, null: false
  t.decimal :volume, precision: 30, scale: 8, null: false
  t.timestamps
end
add_index :candles, [:symbol, :timeframe_seconds, :bar_open_at], unique: true
```

The unique index is the deduplication key: a re-imported vendor file cannot double-count volume. A candle loaded twice is a bug caught at the door, not an annual surprise.

Internal consistency is checkable and should be: `low <= open <= high`, `low <= close <= high`, `high >= max(open, close)`, volume `>= 0`. A candle that fails these is corrupt data, and loading it should fail loudly.

## Candle gaps

Gaps are facts with causes, and each cause has a different correct handling:

| Gap cause | Correct handling |
|---|---|
| market closed (session boundary, overnight) | not a gap — the session calendar explains it |
| holiday | not a gap — calendar |
| vendor data miss | a real gap: record, backfill from another source or leave absent |
| partial session (half-day) | calendar entry with shortened session |
| instrument halted | a fact — record the halt, do not interpolate prices |

Detection is arithmetic against the calendar, not against "the previous bar":

```ruby
class CandleGapScanner
  def initialize(calendar:, timeframe_seconds:)
    @calendar = calendar
    @timeframe = timeframe_seconds
  end

  def scan(symbol, bars)
    expected_session_frames(@calendar, bars.first.bar_open_at, bars.last.bar_open_at)
      .then { |frames| missing_frames(bars, frames) }   # frames with no bar
  end

  private

  def missing_frames(bars, frames)
    present = bars.map(&:bar_open_at).to_set
    frames.reject { |frame_start| present.include?(frame_start) }
  end
end
```

The repair policy is a decision, not a default: **leave absent** (indicators must handle absence), **backfill** from a second source (recorded, with provenance), or **mark unavailable** for the range. What is never acceptable: silent forward-fill as if nothing happened — an indicator over a silently bridged gap is a bias generator wearing a data-cleaning costume. When a dataset ships, its gap log ships with it.

## Timeframe alignment

Mixing timeframes is where alignment bugs breed:

- a 5-minute bar series and a 15-minute series align only at `minute % 15 == 0` boundaries — but only if both use bar-open convention and the same epoch;
- vendor A anchors hourly bars at :00, vendor B at :30 — joining them without normalization silently duplicates/omits boundaries;
- converting a 1-minute series to 5-minute bars is an aggregation (`high = max(high)`, `volume = sum(volume)`, `open = first.open`, `close = last.close`) — recomputing, not averaging, and the last partial frame is excluded or marked partial.

Rules: one convention per pipeline (bar-open UTC everywhere), explicit `timeframe_seconds` on every stored row, and aggregation as a tested pure function with known expected outputs.

## Session calendars and timezones

Sessions decide what "a day" and "a gap" mean, per exchange:

```ruby
class ExchangeCalendar
  # All instants in UTC; conversion happens exactly at the edges.
  def session_for(exchange, date)
    Session.new(
      opens_at: date.in_time_zone(exchange.timezone).change(session_open_local).utc,
      closes_at: date.in_time_zone(exchange.timezone).change(session_close_local).utc
    )
  end

  def trading_day?(exchange, date)
    weekday?(date) && !holiday?(exchange, date)
  end
end
```

The timezone discipline:

- store everything in UTC (`timestamptz`), convert only at the display or session-computation edge;
- the exchange's timezone comes from the IANA database (`Asia/Kolkata`, `America/New_York`), never a fixed offset — DST moves sessions;
- day boundaries are session boundaries, not midnight: "today's candles" for an exchange closing 15:30 local spans two UTC dates;
- DST-transition days have sessions shifted or shortened; a calendar that cannot represent them will invent or lose a bar each transition.

## Instrument master

The instrument master answers "what did this symbol mean on that date":

- symbols change (renames, re-listings) and expire (derivatives); an **as-of** instrument table (`symbol, effective_from, effective_to, attributes`) beats a mutable current row for historical work;
- corporate actions (splits, bonuses) split-adjust history: decide and record whether stored candles are adjusted or raw — one convention per dataset, stated;
- tick size, lot size, and expiry belong to the instrument, not the strategy: validating them in one place (see the financial data integrity skill) keeps execution-time rejections out of live trading;
- survivorship: building a universe from *today's* active symbols backtests only winners — historical membership is a first-class field of the master, and its absence is a red flag worth reporting.
