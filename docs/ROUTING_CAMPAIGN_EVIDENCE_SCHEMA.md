# Routing Campaign Evidence Schema

Protocol version: 1

A campaign evidence package captures one completed public routing campaign together with its aggregate, confusion report, routing contract, repository metadata, and raw per-run model outputs.

## Required fields

- `protocol_version`
- `evidence` = `skill-routing-campaign-v1`
- `campaign`
- `campaign_version`
- `routing_case_count`
- `requested_repetitions`
- `repository`
- `agent`
- `campaign_metrics`
- `analysis`
- `artifacts`
- `intake`
- `replay`

## Integrity

The package is accepted only after `bin/routing-campaign-verify` passes.

Every artifact records its absolute path, SHA-256 digest, and byte size.

Raw per-run result files are included explicitly so that aggregate campaign JSON cannot become the only preserved evidence.

Dirty worktrees are rejected by default and require explicit `--allow-dirty`.

## Evidence boundary

This package records observed model output. It does not convert routing measurements into a quality score or claim that one model is better than another.

Generated evidence should remain outside the source repository unless intentionally curated as a release artifact.