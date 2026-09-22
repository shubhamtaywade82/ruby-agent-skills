# Routing Evaluation Result Schema

Iteration 54 defines a provider-neutral result contract for measuring actual agent skill selection against the repository's adversarial routing cases.

## Required result

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

- `case_id` must match a registered routing case.
- `primary_skill` must be one registered skill.
- `secondary_skills` must be an array of registered skills and must not contain the primary skill.
- `reason` should state the ownership/boundary rationale without reproducing hidden benchmark material.
- Agent/provider metadata is optional and may be included under `metadata`.
- The evaluator treats the expected secondary skills as required supporting coverage, not as an exhaustive prohibition on additional context.
- The evaluator does not score reasoning quality yet; it records the reason for auditability.

## Scoring

For each case:

- `primary_accuracy`: exact match between expected and observed primary skill.
- `secondary_recall`: proportion of expected secondary skills observed.
- `unexpected_secondary_count`: observed secondary skills not declared by the routing case.

For a campaign:

- `primary_accuracy`: exact-primary matches / completed cases.
- `secondary_recall`: total matched required secondary skills / total required secondary skills.
- `complete`: every selected case produced a valid result.

The individual case results remain the source of truth.
