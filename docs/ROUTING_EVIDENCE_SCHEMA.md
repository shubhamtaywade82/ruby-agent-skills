# Routing Experiment Evidence Schema

Protocol version: 1

A routing evidence package is an auditable record of one completed baseline/candidate routing experiment.

## Required top-level fields

- `protocol_version`
- `evidence`
- `campaign`
- `campaign_version`
- `routing_case_count`
- `requested_repetitions`
- `repository`
- `agent`
- `compatibility`
- `artifacts`
- `metrics`
- `gate`
- `replay`
- `comparison_provenance` (when the comparison uses Iteration 85+ provenance)

## Artifact identity

Every material artifact is represented by:

```json
{
  "path": "/path/to/artifact",
  "sha256": "64-character-hex-digest"
}
```

Routing contracts additionally record their byte size.

Required hashed artifacts:

- baseline campaign result
- candidate campaign result
- comparison result
- baseline routing contract
- candidate routing contract
- skill manifest
- routing campaign manifest
- routing result schema
- remediation policy

## Compatibility

The evidence package records:

- same agent configuration
- same campaign
- same campaign version
- same routing case count
- same repetition count

All compatibility flags must be `true`.

## Evidence policy

Evidence packages may be stored outside the source repository or attached to a release/benchmark record. They must not contain secrets or raw model credentials.

A result without an evidence package remains a valid experiment result, but it is not considered fully auditable release evidence.



## Repository integrity

Iteration 61 records repository identity and worktree state:

- `git_sha`
- `git_branch`
- `git_status`
- `worktree_clean`
- `status_entries`

Evidence packaging rejects a dirty worktree by default. `--allow-dirty` is an explicit opt-in for experiments that intentionally capture an uncommitted routing-contract change.

## Evidence verification

`bin/routing-evidence-verify` independently validates routing evidence before it is stored or attached to a benchmark/release record.

Default verification checks protocol identity, required fields, compatibility flags, remediation-gate state, digest shape, and repository worktree policy. `--check-files` additionally recalculates SHA-256 for every recorded artifact path and rejects mismatches.


## Comparison provenance

When `routing-compare` emits provenance, experiment evidence preserves the same block under `comparison_provenance`. It binds:

- the exact baseline campaign path and SHA-256;
- the exact candidate campaign path and SHA-256;
- the remediation policy path and SHA-256;
- the comparator implementation path and SHA-256.

`bin/routing-compare-verify` recomputes the comparison from these inputs and rejects a stored comparison whose JSON differs from the recomputed result.

`bin/routing-experiment` runs this comparison verifier, then packages and verifies the final experiment evidence before reporting success.
