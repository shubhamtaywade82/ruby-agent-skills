# Routing Campaign Resume

Protocol version: 1

A public routing campaign may be interrupted by a model/runtime failure, process termination, network failure, or operator interruption. Re-running the complete campaign is wasteful and can change the empirical sample. The evaluator therefore supports checkpointed execution and explicit resume.

## Execution contract

Every repetition is stored under:

```text
<campaign-output>/
└── <case-id>/
    └── run-<n>/
        ├── prompt.txt
        ├── case.yml
        ├── result.json
        └── run.json
```

A completed repetition also has a `run.json` receipt containing:

- protocol version;
- case ID;
- run number;
- completion status;
- SHA-256 of `result.json`;
- execution metadata.

The receipt is written only after the result passes the same skill-reference validation used for normal campaign execution.

## Checkpointing

`bin/routing-eval` writes `campaign.json` after every repetition. A checkpoint may therefore have:

```json
{
  "complete": false,
  "requested_runs": 42,
  "completed_runs": 17
}
```

An incomplete checkpoint is not valid release evidence and cannot pass the campaign intake or release gates.

## Resume

Resume an interrupted evaluator run with:

```bash
ruby bin/routing-eval   --command "<trusted-agent-command>"   --model "<model>"   --provider ollama   --model-version "<model-digest>"   --tool-mode local-filesystem   --runs 3   --output ./routing-campaign-output/campaign.json   --resume
```

The evaluator verifies that the existing checkpoint uses the same campaign identity, repetition count, routing contract, provider, model, tool mode, and model version before reusing any prior run.

A run is reusable only when both `result.json` and `run.json` exist, the receipt matches the case/run identity, the recorded result digest matches the current bytes, and the observed skills still satisfy the registered-skill contract.

Missing, invalid, or unverifiable repetitions are executed again. No result is synthesized from the checkpoint.

## Campaign wrapper

The higher-level runner exposes the same operation:

```bash
ruby bin/routing-campaign   --model "<model>"   --url "http://127.0.0.1:11434"   --runs 3   --output ./routing-campaign-output   --resume
```

The wrapper still performs runtime preflight before evaluation and supplies the model digest as the evaluator's model version. A changed model digest is therefore treated as an incompatible campaign rather than silently mixing runtime identities.

## Operational rules

- Use a dedicated output directory per campaign execution.
- Preserve the checkpoint and run directories when a campaign fails.
- Do not manually edit `campaign.json`, `result.json`, or `run.json`.
- Import only after `complete: true`.
- Archive only through the normal evidence/import path.
- A resumed campaign remains one empirical campaign; it does not create synthetic missing repetitions.

The resume path is an execution-recovery mechanism, not a way to alter routing cases, expected labels, or measured results.
