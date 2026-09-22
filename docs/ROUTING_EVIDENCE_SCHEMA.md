# Routing Experiment Evidence Schema

Protocol version: 1

A routing evidence package is an auditable record of one completed baseline/candidate routing experiment.

## Required top-level fields

- `protocol_version`
- `evidence`
- `repository`
- `agent`
- `compatibility`
- `artifacts`
- `metrics`
- `gate`
- `replay`

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

