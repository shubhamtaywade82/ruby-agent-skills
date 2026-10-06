# Changelog

## Iteration 155 — Rails ↔ React Boundary and Deprecation Release Readiness

- Keep the Rails side of the Rails ↔ React seam in this pack and prepare the deprecated standalone React/TypeScript skills for removal in a release after v1.2.0. Nothing is deleted in this iteration.
- Move `rails-react-integration` to the `rails` family: its five patterns now live in `patterns/rails/` and its evaluation in `evals/rails-react-integration/` (version 2). Add a "Composing with react-agent-skills" section assigning each side of a full-stack change.
- Remove every dependency of retained content on a deprecated skill:
  - The integration skill, its patterns, six stack-minimality patterns, and five stack-minimality evaluations (each bumped one version) now point to `react-agent-skills / <skill>`, or drop the deprecated skill.
  - `router/ROUTING.md` maps the deprecated skills to their replacements.
  - Routing cases no longer expect a deprecated skill. The frontend-only `react-filter-render-performance` case is removed: routing campaign version 7, 25 cases, and stale case counts are corrected across the docs.
  - `test/react_agent_skills_deprecation_test.rb` enforces all of the above pack-wide.
- Add `relocated_skills:` to the manifest. `bin/install` removes a relocated skill from an existing installation and prints its destination pack. `scripts/validate_deprecations.rb` rejects relocated skills that are still registered or still deprecated in place.
- Release notes: `scripts/build_release_archive.rb` includes `docs/releases/<version>.md` when present. `docs/releases/v1.2.0.md` announces the deprecations and names every replacement, and a system test ties it to the manifest.
- `docs/REACT_AGENT_SKILLS_MIGRATION.md` records the status of each removal gate and a removal checklist. `docs/DEPRECATION_GOVERNANCE.md` documents the frontmatter and relocation rules. The README describes the retained and deprecated frontend skills.

## Iteration 154 — Review Remediation: Deprecation Visibility, Drift Detection, and Benchmark Honesty

- Framework drift detection was inert: every `match` in `framework-drift.yml` was double-escaped inside YAML single quotes, so no regex could match real code and the audit passed vacuously. Fix the escaping and quote values that YAML truncated at ` #`. Add a required `example` per entry that the validator must match, and a system test that the committed registry detects every entry's example.
- Add five drift entries verified against official release notes: Rails 5.1 controller `*_filter` callbacks and `render text:`/`nothing:`; Ruby 3.2 `Fixnum`/`Bignum`, `File.exists?`/`Dir.exists?`, and `taint`/`untaint`/`tainted?`. Findings now name the framework (Rails or Ruby) instead of always saying Rails.
- Make deprecation visible where agents select skills: the nine React/TypeScript `SKILL.md` descriptions now start with `DEPRECATED` and name their replacement. `scripts/validate_deprecations.rb` and `test/react_agent_skills_deprecation_test.rb` enforce this.
- RSpec lint scope: the RSpec reference now ships the consumer `rubocop-rspec` settings, kept identical to `.rubocop.yml` by a system test. `docs/RSPEC_STYLE_GUIDE.md` and `.rubocop.yml` now say that this repository has no lintable specs and that installation does not lint consuming projects.
- The test-engineering verifier's `scope_control` check now fails on any change outside `test/` or `spec/` (previously it always passed). Regression-tested against fixture and reference workspaces. `docs/BENCHMARK_QUALITY_AUDIT.md` now says that benchmark-measured does not mean executed: that campaign is graded statically.
- `bin/coding-agent-claude` and `bin/routing-agent-claude` require `CLAUDE_MODEL` instead of defaulting to `claude-sonnet-5`, which is neither a `claude` CLI alias nor a full model name. `docs/LOCAL_BENCHMARKING.md` passes the same value to `--model`.
- Make `ChangeVerifierRunnerTest#test_runner_normalizes_non_ascii_command_output` locale-independent. It used to fail under POSIX/US-ASCII locales because the child `ruby -e` source was non-ASCII.
- Not changed: no release was tagged; `v1.1.0` (Iteration 133) still trails `main`. Other verifier families keep the record-only `scope_control`, because their fixtures have no shared out-of-scope rule.

## Iteration 153 — RSpec Method Naming, Aggregate Failures, and HTTP Stubbing

- Add three Better Specs-derived rules to `skills/rails-test-engineering/references/rspec.md`: `#instance_method` / `.class_method` describe naming (and the narrow scope of `RSpec/DescribeMethod`), `:aggregate_failures` for expensive multi-assertion specs (and how `RSpec/MultipleExpectations` treats it), and WebMock/VCR HTTP stubbing with `disable_net_connect!(allow_localhost: true)` and cassette credential filtering.
- Keep the existing-convention rule: the reference does not prescribe factories over fixtures and does not add WebMock/VCR to suites that isolate HTTP another way.
- Add a regression assertion for the three rules to `test/test_engineering_system_test.rb`.

## Iteration 152 — Action Controller Resource-Loading Evidence

- Make resource-loading placement explicit in `rails-action-controller`: narrow `before_action` for shared request prerequisites, action-local lookup for one-off access when clearer, and memoized readers only as a lazy-access option.
- Explicitly reject the unsupported claim that `@resource ||= ...` is inherently faster than `before_action`; performance claims require representative workload evidence.
- Add the resource-loading policy and memoization evidence cases to the Action Controller evaluation and system-test coverage.
- Record the evidence boundary between repository-authored Rails rules and the uploaded historical training/assessment material.

## Iteration 151 — Benchmark Documentation and Reconciliation Audit

- Record the closed `#80` reconciliation explicitly: all 43 paths touched by the stale branch are present in current `main`; 31 are byte-identical and the remaining 12 have current-main equivalents that supersede the stale versions.
- Correct the controlled benchmark documentation to match the current corpus: the Rails campaign covers all 28 public Rails evaluations / 268 cases.
- Document the dedicated `ruby-toolchain` and `ruby-gem-development` three-repetition paired campaigns and distinguish benchmark infrastructure integrity from actual external-agent model evidence.
- Add CI smoke coverage that executes both foundation campaign manifests through the real benchmark runner for all three paired repetitions using a no-op agent, proving campaign completion without fabricating model-quality results.


## Iteration 150 — Hardening Reconciliation and Ruby Platform Benchmark Coverage

- Reconcile the still-missing Iterations 144–148 validation hardening onto the Iteration 149 release line instead of merging the stale #80 branch wholesale.
- Restore Agent Skills frontmatter validation, runtime compatibility enforcement, deprecation governance, executable framework-drift detection, validation-gate integrity preflight, and their release/install integrity surfaces.
- Add validator-aligned `ruby-toolchain` and `ruby-gem-development` benchmark families with independent pristine references and verifier coverage.
- Promote both foundation evaluations from static-only to controlled benchmark-backed coverage; no model-quality result is claimed until an external campaign is actually executed.
- Update inventories, routing/evaluation provenance, documentation, and release surfaces.

## Iteration 149 — Ruby and Rails Platform Foundations

- Add `ruby-toolchain` for Ruby version-manager/toolchain selection, RubyGems/Bundler setup, executable provenance, PATH/GEM_HOME diagnostics, dependency installation, and native-extension failure diagnosis.
- Add `rails-application-bootstrap` for `rails new`, standard monolith versus API-only shape, database/frontend/build choices, version-aware generator help, templates, skip/force safety, and post-bootstrap verification. In-app `bin/rails generate` remains owned by `rails-generators`.
- Add `ruby-gem-development` for `bundle gem`, gemspec/package contracts, namespaces/load paths, runtime versus development dependencies, executables, `.gem` build/inspection, isolated installation, and release authorization.
- Add three deterministic evaluations and adversarial routing cases for the new boundaries; update manifest, source coverage, README inventory, and validation registration.
- CI policy: no workflow relaxation or skipped validation was introduced; new coverage is wired into the existing repository validation path.

## Iteration 148 — Validation Gate Integrity Preflight

- Add `test/validation_gate_integrity_system_test.rb` to verify that `bin/validate` initializes its repository root before use, keeps repository paths root-qualified, and retains the framework-drift audit/test.
- Run the integrity test as an independent CI step before `bash bin/validate`, so validation-gate truncation or path corruption cannot silently disable later checks.

## Iteration 147 — Executable Framework Drift Detection

- Add a bounded, machine-readable Rails framework-drift registry and executable scanner for Ruby code fences, with explicit in-block suppressions and official source references.
- Register and enforce the detector through `skill-manifest.yml`, `bin/validate`, repository completeness, and system tests.

## Iteration 146 — Deprecation Governance

- Add explicit migration-state governance for deprecated React/TypeScript skills, with evidence-backed replacement paths and exactly five removal gates per entry.
- Validate the registry and prevent duplicate replacement ownership.

## Iteration 145 — Executable Runtime Compatibility Gate

- Add `RubyAgentSkills::VersionConstraint` using RubyGems requirement semantics and enforce explicit compatibility constraints for selected skills and patterns.
- Add `bin/skill-pack-compatibility`, runtime-profile propagation in evaluations, and three Rails 8.1 version-bound patterns without claiming model-quality improvement.

## Iteration 144 — Agent Skills Frontmatter Contract Validation

- Enforce the Agent Skills frontmatter contract for `name`, `description`, `compatibility`, `metadata`, `license`, and `allowed-tools`, including deterministic length/type/name checks.
- Add system coverage and bind campaign cardinality documentation/tests to the configured routing campaign.

## Iteration 143 — Consumer-Side Change Verification

- Add `bin/verify-change` (`RubyAgentSkills::ChangeVerifier`): verifies a change in a downstream Ruby/Rails project and writes a JSON (or Markdown) evidence report. `bin/validate` validates this pack; nothing verified a consuming project's change, so an agent's "done" could not be checked.
- Nine checks: `runtime_profile`, `dependency_lock_sync`, `migration_integrity`, `test_presence`, `rubocop` (changed files only), `tests` (rspec, `bin/rails test`, or `--test-command`), `brakeman`, `bundler_audit`, `zeitwerk`. Tools resolve from the project's bundle or `PATH`; a missing tool is `skipped`, never `pass`.
- Overall status is `pass`, `fail`, or `incomplete`. Exit codes: 0, 1 (failed check), 2 (usage), 3 (`incomplete` under `--strict`).
- Change detection from git (working tree versus `HEAD`, optionally `--base REF`), or an explicit `--files` list. The report records HEAD, branch, dirty state, per-check command, exit code, duration, and output tail (`--no-output` omits tails).
- Commands run as argv arrays with no shell, a per-check timeout that kills the process group, and a stripped Bundler environment. Changed paths are passed to RuboCop after `--`.
- `contract_pointers` names the owning skills whose change contract applies to the changed paths; it is a routing hint and does not verify adherence. A test asserts every pointed-at skill exists.
- `bin/install` and the release archive ship the tool and its two library files; `bin/skill-pack-verify` hash-checks them. `skill-manifest.yml` registers `installation.change_verifier`.
- Add `docs/VERIFY_CHANGE.md` (usage, checks, statuses, report schema, CI and agent wiring, limits) and `test/change_verifier_system_test.rb` (91 → 92 system tests).
- Not done: no measured effect on agent behavior is claimed, frontend code is not verified, and the `tests` check always runs the full suite (ceiling recorded in the docs).

## Iteration 142 — Training-Corpus Review Heuristics, Regression-Surface Planning, and Two New Algorithm Benchmarks

- Fold reviewer heuristics from a personal Ruby/Rails training corpus into the skills that already own that boundary, rather than a new parallel skill tree: `change-review`'s smell baseline gains four judgement-call smells (redundant context argument, control flow via exit/abort, validation glued to parsing, an unbounded concern) plus an explicit "argument count/method length/line length are heuristics, not hard rules — defer to the repository's own linter" note; `rails-test-engineering`'s RSpec reference gains the `let` vs `let!` distinction.
- `planning-spec` gains a regression-surface step: for each touched boundary, name its dependents (direct callers, indirect readers) and whether existing tests already cover them; an uncovered dependent goes in the spec's Notes as a gap, never an assumption. `ruby-debugging` already fully owned the corpus's bug-fix protocol (reproduce → hypothesize → instrument → fix → regression test), so no change was needed there.
- Add two new `ruby-training` algorithm benchmarks continuing the `allerin-ruby-set-*` corpus already partially covered by Set 2 (`selection-sort` and siblings): `bubble-sort` (Set 1) and `equilibrium-index` (Set 3), each with a fixture, a verified reference implementation, and wiring into `scripts/verify_training_eval.rb`, `benchmarks/ruby-training/{campaign,fixtures}.yml`, and `skill-manifest.yml` (128 → 130 evaluation files, 466 → 476 evaluation cases).

## Iteration 141 — Fix Ambiguous-Pattern False Positive for Dual-Registered Patterns

- Fix `RubyAgentSkills::SkillPack#resolve_pattern`: a pattern registered under two manifest families at once (the repository's intentional "testing" cross-listing, checked by `scripts/audit_repository_completeness.rb`) made every basename lookup for that pattern raise `ambiguous pattern`, because the candidate list was built from the flattened, non-deduplicated set of family paths. `bin/agent-benchmark` against `benchmarks/rails/campaign.yml` failed immediately with this error for `credentials-testing-contract`, which is registered under both `rails` and `testing`.
- The fix deduplicates the flattened path list before comparing candidates, so a pattern registered under several families resolves to the one file it names; a pattern whose basename is shared by two genuinely different files still raises `ambiguous pattern` as before.
- Add `test/skill_pack_dual_registered_pattern_system_test.rb` (89 → 90 system tests), verified to fail against the pre-fix code with the exact error reported, and to pass with the fix, without touching the existing ambiguous-basename regression test.

## Iteration 140 — Rails Data Modeling: Decision Framework, Worked Examples, and Cross-Skill Boundaries

- `rails-data-modeling` gains a 14-question **decision framework**. It runs from the business fact through identity, lifecycle, ownership, determinant, cardinality, optionality, uniqueness, normal form, history, the JSON boundary, the enforcing constraint, and the Rails representation, to the queries and write paths served. Unanswerable questions go to `planning-interview`.
- **Version-sensitive compatibility** section: use the modern API on current Rails; recognize historical APIs (finder option hashes, `update_attributes`, `set_table_name`, `set_primary_key`, observers, plugin composite keys) only to read and upgrade old code; never generate them in a modern application unless repository evidence requires it.
- **Data-model review procedure**: ten ordered steps from facts and normal form through identity, integrity, tenancy, flexible data, history, access paths, and evolution to the Rails mapping and version. Two new decision rules: design indexes from access paths, and treat existing data as part of the model.
- **New reference `aggregates-access-and-evolution.md`**: aggregate ownership (root-controlled mutation, transaction and lock scope), a Rails mapping matrix from relational decision to representation, query-driven index design, write-path analysis (creators, immutable and append-only rows, contention, bulk writers), counter caches and aggregates, and schema evolution (splitting facts, tightening integrity, changing hierarchies, renames).
- **New reference `worked-examples.md`**, six Rails 8.1 examples:
  1. commerce with `products.price_cents` versus `order_items.unit_price_cents` snapshots;
  2. SaaS multi-tenancy with memberships and a composite `[:account_id, :slug]` unique index;
  3. a field-by-field JSON-versus-relational table;
  4. UUID versus bigint as a per-table decision, including a public UUID beside a bigint key;
  5. a natural composite primary key with composite-foreign-key associations, versus a surrogate key with a composite unique index;
  6. a stored order total with source, update path, reconciliation job, and failure behavior, plus the counter-cache equivalent.

  The Ruby reference example moved from `SKILL.md` into these examples.
- **Rails documentation check**: the version-sensitive claims were compared against the Rails 8.1.4 guides and API documentation. These cover composite primary keys, composite `foreign_key:` arrays, `id: :uuid` defaulting to `gen_random_uuid()`, `create_enum` and `t.enum`, unique and exclusion constraints, stored virtual columns, `enum ... validate:`, and the Rails 8.0 removal of the keyword `enum` form. They also cover counter-cache limits and `reset_counters`, `dependent:` values, `delegated_type`, `add_check_constraint`, `add_foreign_key ... on_delete:`, and partial and concurrent indexes.
- **Cross-skill boundaries**, composed rather than duplicated:
  - `rails-active-record`: what is modeled versus how Active Record operates on it;
  - `rails-associations`: decide the relationship, express it in Rails, enforce it in the database;
  - `rails-database-engineering`: "Should this fact be a separate relation?" versus "How do I migrate it safely?";
  - `ruby-domain-modeling`: persisted shape versus Ruby objects and language.

  Each skill gains a boundary row or a short routing block.
- **Evaluation**: `data-modeling-contract` gains `json-boundary` and `key-choice` cases (464 → 466).
- **System test**: `test/rails_data_modeling_system_test.rb` checks the new sections, all six examples, and the four cross-skill boundaries. It still syntax-checks every Ruby example and rejects removed APIs in them.

## Iteration 139 — Rails Data Modeling

- Add the `rails-data-modeling` skill (92 → 93 skills). It decides what a Rails schema should represent before models or migrations are written, and sits above `rails-associations`, `rails-database-engineering`, and `rails-active-record`.
  - **Order of work:** business facts → entities and values → ownership and cardinality → keys and functional dependencies → 3NF by default → constraints → Rails mapping → access paths → deliberate denormalization → existing data.
  - **Invariants:** a database constraint, not an association or validation, guarantees integrity. `has_one` needs a unique index on its foreign key. Tenant-scoped business keys need composite unique indexes. JSON columns never hold values the application joins, filters, sorts, or constrains on. Historical snapshots are never "normalized away".
- Five references hold the detail:
  - `normalization-and-keys.md`: functional dependencies, 1NF through BCNF with Rails examples, update/insert/delete anomalies, and primary key strategies (bigint, UUID, composite, custom) with a decision rule;
  - `relationships-and-integrity.md`: foreign-key ownership, one-to-one, join models, `NULL` semantics, a constraint matrix pairing validations with database guarantees, and multi-tenant ownership;
  - `types-hierarchies-and-flexible-data.md`: STI, delegated types, separate tables, and composition; polymorphic trade-offs and alternatives that keep foreign keys; Rails enums versus check constraints versus PostgreSQL enum types; the JSON boundary; value-object mapping;
  - `history-and-denormalization.md`: snapshots, effective-dated and append-only history, soft deletion decisions with partial unique indexes, derived values, and the source/update/repair/failure rule for every denormalized value;
  - `legacy-schemas-and-api-drift.md`: legacy table mapping (`self.table_name`, `self.primary_key`, `ignored_columns`, `alias_attribute`, explicit keys), a table of removed or replaced APIs (finder option hashes, `find_all_by_*`, `update_attributes`, `set_table_name`, observers, the keyword `enum` form), and the Rails version each gated feature needs.
- The durable concepts of *Pro Active Record: Databases with Ruby and Rails* (Apress, 2007) are credited in the source foundation. Its API examples are not reused; the drift table lists their replacements. The book's text was not available in this repository, so version claims come from the Rails guides and release history, gated on the application's resolved Rails version.
- `rails-database-engineering` now points schema-design decisions to the new skill.
- **Routing:** a matrix row, a `Rails data modeling` composition, and one routing case (`schema-design-before-migration`). The public routing campaign moves to version 5: 23 cases × 3 repetitions = 69 runs; the release contract, routing docs, and pinned tests are updated. No empirical campaign evidence was recorded under version 4.
- **Evaluation and test:**
  - the static-only `data-modeling-contract` evaluation (4 cases; 460 → 464): snapshots, tenant uniqueness, plan history, and retirement. It lives in `evals/data-modeling/`, not `evals/rails/`, because the Rails benchmark campaign requires every evaluation there to have a benchmark fixture, and this one has none yet. The static-only classification test now covers that directory;
  - `test/rails_data_modeling_system_test.rb` (89 system tests), registered in `bin/validate`. It checks registration, routing, the key invariants, and the drift table, syntax-checks every Ruby example in the skill, and rejects removed APIs in those examples.

## Iteration 138 — Tracker-Neutral Planning Layer

- Add five `planning` skills (87 → 92 skills) that turn ideas into decisions and work items before code:
  - `planning-interview`: interviews the user in rounds over a design tree. Each round asks every question whose prerequisites are settled, each with a recommended answer. Facts come from the repository, never from the user, and nothing proceeds until the user confirms the summary. Glossary and decision records go through `ruby-domain-modeling`.
  - `planning-spec`: writes a discussed feature up as a spec without re-interviewing. It hands missing decisions back to `planning-interview`, requires agreed test seams, names each boundary's owning skill and its data impact (migrations, backfills, constraints), and publishes as a `kind: spec` item.
  - `planning-tickets`: slices a spec into vertical tracer-bullet tickets that fit one session, with prefactoring first, honest blocking edges, and expand–contract sequencing for wide refactors such as column renames. The user approves the breakdown before anything is published.
  - `planning-wayfinder`: charts an effort larger than one session as a map of typed decision items (`research`, `interview`, `prototype`, `task`) toward a named destination. It resolves one decision per session and keeps unclear questions in `Not yet specified` and ruled-out work in `Out of scope`.
  - `planning-tracker`: the shared, backend-neutral item model (`map`, `decision`, `spec`, `ticket`; open or closed; labels, parent, blocking edges, assignee) and its operations. Backend resolution order: the task's instruction, a `## Planning tracker` declaration in `AGENTS.md` or `CLAUDE.md`, an existing `docs/planning/` directory, then the user, with local Markdown as the fallback. `references/local-markdown.md` and `references/github.md` map every operation. GitHub writes need the user's confirmation unless the repository declaration authorizes them.
- Add `skills/planning-tracker/scripts/tracker.rb`, a standard-library Ruby script for local trackers:
  - `validate`: rejects bad front matter, id and file-name mismatches, unknown kinds or statuses, duplicate ids, missing parents or blockers, self-blocks, and blocking cycles;
  - `list`: filters items;
  - `frontier`: lists open, unclaimed, non-map items whose blockers are closed;
  - `next-id`: gives the next free id.

  It ships with the skill; the installer already hashes every skill file.
- Route the planning layer in `router/ROUTING.md`: five matrix rows, and a composition from wayfinder through interview, spec, tickets, and implementation to `change-review`. `agent-workflow` points to it before its implementation loop.
- Add two routing cases, `spec-then-tickets-not-wayfinder` and `multi-session-effort-needs-a-map`. The public routing campaign moves to version 4: 22 cases × 3 repetitions = 66 runs; `router/ROUTING_RELEASE.yml`, the routing docs, and the tests that pin the protocol are updated. No empirical campaign evidence was recorded under version 3.
- Add three static-only evaluations: `planning-spec-contract`, `planning-tickets-contract`, and `planning-wayfinder-contract`, with 3 cases each (451 → 460 cases).
- Add `test/planning_layer_system_test.rb` (88 system tests). It checks registration, routing, credit, and the evaluations, and runs `tracker.rb` against temporary trackers for the frontier, claims, parent filters, `next-id`, cycles, missing links, bad kinds, and id mismatches. Registered in `bin/validate`.
- The skills are adapted, in this repository's words and with Rails slices and schema expand–contract, from `grilling`, `grill-with-docs`, `to-spec`, `to-tickets`, and `wayfinder` in https://github.com/mattpocock/skills (MIT License, Copyright (c) 2026 Matt Pocock). That repository's tracker setup and labels are replaced by `planning-tracker`. Linear and Jira are not supported yet.

## Iteration 137 — Change Review and Adapted Engineering Disciplines

- Add the `change-review` skill (86 → 87 skills). It reviews the diff between `HEAD` and a pinned fixed point on two separate axes: **Standards** (the repository's documented standards, `.rubocop.yml`, and the `## <Domain> changes` contract of each owning skill) and **Spec** (missing, extra, or wrong behavior against the originating issue or spec). It never merges or re-ranks findings across the axes, reports code smells only as labelled judgement calls that a repository standard overrides, and cites tool runs only when observed. `references/smell-baseline.md` lists the baseline smells with Ruby signs and fixes, plus Rails checks that are hard findings because a skill change contract owns them. Triggers avoid `code review`, which stays with `ruby-clean-code`.
- Fold four disciplines into the skills that already own them, each through a new `references/` file so every `SKILL.md` stays within the size gate:
  - `ruby-debugging`: the loop now starts by building a feedback loop. Phase 1 is complete only with one command, already run, that is red-capable, deterministic, fast, and agent-runnable; then minimise, rank 3–5 falsifiable hypotheses, instrument one variable at a time with tagged `[DEBUG-…]` logs, fix at a seam that reproduces the real call pattern, and clean up. `references/feedback-loops.md` lists ten ways to build a loop in a Ruby/Rails repository; `references/reproduce-hypothesise-instrument.md` covers the middle phases and performance regressions.
  - `ruby-tdd-refactoring`: agree test seams before the first test, work in vertical slices, take expected values from an independent source, and double only at system boundaries. `references/test-quality.md` has Minitest examples of implementation-coupled and tautological tests and of designing for doubles. Refactoring stays inside the loop, on green.
  - `ruby-domain-modeling`: maintain a domain glossary (`CONTEXT.md`, `CONTEXT-MAP.md`) and decision records while designing, following existing repository conventions and proposing new files rather than creating them silently. `references/context-and-adrs.md` gives the formats and the three conditions for a decision record.
  - `ruby-api-design`: module depth, the deletion test, the interface as the test surface, and "one adapter is a hypothetical seam". `references/deep-modules.md` adds the vocabulary, four dependency categories mapped to Rails test stand-ins, replace-don't-layer testing, and designing an interface twice. "Boundary" remains an allowed word.
- `agent-workflow` gains an implementation loop (agreed seams, test-first slices, focused tests per slice, one full-suite run, `change-review` before commit). `stack-minimality-review` applies the deletion test and points to `change-review` for full reviews.
- Add `docs/WRITING_SKILLS.md`, a contributor guide to wording skills for agents (pointers, the two costs, placing material between `SKILL.md` and `references/`, completion criteria, words that carry behavior, pruning), linked from `docs/SKILL_CONTRACT.md` and `CONTRIBUTING.md`. It is documentation, not a shipped skill.
- Route `change-review` in `router/ROUTING.md` (matrix row and a composition) and add two routing cases separating it from `stack-minimality-review`. The public routing campaign moves to version 3: 20 cases × 3 repetitions = 60 runs; `router/ROUTING_RELEASE.yml`, the routing docs, and the tests that pin the protocol are updated. No empirical campaign evidence was recorded under version 2.
- Add the `change-review-contract` evaluation (4 cases, static-only; 447 → 451 cases) and `test/change_review_system_test.rb`, registered in `bin/validate` (86 → 87 system tests). Correct the stale evaluation-corpus figures in `docs/IMPLEMENTATION_HANDOFF.md`.
- The adapted material is rewritten in this repository's words with Ruby and Rails examples, not copied. Each adapted skill and the writing guide credit https://github.com/mattpocock/skills (MIT License, Copyright (c) 2026 Matt Pocock), and the system test checks the credit.

## Iteration 136 — Progressive Disclosure for Oversized Skills

- Split the 17 largest skills into an operating `SKILL.md` plus skill-local `references/*.md` files (85 in total) that load on demand: `rails-active-storage`, `rails-authentication`, `rails-i18n`, `rails-action-cable`, `rails-action-text`, `rails-action-mailbox`, `rails-test-engineering`, `rails-active-record`, `rails-reliability-engineering`, `rails-event-driven-messaging`, `rails-action-view`, `rails-performance`, `rails-distributed-systems`, `rails-action-controller`, `rails-validations`, `rails-active-job`, and `rails-associations`. Before the split, 15 exceeded the Agent Skills recommendation of 500 lines or about 5,000 tokens (`rails-authentication` was 785 lines, about 7,500 estimated tokens); `rails-active-job` (496 lines) and `rails-associations` (about 4,900 estimated tokens) were at the limit. After it, each `SKILL.md` is 193–281 lines and about 2,300–3,800 estimated tokens. No skill was added or removed, and routing is unchanged.
- Each split `SKILL.md` keeps purpose, activation, repository inspection, the domain change contract, review checklist, failure modes, verification, and sources. It gains `## Decision rules`, `## Critical invariants` (the safety rules from the moved sections, kept verbatim), and a `## References` table saying when to load each reference and which registered patterns to consult. Every other line of the original files moved unchanged into a reference, checked line by line. The only edits removed stale text left by the Iteration 128 merge: "deepens the foundational … skill" and "is the lighter entry point" self-references, and duplicated composition entries in five skills.
- `scripts/validate_skills.rb` now fails a `SKILL.md` over 500 lines or about 5,000 estimated tokens (bytes ÷ 4, reported as an estimate). It also fails a reference over 500 lines, a reference not directly under `references/`, a reference that links to another reference, a reference not linked from `SKILL.md`, a link to a missing reference, a skill with references but no `## References` section, an unregistered pattern in that table, and unexpected entries in a skill directory. Skills above the 350-line / about 3,500-token repository target are reported, not failed: 14 remain above it, 10 unsplit skills and 4 split skills (`rails-action-mailbox`, `rails-active-record`, `rails-authentication`, `rails-validations`) that exceed only the token target. The validator accepts `--root` for regression tests.
- Add `test/skill_size_policy_system_test.rb` (12 tests), registered in `bin/validate`. It runs the validator against mutated copies of the repository for each failure above.
- `bin/install` records a SHA-256 for every file in each skill directory, not only `SKILL.md`, and `bin/skill-pack-verify` fails on a missing, altered, or unrecorded skill file. New installer tests cover a tampered and an injected reference; they fail against the previous installer and verifier.
- `RubyAgentSkills::SkillPack#materialize` copies each selected skill's references into the benchmark workspace, records their paths and SHA-256 in the materialized `manifest.json`, and notes their location in `context.md`, so `SKILL.md` links resolve in skills-enabled runs. No benchmark campaign was run for this change.
- Document the layout and limits in `docs/SKILL_CONTRACT.md`, `README.md`, `AGENTS.md`, and `CONTRIBUTING.md`. System/contract tests: 85 → 86.

## Iteration 135 — RSpec coverage in rails-test-engineering

- Add an "RSpec" section to `rails-test-engineering`: detect the suite before writing tests, request specs over controller specs, block-form enqueue matchers on the default `:test` adapter, `errors.of_kind?` instead of `errors.added?`, verifying doubles, trait-based factories, and shared examples only for repeated contracts. No new skill; RSpec stays owned by the test-engineering skill.
- Add six `testing` patterns (437 → 443): `rspec-request-spec`, `rspec-job-and-mail-enqueue`, `rspec-mailer-spec`, `rspec-factory-traits`, `rspec-shared-examples-contract`, and `rspec-verifying-doubles`. Their examples come from a Rails 8.0 app with rspec-rails 8.0, where they run as 15 examples with 0 failures. Three mutations (dropping the job enqueue, making the job ignore order status, renaming the gateway keyword) each fail the suite.
- Record two behaviours found while running the examples: `have_enqueued_mail` raises `ArgumentError` outside block form, and `errors.added?` fails unless every error option is passed.
- Add RSpec triggers to the `testing` pattern family and the `rspec-request-contract` evaluation (two cases; 445 → 447 evaluation cases).
- Benchmark the new evaluation in the `test-engineering` campaign (version 2 → 3). Its fixture is a controller spec with `allow_any_instance_of`, `assigns`, and a non-block `have_enqueued_mail`. `scripts/verify_test_engineering_eval.rb` gains an `rspec-request-contract` branch that scans `spec/**/*.rb`. It checks for a request spec, block-form enqueue matchers, a shared 422 contract, and the 201/422/unchanged-count assertions, and it rejects `any_instance` stubs and `sleep`. The baseline fails. The reference under `benchmarks/test-engineering/references/rspec-request-contract/` passes, and it runs green in the Rails 8.0 app (4 examples). Four mutations of the executed request spec each fail.

## Iteration 134 — Rails and React Integration Seam

- Add the `rails-react-integration` skill. It owns the client side of the Rails ↔ React boundary and composes with `rails-api-integration`, `rails-authentication`, `rails-validations`, `typescript-runtime-contracts`, and `react-data-fetching` for the server side. It covers choosing the integration mode (Inertia, JSON API with a separate client, or React islands), runtime validation of Rails JSON, CSRF and session handling from `fetch`, Rails 422 errors in forms, and pagination. 85 → 86 skills.
- Add five `react-typescript` patterns: `rails-react-integration-mode`, `rails-react-typed-api-contract`, `rails-react-validation-error-mapping`, `rails-react-csrf-session-fetch`, and `rails-react-pagination-contract` (432 → 437). Their TypeScript examples pass `tsc --strict` with `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes`, and nine Vitest behaviour checks. Removing the CSRF header from the fetch example fails two of them. The Ruby example passes `ruby -c`.
- Add a "Rails and React cross-stack routing" section to `router/ROUTING.md` with six task rows, and the `rails-react-integration-contract` evaluation (3 cases, static-only; 23 static-only evaluation files).
- Add four public routing cases, the first React and cross-stack cases in the corpus. The public campaign becomes 18 cases × 3 repetitions = 54 runs, and `router/ROUTING_CAMPAIGN.yml` moves to version 2. `router/ROUTING_RELEASE.yml`, the routing docs, and the tests that pin the protocol are updated. No empirical campaign evidence existed under version 1.
- Fix `bin/routing-eval` resume validation. It compared a checkpoint's `campaign_version` with a literal `1` while checkpoints record the version from `ROUTING_CAMPAIGN.yml`, so any version bump would have made every resume fail. It now compares against the configured version.
- The README lists the React and TypeScript skills and names the frontend areas not yet covered.

## Iteration 133 — Release v1.1.0 Preparation

- Point the README quick-start at the `v1.1.0` release archive; it still downloaded `v1.0.1`, which predates the skill merge, benchmark references, code examples, and RuboCop CI.
- Correct the `RELEASE.md` archive-contents table from 91 skills / 431 patterns to the current 85 / 432.
- `scripts/audit_documentation_consistency.rb` now checks the `RELEASE.md` skill and pattern counts against the filesystem, so the table cannot drift silently again; covered by a new regression test.

## Iteration 132 — Trim Duplicated Iteration History

- Trim the `docs/ITERATIONS.md` entries for Iteration 101 onward (31 of them) from full copies of their `CHANGELOG.md` bullet lists to one-line summaries. Iterations 41–100 have no `CHANGELOG.md` counterpart and are unchanged.
- `docs/ITERATIONS.md` drops from 500 to 395 lines. A note at the top of the file says iterations from 101 onward are summarized there and points to `CHANGELOG.md` for the itemized changes.

## Iteration 131 — Iteration History Out of the README

- Move every iteration narrative out of `README.md` into the new `docs/ITERATIONS.md`, one section per iteration in ascending order. It merges the 65 README narratives (previously in six places and out of order) with the `CHANGELOG.md` entries, covering Iterations 41–131. The eleven narratives that had no number in their heading (for example "Rails Encryption and Credentials Engineering") are filed under the iteration their text named.
- `docs/ITERATIONS.md` now carries the current-milestone line. The README keeps only the current system (quick start, coverage, architecture, validation, installation, and a rewritten status section with no iteration numbers) and drops from 1,018 to 718 lines.
- `scripts/audit_documentation_consistency.rb`, `scripts/audit_release_readiness.rb`, and `scripts/audit_repository_completeness.rb` read the milestone and release-history markers from `docs/ITERATIONS.md`. The documentation audit also rejects iteration mentions in the README, requires ascending order, and requires a section for the latest changelog iteration, each covered by a new regression test.
- `AGENTS.md`, `CONTRIBUTING.md`, the README contributing steps, and the implementation handoff describe where iterations are recorded.

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
