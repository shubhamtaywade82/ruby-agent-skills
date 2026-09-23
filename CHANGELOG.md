# Changelog

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
