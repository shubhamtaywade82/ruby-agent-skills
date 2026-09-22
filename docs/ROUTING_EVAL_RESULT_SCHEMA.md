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

Individual run results remain the source of truth. Aggregate metrics are descriptive measurements, not quality claims. Public routing cases do not constitute hidden evaluations; hidden/adversarial additions remain external-only.
