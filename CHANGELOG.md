# Changelog

## Iteration 113 — Benchmark Fixture Controls

- Add `RubyAgentSkills::FixtureRegistry` and resolve campaign fixtures through each `fixtures.yml` registry in both `bin/benchmark campaign` and `scripts/audit_benchmark_quality.rb`. Previously the runner ignored registry `root` overrides, so 9 of 27 Rails campaign evaluations aborted with `fixture not found` while the audit passed.
- Abort a campaign before any agent run when an evaluation does not resolve to a fixture.
- Remove shipped answers from 24 fixtures (14 Rails, 10 design-patterns) that passed their verifier with a no-op agent. Their workspaces now hold skeletons (`NotImplementedError` bodies) or, for the two refactor tasks, the pre-refactor code; the prior implementations move to `benchmarks/<set>/references/<id>/` outside the agent workspace.
- Declare `observability/health-semantics` as `noop_expected: pass` with a rationale: it is a review/preserve task where no change is correct.
- Add `test/benchmark_fixture_controls_system_test.rb`: every campaign fixture must fail under a no-op agent unless declared otherwise, and every reference must pass its verifier. Register it in `bin/validate`.
- Extend the benchmark-quality audit to reject references inside agent workspaces, references carrying non-implementation files, orphaned references, and undeclared no-op exemptions.

## Iteration 112 — Release File-Level Provenance & Publication Gate

- Record `protocol_version` and file-level SHA-256/byte-size provenance for every shipped file in `RELEASE.json`, computed from the staged archive tree.
- Extend `scripts/verify_release_archive.rb` with pre-extraction tar listing safety (regular files/directories only, no absolute or parent-traversal names), protocol-version enforcement, file-record containment, and `--check-files` verification of every file's size/digest plus rejection of unrecorded shipped files.
- Gate the tag-triggered release workflow on `verify_release_archive.rb --checksums dist/SHA256SUMS --check-files` before `gh release create`.
- Extend release verification regression coverage to tampered file content, injected unrecorded files, unknown protocol versions, escaping file records, symlink entries, and the workflow publication gate.

## Iteration 111 — Corpus Quality & Benchmark Coverage

- Add `scripts/audit_corpus_quality.rb` with exact corpus measurements for skill examples, executable examples, pattern implementation anchors, failure/testing guidance, evaluation case integrity, grading depth, benchmark coverage, routing trigger collisions, and stale manifest paths.
- Register the corpus-quality audit and system test in `bin/validate`.
- Replace the ambiguous public-evaluation benchmark warning with an explicit coverage contract: campaign-backed evaluations are empirical; the 13 stack-minimality and 9 React/TypeScript evaluation files are declared `coverage: static-only`.
- Extend benchmark-quality tests to enforce the 22-file static-only classification.
- Make release archive system-test inventory expectations derive from `skill-manifest.yml` rather than hard-coded counts.

## Iteration 110 — Multi-Region Data Boundary Pattern

- Add the `multi-region-data-boundary` implementation pattern: region routing, authoritative write ownership, data-residency enforcement at the storage layer, replication lag budgets, fenced failover with stated RPO/RTO, and conflict handling for the failover window.
- Wire the pattern into the `rails-distributed-systems` skill (design guidance, review checklist, and anti-pattern), the skill manifest (registry path plus multi-region/data-residency/region-failover triggers), and the router pattern-selection matrix.
- Correct the README validation-suite prose summary to the actual system/contract test count (82), closing a prose-only drift the inventory table guard could not see.

## Iteration 109 — Release Documentation Polish

- Deduplicate the repeated Iteration 95–97 sections in the README and restore a single ordered iteration narrative (92–104) including the previously orphaned Iteration 98 entry.
- Refresh the README "Current implementation status" section to the current milestone, including the release infrastructure: reproducible checksummed archives, offline installation, the tag-triggered release workflow, and published GitHub releases.
- Add a README quick start with the direct release-archive download, git checkout, and installation verification commands; link the Installation section to the releases page.

## Iteration 106 — Independent Release Archive Verification

- Add a standalone release archive verifier independent of the archive builder's self-test.
- Verify release metadata, skill/pattern inventory, required agent-facing paths, archive safety, and optional published SHA-256 checksums.
- Add regression coverage and wire the verifier into `bin/validate`.

## Iteration 105 — Release Infrastructure

- Add `scripts/build_release_archive.rb`: deterministic, reproducible release archive with embedded `RELEASE.json` provenance, SHA-256 checksums, and generated release notes.
- Extend `bin/install` with offline archive support: a plain local directory (an extracted release archive) installs directly without git, recording release provenance; the installer also self-detects when it runs from an extracted archive or a repository checkout.
- Add `.github/workflows/release.yml`: tag-triggered release CI that validates, builds, self-tests, checks reproducibility, and publishes the GitHub Release with archive and checksums.
- Add `test/release_archive_system_test.rb` covering archive contents, provenance, offline install, verification, and reproducibility.
- Add `RELEASE.md` documenting the release definition and process; document offline archive installs in `docs/INSTALLATION.md` and `README.md`.

## Iteration 104 — Verified Routing History Boundary

- Reject history entries whose archive paths resolve outside the declared archive root.
- Record archive-manifest SHA-256 provenance for every indexed archive.
- Add an aggregate archive-set SHA-256 to generated history and verify it during replay.
- Add regression coverage for archive-root escape and provenance requirements.

## Iteration 103 — Release Bundle Component Provenance

- Bind bundled public evidence to its archive manifest by source-evidence hash and shared campaign/repository/agent identity.
- Require optional matrix evidence to match the public campaign and repository revision.
- Add regression coverage for release component identity binding.

## Iteration 102 — Documentation Consistency Contract

- Add a deterministic documentation audit covering README, implementation handoff, changelog milestone, filesystem inventory, and manifest identity.
- Make `bin/validate` enforce documentation consistency before release readiness.
- Synchronize current inventory and implementation-status documentation with the verified Iteration 101 repository state.

## Iteration 101 — Verified Routing History

- Add `routing-history --verify` for integrity-gated longitudinal history generation.
- Validate every indexed archive against its independent archive verifier and manifest identity.
- Keep historical model reporting descriptive-only.
