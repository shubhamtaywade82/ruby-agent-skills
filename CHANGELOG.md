## Iteration 101 — Verified Routing History

- Add `routing-history --verify` for integrity-gated longitudinal history generation.
- Validate every indexed archive against its independent archive verifier and manifest identity.
- Keep historical model reporting descriptive-only.

## Iteration 100 — Matrix Report Integrity Gate

- Add `routing-model-matrix-report --verify` to reject histories containing unverified archives.
- Reuse the independent routing history verifier before producing descriptive reports.

## Iteration 99 — Routing History Integrity

- Add `bin/routing-history-verify` for independent historical evidence validation.
- Detect archive identity drift, duplicate archive IDs, missing entries, and archive-integrity failures.
- Add regression coverage for tampered historical archives.

## Iteration 98 — Self-Verifying Release Evidence

- Make release bundle creation replay its own manifest and component verifiers before reporting success.
- Add bundle-aware release readiness through `routing-release-check --bundle`.
- Require the public release component in bundle verification.

## Iteration 97 — Verified Release Evidence Bundle

- Add a deterministic release-evidence bundle composer for verified public campaign evidence.
- Freeze a copy of the release policy inside the bundle.
- Preserve optional verified matrix evidence and external-only hidden benchmark receipts.

## Iteration 96 — Hidden Benchmark Receipt Verification

- Add a standalone verifier for safe hidden-benchmark intake receipts.
- Reassert the external-only boundary and reject hidden cases, prompts, and gold-label payloads.
- Verify the recorded external artifact hash and byte size when requested.

## Iteration 95 — Routing Release Evidence Bundle

- Compose a release-evidence directory from verified public campaign evidence and an immutable archive.
- Record SHA-256 and byte-size provenance for bundle components.
- Add independent bundle verification that replays underlying evidence/archive verifiers.

## Iteration 97 — Verified Release Evidence Bundle

- Add a deterministic release-evidence bundle composer for verified public campaign evidence.
- Freeze a copy of the release policy inside the bundle.
- Preserve optional verified matrix evidence and external-only hidden benchmark receipts.

## Iteration 96 — Hidden Benchmark Receipt Verification

- Add a standalone verifier for safe hidden-benchmark intake receipts.
- Reassert the external-only boundary and reject hidden cases, prompts, and gold-label payloads.
- Verify the recorded external artifact hash and byte size when requested.

## Iteration 95 — Routing Release Evidence Bundle

- Compose a portable release evidence directory from a verified public campaign evidence package and immutable archive.
- Record SHA-256 and byte-size provenance for bundle components.
- Add independent bundle verification that replays underlying evidence/archive verifiers.

## Iteration 94 — Verified Multi-Model Matrix Evidence

- Emit a single `matrix-evidence.json` binding the matrix plan, each completed model evidence package, and each immutable archive tree.
- Add independent aggregate evidence verification with underlying per-model verifier replay.

## Iteration 93 — Matrix Evidence Integrity Verification

- Add `bin/routing-model-matrix-evidence-verify` for plan/model-set/hash integrity checks.
- Detect tampered model evidence, archive trees, and matrix-plan provenance.
- Reuse the existing campaign evidence and archive verifiers during `--check-files` validation.

## Iteration 92 — Matrix Evidence Aggregation

- Make a completed multi-model campaign automatically produce and verify aggregate evidence.
- Keep failed or incomplete model results ineligible for aggregate evidence.
- Add system coverage for aggregation, incompleteness rejection, and plan tampering.

## Iteration 91 — End-to-End Experiment Evidence Finalization

- Make baseline/candidate routing experiments replay-verify comparison provenance before packaging evidence.
- Automatically package `evidence.json` after a successful comparison gate.
- Verify final experiment evidence with recorded artifact hashes before reporting success.

## Iteration 90 — Routing Comparison Replay Verification

- Add `bin/routing-compare-verify` to independently recompute a stored comparison.
- Bind verification to the recorded baseline/candidate inputs, remediation policy, and comparator implementation hashes.
- Reject comparison reports that differ from the recomputed result.

## Iteration 89 — Routing Comparison Provenance Binding

- Record SHA-256 provenance for the exact baseline campaign, candidate campaign, remediation policy, and comparator implementation.
- Preserve comparison provenance in experiment evidence.
- Add regression coverage for comparison provenance and tamper detection.

## Iteration 88 — End-to-End Campaign Finalization

- Make campaign import regenerate the canonical routing analysis before evidence packaging.
- Make the external campaign handoff run import, evidence verification, and optional archive creation automatically.
- Add regression coverage for the complete campaign finalization path.

## Iteration 87 — Design-Pattern Corpus Revision

- Versioned the design-pattern public campaign from v1 to v2 after expanding it from 18 to 24 cases.
- Added a benchmark-quality guard for campaign corpus version/source identity.
- Synchronized public benchmark documentation with the new campaign revision.

## Iteration 86 — Pattern Selection Restraint Integration

- Expanded the design-pattern evaluation corpus with six negative-selection cases where the correct choice is to introduce no pattern.
- Expanded the public design-pattern campaign from 18 to 24 cases.
- Registered all six new evaluations and fixture contracts.
- Added campaign-quality coverage requiring the public campaign to cover every public design-pattern evaluation.
- Documented the integration with stack-minimality and the existing pattern-selection verifier.

## Iteration 85 — Stack Minimality Evaluation Guardrails

- Extended repository completeness auditing to verify the stack-minimality evaluation registry against the filesystem.
- Added schema-level system coverage for every stack-minimality evaluation.
- Kept the adversarial corpus focused on security, accessibility, performance evidence, migration safety, service boundaries, and React state semantics.

## Iteration 84 — Stack Minimality Adversarial Evaluation Expansion

- Added adversarial evaluations for security, accessibility, performance evidence, migration safety, service-boundary decisions, and React derived state.
- Expanded the stack-minimality corpus from 7 to 13 evaluation contracts.
- Hardened the system test to require the complete minimality evaluation set.

## Iteration 82 — Installed Stack Minimality Tooling

- Added a deterministic `bin/stack-minimality` tool for shortcut-debt and real Git-diff evidence reports.
- Extended the installer to ship the tool with the installed pack and record its SHA-256 provenance.
- Extended installed-pack verification to reject tampered or missing minimality tooling.
- Added system coverage for tool execution and installer integrity.

## Iteration 81 — Ponytail-inspired Stack Minimality

- Added six stack-minimality skills adapted from Ponytail for Ruby, Rails, React, TypeScript, and PostgreSQL.
- Added 14 implementation patterns covering Rails conventions, Active Record, PostgreSQL invariants/query evidence, React state, TypeScript boundaries, dependencies, modularity, and shared-root bug fixes.
- Added seven evaluation contracts and system-test coverage for manifest/routing completeness.
- Integrated stack minimality into skill routing, AGENTS guidance, README, and canonical validation.
- External Ponytail benchmark results are treated as source context, not as measurements of this repository.

## Iteration 83 — Matrix Resume Integrity

- Revalidate completed-and-archived model results with the campaign evidence verifier during matrix resume.
- Revalidate the recorded archive with the independent routing archive verifier before reusing a checkpoint result.
- Add regression coverage for the resume trust boundary.

## Iteration 82 — Routing Evidence Archive Integrity

- Added `bin/routing-archive-verify` for standalone archive integrity validation.
- Made archive creation self-verify before reporting success.
- Made release readiness verify the exact archived package containing the supplied evidence.
- Added artifact path traversal and symlink-boundary checks.

## Iteration 81 — Routing Analysis Provenance Binding

- Bound preserved `routing-report.json` to an independent recomputation from `campaign.json` during evidence packaging.
- Extended `routing-campaign-evidence-verify --check-files` to replay the analyzer and reject report/evidence/source-metric drift.
- Added regression coverage for tampered routing analysis and upgraded archive fixtures to use semantically valid campaign/report artifacts.

## Iteration 80 — Routing Evidence Integrity Gate

- Hardened `routing-compare` to recompute primary accuracy, secondary recall, and unexpected-secondary metrics directly from recorded runs.
- Added regression coverage proving tampered campaign metrics are rejected.

# Changelog

## Iteration 79 — Documentation consistency & empirical readiness

- Synchronized README inventory and current implementation status with the verified Iteration 78 repository state.
- Removed the stale validation inventory and stale Iteration 76 current-status claim from README.
- Extended the repository completeness audit to validate the documented dedicated system/contract test count.
- Hardened routing analysis with structural validation and recomputed primary/secondary metrics, confusion data, and repetition stability.
- Added a routing-campaign analysis guide and release checks for README/CHANGELOG/inventory consistency.


## Iteration 78 — Verified agent installation doctor

- Added `bin/skill-pack-doctor` for deterministic installed-pack health checks.
- Registered the doctor in the skill manifest, repository completeness audit, canonical validator, README, and implementation handoff.
- Added success/tamper system coverage for the installed-pack doctor.


## Iteration 77 — React + TypeScript engineering pack

- Added dedicated TypeScript core, type-design, and runtime-contract skills.
- Added React component, state/effects, data-fetching, testing, accessibility/performance, and architecture skills.
- Added 24 React/TypeScript implementation patterns and 9 public evaluations.
- Added routing and system-test coverage for the new frontend skill family.
- Preserved the existing evidence-first, version-aware, repository-inspection workflow.


## Unreleased

### Iteration 76 — Implementation hardening

- Added resumable multi-model routing execution with provenance-bound matrix checkpoints.
- Added a provenance-aware installer that installs skills and reusable patterns and cleans removed skills on upgrade.
- Added independent installed-pack verification for exact skill/pattern inventory and manifest/routing integrity.
- Added installation, matrix-resume, and verifier system-test coverage.
- Hardened `RubyAgentSkills::SkillPack` materialization with manifest provenance and deterministic pattern resolution.


### Routing campaign execution

- Added checkpointed routing evaluation after every repetition.
- Added hash-bound per-run receipts and explicit `--resume` recovery.
- Resume rejects incompatible campaign, routing-contract, model, or runtime configuration and never synthesizes missing results.


### CI toolchain maintenance

- Upgraded the validation workflow from `actions/checkout@v4` to `actions/checkout@v7`.
- Added an executable CI toolchain audit and canonical system-test coverage for action-runtime compatibility.


### Rails benchmark coverage

- Expanded the Rails public benchmark campaign from 4 to 9 evaluations across security and identity boundaries.
- Added deterministic fixtures for authentication, authorization, cross-boundary authorization, encryption/credentials, and serialization/Global ID.

### Repository hardening

- Completed the Rails skill-system completeness audit.
- Hardened benchmark campaign and fixture validation.
- Added release/public-readiness checks and publication metadata.
- Kept inventory, routing, evaluation, and CI verification synchronized.
