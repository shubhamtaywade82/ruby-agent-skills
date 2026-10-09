# Implementation Handoff

## Repository-side implementation status

The skill library, pattern library, corpus-quality audit, routing infrastructure, evidence pipeline, provenance controls, resumable execution, multi-model matrix runner, verified installer, React/TypeScript engineering layer, and stack-minimality layer are implemented in the current release line.

Current inventory:

- 96 skills
- 447 implementation patterns
- 500 evaluation cases
- 103 system/contract tests

## Corpus quality and evaluation coverage

Run the corpus audit independently:

    ruby scripts/audit_corpus_quality.rb

The audit reports exact measurements rather than estimates for:
- skill reference/executable example coverage and example-language distribution;
- pattern code/example coverage, implementation anchors, failure modes, and testing guidance;
- evaluation case integrity and grading-dimension depth;
- benchmark-backed versus explicitly static-only evaluation coverage;
- routing trigger collisions and stale manifest skill paths.

The public evaluation corpus has 137 evaluation files / 500 cases. Campaigns provide controlled benchmark coverage for 109 evaluation files; the remaining 28 files / 66 cases are explicitly classified as `coverage: static-only` and are not represented as real-model benchmark results. The new validator-aligned `ruby-toolchain` and `ruby-gem-development` benchmark campaigns cover their respective contract evaluations with independent fixture references; actual model results remain separate empirical evidence.

## Iteration 152 — Action Controller Resource-Loading Evidence

This iteration makes the controller resource-loading policy explicit and regression-checked:

- `before_action` remains a narrow request-prerequisite mechanism.
- one-off resource access may stay action-local;
- memoized readers are allowed for lazy access but are not treated as an inherent performance optimization;
- performance comparisons require comparable workload evidence;
- query/read boundaries remain the escalation path for complex controller reads.

## Iteration 153 — RSpec Method Naming, Aggregate Failures, and HTTP Stubbing

The RSpec reference in `rails-test-engineering` now covers `#method` / `.method` describe naming, `:aggregate_failures` for expensive multi-assertion specs, and WebMock/VCR HTTP stubbing with `disable_net_connect!`. These are regression-checked in `test/test_engineering_system_test.rb`.

## Iteration 154 — Review Remediation: Deprecation Visibility, Drift Detection, and Benchmark Honesty

- Framework drift detection now actually matches: registry regexes are singly escaped, each entry carries an `example` the validator must match, and the committed registry is tested against every example.
- Deprecated React/TypeScript skills announce `DEPRECATED` and their replacement in frontmatter, enforced by the deprecation validator.
- Test-engineering `scope_control` rejects changes outside `test/`/`spec/`. The campaign is documented as statically graded.
- Claude benchmark adapters require an explicit `CLAUDE_MODEL`.
- `v1.2.0` was tagged at Iteration 155; it was created in the GitHub UI, so its archive was never attached (see Iteration 158).

## Iteration 155 — Rails ↔ React Boundary and Deprecation Release Readiness

- `rails-react-integration` stays in this pack under the `rails` family, with guidance on composing with react-agent-skills.
- The nine deprecated React/TypeScript skills still ship. v1.2.0 (Iteration 155) announced their deprecation; the next release is v1.3.0, with notes from `docs/releases/v1.3.0.md`.
- Delete them in a later release, following the checklist in `docs/REACT_AGENT_SKILLS_MIGRATION.md`.

## Iteration 156 — Verification Gates in Owning Skills and GraphQL

- The new gates live in their owning skills; `test/engineering_gates_system_test.rb` pins them.
- GraphQL work routes to `rails-api-integration` (`references/graphql.md`), with the policy decision kept in `rails-authorization`.

## Iteration 157 — Agent Skills Specification Conformance and Publish Readiness

- `bin/skills-spec-check` (also run in CI) and `bin/publish-readiness` are the deterministic publishing gates. `docs/PUBLISHING.md` lists the model-based stages still to run before a public announcement.

## Release archive verification

The release archive builder records file-level SHA-256/byte-size provenance in `RELEASE.json`. Independently verify a built archive with:

    ruby scripts/verify_release_archive.rb ./dist/ruby-agent-skills-vX.Y.Z.tar.gz --checksums ./dist/SHA256SUMS --check-files

The verifier rejects unsafe tar entries before extraction, validates release metadata and inventory, checks the published archive checksum, verifies every recorded file's size and digest, and rejects files shipped without a provenance record. The tag-triggered release workflow runs this verifier before creating the GitHub Release.

## First checkout

    git clone https://github.com/shubhamtaywade82/ruby-agent-skills.git
    cd ruby-agent-skills
    git checkout main
    git pull --ff-only

Before empirical execution, run:

    bash bin/validate

The repository's validation workflow should also be green for the release commit you use.

## Install the agent pack

Example for a project-scoped Claude installation:

    bash bin/install \
      --scope project \
      --agent claude \
      --project /path/to/your/rails-app

For reproducibility, pin a trusted tag or commit:

    bash bin/install --ref <trusted-tag-or-commit> --agent claude

Verify the installed pack:

    ruby bin/skill-pack-verify --root /path/to/your/rails-app/.claude/skills

Run the installation doctor:

    ruby bin/skill-pack-doctor --root /path/to/your/rails-app/.claude/skills

The installer records the resolved Git SHA plus manifest and routing hashes under `.ruby-agent-skills/INSTALLATION.json`.

## Public routing campaign

Generate an external handoff from a clean checkout:

    ruby bin/routing-campaign-handoff --model <ollama-model>

Run the generated campaign on the machine that has Ollama access:

    ./routing-handoff/run-campaign.sh

The campaign is 31 public cases × 3 repetitions = 93 model decisions.

If interrupted, rerun the generated launcher. When a checkpoint exists, it automatically resumes verified completed repetitions.

After completion, import and archive the evidence:

    ruby bin/routing-campaign-import ./routing-campaign-output \
      --archive ./routing-archives

Analyze the completed campaign independently:

    ruby bin/routing-analyze ./routing-campaign-output/campaign.json \
      --output ./routing-campaign-output/analysis.json

The analysis recomputes completion and routing metrics from the recorded runs. It reports primary accuracy, secondary recall, unexpected secondary selections, confusion pairs, modal primary selection, and repetition stability. It exits non-zero for incomplete or structurally inconsistent campaigns.

## Multi-model campaign

Plan without executing:

    ruby bin/routing-model-matrix-campaign \
      --model <model-a> \
      --model <model-b> \
      --output ./routing-matrix-output

Execute and archive:

    ruby bin/routing-model-matrix-campaign \
      --model <model-a> \
      --model <model-b> \
      --execute \
      --archive ./routing-matrix-archives \
      --output ./routing-matrix-output

Resume an interrupted matrix:

    ruby bin/routing-model-matrix-campaign \
      --model <model-a> \
      --model <model-b> \
      --execute \
      --archive ./routing-matrix-archives \
      --output ./routing-matrix-output \
      --resume


## Routing comparison and experiment finalization

The baseline/candidate experiment path now verifies `comparison.json` against its exact source campaigns and policy, packages `evidence.json`, and verifies that evidence before reporting success.

Use `bin/routing-compare-verify` to independently replay a comparison. The report records SHA-256 provenance for the baseline, candidate, remediation policy, and comparator implementation.

## Multi-model matrix evidence

A fully completed model matrix automatically produces `matrix-evidence.json`. It binds the exact matrix plan, completed per-model evidence, and immutable archive trees. Verify it independently with:

    ruby bin/routing-model-matrix-evidence-verify ./routing-matrix-output/matrix-evidence.json --check-files

The aggregate remains descriptive-only: it does not rank models or synthesize missing results.

## Verified release evidence bundle

After externally executing the public campaign and obtaining verified immutable evidence, compose a frozen release bundle:

    ruby bin/routing-release-bundle \
      --public-evidence ./routing-campaign-output/campaign-evidence.json \
      --public-archive ./routing-archives/<archive> \
      --matrix-evidence ./routing-matrix-output/matrix-evidence.json \
      --hidden-receipt ./hidden-benchmark/receipt.json \
      --output ./routing-release-bundle

The matrix and hidden receipt inputs are optional. When supplied, they are independently verified and preserved without importing hidden cases or gold labels.

Verify the resulting bundle independently:

    ruby bin/routing-release-bundle-verify ./routing-release-bundle --check-files

The bundle contains a frozen release-policy copy and a cryptographic manifest for the public evidence, archive tree, and any optional empirical components.

## Verified routing history

Build historical archive data with integrity verification:

    ruby bin/routing-history ./routing-archives \
      --output ./routing-history.json \
      --verify

The verifier replays the independent archive verifier for every indexed archive and checks history entries against the archive manifests.

For descriptive model-history reporting, require the same gate:

    ruby bin/routing-model-matrix-report ./routing-history.json \
      --verify \
      --output ./routing-history-report.json

The report remains descriptive-only and does not rank or select models.

## Release evidence bundle

After the required external evidence is available, create the release bundle:

    ruby bin/routing-release-bundle \
      --public-evidence ./routing-campaign-output/campaign-evidence.json \
      --public-archive ./routing-archives/<archive> \
      --output ./routing-release-bundle

Optionally add verified matrix evidence and the safe hidden-benchmark receipt with `--matrix-evidence` and `--hidden-receipt`.

The command self-verifies the resulting bundle. An existing bundle can be gated independently with:

    ruby bin/routing-release-check --bundle ./routing-release-bundle

## Installation doctor

After installation and before controlled agent use:

    ruby bin/skill-pack-doctor --root /path/to/agent-skill-root

The doctor is intentionally narrower than an agent runtime test: it verifies the installed pack and then delegates content integrity to the embedded verifier. It does not claim that a particular coding agent has loaded or used the skills.

## Stack minimality integration

Use `stack-minimality` with the domain skill that owns the actual contract. The pack includes six skills, 14 implementation patterns, and 13 evaluation contracts. The installed pack also ships `.ruby-agent-skills/bin/stack-minimality` with integrity metadata and verification.

## Verified routing history

`bin/routing-history --verify` now produces a history with deterministic archive-set provenance. `bin/routing-history-verify --check-files` verifies each archive, enforces archive-root containment, validates the recorded archive-manifest hashes, and checks the aggregate archive-set digest.

## Documentation consistency

`scripts/audit_documentation_consistency.rb` cross-checks the README, implementation handoff, changelog, `docs/ITERATIONS.md`, filesystem inventory, and manifest. It requires the current milestone in `docs/ITERATIONS.md` and the documented counts to match repository reality, keeps `docs/ITERATIONS.md` in ascending order with a section for the latest iteration, and rejects iteration history in the README. `bin/validate` runs this audit before release-readiness checks.

## Remaining non-implementation work

1. Execute the real 78-run public routing campaign.
2. Analyze observed confusion and repetition instability.
3. Perform evidence-based routing remediation where failures are observed.
4. Run compatible baseline/candidate experiments.
5. Execute the private hidden benchmark externally.
6. Run the multi-model empirical campaign.
7. Publish final benchmark/release evidence.

These steps depend on an externally reachable Ollama runtime/model and real model execution. No repository code should synthesize missing measurements.

## PR handoff

The repository-side implementation line is complete through Iteration 162. The remaining work is empirical execution and evidence analysis using a reachable Ollama runtime/model, or a locally authenticated `claude` CLI (see `docs/LOCAL_BENCHMARKING.md`).
