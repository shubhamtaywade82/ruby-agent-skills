# RSpec

Reference for the `rails-test-engineering` skill. Load it on demand when the repository uses RSpec. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## RSpec
Detect RSpec before writing tests: `spec/`, `.rspec`, `spec/rails_helper.rb`, and `rspec-rails` in the Gemfile. Follow the suite the repository already runs; never add a second framework.

- Prefer request specs (`type: :request`) over controller specs for HTTP contracts; assert status, `response.parsed_body`, and persisted side effects.
- Enqueue matchers (`have_enqueued_job`, `have_enqueued_mail`) need the `:test` queue adapter, the Rails 7.2+ test-environment default; a global override breaks them. Use the block form: `have_enqueued_mail` raises `ArgumentError` without a block.
- Assert validation failures with `errors.of_kind?(:attribute, :type)`; `errors.added?` also compares the error's options (`count:`, `value:`) and fails when any is omitted.
- Use verifying doubles (`instance_double`, `class_double`) so signature drift fails the spec; do not use `allow_any_instance_of`.
- Keep the base factory minimal and valid; put state in traits (`:paid`, `:cancelled`). Prefer `build`/`build_stubbed` when persistence is not under test.
- Use shared examples only for a repeated contract (for example, the 422 error shape across endpoints), parameterised by keyword arguments, not to hide setup.
- `let` is lazy and memoized per example; `let!` forces the call in a `before` hook, so use `let!` only when a later example needs the record to already exist (a query scope, a count, an association preload) — a `let` no example calls never runs and hides that the fixture is unused.
- Load support files deterministically: `Rails.root.glob("spec/support/**/*.rb").sort_by(&:to_s).each { |f| require f }`.

Patterns: `rspec-request-spec`, `rspec-job-and-mail-enqueue`, `rspec-mailer-spec`, `rspec-factory-traits`, `rspec-shared-examples-contract`, `rspec-verifying-doubles`.
