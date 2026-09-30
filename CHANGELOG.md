# Changelog

## Iteration 148 — Validation Gate Integrity Preflight

- Add `test/validation_gate_integrity_system_test.rb` to verify that `bin/validate` initializes its repository root before use, keeps repository paths root-qualified, and retains the framework-drift audit/test.
- Run the integrity test as an independent CI step before `bash bin/validate`, so truncation or path corruption in the validation gate cannot silently disable later checks.
- Increase the dedicated system/contract test inventory from 96 to 97.

## Iteration 147 — Executable Framework Drift Detection

- Add `framework-drift.yml), a machine-readable registry of high-confidence Rails API/configuration drift with status, version boundary, replacement, and official Rails release-note source.
- Add `scripts/audit_framework_drift.rb`, which scans Ruby code fences in skills and patterns, reports file/line findings, and permits only explicit in-block suppression directives.
- Register and enforce the detector through `skill-manifest.yml`, `bin/validate`, and repository completeness auditing.
- Add system coverage for detection, prose exclusion, suppression, and gate registration.
- The registry is intentionally bounded to evidence-backed findings from Rails 6.1 and 8.1 release notes; it is not presented as a complete Rails deprecation database.

## Iteration 146 — Deprecation Governance

- Add `docs/DEPRECATION_GOVERNANCE.md` as the operational contract for skills retained during migration but excluded from new standalone work.
- Add `scripts/validate_deprecations.rb` to require explicit deprecated status, migration scope, replacement, migration documentation, and exactly five removal gates.
- Register the nine migrated React/TypeScript skills in `skill-manifest.yml` and prevent duplicate replacement ownership.
- Add `test/deprecation_governance_system_test.rb` and wire the validator into `bin/validate`.
- Keep removal evidence-driven: the repository does not infer adoption, dates, or completion from the existence of the replacement repository.

## Iteration 145 — Executable Runtime Compatibility Gate

- Add `RubyAgentSkills::VersionConstraint`, using RubyGems version/requirement semantics for deterministic compatibility checks.
- Extend `SkillPack` with compatibility reporting and enforcement for selected skills and pattern frontmatter. Known `unsupported`/`conflict` material is rejected; strict mode also rejects unknown runtime evidence.
- Bind `EvalRunner` to the target workspace runtime profile so compatibility evidence travels with evaluation results.
- Add `bin/skill-pack-compatibility` for project-side compatibility checks and ship/verify it through installer and release integrity surfaces.
- Add three Rails 8.1 version-bound patterns: `active-job-continuation-contract`, `structured-event-reporting`, and `credentials-fetch-contract`.
- Validate pattern/manifest compatibility requirements and add system/unit coverage.
- No model benchmark result is claimed; this iteration hardens deterministic version safety only.

## Iteration 144 — Agent Skills Frontmatter Contract Validation

- Extend `scripts/validate_skills.rb` to enforce the current Agent Skills frontmatter constraints for `name`, `description`, `compatibility`, `metadata`, and `allowed-tools`.
- Enforce skill names at most 64 characters using lowercase letters, numbers, and single hyphens; descriptions must be non-empty strings of at most 1024 characters; compatibility is optional but must be a non-empty string of at most 500 characters when present.
- Validate optional metadata as a string-to-string mapping and reject non-string `allowed-tools` values.
- Add `test/skill_frontmatter_spec_system_test.rb` and wire it into `bin/validate`, increasing the dedicated system/contract test inventory from 92 to 93.
- Bind the documented public routing campaign run count to `router/ROUTING_CAMPAIGN.yml` in `scripts/audit_documentation_consistency.rb`, preventing stale 42-run handoff instructions when the campaign corpus changes.
- This is a repository-spec hardening change only; no model-quality or benchmark outcome is claimed.

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