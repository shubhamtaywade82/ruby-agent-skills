# Reproduce, hypothesise, and instrument

Reference for the `ruby-debugging` skill. Load it on demand when reproducing, minimising, hypothesising, or instrumenting after the Phase 1 loop exists. The fix, cleanup, and verification rules stay in the skill's `SKILL.md`.

## Reproduce

Run the loop and watch it go red. Confirm:

- it produces the failure the reporter described, not a different failure nearby; a wrong bug leads to a wrong fix;
- it reproduces across runs, or at a pinned rate for an intermittent bug;
- the exact symptom is captured (exception class and message, wrong value, timing) so the fix can be checked against it.

## Minimise

Shrink the reproduction to the smallest scenario that still goes red. Remove one element at a time and re-run after each cut: records and attributes, callers, configuration, middleware, steps, and input size. Keep only what is load-bearing.

Minimisation is done when removing any remaining element turns the loop green. The minimal case narrows the hypothesis space and becomes the regression test.

## Hypothesise

Write 3–5 ranked hypotheses before testing any. A single hypothesis anchors on the first plausible idea.

Each hypothesis must be falsifiable, stated as a prediction:

```text
If <cause> is responsible, then <changing X> makes the failure disappear,
and <changing Y> makes it worse or leaves it unchanged.
```

A hypothesis without a prediction is a hunch: sharpen or drop it.

Show the ranked list to the user before testing when they are available. They often know which one a recent deploy touched, or which ones were already ruled out. Proceed with your ranking when they are not.

## Instrument

Each probe tests one prediction. Change one variable per run.

Preference order:

1. the debugger or a console at the suspect point: `binding.break` with the `debug` gem (or the repository's debugger), `bin/rails console` for state;
2. targeted log lines at the points that separate the hypotheses;
3. never "log everything and grep".

Tag every temporary log line with one unique prefix so cleanup is a single search:

```ruby
Rails.logger.debug("[DEBUG-a4f2] invoice=#{invoice.id} total=#{invoice.total_cents} state=#{invoice.state}")
```

Log identifiers and state transitions, never passwords, tokens, cookies, or full sensitive payloads.

## Performance regressions

Logs are usually the wrong tool. Establish a baseline first, then bisect:

- time the loop with `Benchmark.realtime` or `benchmark-ips` when the repository uses it;
- capture query counts and plans (`EXPLAIN` through `relation.explain`) for database-bound paths;
- profile allocations or CPU with the repository's profiler when one is configured;
- bisect commits or configuration with the same measurement, and compare against the baseline, not intuition.

Hand sustained query and capacity work to `rails-performance` or `ruby-performance`.
