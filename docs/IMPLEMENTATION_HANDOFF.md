# Implementation Handoff

## Repository-side implementation status

The skill library, pattern library, routing infrastructure, evidence pipeline, provenance controls, resumable execution, multi-model matrix runner, verified installer, and React/TypeScript engineering layer are implemented in the current release line.

Current inventory:

- 85 skills
- 417 implementation patterns
- 410 evaluation cases
- 75 system/contract tests

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

The campaign is 14 public cases × 3 repetitions = 42 model decisions.

If interrupted, rerun the generated launcher. When a checkpoint exists, it automatically resumes verified completed repetitions.

After completion, the generated handoff launcher invokes `bin/routing-campaign-import`, which regenerates the canonical routing analysis, packages and verifies evidence, and creates the requested immutable archive.

For a baseline/candidate remediation experiment, `bin/routing-experiment` now verifies `comparison.json`, packages `evidence.json`, and runs `bin/routing-evidence-verify --check-files` before reporting success.

`bin/routing-compare-verify` can independently replay a stored comparison and validate its cryptographic provenance. `bin/routing-analyze` remains the underlying analysis primitive and recomputes completion/routing metrics from recorded runs; it exits non-zero for incomplete or structurally inconsistent campaigns.

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

## Comparison and experiment evidence finalization

Comparison reports now bind the exact baseline/candidate inputs plus the remediation policy and comparator implementation with SHA-256 hashes. The standalone comparison verifier replays those inputs and rejects report drift.

The baseline/candidate experiment command consumes this verifier and then creates independently verified experiment evidence.

## End-to-end campaign finalization

The external handoff runner now executes the campaign and then invokes `bin/routing-campaign-import`, which regenerates the routing analysis, packages and verifies evidence, and creates the requested archive. This removes the manual analyze/import/finalize sequence from the public handoff workflow.

## Matrix resume integrity

Resume revalidates completed/archive results by running both the campaign evidence verifier and archive integrity verifier before reuse.

## Installation doctor

After installation and before controlled agent use:

    ruby bin/skill-pack-doctor --root /path/to/agent-skill-root

The doctor is intentionally narrower than an agent runtime test: it verifies the installed pack and then delegates content integrity to the embedded verifier. It does not claim that a particular coding agent has loaded or used the skills.

## Remaining non-implementation work

1. Execute the real 42-run public routing campaign.
2. Analyze observed confusion and repetition instability.
3. Perform evidence-based routing remediation where failures are observed.
4. Run compatible baseline/candidate experiments.
5. Execute the private hidden benchmark externally.
6. Run the multi-model empirical campaign.
7. Publish final benchmark/release evidence.

These steps depend on an externally reachable Ollama runtime/model and real model execution. No repository code should synthesize missing measurements.

## PR handoff

The repository-side implementation line is complete through Iteration 87. The remaining work is empirical execution and evidence analysis using a reachable Ollama runtime/model.
