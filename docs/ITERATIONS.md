# Iterations

The repository is built in numbered iterations. This file is the ordered history, oldest first: one section per iteration, with its summary and, where one was recorded, its itemized change list. `CHANGELOG.md` keeps the same itemized entries newest first.

> **Current milestone:** Iteration 131 — Iteration History Out of the README

No entry was recorded for iterations before 41, or for 68, 80, 107, and 108.

---

## Iteration 41 — Rails Encryption and Credentials Engineering

Iteration 41 adds explicit contracts for Rails encrypted credentials, master-key delivery, environment-specific credential selection, secret redaction, Active Record Encryption, deterministic encrypted queries, storage sizing, encrypted-data migration, key rotation, and synthetic-secret testing.

## Iteration 42 — Rails Serialization and Global IDs Engineering

Iteration 42 adds explicit contracts for Rails serialization ownership, JSON representation, nested payloads, sensitive-field exclusion, serialized payload compatibility, Global ID identity, Signed Global ID integrity, locator restrictions, resolution failures, Active Job arguments, and custom serializers.

 

## Iteration 43 — Rails Operational Tasks and Maintenance

Iteration 43 adds executable contracts for custom Rake tasks, runner workflows, maintenance and cleanup, environment gates, dry-runs, idempotency, batching/checkpointing, locking, invariant preservation, partial failures, operational observability, scheduler overlap, data-repair verification, and production runbooks.

## Iteration 44 — Rails Cross-Boundary Authorization and Security Composition

Iteration 44 adds explicit security composition contracts across controllers, services, jobs, APIs, realtime channels, engines, operational commands, asynchronous event consumers, capabilities, denial semantics, authorization caches, and audit boundaries.

## Iteration 45 — Rails Staff and Principal Architecture

Iteration 45 adds a staff/principal decision layer for dependency direction, bounded contexts, modular monoliths, data ownership, shared kernels, cross-cutting ownership, change coupling, process-extraction readiness, incremental architecture migration, ADRs, executable architecture fitness checks, system tradeoffs, and operational ownership.

## Iteration 46 — Repository-wide Completeness and Gap Audit

Iteration 46 adds repository-level completeness enforcement for manifest registration, pattern/evaluation registration, routing coverage, system-test execution, README inventory drift, and current Rails framework evolution. Rails 8/8.1 additions are routed to their existing owning skills rather than fragmented into duplicate skill boundaries.

## Iteration 47 — Evaluation and Benchmark Hardening

Iteration 47 hardens the benchmark system with fixture-seam validation, controlled campaign requirements, public/hidden coverage disclosure, and campaign provenance preserved in campaign results. Public evaluation families without campaigns are reported explicitly rather than being treated as measured benchmark evidence.

## Iteration 48 — Final Release and Public-Readiness Hardening

Iteration 48 adds public contribution and security entry points, a changelog baseline, and an executable release-readiness audit covering required publication metadata, stale inventory/release markers, and generated benchmark artifacts.

## Iteration 49 — Rails Benchmark Coverage Expansion

Iteration 49 started measured benchmark coverage for the deep Rails evaluation corpus. The public campaign established paired baseline/skills-enabled execution, deterministic fixtures, independent verification, and explicit coverage disclosure.

## Iteration 50 — Rails Security and Identity Benchmark Expansion

Iteration 50 expanded the Rails benchmark campaign with five high-risk identity/security boundaries: `authentication-contract`, `authorization-contract`, `rails-cross-boundary-authorization-security-contract`, `rails-encryption-credentials-contract`, and `rails-serialization-globalid-contract`. These fixtures exercise identity lifecycle, tenant/resource authorization, delayed execution, secret/encryption boundaries, representation allowlists, Global ID integrity, and signed-identifier verification.

## Iteration 51 — Rails Benchmark Coverage Completion

Iteration 51 completes the public Rails benchmark campaign. All **27** Rails evaluation families now have disposable implementation/test seams and are registered in the controlled benchmarks/rails/campaign.yml. The campaign enforces paired execution, three repetitions, fresh workspaces, shared fixtures for baseline/skills-enabled comparisons, and explicit hidden-case disclosure.

The benchmark-quality audit now treats missing public Rails coverage as an error rather than a warning.

## Iteration 52 — CI Toolchain and Release-Guard Maintenance

Iteration 52 removes the Node 20 checkout warning from CI, standardizes the repository on Node 24-compatible `actions/checkout@v7`, adds an executable CI toolchain audit, and makes the maintenance contract part of `bin/validate`.

## Iteration 53 — Skill Routing and Activation Quality

Iteration 53 added adversarial routing cases for overlap-heavy tasks and made primary/secondary skill ownership an explicit repository contract.

## Iteration 54 — Empirical Skill Routing Evaluation

Iteration 54 added a provider-neutral routing evaluator that measures actual primary-skill selection and secondary-skill recall.

## Iteration 55 — Real Agent Routing Campaign

Iteration 55 turns the evaluator into a repeated campaign: three fresh repetitions per public routing case, campaign-level completion checks, and an expected-primary versus observed-primary confusion matrix. The repository now has a measurement path for discovering real cross-boundary routing failures instead of relying only on structural routing tests.

## Iteration 56 — Real Agent Routing Benchmark Adapter

Iteration 56 adds an actual Ollama-backed routing adapter and closes a benchmark-integrity gap: agent workspaces receive only the task prompt and protocol metadata, never the gold primary/secondary labels. The adapter uses Ollama chat JSON output, normalizes it to the routing result contract, and preserves provider/model provenance for campaign evidence.

## Iteration 57 — Real Agent Routing Campaign and Confusion Analysis

Iteration 57 adds the executable `bin/routing-campaign` command and `bin/routing-analyze` report generator. The runner validates Ollama availability/model presence, executes the configured repeated routing campaign, then produces per-case stability and expected-primary versus observed-primary confusion evidence. A missing model/runtime is reported explicitly rather than producing synthetic benchmark results.

## Iteration 58 — Routing Remediation and Before/After Regression Gate

Iteration 58 adds `router/ROUTING_REMEDIATION.yml` and `bin/routing-compare`. The comparator takes a baseline and candidate campaign and reports metric deltas, resolved/new confusion pairs, and per-case routing changes. The remediation gate rejects incomplete campaigns, primary/secondary regressions, newly introduced primary confusion pairs, and case-level primary regressions according to explicit thresholds.

## Iteration 59 — Reproducible Routing Baseline/Candidate Experiment

Iteration 59 adds `bin/routing-experiment`, which runs baseline and candidate routing-contract snapshots with the same agent command, model metadata, timeout, and repetitions, then applies the Iteration 58 comparison gate. This makes routing remediation experiments reproducible and isolates the routing contract as the intended experimental variable.

## Iteration 60 — Auditable Routing Experiment Evidence

Iteration 60 adds `bin/routing-evidence`, which packages a completed routing experiment with the repository revision, baseline/candidate campaign hashes, exact routing-contract hashes, campaign/schema/remediation-policy hashes, agent configuration, comparison deltas, and replay metadata. This turns external model runs into auditable evidence rather than ephemeral local output.

## Iteration 61 — Routing Evidence Integrity & Intake

Iteration 61 hardens routing experiment evidence before the first real external-model campaign. Evidence packaging now records the exact Git revision, branch, worktree cleanliness, and status entries, while rejecting dirty repositories unless explicitly allowed. `bin/routing-evidence-verify` independently validates compatibility, gate state, digest structure, and—when requested—artifact SHA-256s. No local model score is claimed when the external model runtime is unavailable.

## Iteration 62 — Routing Evidence Archive & Benchmark Intake

Iteration 62 adds a portable archive for completed routing evidence. `bin/routing-archive` verifies an evidence package, copies the exact evidence and hashed artifacts into an immutable archive location keyed by campaign/model/repository revision, and refuses silent overwrites. This creates the storage boundary for the first real external-model routing campaign without claiming a benchmark result that has not been observed.

## Iteration 63 — Routing Campaign Intake Gate

Iteration 63 adds a strict acceptance boundary for externally produced routing campaigns. The intake verifier requires the configured public corpus, repetition count, complete case coverage, valid registered skills, and complete agent metadata before a real model campaign can be treated as evidence. The current public protocol therefore requires 14 cases × 3 repetitions = 42 completed routing decisions.

## Iteration 64 — Real Routing Campaign Evidence Pack

Iteration 64 adds `bin/routing-campaign-evidence`, which packages a completed public routing campaign together with its analysis, routing contract, repository contracts, and every raw per-run result file. The packager first enforces the Iteration 63 intake gate and records SHA-256 identities plus repository state. It creates a portable evidence boundary without fabricating a result when the external model runtime is unavailable.

## Iteration 65 — Routing Campaign Runtime Preflight

Iteration 65 adds a pre-run runtime gate for the real routing campaign. Before any model case executes, the runner records the Ollama runtime version, exact model identity/digest, public case count, repetitions, expected total runs, execution controls, and repository contract hashes. The preflight JSON is preserved as part of campaign evidence when a real run is executed.

## Iteration 66 — External Routing Campaign Handoff

Iteration 66 adds a portable external-runtime handoff for the public routing campaign and defines the private/hidden benchmark boundary. The handoff captures the exact repository SHA, public 14-case/3-repetition protocol, model/runtime settings, and contract hashes, then emits an executable campaign command. Hidden routing cases and gold labels remain external-only and are explicitly forbidden from repository storage or agent exposure.

## Iteration 67 — External Routing Campaign Intake

Iteration 67 completes the runtime handoff boundary. `bin/routing-campaign-preflight-verify` validates captured preflight without contacting Ollama, and `bin/routing-campaign-import` provides one intake command that verifies the completed campaign, cross-checks it against preflight, packages raw results as auditable campaign evidence, and optionally creates the immutable evidence archive. Hidden routing cases and gold labels remain external-only.

## Iteration 69 — Routing Campaign Evidence Integrity

Campaign evidence is now independently verifiable before archival. The evidence verifier checks public campaign cardinality, preflight presence, raw-run artifact count, provenance, and recorded SHA-256/byte-size metadata; the importer and archive now enforce that gate.

## Iteration 70 — Routing Release Readiness

A release gate now separates static repository readiness from empirical routing readiness. The gate requires a verified public 14-case × 3-repetition campaign, intact raw-result evidence, the captured preflight, and an immutable archive before an empirical routing release can be marked ready. Without real evidence it reports the release as pending rather than inventing a result.

## Iteration 71 — Routing Model Matrix Execution

The repository now has an explicit multi-model execution harness for the public routing campaign. It supports plan-only operation and, when explicitly requested, executes each named Ollama model with identical corpus/repetition/timeout settings, imports and verifies its evidence, and archives each completed model independently. It never ranks models or synthesizes missing results.

## Iteration 72 — Hidden Benchmark External Intake

Hidden routing cases, gold labels, raw results, and hidden case counts now have an explicit external-only intake contract. The repository can verify an externally supplied benchmark evidence artifact and emit a safe provenance receipt without importing hidden case content or gold labels, and hidden cardinality is supplied privately rather than inferred from the public routing corpus.

## Iteration 73 — Routing Campaign Provenance Binding

Campaign imports now bind evidence to the exact repository state captured by preflight. The importer verifies the recorded Git SHA and the SHA-256 hashes of the skill manifest, campaign manifest, public routing corpus, and routing contract before evidence is packaged and archived. This prevents a campaign from being silently attached to changed routing inputs.

## Iteration 74 — Routing Campaign Handoff Binding

External campaign handoffs are now verified against the receiving checkout before model execution. The verifier binds the handoff to the public campaign contract, expected 14-case × 3-repetition plan, exact Git SHA, routing-input hashes, and a clean worktree; the generated launcher refuses to start the campaign when these inputs do not match.

## Iteration 75 — Checkpointed Routing Campaign Resume

Routing campaign execution now checkpoints after every repetition and records a hash-bound `run.json` receipt for each successfully validated run. An interrupted campaign can be resumed with `--resume`; only compatible, receipt-backed runs whose result digest still matches are reused. Missing or invalid runs execute normally, and incomplete checkpoints remain ineligible for evidence import or release readiness.

## Iteration 76 — Implementation Hardening & Verified Agent Installation

The execution layer now supports resumable multi-model routing campaigns, and the agent installer installs both skills and reusable patterns with immutable source/ref provenance. Installed packs can be independently verified for manifest/routing integrity and exact skill/pattern inventory. Removed skills are cleaned up during upgrades, and installation behavior has system-test coverage.
The agent-facing `SkillPack` materializer now records the source manifest digest, creates stable baseline directories, and rejects ambiguous basename-only pattern resolution rather than selecting a non-deterministic match.

## Iteration 77 — React + TypeScript Engineering Pack

The repository now includes a dedicated frontend engineering layer for React and TypeScript instead of relying on generic Rails asset guidance.

Skills:
- typescript-core-engineering
- typescript-type-design
- typescript-runtime-contracts
- react-component-engineering
- react-state-effects
- react-data-fetching
- react-testing-engineering
- react-accessibility-performance
- react-architecture

The pack includes 24 reusable implementation patterns and 9 public evaluations covering type modeling, runtime boundaries, component composition, state/effect ownership, server-state caching, testing, accessibility/focus, rendering performance, and frontend architecture.

## Iteration 78 — Verified Agent Installation Doctor

The installed-pack workflow now has a deterministic local doctor command. It validates the installation metadata, supported agent/scope, recorded skill inventory, embedded verifier, and content integrity before a pack is used in a controlled agent environment.

## Iteration 79 — Repository Consistency & Empirical Analysis Hardening

The public documentation and release-readiness surfaces now share one verified inventory/current-milestone contract. Routing analysis also reports primary accuracy, secondary recall, unexpected secondary selections, per-case repetition stability, and explicit input validation without synthesizing missing runs.

## Iteration 81 — Routing Analysis Provenance Binding

Campaign evidence now proves that the preserved `routing-report.json` is the exact output of independently recomputing `campaign.json`. The packager rejects a tampered report before evidence capture, and `routing-campaign-evidence-verify --check-files` replays the analyzer while checking that evidence-level analysis and metrics match their source artifacts.

## Iteration 82 — Installed Stack Minimality Tooling

The repository now includes a stack-aware minimality layer for Ruby, Rails, React, TypeScript, and PostgreSQL. It adapts Ponytail's useful discipline—YAGNI, repository reuse, framework/native primitives first, focused over-engineering review, repository-wide audit, explicit simplification debt, and evidence-backed measurement—to this stack.

Skills:
- stack-minimality
- stack-minimality-review
- stack-minimality-audit
- stack-minimality-debt
- stack-minimality-evidence
- stack-minimality-help

The pack is a cross-cutting modifier, not a replacement for Rails, React/TypeScript, PostgreSQL, security, accessibility, testing, performance, or API skills. It never treats smaller code as automatically safer and does not copy external benchmark numbers into repository measurements.

See docs/STACK_MINIMALITY.md and the stack-minimality skill for the operational contract.

The installed pack also provides `bin/stack-minimality` under `.ruby-agent-skills/bin/` for deterministic shortcut-ledger and Git-diff evidence reports.

## Iteration 82 — Routing Evidence Archive Integrity

Routing evidence archives now have an independent verifier that validates archive identity, preserved evidence, artifact sets, SHA-256/byte-size metadata, relative paths, and symlink traversal. Archive creation self-verifies before succeeding, and release readiness verifies the exact archived package containing the supplied evidence.

## Iteration 83 — Matrix Resume Integrity

Matrix campaign resume no longer trusts a `completed_and_archived` checkpoint entry by status alone. On resume, the runner revalidates the recorded campaign evidence with `routing-campaign-evidence-verify --check-files` and independently validates the recorded archive with `routing-archive-verify` before reusing the result.

## Iteration 84 — Stack Minimality Adversarial Evaluation Expansion

The minimality layer now has adversarial evaluations for security, accessibility, performance evidence, migration safety, service-boundary decisions, and React derived state. These cases explicitly prevent “fewer lines” from becoming a reason to weaken a required engineering guarantee.

## Iteration 85 — Stack Minimality Evaluation Guardrails

The completeness audit now verifies that the stack-minimality evaluation registry matches the filesystem and that the adversarial corpus retains its minimum coverage. Dedicated system tests validate the schema of every stack-minimality evaluation.

## Iteration 86 — Pattern Selection Restraint Integration

The design-pattern evaluation system now includes six negative-selection cases that explicitly require the agent to decline an otherwise familiar abstraction when the responsibility, variation, ownership, or lifecycle boundary has not been earned. The campaign expands from 18 to 24 public cases, and benchmark-quality tests require campaign coverage to match the complete public design-pattern evaluation set.

## Iteration 87 — Design-Pattern Corpus Revision

The design-pattern benchmark is now version 2. Its public campaign contains 24 cases, including six negative-selection cases integrated with stack-minimality. The campaign revision is recorded explicitly so future empirical results cannot be silently attached to the older 18-case corpus.

## Iteration 88 — End-to-End Campaign Finalization

Campaign import now regenerates the canonical routing analysis before evidence packaging, and the external handoff launcher invokes finalization automatically.

## Iteration 89 — Routing Comparison Provenance Binding

`bin/routing-compare` records SHA-256 provenance for the exact baseline campaign, candidate campaign, remediation policy, and comparator implementation.

## Iteration 90 — Routing Comparison Replay Verification

`bin/routing-compare-verify` independently recomputes a stored comparison against its recorded baseline/candidate inputs and remediation policy, while checking provenance hashes.

## Iteration 91 — End-to-End Experiment Evidence Finalization

The baseline/candidate remediation experiment now verifies comparison provenance, packages its `evidence.json`, and verifies the final evidence package before reporting success.

## Iteration 92 — Matrix Evidence Aggregation

The multi-model campaign runner now automatically finalizes a completed matrix into aggregate evidence and verifies that aggregate before reporting overall success. Failed or incomplete model runs remain ineligible for aggregate evidence.

## Iteration 93 — Matrix Evidence Integrity Verification

Added an independent verifier for aggregate matrix evidence. It detects plan drift, model-set drift, evidence/archive hash changes, archive tree changes, and underlying campaign/archive verification failures when file checking is requested.

## Iteration 94 — Verified Multi-Model Matrix Evidence

Completed multi-model routing matrices now emit a single `matrix-evidence.json` that cryptographically binds the matrix plan, every completed model evidence package, and every immutable archive tree. `bin/routing-model-matrix-evidence-verify` independently checks these bindings and replays the existing per-model evidence/archive verifiers.

## Iteration 95 — Routing Release Evidence Bundle

`bin/routing-release-bundle` composes verified public routing evidence into an auditable release-evidence directory and cryptographically records each component.

## Iteration 96 — Hidden Benchmark Receipt Verification

`bin/routing-hidden-benchmark-receipt-verify` independently validates safe external hidden-benchmark receipts without importing hidden cases, prompts, or gold labels into the repository.

## Iteration 97 — Verified Release Evidence Bundle

Completed routing release inputs can now be composed into a frozen `RELEASE_MANIFEST.json` bundle. The bundle verifies the required public campaign evidence and immutable archive before capture, optionally includes verified multi-model matrix evidence and the external-only hidden benchmark receipt, and carries a frozen copy of the release policy.

## Iteration 98 — Self-Verifying Release Evidence

Release bundles now self-verify before reporting success, and `bin/routing-release-check --bundle` can gate an already-created bundle directly.

## Iteration 99 — Routing History Integrity

`bin/routing-history-verify` independently validates history structure, archive identity, and every referenced archive before trusted longitudinal reporting.

## Iteration 100 — Matrix Report Integrity Gate

`bin/routing-model-matrix-report --verify` now refuses to consume history that references archives failing the independent archive verifier.

## Iteration 101 — Verified Routing History

Routing history can now be generated with `--verify`, which replays archive integrity checks before the historical dataset is reported. Historical model reports can also require verified history with `--verify`; the comparison remains descriptive-only.

Changes:

- Add `routing-history --verify` for integrity-gated longitudinal history generation.
- Validate every indexed archive against its independent archive verifier and manifest identity.
- Keep historical model reporting descriptive-only.

## Iteration 102 — Documentation Consistency Contract

The repository now has an executable documentation consistency audit covering README, implementation handoff, changelog milestone, filesystem inventory, and manifest identity.

Changes:

- Add a deterministic documentation audit covering README, implementation handoff, changelog milestone, filesystem inventory, and manifest identity.
- Make `bin/validate` enforce documentation consistency before release readiness.
- Synchronize current inventory and implementation-status documentation with the verified Iteration 101 repository state.

## Iteration 103 — Release Bundle Component Provenance

The release bundle verifier now proves that bundled public evidence belongs to the bundled archive and that optional matrix evidence matches the same campaign and repository revision.

Changes:

- Bind bundled public evidence to its archive manifest by source-evidence hash and shared campaign/repository/agent identity.
- Require optional matrix evidence to match the public campaign and repository revision.
- Add regression coverage for release component identity binding.

## Iteration 104 — Verified Routing History Boundary

Routing history now enforces that referenced archives resolve inside the declared archive root and records a deterministic SHA-256 digest of the indexed archive set. Verification checks that digest and each archive manifest before history is trusted.

Changes:

- Reject history entries whose archive paths resolve outside the declared archive root.
- Record archive-manifest SHA-256 provenance for every indexed archive.
- Add an aggregate archive-set SHA-256 to generated history and verify it during replay.
- Add regression coverage for archive-root escape and provenance requirements.

## Iteration 105 — Release Infrastructure

- Add `scripts/build_release_archive.rb`: deterministic, reproducible release archive with embedded `RELEASE.json` provenance, SHA-256 checksums, and generated release notes.
- Extend `bin/install` with offline archive support: a plain local directory (an extracted release archive) installs directly without git, recording release provenance; the installer also self-detects when it runs from an extracted archive or a repository checkout.
- Add `.github/workflows/release.yml`: tag-triggered release CI that validates, builds, self-tests, checks reproducibility, and publishes the GitHub Release with archive and checksums.
- Add `test/release_archive_system_test.rb` covering archive contents, provenance, offline install, verification, and reproducibility.
- Add `RELEASE.md` documenting the release definition and process; document offline archive installs in `docs/INSTALLATION.md` and `README.md`.

## Iteration 106 — Independent Release Archive Verification

- Add a standalone release archive verifier independent of the archive builder's self-test.
- Verify release metadata, skill/pattern inventory, required agent-facing paths, archive safety, and optional published SHA-256 checksums.
- Add regression coverage and wire the verifier into `bin/validate`.

## Iteration 109 — Release Documentation Polish

The repository-side implementation line is complete through Iteration 109. The current implementation includes checkpointed routing campaigns, resumable multi-model execution, provenance-bound installation, exact installed-pack verification, React/TypeScript engineering coverage, the installed-pack doctor, synchronized release documentation, richer routing-campaign analysis, and the complete release line: reproducible, checksummed release archives with offline installation, a tag-triggered release workflow, and published GitHub releases. The repository-side integration line is complete through Iteration 101. Remaining work is empirical execution with a reachable external model runtime: capture real campaign evidence, analyze observed routing behavior, run evidence-based remediation experiments, execute the external hidden benchmark, and publish verified release evidence.

Changes:

- Deduplicate the repeated Iteration 95–97 sections in the README and restore a single ordered iteration narrative (92–104) including the previously orphaned Iteration 98 entry.
- Refresh the README "Current implementation status" section to the current milestone, including the release infrastructure: reproducible checksummed archives, offline installation, the tag-triggered release workflow, and published GitHub releases.
- Add a README quick start with the direct release-archive download, git checkout, and installation verification commands; link the Installation section to the releases page.

## Iteration 110 — Multi-Region Data Boundary Pattern

The distributed-systems skill now covers multi-region deployments. The new `multi-region-data-boundary` pattern defines region routing, authoritative write ownership, data-residency enforcement at the storage layer, replication lag budgets, fenced failover with stated RPO/RTO, and conflict handling for the failover window. The pattern is registered in the manifest, routed in the router pattern-selection matrix, and guarded by the repository and documentation consistency audits (432 implementation patterns).

Changes:

- Add the `multi-region-data-boundary` implementation pattern: region routing, authoritative write ownership, data-residency enforcement at the storage layer, replication lag budgets, fenced failover with stated RPO/RTO, and conflict handling for the failover window.
- Wire the pattern into the `rails-distributed-systems` skill (design guidance, review checklist, and anti-pattern), the skill manifest (registry path plus multi-region/data-residency/region-failover triggers), and the router pattern-selection matrix.
- Correct the README validation-suite prose summary to the actual system/contract test count (82), closing a prose-only drift the inventory table guard could not see.

## Iteration 111 — Corpus Quality & Benchmark Coverage

- Add `scripts/audit_corpus_quality.rb` with exact corpus measurements for skill examples, executable examples, pattern implementation anchors, failure/testing guidance, evaluation case integrity, grading depth, benchmark coverage, routing trigger collisions, and stale manifest paths.
- Register the corpus-quality audit and system test in `bin/validate`.
- Replace the ambiguous public-evaluation benchmark warning with an explicit coverage contract: campaign-backed evaluations are empirical; the 13 stack-minimality and 9 React/TypeScript evaluation files are declared `coverage: static-only`.
- Extend benchmark-quality tests to enforce the 22-file static-only classification.
- Make release archive system-test inventory expectations derive from `skill-manifest.yml` rather than hard-coded counts.

## Iteration 112 — Release File-Level Provenance & Publication Gate

- Record `protocol_version` and file-level SHA-256/byte-size provenance for every shipped file in `RELEASE.json`, computed from the staged archive tree.
- Extend `scripts/verify_release_archive.rb` with pre-extraction tar listing safety (regular files/directories only, no absolute or parent-traversal names), protocol-version enforcement, file-record containment, and `--check-files` verification of every file's size/digest plus rejection of unrecorded shipped files.
- Gate the tag-triggered release workflow on `verify_release_archive.rb --checksums dist/SHA256SUMS --check-files` before `gh release create`.
- Extend release verification regression coverage to tampered file content, injected unrecorded files, unknown protocol versions, escaping file records, symlink entries, and the workflow publication gate.

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

## Iteration 114 — Rails Benchmark Reference Solutions

- Add known-good reference implementations for the 12 Rails campaign fixtures that lacked one (action-controller, active-storage, associations, authentication, authorization, cross-boundary authorization, encryption/credentials, hotwire, rack middleware, routing, serialization/Global ID, validations). All 27 Rails fixtures now have a positive control that passes its verifier.
- Fix a contradictory assertion in the `validations-contract` fixture test: it required a token already taken in tenant 11 to be available in tenant 11, so no correct implementation could pass. The test now requires tenant-scoped uniqueness in both directions (including `except_id`).
- Add `validations-contract` tests for the shared validation rule across models and bounded associated validation; previously the unmodified fixture passed every behavioural test and failed only a source regex.
- Bump the Rails campaign version to 5.

## Iteration 115 — Design-Pattern Benchmark Reference Solutions

- Add known-good reference implementations for the 14 design-pattern campaign fixtures that lacked one (PORO extraction, service/command objects, adapter, policy, dependency injection, factory, builder, null object, decorator, facade, specification, presenter, pattern restraint). All 24 design-pattern fixtures now have a positive control that passes its verifier.

## Iteration 116 — Database-Engineering Verifier Repair and References

- Repair `scripts/verify_database_engineering_eval.rb`: its regexes had lost every backslash (e.g. `/add_columns+:customers,s*:display_name/`, `/BATCH_SIZEs*=s*d+/`), so they required literal text that real migrations never contain and every submission failed. Reconstructions match the patterns preserved in the fixtures' own tests.
- With a working verifier, all 5 fixtures passed under a no-op agent because they shipped the finished change. Their workspaces now start from the unsafe version each prompt warns against (destructive expand migration, non-concurrent index, non-unique composite index, unbounded `User.all.each`, unlocked check-then-decrement); the finished changes move to `benchmarks/database-engineering/references/`.
- Bump the database-engineering campaign version.

## Iteration 117 — Production-Runtime Verifier Repair and References

- Repair `scripts/verify_production_runtime_eval.rb`, which did not parse: stripped escapes (`/putss+ENV[|ps+ENV[/`) and `\b` turned into backspace bytes. The whole campaign failed every run regardless of the submission.
- `graceful-shutdown`: the contract rejected `exec .* puma .* &`, which every trap-and-forward entrypoint (the pattern `functional` requires) contains, including the shipped solution. The contract now rejects what the prompt forbids: an ignored TERM (`trap '' TERM`) or a contradictory `exec … &` line.
- `puma-capacity`: the verifier only checked that `workers`/`threads` appeared, so any configuration passed. It now reads the `WEB_CONCURRENCY`/`RAILS_MAX_THREADS` defaults and enforces the prompt's budget (workers ≤ 4 cores, threads ≤ database pool of 12).
- All 5 fixtures shipped the finished change and passed under a no-op agent once the verifier ran. Workspaces now start from over-budget Puma settings, a TERM-swallowing entrypoint, destructive-first release ordering, secret-printing boot configuration, and a rollback-assuming migration plan; the finished changes move to `benchmarks/production-runtime/references/`.
- Bump the production-runtime campaign version.

## Iteration 118 — Test-Engineering Verifier Repair and References

- Repair `scripts/verify_test_engineering_eval.rb`, which did not parse (stripped escapes, backspace bytes); every run of the campaign failed regardless of the submission.
- Make the campaign winnable and honest. The `tests` check ran every `*_test.rb` with plain `ruby`, but these are Rails tests and the fixtures contain no Rails application, so it could never pass. It is now explicitly static: every Ruby file under `test/` must parse and at least one test must assert something; behavioural judgement stays in the evaluation-specific checks.
- Remove the fixtures' meta-tests. They duplicated verifier logic, were agent-editable, two read files from the wrong directory, and their own source text (`"OrdersController"`/`"get :"`, `rescue.*retry`) made the verifier report a direct-controller test or a retry workaround in every submission.
- `parallel-safety` and `test-performance` inspected `*_test.rb` bodies for problems that live in `test/test_helper.rb`, so they could never detect them; both now inspect the helper. `boundary-selection` matches per file instead of across concatenated files.
- Workspaces now start from the problem each prompt describes (direct controller test, sleep plus direct `perform`, fixed port and shared global array, global state with a retry loop, calculation-coupled system test, eager helper glob with a deep factory); finished versions move to `benchmarks/test-engineering/references/`. Every fixture has an assertion-bearing test file.
- Bump the test-engineering campaign version.

## Iteration 119 — Zeitwerk Verifier Repair and References

- Repair `scripts/verify_zeitwerk_eval.rb`: backspace bytes in place of `\b` and stripped escapes (`/modules+Paymentss*…/`, `/ApiGateway.endpoints*=…/`) meant the namespace, reload, and eager-require checks never matched real code.
- Both fixtures shipped the finished change. Workspaces now start from a path/constant mismatch (`PaymentProcessor` in `payments/processor.rb`) and a one-time initializer that requires and configures the reloadable class at boot; finished versions, including the tests the prompts require, move to `benchmarks/zeitwerk/references/`.
- References may include `test/` or `spec/` files when the evaluation requires the agent to write tests; the benchmark-quality audit and fixture schema document this.
- Bump the zeitwerk campaign version.

## Iteration 120 — Active Job Benchmark References

- Add reference implementations for all 4 Active Job fixtures: a claim-before-side-effect idempotent delivery, bounded `retry_on` for transient timeouts with `discard_on` for invalid state, `enqueue_after_transaction_commit`, and per-account `limits_concurrency`. The fixtures already started from genuine unsolved states.

## Iteration 121 — Observability Benchmark References

- Add reference implementations for the 3 observability fixtures with unsolved starting states: a narrow `InvalidOrderState` → 409 mapping that leaves other errors on the 5xx path, request-id log tags with authorization filtering, and a minimal `checkout.completed` notification. `health-semantics` remains a declared review/preserve task.

## Iteration 122 — Concurrency Benchmark Reference

- The `concurrency-counter` fixture shipped a mutex-synchronized counter and passed everything except the "test changed" check under a no-op agent. The workspace now starts from an unsynchronized read-modify-write that loses updates; the synchronized counter and its tests move to `benchmarks/concurrency/references/`.
- Bump the concurrency campaign version.

## Iteration 123 — Performance Benchmark References

- Both performance fixtures shipped their solution and failed a no-op agent only on the "test changed" check. Workspaces now start from a chained `map … map` intermediate collection and a tenant-less cache key; references (one-pass labels with an allocation test; a versioned, integer-validated tenant/dashboard key whose components cannot be forged) move to `benchmarks/performance/references/`.
- Bump the performance campaign version.

## Iteration 124 — Security Verifier Fix and References

- The `parameterized-query-boundary` security check flagged any `#{term` inside `where(...)`, including the parameterized form the functional check requires (`where("name ILIKE ?", "%#{term}%")`), so the correct solution failed. It now flags interpolation inside the SQL string literal, which is the injection.
- Both security fixtures shipped their solution. Workspaces now start from SQL-string interpolation and an any-signed-in-user policy; references with owner/admin/unrelated/missing-user and hostile-term tests move to `benchmarks/security/references/`.
- Bump the security campaign version.

## Iteration 125 — Ruby-Training Verifier Fixes and References

- `triplet-sum` could never pass: the verifier read `target` from the case instead of `input.target` (`KeyError` on every run), demanded one specific triplet although the evaluation grades "a valid target-sum triplet", and had no `auxiliary_space` heuristic, so the check was always `not_evaluated`. It now accepts any ascending sub-multiset that sums to the target and recognizes an in-place sort with two pointers and no auxiliary collections.
- A missing class or method is now a recorded `functional` failure with evidence instead of an uncaught verifier crash, and `edge_cases` no longer passes when `functional` failed.
- The `chocolate-feast` `exact-threshold` case (`wrappers: 1`, expected 2) was undefined under the evaluation's own rule: at one wrapper per chocolate the exchange never terminates. It is replaced by a well-defined exact-threshold case (4, 2, 2 → 3); the reference rejects thresholds below 2.
- Add reference implementations with tests generated from each evaluation's public cases for all 9 fixtures.
- Bump the ruby-training campaign version.

## Iteration 126 — Ruby-Workshop Verifier Fixes, References, and Full Positive-Control Coverage

- `verify_workshop_eval.rb` crashed instead of failing on unimplemented skeletons (`NotImplementedError` is a `ScriptError`, outside its `rescue StandardError`), and `rails-rest-contract` reported a missing strong-parameter boundary as the status string `strong_parameter_contract_missing`, which never counted as a failure. Both fixed.
- The `service-object` scaffold's `ApplicationService.call(*args)` could not forward keyword arguments under Ruby 3, so `Post::Creator.call(user, status_text:)` raised for every implementation; it now uses `call(...)`.
- Add references with tests for all 8 workshop fixtures, including a warning-free gemspec build for `ruby-gem-boundary`; the registry lists the gemspec and routes as part of those implementation seams.
- Every non-exempt fixture across all 13 campaigns now has a reference. `test/benchmark_fixture_controls_system_test.rb` enforces that coverage and runs each reference's own tests against it.
- Bump the ruby-workshop campaign version.

## Iteration 127 — Slim Always-Loaded Agent Contract

- Cut `AGENTS.md` from 858 lines (74 KB) to 137 lines (9.5 KB). It now holds only the repository-wide operating contract (sequence, context, routing, design, precedence, verification, skill-pack and benchmark integrity, and repository-maintenance rules).
- Move the 42 domain "changes" sections verbatim into their owning skills (for example `skills/rails-action-cable/SKILL.md` → `## Rails Action Cable changes`), so they load only when the skill is routed. Every non-blank line of the previous file appears verbatim in the new file or a skill.
- Point the 33 system tests that pinned those rules at the owning skill instead of `AGENTS.md`.
- The documentation consistency audit enforces a 150-line budget for `AGENTS.md` and rejects domain change sections there.

## Iteration 128 — Merge Duplicate Rails Skills

- Merge six overlapping skills into the deeper skill that owns the same framework boundary: `rails-activerecord` → `rails-active-record`, `rails-controllers` → `rails-action-controller`, `rails-views` → `rails-action-view`, `rails-testing` → `rails-test-engineering`, `rails-best-practices` → `rails-architecture`, `rails-deployment` → `rails-release-engineering`. Each survivor gains the retired skill's guidance under one scoped section, its triggers, and a description clause; every manifest, router, pattern, evaluation, and documentation reference is rewritten and de-duplicated. 91 → 85 skills.
- Keep `rails-security` and `rails-security-engineering` separate: they own different layers (code-level controls versus architecture-level threat modeling) and are each routed independently.
- Record retirements under `retired_skills` in `skill-manifest.yml`; the installer reports the replacement when an upgrade removes a retired skill, covered by a new installer system test. `docs/INSTALLATION.md` lists the mapping.

## Iteration 129 — Code Examples for Every Skill and Pattern

- Add a fenced `## Example` to the 421 patterns that had none (324 Ruby, 20 TSX, 9 TypeScript, 4 JavaScript, 11 ERB, 24 Bash, 6 YAML, 1 SQL, and 22 Markdown runbook/decision tables); the other 11 patterns already carried code. Examples use real Rails, Ruby, React, and TypeScript APIs and were syntax-checked before insertion (`ruby -c`, ERB compiled inside a method, `bash -n`, `node --check`, and `tsc --strict` or vitest with jsdom for TypeScript and React).
- Add a `## Reference example` to the 15 skills without one (React, TypeScript, and stack-minimality families), and replace the `...` placeholder in `ruby-method-design`.
- `scripts/audit_corpus_quality.rb` recognizes `~~~` fences and now fails when any skill or pattern lacks a code example, so coverage cannot regress.

## Iteration 130 — RuboCop in CI and Executable Scripts

- Run `bundle exec rubocop` in the `Validate skills` workflow. A `Gemfile` (lint group only: `rubocop ~> 1.90`, `rubocop-performance`, `rubocop-minitest`, `rubocop-rspec`, `rubocop-thread_safety`) and lockfile pin the toolchain; the skill library, validators, and harness still use only the Ruby standard library.
- Replace the previous `.rubocop.yml`, which could not load: it listed the whole target-application plugin catalog, including three extensions that are not `lint_roller` plugins, `cookstyle` (which replaces RuboCop's defaults with Chef's), `rubocop-changed`, and framework plugins this repository does not use. The catalog stays documented in `data/rubocop/plugins.yml` and `docs/RUBOCOP_PLUGINS.md`. `benchmarks/` is excluded because fixtures and references are digest-pinned measurement infrastructure.
- Apply whitespace-only layout autocorrections (plus leading-dot method chains) to the repository's own Ruby; line length, trailing whitespace inside heredocs, and heredoc indentation are left alone. The remaining 2,686 pre-existing offenses across 90 cops are recorded in `.rubocop_todo.yml`, so CI fails only on new offenses.
- Set the executable bit on the 70 tracked scripts with a shebang that lacked it (39 in `bin/`, 30 in `scripts/`, 1 in `adapters/`).
- `CONTRIBUTING.md` and the README validation section describe the lint step.

## Iteration 131 — Iteration History Out of the README

The README now describes only the current system, and this file became the single ordered home for iteration history.

Changes:

- Move every iteration narrative out of `README.md` into the new `docs/ITERATIONS.md`, one section per iteration in ascending order. It merges the 65 README narratives (previously in six places and out of order) with the `CHANGELOG.md` entries, covering Iterations 41–131. The eleven narratives that had no number in their heading (for example "Rails Encryption and Credentials Engineering") are filed under the iteration their text named.
- `docs/ITERATIONS.md` now carries the current-milestone line. The README keeps only the current system (quick start, coverage, architecture, validation, installation, and a rewritten status section with no iteration numbers) and drops from 1,018 to 715 lines.
- `scripts/audit_documentation_consistency.rb`, `scripts/audit_release_readiness.rb`, and `scripts/audit_repository_completeness.rb` read the milestone and release-history markers from `docs/ITERATIONS.md`. The documentation audit also rejects iteration mentions in the README, requires ascending order, and requires a section for the latest changelog iteration, each covered by a new regression test.
- `AGENTS.md`, `CONTRIBUTING.md`, the README contributing steps, and the implementation handoff describe where iterations are recorded.
