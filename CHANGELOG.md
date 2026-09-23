# Changelog

## Unreleased

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
