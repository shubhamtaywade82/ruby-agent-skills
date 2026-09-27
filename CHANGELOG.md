# Changelog

## Iteration 130 — RuboCop in CI and Executable Scripts

- Run `bundle exec rubocop` in the `Validate skills` workflow. A `Gemfile` (lint group only: `rubocop ~> 1.90`, `rubocop-performance`, `rubocop-minitest`, `rubocop-rspec`, `rubocop-thread_safety`) and lockfile pin the toolchain; the skill library, validators, and harness still use only the Ruby standard library.
- Replace the previous `.rubocop.yml`, which could not load: it listed the whole target-application plugin catalog, including three extensions that are not `lint_roller` plugins, `cookstyle` (which replaces RuboCop's defaults with Chef's), `rubocop-changed`, and framework plugins this repository does not use. The catalog stays documented in `data/rubocop/plugins.yml` and `docs/RUBOCOP_PLUGINS.md`. `benchmarks/` is excluded because fixtures and references are digest-pinned measurement infrastructure.
- Apply whitespace-only layout autocorrections (plus leading-dot method chains) to the repository's own Ruby; line length, trailing whitespace inside heredocs, and heredoc indentation are left alone. The remaining 2,686 pre-existing offenses across 90 cops are recorded in `.rubocop_todo.yml`, so CI fails only on new offenses.
- Set the executable bit on the 70 tracked scripts with a shebang that lacked it (39 in `bin/`, 30 in `scripts/`, 1 in `adapters/`).
- `CONTRIBUTING.md` and the README validation section describe the lint step.

## Iteration 129 — Code Examples for Every Skill and Pattern

- Add a fenced `## Example` to the 421 patterns that had none (324 Ruby, 20 TSX, 9 TypeScript, 4 JavaScript, 11 ERB, 24 Bash, 6 YAML, 1 SQL, and 22 Markdown runbook/decision tables); the other 11 patterns already carried code. Examples use real Rails, Ruby, React, and TypeScript APIs and were syntax-checked before insertion (`ruby -c`, ERB compiled inside a method, `bash -n`, `node --check`, and `tsc --strict` or vitest with jsdom for TypeScript and React).
- Add a `## Reference example` to the 15 skills without one (React, TypeScript, and stack-minimality families), and replace the `...` placeholder in `ruby-method-design`.
- `scripts/audit_corpus_quality.rb` recognizes `~~~` fences and now fails when any skill or pattern lacks a code example, so coverage cannot regress.

## Iteration 128 — Merge Duplicate Rails Skills

- Merge six overlapping skills into the deeper skill that owns the same framework boundary: `rails-activerecord` → `rails-active-record`, `rails-controllers` → `rails-action-controller`, `rails-views` → `rails-action-view`, `rails-testing` → `rails-test-engineering`, `rails-best-practices` → `rails-architecture`, `rails-deployment` → `rails-release-engineering`. Each survivor gains the retired skill's guidance under one scoped section, its triggers, and a description clause; every manifest, router, pattern, evaluation, and documentation reference is rewritten and de-duplicated. 91 → 85 skills.
- Keep `rails-security` and `rails-security-engineering` separate: they own different layers (code-level controls versus architecture-level threat modeling) and are each routed independently.
- Record retirements under `retired_skills` in `skill-manifest.yml`; the installer reports the replacement when an upgrade removes a retired skill, covered by a new installer system test. `docs/INSTALLATION.md` lists the mapping.

## Iteration 127 — Slim Always-Loaded Agent Contract

- Cut `AGENTS.md` from 858 lines (74 KB) to 137 lines (9.5 KB). It now holds only the repository-wide operating contract (sequence, context, routing, design, precedence, verification, skill-pack and benchmark integrity, and repository-maintenance rules).
- Move the 42 domain "changes" sections verbatim into their owning skills (for example `skills/rails-action-cable/SKILL.md` → `## Rails Action Cable changes`), so they load only when the skill is routed. Every non-blank line of the previous file appears verbatim in the new file or a skill.
- Point the 33 system tests that pinned those rules at the owning skill instead of `AGENTS.md`.
- The documentation consistency audit enforces a 150-line budget for `AGENTS.md` and rejects domain change sections there.

## Iteration 126 — Ruby-Workshop Verifier Fixes, References, and Full Positive-Control Coverage

- `verify_workshop_eval.rb` crashed instead of failing on unimplemented skeletons (`NotImplementedError` is a `ScriptError`, outside its `rescue StandardError`), and `rails-rest-contract` reported a missing strong-parameter boundary as the status string `strong_parameter_contract_missing`, which never counted as a failure. Both fixed.
- The `service-object` scaffold's `ApplicationService.call(*args)` could not forward keyword arguments under Ruby 3, so `Post::Creator.call(user, status_text:)` raised for every implementation; it now uses `call(...)`.
- Add references with tests for all 8 workshop fixtures, including a warning-free gemspec build for `ruby-gem-boundary`; the registry lists the gemspec and routes as part of those implementation seams.
- Every non-exempt fixture across all 13 campaigns now has a reference. `test/benchmark_fixture_controls_system_test.rb` enforces that coverage and runs each reference's own tests against it.
- Bump the ruby-workshop campaign version.

## Iteration 125 — Ruby-Training Verifier Fixes and References

- `triplet-sum` could never pass: the verifier read `target` from the case instead of `input.target` (`KeyError` on every run), demanded one specific triplet although the evaluation grades "a valid target-sum triplet", and had no `auxiliary_space` heuristic, so the check was always `not_evaluated`. It now accepts any ascending sub-multiset that sums to the target and recognizes an in-place sort with two pointers and no auxiliary collections.
- A missing class or method is now a recorded `functional` failure with evidence instead of an uncaught verifier crash, and `edge_cases` no longer passes when `functional` failed.
- The `chocolate-feast` `exact-threshold` case (`wrappers: 1`, expected 2) was undefined under the evaluation's own rule: at one wrapper per chocolate the exchange never terminates. It is replaced by a well-defined exact-threshold case (4, 2, 2 → 3); the reference rejects thresholds below 2.
- Add reference implementations with tests generated from each evaluation's public cases for all 9 fixtures.
- Bump the ruby-training campaign version.

## Iteration 124 — Security Verifier Fix and References

- The `parameterized-query-boundary` security check flagged any `#{term` inside `where(...)`, including the parameterized form the functional check requires (`where("name ILIKE ?", "%#{term}%")`), so the correct solution failed. It now flags interpolation inside the SQL string literal, which is the injection.
- Both security fixtures shipped their solution. Workspaces now start from SQL-string interpolation and an any-signed-in-user policy; references with owner/admin/unrelated/missing-user and hostile-term tests move to `benchmarks/security/references/`.
- Bump the security campaign version.

## Iteration 123 — Performance Benchmark References

- Both performance fixtures shipped their solution and failed a no-op agent only on the "test changed" check. Workspaces now start from a chained `map … map` intermediate collection and a tenant-less cache key; references (one-pass labels with an allocation test; a versioned, integer-validated tenant/dashboard key whose components cannot be forged) move to `benchmarks/performance/references/`.
- Bump the performance campaign version.

## Iteration 122 — Concurrency Benchmark Reference

- The `concurrency-counter` fixture shipped a mutex-synchronized counter and passed everything except the "test changed" check under a no-op agent. The workspace now starts from an unsynchronized read-modify-write that loses updates; the synchronized counter and its tests move to `benchmarks/concurrency/references/`.
- Bump the concurrency campaign version.

## Iteration 121 — Observability Benchmark References

- Add reference implementations for the 3 observability fixtures with unsolved starting states: a narrow `InvalidOrderState` → 409 mapping that leaves other errors on the 5xx path, request-id log tags with authorization filtering, and a minimal `checkout.completed` notification. `health-semantics` remains a declared review/preserve task.

## Iteration 120 — Active Job Benchmark References

- Add reference implementations for all 4 Active Job fixtures: a claim-before-side-effect idempotent delivery, bounded `retry_on` for transient timeouts with `discard_on` for invalid state, `enqueue_after_transaction_commit`, and per-account `limits_concurrency`. The fixtures already started from genuine unsolved states.

## Iteration 119 — Zeitwerk Verifier Repair and References

- Repair `scripts/verify_zeitwerk_eval.rb`: backspace bytes in place of `\b` and stripped escapes (`/modules+Paymentss*…/`, `/ApiGateway.endpoints*=…/`) meant the namespace, reload, and eager-require checks never matched real code.
- Both fixtures shipped the finished change. Workspaces now start from a path/constant mismatch (`PaymentProcessor` in `payments/processor.rb`) and a one-time initializer that requires and configures the reloadable class at boot; finished versions, including the tests the prompts require, move to `benchmarks/zeitwerk/references/`.
- References may include `test/` or `spec/` files when the evaluation requires the agent to write tests; the benchmark-quality audit and fixture schema document this.
- Bump the zeitwerk campaign version.

## Iteration 118 — Test-Engineering Verifier Repair and References

- Repair `scripts/verify_test_engineering_eval.rb`, which did not parse (stripped escapes, backspace bytes); every run of the campaign failed regardless of the submission.
- Make the campaign winnable and honest. The `tests` check ran every `*_test.rb` with plain `ruby`, but these are Rails tests and the fixtures contain no Rails application, so it could never pass. It is now explicitly static: every Ruby file under `test/` must parse and at least one test must assert something; behavioural judgement stays in the evaluation-specific checks.
- Remove the fixtures' meta-tests. They duplicated verifier logic, were agent-editable, two read files from the wrong directory, and their own source text (`"OrdersController"`/`"get :"`, `rescue.*retry`) made the verifier report a direct-controller test or a retry workaround in every submission.
- `parallel-safety` and `test-performance` inspected `*_test.rb` bodies for problems that live in `test/test_helper.rb`, so they could never detect them; both now inspect the helper. `boundary-selection` matches per file instead of across concatenated files.
- Workspaces now start from the problem each prompt describes (direct controller test, sleep plus direct `perform`, fixed port and shared global array, global state with a retry loop, calculation-coupled system test, eager helper glob with a deep factory); finished versions move to `benchmarks/test-engineering/references/`. Every fixture has an assertion-bearing test file.
- Bump the test-engineering campaign version.

## Iteration 117 — Production-Runtime Verifier Repair and References

- Repair `scripts/verify_production_runtime_eval.rb`, which did not parse: stripped escapes (`/putss+ENV[|ps+ENV[/`) and `\b` turned into backspace bytes. The whole campaign failed every run regardless of the submission.
- `graceful-shutdown`: the contract rejected `exec .* puma .* &`, which every trap-and-forward entrypoint (the pattern `functional` requires) contains, including the shipped solution. The contract now rejects what the prompt forbids: an ignored TERM (`trap '' TERM`) or a contradictory `exec … &` line.
- `puma-capacity`: the verifier only checked that `workers`/`threads` appeared, so any configuration passed. It now reads the `WEB_CONCURRENCY`/`RAILS_MAX_THREADS` defaults and enforces the prompt's budget (workers ≤ 4 cores, threads ≤ database pool of 12).
- All 5 fixtures shipped the finished change and passed under a no-op agent once the verifier ran. Workspaces now start from over-budget Puma settings, a TERM-swallowing entrypoint, destructive-first release ordering, secret-printing boot configuration, and a rollback-assuming migration plan; the finished changes move to `benchmarks/production-runtime/references/`.
- Bump the production-runtime campaign version.

## Iteration 116 — Database-Engineering Verifier Repair and References

- Repair `scripts/verify_database_engineering_eval.rb`: its regexes had lost every backslash (e.g. `/add_columns+:customers,s*:display_name/`, `/BATCH_SIZEs*=s*d+/`), so they required literal text that real migrations never contain and every submission failed. Reconstructions match the patterns preserved in the fixtures' own tests.
- With a working verifier, all 5 fixtures passed under a no-op agent because they shipped the finished change. Their workspaces now start from the unsafe version each prompt warns against (destructive expand migration, non-concurrent index, non-unique composite index, unbounded `User.all.each`, unlocked check-then-decrement); the finished changes move to `benchmarks/database-engineering/references/`.
- Bump the database-engineering campaign version.

## Iteration 115 — Design-Pattern Benchmark Reference Solutions

- Add known-good reference implementations for the 14 design-pattern campaign fixtures that lacked one (PORO extraction, service/command objects, adapter, policy, dependency injection, factory, builder, null object, decorator, facade, specification, presenter, pattern restraint). All 24 design-pattern fixtures now have a positive control that passes its verifier.

## Iteration 114 — Rails Benchmark Reference Solutions

- Add known-good reference implementations for the 12 Rails campaign fixtures that lacked one (action-controller, active-storage, associations, authentication, authorization, cross-boundary authorization, encryption/credentials, hotwire, rack middleware, routing, serialization/Global ID, validations). All 27 Rails fixtures now have a positive control that passes its verifier.
- Fix a contradictory assertion in the `validations-contract` fixture test: it required a token already taken in tenant 11 to be available in tenant 11, so no correct implementation could pass. The test now requires tenant-scoped uniqueness in both directions (including `except_id`).
- Add `validations-contract` tests for the shared validation rule across models and bounded associated validation; previously the unmodified fixture passed every behavioural test and failed only a source regex.
- Bump the Rails campaign version to 5.

## Iteration 113 — Benchmark Fixture Controls

- Add `RubyAgentSkills::FixtureRegistry` and resolve campaign fixtures through each `fixtures.yml` registry in both `bin/benchmark campaign` and `scripts/audit_benchmark_quality.rb`. Previously the runner ignored registry `root` overrides, so 9 of 27 Rails campaign evaluations aborted with `fixture not found` while the audit passed.
- Abort a campaign before any agent run when an evaluation does not resolve to a fixture.
- Remove shipped answers from 24 fixtures (14 Rails, 10 design-patterns) that passed their verifier with a no-op agent. Their workspaces now hold skeletons (`NotImplementedError` bodies) or, for the two refactor tasks, the pre-refactor code; the prior implementations move to `benchmarks/<set>/references/<id>/` outside the agent workspace.
- Declare `observability/health-semantics` as `noop_expected: pass` with a rationale: it is a review/preserve task where no change is correct.
- Add `test/benchmark_fixture_controls_system_test.rb`: every campaign fixture must fail under a no-op agent unless declared otherwise, and every reference must pass its verifier. Register it in `bin/validate`.
- Extend the benchmark-quality audit to reject references inside agent workspaces, references carrying non-implementation files, orphaned references, and undeclared no-op exemptions.
- Grade Rails and design-patterns `functional` checks with the fixture's original test file (`RubyAgentSkills::FixtureTestRun`) instead of the agent-editable workspace copy; the agent's own tests count only toward `tests`. Covered by a tamper control across all 51 affected evaluations.
- Fix five broken source-evidence regexes in `benchmarks/rails/fixtures.yml`: four forbidden patterns (including the `redirect_to params` open-redirect guard) were double-escaped in single-quoted YAML and never matched, and `sleep(` did not compile, failing `rails-initialization-configuration-contract` for every submission while masking that its fixture shipped a passing implementation (now a skeleton with a reference). The audit now rejects non-compiling and double-escaped regexes.
- Fix verifier failure evidence being dropped: `String#[-n, n]` returns nil for output shorter than `n`.
- Stop passing `RUBY_AGENT_EVAL_ROOT` to the agent process (verifier only) and delete any agent-written verifier result before verification. This removes a documented adapter variable; no in-repository adapter used it.
- Bump the Rails (4) and design-patterns (3) campaign versions and record per-evaluation `fixture_sha256` plus aggregate `fixtures_sha256` in campaign results so runs against different starting states are not silently compared. Document public-benchmark exposure as accepted residual risk.

## Iteration 112 — Release File-Level Provenance & Publication Gate

- Record `protocol_version` and file-level SHA-256/byte-size provenance for every shipped file in `RELEASE.json`, computed from the staged archive tree.
- Extend `scripts/verify_release_archive.rb` with pre-extraction tar listing safety (regular files/directories only, no absolute or parent-traversal names), protocol-version enforcement, file-record containment, and `--check-files` verification of every file's size/digest plus rejection of unrecorded shipped files.
- Gate the tag-triggered release workflow on `verify_release_archive.rb --checksums dist/SHA256SUMS --check-files` before `gh release create`.
- Extend release verification regression coverage to tampered file content, injected unrecorded files, unknown protocol versions, escaping file records, symlink entries, and the workflow publication gate.

## Iteration 111 — Corpus Quality & Benchmark Coverage

- Add `scripts/audit_corpus_quality.rb` with exact corpus measurements for skill examples, executable examples, pattern implementation anchors, failure/testing guidance, evaluation case integrity, grading depth, benchmark coverage, routing trigger collisions, and stale manifest paths.
- Register the corpus-quality audit and system test in `bin/validate`.
- Replace the ambiguous public-evaluation benchmark warning with an explicit coverage contract: campaign-backed evaluations are empirical; the 13 stack-minimality and 9 React/TypeScript evaluation files are declared `coverage: static-only`.
- Extend benchmark-quality tests to enforce the 22-file static-only classification.
- Make release archive system-test inventory expectations derive from `skill-manifest.yml` rather than hard-coded counts.

## Iteration 110 — Multi-Region Data Boundary Pattern

- Add the `multi-region-data-boundary` implementation pattern: region routing, authoritative write ownership, data-residency enforcement at the storage layer, replication lag budgets, fenced failover with stated RPO/RTO, and conflict handling for the failover window.
- Wire the pattern into the `rails-distributed-systems` skill (design guidance, review checklist, and anti-pattern), the skill manifest (registry path plus multi-region/data-residency/region-failover triggers), and the router pattern-selection matrix.
- Correct the README validation-suite prose summary to the actual system/contract test count (82), closing a prose-only drift the inventory table guard could not see.

## Iteration 109 — Release Documentation Polish

- Deduplicate the repeated Iteration 95–97 sections in the README and restore a single ordered iteration narrative (92–104) including the previously orphaned Iteration 98 entry.
- Refresh the README "Current implementation status" section to the current milestone, including the release infrastructure: reproducible checksummed archives, offline installation, the tag-triggered release workflow, and published GitHub releases.
- Add a README quick start with the direct release-archive download, git checkout, and installation verification commands; link the Installation section to the releases page.

## Iteration 106 — Independent Release Archive Verification

- Add a standalone release archive verifier independent of the archive builder's self-test.
- Verify release metadata, skill/pattern inventory, required agent-facing paths, archive safety, and optional published SHA-256 checksums.
- Add regression coverage and wire the verifier into `bin/validate`.

## Iteration 105 — Release Infrastructure

- Add `scripts/build_release_archive.rb`: deterministic, reproducible release archive with embedded `RELEASE.json` provenance, SHA-256 checksums, and generated release notes.
- Extend `bin/install` with offline archive support: a plain local directory (an extracted release archive) installs directly without git, recording release provenance; the installer also self-detects when it runs from an extracted archive or a repository checkout.
- Add `.github/workflows/release.yml`: tag-triggered release CI that validates, builds, self-tests, checks reproducibility, and publishes the GitHub Release with archive and checksums.
- Add `test/release_archive_system_test.rb` covering archive contents, provenance, offline install, verification, and reproducibility.
- Add `RELEASE.md` documenting the release definition and process; document offline archive installs in `docs/INSTALLATION.md` and `README.md`.

## Iteration 104 — Verified Routing History Boundary

- Reject history entries whose archive paths resolve outside the declared archive root.
- Record archive-manifest SHA-256 provenance for every indexed archive.
- Add an aggregate archive-set SHA-256 to generated history and verify it during replay.
- Add regression coverage for archive-root escape and provenance requirements.

## Iteration 103 — Release Bundle Component Provenance

- Bind bundled public evidence to its archive manifest by source-evidence hash and shared campaign/repository/agent identity.
- Require optional matrix evidence to match the public campaign and repository revision.
- Add regression coverage for release component identity binding.

## Iteration 102 — Documentation Consistency Contract

- Add a deterministic documentation audit covering README, implementation handoff, changelog milestone, filesystem inventory, and manifest identity.
- Make `bin/validate` enforce documentation consistency before release readiness.
- Synchronize current inventory and implementation-status documentation with the verified Iteration 101 repository state.

## Iteration 101 — Verified Routing History

- Add `routing-history --verify` for integrity-gated longitudinal history generation.
- Validate every indexed archive against its independent archive verifier and manifest identity.
- Keep historical model reporting descriptive-only.
