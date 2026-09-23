# Changelog

## Unreleased

### Inventory drift guard

- Extended the repository completeness audit to verify every README inventory count (skills, implementation patterns, evaluation cases, dedicated system/contract tests, and manifest version) against repository-derived counts, failing validation on drift.
- Added tamper-proof system tests that plant stale counts in an isolated repository copy and assert the audit rejects each drifted row.

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
