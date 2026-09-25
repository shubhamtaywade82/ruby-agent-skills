# Implementation Handoff

## Repository-side implementation status

The skill library, pattern library, routing infrastructure, evidence pipeline, provenance controls, resumable execution, multi-model matrix runner, verified installer, React/TypeScript engineering layer, and stack-minimality layer are implemented in the current release line.

Current inventory:

- 91 skills
- 431 implementation patterns
- 436 evaluation cases
- 77 system/contract tests

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

## Installation doctor

After installation and before controlled agent use:

    ruby bin/skill-pack-doctor --root /path/to/agent-skill-root

The doctor is intentionally narrower than an agent runtime test: it verifies the installed pack and then delegates content integrity to the embedded verifier. It does not claim that a particular coding agent has loaded or used the skills.

## Stack minimality integration

Use `stack-minimality` with the domain skill that owns the actual contract. The pack includes six skills, 14 implementation patterns, and 13 evaluation contracts. The installed pack also ships `.ruby-agent-skills/bin/stack-minimality` with integrity metadata and verification.

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

The repository-side implementation line is complete through Iteration 94. The remaining work is empirical execution and evidence analysis using a reachable Ollama runtime/model.
