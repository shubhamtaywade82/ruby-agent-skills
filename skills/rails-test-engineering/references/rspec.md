# RSpec

Reference for the `rails-test-engineering` skill. Load it on demand when the repository uses RSpec. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## RSpec
Detect RSpec before writing tests: `spec/`, `.rspec`, `spec/rails_helper.rb`, and `rspec-rails` in the Gemfile. Follow the suite the repository already runs; never add a second framework.

- Name method groups by receiver: `describe "#instance_method"` and `describe ".class_method"`, with `context "when ..."` / `"with ..."` / `"without ..."` underneath. `RSpec/DescribeMethod` enforces this only for the second argument of a top-level `describe` (`describe Order, "#total"`); nested groups follow it by convention.
- Prefer request specs (`type: :request`) over controller specs for HTTP contracts; assert status, `response.parsed_body`, and persisted side effects.
- Enqueue matchers (`have_enqueued_job`, `have_enqueued_mail`) need the `:test` queue adapter, the Rails 7.2+ test-environment default; a global override breaks them. Use the block form: `have_enqueued_mail` raises `ArgumentError` without a block.
- Assert validation failures with `errors.of_kind?(:attribute, :type)`; `errors.added?` also compares the error's options (`count:`, `value:`) and fails when any is omitted.
- Keep one expectation per example for isolated unit specs. When setup is expensive (request, system, or integration specs) and several assertions describe one outcome, tag the example or group `:aggregate_failures` so every failed expectation is reported instead of only the first. `RSpec/MultipleExpectations` skips examples with that metadata and counts an `aggregate_failures do ... end` block as one expectation; do not use it to merge unrelated behaviors into one example.
- Use verifying doubles (`instance_double`, `class_double`) so signature drift fails the spec; do not use `allow_any_instance_of`.
- Stub outbound HTTP at the network boundary with the library the repository already uses, usually WebMock (`stub_request`) or VCR cassettes hooked into WebMock. Block real connections in the spec helper with `WebMock.disable_net_connect!(allow_localhost: true)`; localhost stays open for system specs driving the app server. Filter credentials out of recorded cassettes with `filter_sensitive_data`. Do not add WebMock or VCR to a suite that isolates HTTP another way.
- Keep the base factory minimal and valid; put state in traits (`:paid`, `:cancelled`). Prefer `build`/`build_stubbed` when persistence is not under test.
- Use shared examples only for a repeated contract (for example, the 422 error shape across endpoints), parameterised by keyword arguments, not to hide setup.
- `let` is lazy and memoized per example; `let!` forces the call in a `before` hook, so use `let!` only when a later example needs the record to already exist (a query scope, a count, an association preload) — a `let` no example calls never runs and hides that the fixture is unused.
- Load support files deterministically: `Rails.root.glob("spec/support/**/*.rb").sort_by(&:to_s).each { |f| require f }`.

Patterns: `rspec-request-spec`, `rspec-job-and-mail-enqueue`, `rspec-mailer-spec`, `rspec-factory-traits`, `rspec-shared-examples-contract`, `rspec-verifying-doubles`.
