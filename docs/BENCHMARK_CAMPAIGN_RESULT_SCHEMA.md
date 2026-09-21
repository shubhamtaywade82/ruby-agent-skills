# Benchmark Campaign Result Schema

A campaign result is JSON containing individual result paths plus dimension-level status counts.

```json
{
  "protocol_version": 1,
  "campaign": "ruby-training-public-v1",
  "repetitions": 3,
  "evaluations": {
    "triplet-sum": {
      "baseline_results": [".../baseline-1.json"],
      "skills_results": [".../skills-1.json"],
      "dimensions": {
        "functional": {
          "baseline": {"pass": 2, "fail": 1},
          "skills_enabled": {"pass": 3}
        }
      }
    }
  }
}
```

Counts are descriptive aggregates. The individual result files remain the source of truth for process output, patches, verifier evidence, configuration and agent metadata.

Allowed status keys are `pass`, `fail`, and `not_evaluated`.