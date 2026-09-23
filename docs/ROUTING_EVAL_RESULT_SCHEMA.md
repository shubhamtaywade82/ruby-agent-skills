# Routing Evaluation Result Schema

Iteration 54 defines the provider-neutral result contract for measuring actual agent skill selection. Iteration 55 extends it to repeated public campaigns and primary-skill confusion analysis.

## Case result

Example JSON:

{
  "protocol_version": 1,
  "case_id": "tenant-scoped-resource-access",
  "primary_skill": "rails-authorization",
  "secondary_skills": [
    "rails-active-record",
    "rails-security-engineering",
    "rails-test-engineering"
  ],
  "reason": "Authorization is the dominant boundary; persistence and security are dependent constraints."
}

## Rules

- case_id must match a registered routing case.
- primary_skill must be one registered skill.
- secondary_skills must contain registered skills and must not contain the primary skill.
- reason should state the ownership/boundary rationale without reproducing hidden benchmark material.
- Provider/model metadata may be recorded by the adapter but must not contain secrets.
- Expected secondary skills are required supporting coverage, not an exhaustive prohibition on additional context.

## Campaign result

A campaign records independent repetitions for each routing case and aggregates them without discarding the individual evidence.

Required campaign fields include:

- requested_repetitions
- requested_runs
- completed_runs
- complete
- metrics
- confusion_matrix
- cases

## Metrics

For each completed repetition:

- primary_accuracy = exact expected-primary match.
- secondary_recall = matched expected secondary skills / expected secondary skills.
- unexpected_secondary_count = observed secondary skills not declared by the routing case.

For the campaign:

- primary_accuracy = exact-primary matches / valid completed repetitions.
- secondary_recall = matched required secondary skills / total required secondary skills.
- average_unexpected_secondary_count = mean unexpected secondary selections per valid repetition.
- confusion_matrix = expected primary skill -> observed primary skill -> count.

The confusion matrix is the key diagnostic surface for cross-boundary routing errors. A perfect routing campaign has only diagonal entries.

## Evidence policy

Individual run results remain the source of truth. Aggregate metrics are descriptive measurements, not quality claims. Public routing cases do not constitute hidden evaluations; hidden/adversarial additions remain external-only. The evaluator must not expose gold routing labels to the agent workspace. Concrete adapters consume only the task prompt, routing contract, and registered skill inventory.

Public campaigns are accepted as externally measured routing evidence only after `bin/routing-campaign-verify` confirms corpus identity, repetition completeness, valid skill references, and agent metadata. The campaign runner executes this intake verification before generating the confusion analysis.

## Checkpoint and resume semantics

Campaign execution is checkpointed after each repetition using atomic file replacement. Each successfully validated repetition records a `run.json` receipt containing its case/run identity, execution metadata, and the SHA-256 digest of `result.json`. `bin/routing-eval --resume` reuses only repetitions with a valid receipt and matching result digest; missing or invalid repetitions are executed again. Resume requires compatible campaign identity, repetition count, routing contract, routing-input SHA-256 values, provider, model, tool mode, and model version. Incomplete checkpoints are never treated as completed evidence.

Before/after remediation evidence is evaluated by `bin/routing-compare` against the explicit thresholds in `router/ROUTING_REMEDIATION.yml`. Comparisons must use compatible campaign and agent configurations. `bin/routing-experiment` enforces the same invocation/configuration for the two sides while allowing the routing contract path to differ. `bin/routing-evidence` records hashes and repository metadata needed to audit or replay the resulting experiment.
