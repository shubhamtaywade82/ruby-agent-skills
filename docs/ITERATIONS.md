# Iterations

The repository is built in numbered iterations. This file is the ordered history, oldest first: one section per iteration with a short summary. `CHANGELOG.md` keeps the itemized changes, newest first.

> **Current milestone:** Iteration 151 — Benchmark Documentation and Reconciliation Audit

No entry was recorded for iterations before 41, or for 68, 80, 107, and 108.

Iterations 101 and later summarize in one line what `CHANGELOG.md` records in full; see `CHANGELOG.md` for the itemized changes behind each of those entries.

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

Routing history can be generated and reported with `--verify`, replaying archive integrity checks before the historical dataset is reported.

## Iteration 102 — Documentation Consistency Contract

Added an executable documentation consistency audit covering the README, implementation handoff, changelog milestone, filesystem inventory, and manifest identity.

## Iteration 103 — Release Bundle Component Provenance

The release bundle verifier now binds bundled public evidence and optional matrix evidence to the same archive, campaign, and repository revision.

## Iteration 104 — Verified Routing History Boundary

Routing history now rejects archives outside the declared root and records a verified SHA-256 digest of the indexed archive set.

## Iteration 105 — Release Infrastructure

Added the reproducible release archive builder, offline installer support, and the tag-triggered release workflow.

## Iteration 106 — Independent Release Archive Verification

Added a standalone release archive verifier, independent of the builder's self-test, and wired it into `bin/validate`.

## Iteration 109 — Release Documentation Polish

Deduplicated the repeated README iteration sections and refreshed the current-status and quick-start documentation to match the release infrastructure.

## Iteration 110 — Multi-Region Data Boundary Pattern

Added the `multi-region-data-boundary` implementation pattern and routed it into the distributed-systems skill.

## Iteration 111 — Corpus Quality & Benchmark Coverage

Added `scripts/audit_corpus_quality.rb` with exact corpus measurements and an explicit static-only benchmark coverage contract.

## Iteration 112 — Release File-Level Provenance & Publication Gate

Release archives now record file-level SHA-256/byte-size provenance, and the release workflow verifies it before publishing.

## Iteration 113 — Benchmark Fixture Controls

Fixed a fixture-registry bug that silently skipped 9 of 27 Rails evaluations, then removed shipped answers from 24 fixtures that passed under a no-op agent.

## Iteration 114 — Rails Benchmark Reference Solutions

Added reference implementations for the 12 Rails campaign fixtures that lacked one; all 27 Rails fixtures now have a positive control.

## Iteration 115 — Design-Pattern Benchmark Reference Solutions

Added reference implementations for the 14 design-pattern campaign fixtures that lacked one; all 24 now have a positive control.

## Iteration 116 — Database-Engineering Verifier Repair and References

Repaired a verifier whose regexes had lost every backslash, then added references after its 5 fixtures turned out to already ship the finished change.

## Iteration 117 — Production-Runtime Verifier Repair and References

Repaired a verifier that could not parse, fixed two miscalibrated checks, then added references for its 5 fixtures.

## Iteration 118 — Test-Engineering Verifier Repair and References

Repaired an unparseable verifier, made its `tests` check honestly static, removed agent-editable meta-tests, and added references.

## Iteration 119 — Zeitwerk Verifier Repair and References

Repaired a verifier whose escapes had been corrupted, then added references for both fixtures.

## Iteration 120 — Active Job Benchmark References

Added reference implementations for all 4 Active Job fixtures, which already started from genuine unsolved states.

## Iteration 121 — Observability Benchmark References

Added reference implementations for the 3 observability fixtures with unsolved starting states.

## Iteration 122 — Concurrency Benchmark Reference

Replaced the `concurrency-counter` fixture's shipped solution with an unsynchronized starting state and moved the fix to its reference.

## Iteration 123 — Performance Benchmark References

Replaced both performance fixtures' shipped solutions with genuine starting states and moved the fixes to references.

## Iteration 124 — Security Verifier Fix and References

Fixed a security check that flagged the required parameterized-query solution as unsafe, then added references for both fixtures.

## Iteration 125 — Ruby-Training Verifier Fixes and References

Fixed a verifier that could never pass `triplet-sum`, corrected an ill-defined test case, and added references for all 9 fixtures.

## Iteration 126 — Ruby-Workshop Verifier Fixes, References, and Full Positive-Control Coverage

Fixed two verifier bugs and a scaffold's keyword-argument bug, then added references for all 8 fixtures, completing positive-control coverage across all 13 campaigns.

## Iteration 127 — Slim Always-Loaded Agent Contract

Cut `AGENTS.md` from 858 to 137 lines by moving its 42 domain-specific sections into the skills that own them.

## Iteration 128 — Merge Duplicate Rails Skills

Merged six overlapping Rails skills into the deeper skill that owns the same framework boundary (91 → 85 skills).

## Iteration 129 — Code Examples for Every Skill and Pattern

Added a code example to the 421 patterns and 15 skills that had none; the corpus audit now requires one.

## Iteration 130 — RuboCop in CI and Executable Scripts

Wired `bundle exec rubocop` into CI with a loadable config and offense baseline, and set the executable bit on 70 scripts.

## Iteration 131 — Iteration History Out of the README

Moved iteration history out of the README into this file, one section per iteration, oldest first.

## Iteration 132 — Trim Duplicated Iteration History

Trimmed this file's own Iteration 101+ entries from full CHANGELOG copies down to one-line summaries.

## Iteration 133 — Release v1.1.0 Preparation

Pinned the README quick-start to `v1.1.0`, corrected the stale `RELEASE.md` inventory, and added an audit so it cannot drift again.

## Iteration 134 — Rails and React Integration Seam

Added the `rails-react-integration` skill, five cross-stack patterns, cross-stack routing, and the first React routing cases (public campaign version 2: 18 cases).

## Iteration 135 — RSpec coverage in rails-test-engineering

Added RSpec guidance to `rails-test-engineering` and six RSpec patterns whose examples were run in a Rails 8.0 app.

## Iteration 136 — Progressive Disclosure for Oversized Skills

Split the 17 largest skills into an operating `SKILL.md` plus on-demand `references/` files, and made `bin/validate` enforce a 500-line / ~5,000-token `SKILL.md` limit with one-level-deep references.

## Iteration 137 — Change Review and Adapted Engineering Disciplines

Added the two-axis `change-review` skill and folded feedback-loop debugging, seam-first TDD, glossary and decision-record discipline, and deep-module design into existing skills, adapted from mattpocock/skills (MIT).

## Iteration 138 — Tracker-Neutral Planning Layer

Added five planning skills (interview, spec, tickets, wayfinder, tracker) over one backend-neutral item model, with local Markdown validated by a bundled script and GitHub Issues as the second backend.

## Iteration 139 — Rails Data Modeling

Added `rails-data-modeling`, which decides what the schema represents (facts, keys, normal forms, constraints, hierarchies, JSON boundary, history, denormalization) before associations and migrations, with a table of removed Rails APIs and their replacements.

## Iteration 140 — Rails Data Modeling: Decision Framework, Worked Examples, and Cross-Skill Boundaries

Gave `rails-data-modeling` a 14-question decision framework, a version-safety section, a review procedure, and six worked Rails 8.1 examples. Its Rails claims were checked against the 8.1.4 guides. Made its boundary explicit in `rails-active-record`, `rails-associations`, `rails-database-engineering`, and `ruby-domain-modeling`.

## Iteration 141 — Fix Ambiguous-Pattern False Positive for Dual-Registered Patterns

Fixed `SkillPack#resolve_pattern` raising `ambiguous pattern` for a pattern intentionally registered under two manifest families, which broke `bin/agent-benchmark` against the Rails campaign for `credentials-testing-contract`.

## Iteration 142 — Training-Corpus Review Heuristics, Regression-Surface Planning, and Two New Algorithm Benchmarks

Folded reviewer heuristics from a personal Ruby/Rails training corpus into `change-review` and `rails-test-engineering`, added a regression-surface step to `planning-spec`, and added two `ruby-training` algorithm benchmarks (`bubble-sort`, `equilibrium-index`) continuing the corpus's `allerin-ruby-set-*` fixtures.

## Iteration 143 — Consumer-Side Change Verification

Added `bin/verify-change`, a provider-neutral verifier that runs a downstream project's own gates (RuboCop, tests, Brakeman, bundler-audit, `zeitwerk:check`) plus deterministic structural checks and writes an evidence report that never reports an unrun check as passed. It ships in the installer and the release archive.

## Iteration 144 — Agent Skills Frontmatter Contract Validation

Frontmatter validation is executable for the Agent Skills contract, including name, description, compatibility, metadata, license, and allowed-tools constraints.

## Iteration 145 — Executable Runtime Compatibility Gate

Version requirements are enforced with RubyGems semantics; runtime profiles and compatibility reports travel through evaluation and installation paths, with explicit version-bound patterns.

## Iteration 146 — Deprecation Governance

Deprecated frontend skills now have explicit migration scope, replacements, migration documentation, and evidence-backed removal gates.

## Iteration 147 — Executable Framework Drift Detection

A bounded Rails framework-drift registry and Ruby-code-fence scanner detect evidence-backed API drift and require explicit suppressions.

## Iteration 148 — Validation Gate Integrity Preflight

An independent integrity test protects the validation gate itself from root/path corruption or accidental removal of critical checks.

## Iteration 149 — Ruby and Rails Platform Foundations

Added explicit foundational ownership for the platform setup and project-creation lifecycle that was missing from the prior skill tree: `ruby-toolchain`, `rails-application-bootstrap`, and `ruby-gem-development`. Added routing contracts, evaluations, and registration so agents can distinguish machine/toolchain setup from runtime compatibility, `rails new` from in-app generators, and gem authoring from application dependency installation.


## Iteration 150 — Hardening Reconciliation and Ruby Platform Benchmark Coverage

Reconciled Iterations 144–148 onto the Iteration 149 release line, added independent benchmark fixtures/references for Ruby toolchain and gem development, and moved those evaluations from static-only to controlled benchmark-backed coverage.

## Iteration 151 — Benchmark Documentation and Reconciliation Audit

Recorded the closed #80 reconciliation, corrected stale controlled-benchmark documentation, documented the remaining boundary between verified benchmark infrastructure and actual external-agent empirical execution, and exercised both Ruby foundation campaigns end-to-end in CI with the real benchmark runner.
