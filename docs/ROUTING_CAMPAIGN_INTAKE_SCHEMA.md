# Routing Campaign Intake Schema

Protocol version: 1

`bin/routing-campaign-verify` is the acceptance gate for externally produced public routing campaigns.

## Acceptance requirements

The submitted campaign must:

- use protocol version 1;
- identify the configured public campaign and version;
- contain every public routing case exactly once;
- request the configured repetition count;
- contain exactly case_count × repetitions runs;
- mark every case and the whole campaign complete;
- provide provider and model metadata;
- use only registered primary and secondary skills;
- never place the observed primary skill in the secondary list.

For the current public campaign this means **14 routing cases × 3 repetitions = 42 completed runs**.

## Purpose

This command is an intake boundary, not a scoring system. It does not alter model results, repair missing runs, or infer a score. A campaign either satisfies the declared experimental protocol or is rejected.

The verifier should run before `bin/routing-evidence` and `bin/routing-archive` when accepting results from an external model runtime.

The public default is 3 repetitions per case. Explicit experimental overrides are supported through `--expected-repetitions` and must still cover the full public case set.
