# Benchmark Runner

Phase 6 introduces a reproducible execution harness around the machine-readable evaluation corpus.

The runner is provider-neutral. It does not assume Codex, Claude, Copilot, Cursor or a particular model. Any agent that can be invoked as a command can be benchmarked.

## CLI

List evaluations:

    bin/eval list

Inspect a task:

    bin/eval show triplet-sum

Generate an agent packet:

    bin/eval packet triplet-sum --output /tmp/triplet-sum.json

Run an agent against a disposable copy of a workspace:

    bin/eval run triplet-sum --workspace /path/to/fixture --agent-command 'your-agent-command' --verify-command 'your-verifier-command' --output results/triplet-sum.json

The source workspace is copied into a temporary directory before the agent runs. The source workspace is not modified.

## Agent contract

The agent receives these environment variables:

- RUBY_AGENT_EVAL_ID
- RUBY_AGENT_EVAL_PROMPT
- RUBY_AGENT_EVAL_FILE
- RUBY_AGENT_EVAL_RESULT_FILE

The prompt and complete evaluation YAML are materialized under `.ruby-agent-eval/` in the disposable workspace.

The agent command must make the implementation change in that workspace.

## Verification contract

The optional verifier runs after the agent command.

It may write JSON to `RUBY_AGENT_EVAL_RESULT_FILE`:

    {
      "metadata": { "ruby": "3.3.12" },
      "checks": {
        "functional": "pass",
        "complexity": "pass",
        "oop": "pass",
        "tests": "pass"
      }
    }

Only checks declared by the evaluation are accepted into the result.

The verifier process exit code is recorded separately from individual check statuses.

## Captured evidence

Every run records:

- timestamps
- agent command and process output
- verifier command and process output
- exit codes and timeout state
- git status
- git diff stat
- the binary-capable git diff
- dimension-level check statuses
- overall status

This keeps a run replayable and debuggable instead of reducing it to one pass/fail scalar.

## Overall status

- `passed`: agent and verifier succeeded and every declared check has a result other than `not_evaluated`.
- `failed`: agent/verifier failed, timed out, or a reported check is `fail`.
- `incomplete`: execution occurred but one or more declared checks remain `not_evaluated`.

## Baseline comparison

The runner deliberately does not compare agents automatically.

A benchmark campaign should execute the same evaluation packet against:

1. the baseline agent configuration without these skills
2. the agent configuration with these skills

The resulting JSON artifacts can then be compared dimension by dimension.

## Hidden benchmark packs

The public YAML cases remain visible in this repository.

For hidden campaigns, keep the hidden evaluation YAML outside the repository and load it through a private benchmark harness using the same schema.

## Safety properties

- no mutation of the source workspace
- explicit agent command
- explicit verifier command
- configurable timeout
- captured stdout/stderr
- captured patch evidence
- no claim of success without verifier evidence