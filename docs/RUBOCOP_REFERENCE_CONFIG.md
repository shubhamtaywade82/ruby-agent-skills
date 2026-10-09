# RuboCop Reference Configuration for Target Rails Applications

This document accompanies `data/rubocop/reference-config.yml`, a version-parameterized `.rubocop.yml` template for Rails applications that adopt this pack's lint policy.

It is the consumable form of three sources this repository already owns:

- `data/rubocop/plugins.yml` — the plugin catalog and selection rules
- `docs/RUBOCOP_PLUGINS.md` — loading model and applicability
- `skills/rails-test-engineering/references/rspec.md` — the RSpec rules these settings make executable

The repository's own `.rubocop.yml` remains minimal and is **not** this template. It lints this pack (no Rails app, no lintable specs) and loads only four plugins on applicability grounds. Do not conflate the two.

## Why a template and not a fixed config

Two settings are version-sensitive and must come from the consuming application, not from this repository:

- `AllCops/TargetRubyVersion` — from `.ruby-version`
- `AllCops/TargetRailsVersion` — from `Gemfile.lock`

Pin them explicitly for a reproducible baseline. `rubocop-rails` can resolve the Rails version from the lockfile, but an explicit value takes precedence and is the standardized choice here.

## Substitution procedure

1. Resolve the Ruby version: `cat .ruby-version`
2. Resolve the Rails version: `bundle show rails | sed 's/.*-rails-//'` or read `Gemfile.lock`
3. List real environments from `config/environments/*.rb`. Rails 7.1+ names the development environment `local`; older targets use `development`.
4. Replace `__TARGET_RUBY_VERSION__`, `__TARGET_RAILS_VERSION__`, `__KNOWN_ENVIRONMENTS__` in the template.
5. Uncomment only the optional plugin blocks whose gems are in the Gemfile.
6. Write the result as `.rubocop.yml`.

## Version-gate decision table

The gates below are the version-sensitive behaviors that change which cops activate or how they resolve. Verify each against the installed extension rather than trusting this table blind — run `bundle exec rubocop --show-cops` after substitution and confirm no cop reports an unexpected `Enabled by default: pending` state.

| Condition | Effect | Source |
|---|---|---|
| RuboCop < 1.72 | `plugins:` directive unavailable; use `require:` | RuboCop docs, Plugins |
| rubocop-rails < 2.30 | rubocop-rails is not pluginfied; load via `require:` | rubocop-rails 2.30.0 changelog |
| rubocop-rails < 2.37 | Lazy cop loading unavailable; requires RuboCop 1.89+ | rubocop-rails 2.37.0 changelog |
| rubocop-rails 2.38+ | `AllCops/TargetRailsVersion` resolved by rubocop-rails, not core; explicit value beats lockfile | rubocop-rails 2.38.0 changelog |
| RuboCop 2.0 (future) | `TargetRailsVersion` removed from core; owned by rubocop-rails | rubocop-rails 2.38.0 changelog |
| Rails < 7.1 | `Rails/UnknownEnv` does not know `local`; list `development` | rubocop-rails 2.22.0 changelog |
| Rails >= 7.1 | `local` is a valid environment; add it to `Rails/UnknownEnv` | rubocop-rails 2.22.0 changelog |
| Rails >= 7.2 | `Rails/TransactionExitStatement` disabled by default | rubocop-rails 2.27.0 changelog |
| Rails >= 7.2 | Test queue adapter defaults to `:test`; affects enqueue-matchers, not a cop | `skills/rails-test-engineering/references/rspec.md` |
| Rails < 6.1 | `Rails/CompactBlank` gated off (requires 6.1) | rubocop-rails 2.38 cop docs |
| Rails < 5.1 | `Rails/ContentTag` gated off (requires 5.1) | rubocop-rails 2.38 cop docs |
| Rails < 5.0 | `Rails/ApplicationRecord`, `ApplicationJob`, `ApplicationMailer`, `ActionControllerTestCase`, `BelongsTo` gated off (require 5.0) | rubocop-rails 2.38 cop docs |
| Any target, cop gated on `minimum_target_rails_version` | An explicitly configured `TargetRailsVersion` now enables these cops even without a lockfile | rubocop-rails 2.38.0 changelog |
| `AllCops/MigratedSchemaVersion` | Version-gated Rails cops can be scoped to the schema version actually migrated to, not just the framework version | rubocop-rails 2.28.0 changelog |

`Rails/ActionFilter` is deprecated (rubocop-rails 2.22) and will be removed in rubocop-rails 3.0; it is disabled by default and should not be configured.

## Gemfile companion

```ruby
group :development, :test do
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

# Add only what the application actually uses:
# gem "rubocop-rspec_rails", require: false
# gem "rubocop-factory_bot", require: false
# gem "rubocop-capybara", require: false
# gem "rubocop-minitest",   require: false
# gem "rubocop-rake",       require: false
# gem "rubocop-i18n",       require: false
```

Pin the versions the baseline was validated against. `rubocop-rails` 2.37+ requires RuboCop 1.89+.

## Baseline and todo

Never auto-correct a mature codebase into compliance in one pass. Generate the baseline, then let CI fail only on new offenses:

```bash
bundle exec rubocop --auto-gen-config
bundle exec rubocop --auto-gen-limit-exclusion
```

The template inherits `.rubocop_todo.yml` by default. Keep it shrinking; each entry is a consciously deferred fix, not a permanent exemption.

## CI companion

```yaml
name: lint
on: [push, pull_request]
jobs:
  rubocop:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"   # match the application
          bundler-cache: true
      - run: bundle exec rubocop --format github
```

Run RuboCop in check mode only. Auto-correction belongs in the developer loop, never in CI.

## bin/lint companion

```bash
#!/usr/bin/env bash
set -euo pipefail
bundle exec rubocop -a            # safe autocorrect, then review the diff
bundle exec rubocop               # fail on anything remaining
```

Review the `-a` diff before committing; never mix bulk autocorrect with a behavior change.

## Alternative: omakase

`rubocop-rails-omakase` (Rails 7.2+ default) is a zero-configuration policy: opinionated, non-negotiable, no tuning surface. Choose it when the organization wants no lint debates. Choose this template when specific metrics must be governed (`Metrics/MethodLength`, `RSpec/MultipleExpectations`, `Rails/ReversibleMigration`) and version targets must be pinned explicitly. The two are alternatives, not layers — do not load both.

## Relationship to the RSpec consumer snippet

`skills/rails-test-engineering/references/rspec.md` carries a six-cop RSpec lint snippet that `test/test_engineering_system_test.rb` keeps identical to this repository's `.rubocop.yml`. The template's RSpec block is a superset of that snippet and preserves every one of its settings. If you change an RSpec cop in either place, change both, or that test's contract is violated.

## Important boundary

Cop findings are review signals, not architecture verdicts. `rails-architecture` owns controller/model responsibility, `rails-security` owns trust decisions, `stack-minimality-review` owns over-engineering. A green RuboCop run is not evidence of a correct design, and a red run is not automatically a defect.
