# Routing Evidence Archive Schema

Protocol version: 1

An archive is a portable historical snapshot of completed routing evidence. It accepts both skill-routing-experiment-v1 packages and skill-routing-campaign-v1 packages.

## Required structure

```text
<archive-root>/
└── <campaign>/
    └── <model>/
        └── <git-sha>/
            ├── evidence.json
            ├── ARCHIVE_MANIFEST.json
            └── artifacts/
```

The archive key is deterministic from:

- routing campaign id;
- agent model;
- repository Git SHA.

An existing archive directory is never overwritten.

## Archive manifest

Required top-level fields:

- `protocol_version`
- `archive`
- `archive_id`
- `captured_at`
- `source_evidence`
- `repository`
- `agent`
- `compatibility`
- `gate`
- `artifacts`

Every archived artifact records its original source path, archive-relative path, SHA-256 digest, and byte size.

## Integrity policy

`bin/routing-archive` invokes `bin/routing-evidence-verify --check-files` before copying any artifact. It then recalculates every copied artifact digest and aborts on mismatch.

Archives therefore preserve the exact measured inputs and outputs used to create the evidence package. The archive itself must not be treated as a benchmark result unless its evidence package has a passing experiment gate.

Generated archives are intended to live outside the source repository unless explicitly curated as release artifacts.

## Evidence types

- Experiment evidence uses skill-routing-experiment-v1 and its baseline/candidate remediation gate.
- Single-campaign evidence uses skill-routing-campaign-v1 and the Iteration 63 intake gate.
- Both evidence types require artifact hashes.
- Campaign evidence must carry intake.verified = true.
