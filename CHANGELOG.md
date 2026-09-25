## Iteration 81 — Ponytail-inspired Stack Minimality

- Added six stack-minimality skills adapted from Ponytail for Ruby, Rails, React, TypeScript, and PostgreSQL.
- Added 14 implementation patterns covering Rails conventions, Active Record, PostgreSQL invariants/query evidence, React state, TypeScript boundaries, dependencies, modularity, and shared-root bug fixes.
- Added seven evaluation contracts and system-test coverage for manifest/routing completeness.
- Integrated stack minimality into skill routing, AGENTS guidance, README, and canonical validation.
- External Ponytail benchmark results are treated as source context, not as measurements of this repository.

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
