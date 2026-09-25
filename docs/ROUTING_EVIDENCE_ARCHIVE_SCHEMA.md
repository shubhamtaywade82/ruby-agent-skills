# Routing Evidence Archive Schema

Protocol version: 1

An archive is a portable historical snapshot of completed routing evidence. It accepts both skill-routing-experiment-v1 packages and skill-routing-campaign-v1 packages, and each completed archive can be independently verified without access to the original source paths.

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

`bin/routing-archive` invokes the relevant evidence verifier before copying any artifact. It then recalculates every copied artifact digest and aborts on mismatch. After writing the manifest, it invokes `bin/routing-archive-verify` so the produced archive is itself checked before the command succeeds.

Archives therefore preserve the exact measured inputs and outputs used to create the evidence package. The archive itself must not be treated as a benchmark result unless its evidence package has a passing experiment gate.

Generated archives are intended to live outside the source repository unless explicitly curated as release artifacts.

## Evidence types

- Experiment evidence uses skill-routing-experiment-v1 and its baseline/candidate remediation gate.
- Single-campaign evidence uses skill-routing-campaign-v1 and the Iteration 63 intake gate.
- Both evidence types require artifact hashes.
- Campaign evidence must carry intake.verified = true.
- `bin/routing-archive-verify <archive-dir>` independently validates the archived manifest, evidence identity, artifact set, artifact hashes/byte sizes, archive-relative paths, and optional analysis provenance.
- The release gate uses the archive verifier for the archive containing the supplied evidence package.
