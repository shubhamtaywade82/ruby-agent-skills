---
name: rspec-betterspecs-audit
description: "Audit an RSpec suite against the betterspecs.org guideline set and route each rule to the existing rubocop-rspec cop, pattern, or skill reference that enforces it."
family: testing
---

# RSpec betterspecs.org Audit

## Problem
[betterspecs.org](https://www.betterspecs.org/) is a widely-cited Rails testing guidelines list, but it is prose-only. An agent reviewing an RSpec suite needs an executable mapping: for each betterspecs rule, which `rubocop-rspec` cop, which pattern in `patterns/testing/`, and which `rails-test-engineering` reference already enforces it, and which rules are out of scope for this pack.

## Use when
- A review or PR touches an RSpec suite and the team references betterspecs.org as the spec-quality bar.
- An agent needs to translate a betterspecs prose rule into an executable check.
- You are adopting this skill pack in a repo that already cites betterspecs.org in its `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE.md`, or style guide and need to reconcile the two authorities.

## Do not use when
- The repository uses Minitest (`Test::Unit` / `ActiveSupport::TestCase`); the audit pattern is RSpec-only.
- The repository already pins to `rspec.rubystyle.guide` (the source this pack canonically uses); use the existing `rspec-*` patterns directly.
- A betterspecs rule conflicts with an explicit repository convention. Repository conventions take precedence over external guidelines.

## Repository inspection
Before applying this audit:

1. Detect RSpec: `spec/`, `.rspec`, `spec/rails_helper.rb`, `rspec-rails` in `Gemfile.lock`.
2. Read `.rubocop.yml` for enabled `RSpec/*` cops and their configuration.
3. Read `spec/spec_helper.rb` and `spec/rails_helper.rb` for `expect_with`, `mock_with`, `filter_rails_from_backtrace`, and support-file loading.
4. Inspect `spec/support/` for shared examples, shared contexts, and helpers.
5. Identify the factory backend: `factory_bot_rails` vs hand-rolled fixtures vs no persistence layer.
6. Inspect test-data volume: how many records are created per example, in which contexts.
7. Inspect HTTP-boundary stubbing: `webmock`, `vcr`, `stub_request` usage.
8. Inspect CI test runner: `bundle exec rspec`, `bin/rails test`, Guard, or single-shot.

## Upstream coverage (Iteration 153)

`skills/rails-test-engineering/references/rspec.md` already covers three betterspecs rules added in Iteration 153:

- **#1 Describe methods** — `describe "#instance_method"` and `describe ".class_method"` naming, with `RSpec/DescribeMethod` enforcement scope noted (top-level `describe` second arg only).
- **#4 Single expectation / aggregate_failures** — `:aggregate_failures` for expensive multi-assertion specs, with `RSpec/MultipleExpectations` skipping that metadata.
- **#18 HTTP stubbing** — WebMock `stub_request` and VCR cassettes with `WebMock.disable_net_connect!(allow_localhost: true)` and `filter_sensitive_data` for cassette credentials.

This audit pattern is the cross-reference layer that maps all 19 betterspecs.org rules to their existing enforcement points. Iteration 153 deliberately did not adopt #11 (factories-over-fixtures — already covered by `rspec-factory-traits.md` pattern) and #16 / #19 (Guard and formatter — workflow concerns, not spec-correctness).

## Implementation procedure

1. Run `bundle exec rubocop --only RSpec` on the changed spec files; collect every `RSpec/*` offense.
2. Cross-reference each offense against the mapping table below.
3. For rules marked **pattern**, load the named pattern in `patterns/testing/` and apply its procedure.
4. For rules marked **reference**, load the named file in `skills/rails-test-engineering/references/`.
5. For rules marked **out of scope**, decide explicitly whether to adopt the rule at the repository level (e.g. add a `lib/tasks/test_speed.rake` or a Guardfile); do not silently enforce or silently ignore.
6. Re-run `bundle exec rubocop --only RSpec` and the focused spec file until clean.

## Mapping table: betterspecs.org → existing enforcement

The 19 guidelines at betterspecs.org map onto this pack as follows. "Coverage" grades are: **executable** (cop or pattern enforces it), **partial** (some sub-rules are enforced), **out of scope** (pack does not own this concern).

| # | betterspecs.org rule | Coverage | Existing enforcement | Notes |
|---|---|---|---|---|
| 1 | **Describe methods** — use `.method` for class methods, `#method` for instance methods | executable | `RSpec/DescribeMethod` (rubocop-rspec default) | Part of the RSpec Style Guide that this pack already imports in `docs/RSPEC_STYLE_GUIDE.md`. |
| 2 | **Use contexts** — start `context` with `when` / `with` / `without` | executable | `RSpec/ContextWording` cop, configured in `.rubocop.yml` with `Prefixes: [when, with, without]` | Already wired in this repo's `.rubocop.yml`. |
| 3 | **Short description** — under 40 chars; split with `context` | partial | `RSpec/ExampleWording` cop catches `should`/`it` prefixes; the 40-char limit itself is **not enforced** by rubocop-rspec | Add a custom `RSpec/ExampleLength` cop (not shipped) or enforce via review checklist. |
| 4 | **Single expectation test** — one expectation per isolated example | executable | `RSpec/MultipleExpectations` cop with `Max: 1` in `.rubocop.yml` | Betterspecs allows multiple expectations in non-isolated (integration) tests; configure `RSpec/MultipleExpectations` `Max` per group if you want that escape hatch. |
| 5 | **Test all possible cases** — valid, edge, invalid | executable (as a contract, not a cop) | `evals/test-engineering/rspec-request-contract.yml` `cases:` block requires `created` AND `rejected` cases; verifier rejects suites missing the rejection path. | No rubocop cop can detect "did you cover all cases"; the eval contract does it instead. |
| 6 | **Expect vs should syntax** — use `expect`, not `should` | executable | `RSpec/ImplicitExpect` and `RSpec/ExplicitSubject` cops; `should` is forbidden by `RSpec/NotTo` style. Configure `expect_with :rspec, :rspec` in `spec_helper.rb` to forbid `should` at runtime. | The `transpec` gem (referenced by betterspecs) is the migration path for legacy suites. |
| 7 | **Use subject** — DRY up with `subject` / named `subject(:name)` | executable | `RSpec/LeadingSubject`, `RSpec/NamedSubject` (configured `EnforcedStyle: always`) | Loaded in this repo's `.rubocop.yml`. |
| 8 | **Use `let` and `let!`** — avoid `before { @var = ... }`; `let` is lazy+memoized, `let!` forces eval | executable | `RSpec/InstanceVariable` cop (forbids `@var` in specs); `RSpec/LeadingSubject`; `let!` rule documented in `skills/rails-test-engineering/references/rspec.md` | Reference rule: *"use `let!` only when a later example needs the record to already exist"*. |
| 9 | **Mock or not to mock** — prefer real behavior; mock at boundaries you own | executable | `patterns/testing/rspec-verifying-doubles.md` pattern + `RSpec/AnyInstance` cop forbids `allow_any_instance_of` | The pattern says "use the real object when cheap and deterministic; inject a verifying double at boundaries". |
| 10 | **Create only the data you need** — minimal FactoryBot.create_list size | partial | `RSpec/MultipleMemoizedHelpers` cop (warns on excessive `let`); `patterns/testing/rspec-factory-traits.md` pattern enforces minimal base factory. | No cop enforces "list size 3 vs 10"; review checklist catches it. |
| 11 | **Use factories, not fixtures** — `FactoryBot.create :user` over `User.create(name: ...)` | executable | `patterns/testing/rspec-factory-traits.md` pattern; `data/rubocop/plugins.yml` documents `rubocop-factory_bot` for downstream projects. | The pack's `patterns/testing/rspec-factory-traits.md` rule: *"Keep the base factory minimal and valid; put state in traits"*. |
| 12 | **Easy to read matchers** — `expect { }.to raise_error` over `lambda { }.to` | executable | `RSpec/ImplicitBlockExpectation` cop; `patterns/testing/rspec-job-and-mail-enqueue.md` pattern enforces block form for `have_enqueued_job` / `have_enqueued_mail`. | The eval `rspec-request-contract` `scope_control` check rejects `expect(...).to have_enqueued_mail` (non-block form) — see the `non_block_mail` regex in `scripts/verify_test_engineering_eval.rb`. |
| 13 | **Shared examples** — DRY repeated contracts with `it_behaves_like` | executable | `patterns/testing/rspec-shared-examples-contract.md` pattern; eval `rspec-request-contract` requires `shared_examples` + `it_behaves_like` for the 422 contract. | The pattern explicitly forbids shared examples used to deduplicate unrelated assertions. |
| 14 | **Test what you see** — request/integration specs over controller specs | executable | `patterns/testing/rspec-request-spec.md` pattern; `skills/rails-test-engineering/references/rspec.md` rule: *"Prefer request specs (`type: :request`) over controller specs"*. The eval verifier rejects `type: :controller` and `assigns(`. | This is the most directly enforced betterspecs rule in the pack. |
| 15 | **Don't use `should`** — present tense, not "should" | executable | `RSpec/ExampleWording` cop; `should_clean` / `should_not` gems (referenced by betterspecs) for migration. | Loaded in this repo's `.rubocop.yml`. |
| 16 | **Automatic tests with guard** — `bundle exec guard` watches files and runs affected specs | out of scope | No pattern, no cop. The pack does not own developer-workflow tooling. | Adopt at the project level if wanted; add a `Guardfile` and document in `README.md`. The pack's `data/test-engineering/tools.yml` documents `bin/rails test` as the canonical runner. |
| 17 | **Faster tests (preloading Rails)** — Zeus / Spin / Spork preload Rails to keep single-spec runs fast | out of scope | No pattern, no cop. The referenced tools (Zeus, Spork) are abandoned; Spring (Rails' default preloader) is the modern equivalent. | Spring is the modern Rails preloader; if your repo has `spring-commands-rspec` in the `Gemfile` `:development` group, you have this. The pack does not own preloader choice. |
| 18 | **Stubbing HTTP requests** — use `webmock` / `vcr` for external HTTP | partial | `patterns/testing/rspec-verifying-doubles.md` says: *"For HTTP boundaries, prefer a fake transport or recorded response over stubbing the client."* `data/observability/tools.yml` documents `bin/rails runner` but not `webmock` directly. | The pack recommends a fake transport or recorded response; betterspecs recommends `webmock` directly. Compatible, not identical. Add `webmock` / `vcr` to your Gemfile and configure in `spec/support/webmock.rb`. |
| 19 | **Useful formatter** — `fuubar` for readable progress output | out of scope | No pattern, no cop. Formatter choice is a developer-experience concern. | Add `gem "fuubar"` to `:development, :test` group and `--format Fuubar` to `.rspec`. The pack does not own formatter choice. |

## Example

Auditing an RSpec suite against this mapping:

```ruby
# spec/requests/orders_spec.rb — before the audit (betterspecs violations)
require "rails_helper"

RSpec.describe OrdersController, type: :controller do   # bad: controller spec, betterspecs #14
  it "should create an order and return 200" do         # bad: 'should' wording, betterspecs #15
    @order = FactoryBot.create :order                    # bad: @var in spec, betterspecs #8
    allow_any_instance_of(Order).to receive(:save).and_return(true)  # bad: any_instance, betterspecs #9
    post :create, params: { order: { sku: "SKU-1", quantity: 1 } }
    expect(assigns(:order).sku).to eq("SKU-1")           # bad: assigns(), betterspecs #14
    response.should respond_with 200                     # bad: .should, betterspecs #6
  end
end

# --- After audit + applying patterns #14, #6, #8, #9 ---
# (see benchmarks/test-engineering/references/rspec-request-contract/spec/requests/orders_spec.rb
# for the full reference solution)

require "rails_helper"

RSpec.describe "POST /orders", type: :request do        # betterspecs #14: request spec
  let(:headers) { { "ACCEPT" => "application/json" } }  # betterspecs #8: let, not @var

  context "with valid params" do                         # betterspecs #2: 'with' prefix
    let(:params) { { order: { sku: "BOOK-1", quantity: 2 } } }

    it "creates the order" do                             # betterspecs #15: no 'should'
      expect { post orders_path, params: params, headers: headers }
        .to change(Order, :count).by(1)                  # betterspecs #12: block-form matcher
      expect(response).to have_http_status(:created)    # betterspecs #4: one expectation per isolated example
    end
  end
end
```

Runs green with rspec-rails 8.0 on Rails 8.0. After the audit, `bundle exec rubocop --only RSpec` should be clean and the eval `rspec-request-contract` should pass all four checks (`functional`, `contract`, `tests`, `scope_control`).

## Failure modes

- Treating betterspecs.org as the canonical source when the repository already follows `rspec.rubystyle.guide`; the two authorities differ on minor points (e.g. shared-examples usage). Pick one canonical source and document it.
- Forcing a cop (e.g. `RSpec/MultipleExpectations: Max: 1`) onto integration specs where betterspecs itself allows multiple expectations; use `rubocop-rspec`'s `RSpec/MultipleExpectations` per-`context` override.
- Loading all 9 RSpec-related plugins (rubocop-rspec, rubocop-rspec_rails, rubocop-capybara, rubocop-factory_bot, rubocop-rspec_screenshot, etc.) without inspecting their `lint_roller` plugin metadata; some don't load cleanly together. See `.rubocop.yml` header comment for the pack's documented reasons.
- Reading betterspecs.org rules out of order — rule #1 (Describe methods) is structural; rule #4 (Single expectation) is behavioral. Fix structural issues before behavioral ones; a refactor that touches both will be hard to review.
- Silently ignoring rules marked **out of scope** (Guard, Spring, fuubar). The audit reports them but doesn't enforce; teams adopting betterspecs.org should make an explicit project-level decision.

## Testing

The audit pattern itself is tested by running it against the eval `rspec-request-contract`:

```bash
# Bad fixture (the starting point): should fail multiple checks
ruby /home/z/my-project/ruby-agent-skills/scripts/verify_test_engineering_eval.rb \
  (with RUBY_AGENT_EVAL_FILE=evals/test-engineering/rspec-request-contract.yml
   and workspace = benchmarks/test-engineering/fixtures/rspec-request-contract/)

# Expected: functional=fail (controller_spec, no shared examples, no block matchers),
#           contract=fail (no 201, no 422, no count assertion),
#           tests=pass (file parses, has expect),
#           scope_control=fail (allow_any_instance_of detected).

# Reference solution: should pass all four checks
# (workspace = benchmarks/test-engineering/references/rspec-request-contract/)
```

`bundle exec rubocop --only RSpec` on the audited spec file should produce zero offenses after applying the patterns listed in the mapping table.

## Review checklist

- [ ] `.rubocop.yml` loads `rubocop-rspec` and configures the cops listed in the mapping table
- [ ] `spec/spec_helper.rb` configures `expect_with :rspec` (forbids `should`)
- [ ] `spec/rails_helper.rb` loads `spec/support/**/*.rb` deterministically
- [ ] No `type: :controller` specs remain in the suite (betterspecs #14)
- [ ] No `allow_any_instance_of` / `expect_any_instance_of` (betterspecs #9)
- [ ] No `should` / `should_not` syntax (betterspecs #6, #15)
- [ ] No `@instance_variable` in specs (betterspecs #8)
- [ ] Shared examples exist only for repeated contracts (betterspecs #13)
- [ ] Block-form matchers used for `have_enqueued_job` / `have_enqueued_mail` (betterspecs #12)
- [ ] Decision documented for out-of-scope rules (#16 Guard, #17 Spring, #19 fuubar)

## Related skills

rails-test-engineering,ruby-tdd-refactoring,rubocop
