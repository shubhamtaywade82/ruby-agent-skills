# Feedback loops for Ruby and Rails bugs

Reference for the `ruby-debugging` skill. Load it on demand when building or tightening the Phase 1 loop, or when the bug is intermittent. The completion criterion for Phase 1 stays in the skill's `SKILL.md`.

## Ways to build a loop

Try these roughly in order; the first one that reaches the bug's code path and asserts the reported symptom wins.

1. **Failing test at the seam that reaches the bug.** Use the repository's framework and run one example:
   `bin/rails test test/models/invoice_test.rb:42` or `bundle exec rspec spec/requests/invoices_spec.rb:17`.
   Prefer the highest seam that still reproduces: a request or integration test when the bug needs routing, middleware, or several callers.
2. **Runner script.** A throwaway `script/repro_<topic>.rb` run with `bin/rails runner script/repro_<topic>.rb` (or `bundle exec ruby -Ilib repro.rb` outside Rails) that prints PASS or FAIL and exits non-zero on failure.
3. **HTTP script against a local server.** `curl` against `bin/rails server`, asserting on status, headers, or body with `grep -q` or `jq -e`.
4. **Rake or CLI invocation with a fixture input**, diffing output against a known-good snapshot.
5. **Browser-driven loop.** A system test (`bin/rails test:system`, Capybara) or a Playwright script that asserts on the DOM, console, or network.
6. **Replay a captured payload.** Save the real webhook body, job arguments, or request (redacted) to a fixture file and replay it through the code path in an integration test, for example `post "/webhooks/provider", params: file_fixture("event.json").read, headers: { "CONTENT_TYPE" => "application/json" }`.
7. **Property loop.** When output is "sometimes wrong", run many seeded random inputs (`rng = Random.new(1234)`) and stop at the first failure, printing the seed and input.
8. **Bisection harness.** When the bug appeared between two known states, make the loop a script that exits 0 on good and 1 on bad, then `git bisect run <script>`. Exit 125 skips a commit that cannot be tested.
9. **Differential loop.** Run the same input through two versions or configurations and diff the results, for example the current and next Gemfile with `BUNDLE_GEMFILE=Gemfile.next bundle exec ...` during an upgrade.
10. **Human step as a script.** When a person must perform an action (a device login, a third-party console), write the steps as a script that prompts for each one and captures the output, so the loop stays structured.

## Tighten the loop

Treat the loop as a product. Once one exists:

- **Faster**: run one file or example, skip unrelated setup, and avoid booting the whole app when a plain Ruby harness reaches the code.
- **Sharper**: assert the specific symptom (the wrong total, the exact exception class and message), never "did not crash".
- **More deterministic**: pin the seed (`bin/rails test --seed 1234`, `rspec --seed 1234`), freeze time with `travel_to`, seed `Random`, block real HTTP with WebMock or the repository's equivalent, and run with `PARALLEL_WORKERS=1` while diagnosing.

A two-second deterministic loop is tight. A thirty-second flaky one is barely better than none.

## Intermittent bugs

The goal is a higher reproduction rate, not a clean single reproduction:

- run the loop many times and count failures, for example `for i in $(seq 100); do bin/rails test test/models/invoice_test.rb || echo FAIL; done | grep -c FAIL`;
- for order-dependent failures, find the minimal order with `rspec --bisect`, or the `minitest-bisect` gem when the repository has it;
- raise contention on purpose: run in parallel, add load, narrow timing windows, or inject short sleeps at suspected race points while diagnosing only;
- look at shared state first: class-level caches, `Current` attributes, global configuration, database rows left by other examples, and time-dependent code.

A failure that reproduces half the time is debuggable; one in a hundred is not yet. Keep raising the rate.

## When no loop can be built

Stop and say so explicitly. List what was tried, then ask for one of:

- access to the environment that reproduces the failure;
- a redacted captured artifact: log excerpt, request/response pair, job arguments, database row, or core dump;
- permission to add temporary, tagged production instrumentation.

Do not continue to hypotheses without a loop.
