# Implementation Handoff

## Repository-side implementation status

The skill library, pattern library, corpus-quality audit, routing infrastructure, evidence pipeline, provenance controls, resumable execution, multi-model matrix runner, verified installer, React/TypeScript engineering layer, and stack-minimality layer are implemented in the current release line. The runtime compatibility gate, machine-verifiable deprecation governance, and executable framework-drift detection layers are implemented through Iteration 147.

Current inventory:

- 93 skills
- 446 implementation patterns
- 476 evaluation cases
- 97 system/contract tests

## Corpus quality and evaluation coverage

Run the corpus audit independently:

    ruby scripts/audit_corpus_quality.rb

The audit reports exact measurements rather than estimates for:
- skill reference/executable example coverage and example-language distribution;
- pattern code/example coverage, implementation anchors, failure modes, and testing guidance;
- evaluation case integrity and grading-dimension depth;
- benchmark-backed versus explicitly static-only evaluation coverage;
- routing trigger collisions and stale manifest skill paths.

The public evaluation corpus has 130 evaluation files / 476 cases. Campaigns provide empirical coverage for 102 evaluation files; the remaining 28 files / 66 cases are explicitly classified as `coverage: static-only` and are not represented as real-model benchmark results.

## Release archive verification

The release archive builder records file-level SHA-256/byte-size provenance in `RELEASE.json`. Independently verify a built archive with:

    ruby scripts/verify_release_archive.rb ./dist/ruby-agent-skills-vX.Y.Z.tar.gz --checksums ./dist/SHA256SUMS --check-files

The verifier rejects unsafe tar entries before extraction, validates release metadata and inventory, checks the published archive checksum, verifies every recorded file's size and digest, and rejects files shipped without a provenance record. The tag-triggered release workflow runs this verifier before creating the GitHub Release.