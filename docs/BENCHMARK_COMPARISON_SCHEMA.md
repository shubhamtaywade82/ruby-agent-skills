# Benchmark Comparison Schema

A campaign comparison is JSON:

    {
      "protocol_version": 1,
      "evaluation": "triplet-sum",
      "baseline_result": ".../baseline.json",
      "skills_result": ".../skills.json",
      "dimensions": {
        "functional": {
          "baseline": "pass",
          "skills_enabled": "pass"
        }
      },
      "overall": {
        "baseline": "incomplete",
        "skills_enabled": "passed"
      }
    }

The comparison intentionally preserves both configurations independently. It is a reporting artifact, not an evaluative score or ranking.

Allowed dimension statuses are the same as evaluation results:

- `pass`
- `fail`
- `not_evaluated`

The comparison must not discard evidence such as verifier messages, changed files, execution timing, or patch contents; those remain in the individual result artifacts.
