# Benchmark Campaign Result Schema

A campaign result is JSON containing individual result paths plus dimension-level status counts.

```json
{
  "protocol_version": 1,
  "campaign": "ruby-training-public-v1",
  "campaign_version": 1,
  "evaluation_set": "ruby-training",
  "source": "allerin-ruby-set-2",
  "manifest": "benchmarks/ruby-training/campaign.yml",
  "fixture_root": "benchmarks/ruby-training/fixtures",
  "verifier": "scripts/verify_training_eval.rb",
  "execution": {
    "repetitions": 3,
    "paired": true,
    "fresh_workspace_per_run": true,
    "same_fixture_for_pair": true,
    "require_same_agent_command_when_using_agent_command": true
  },
  "controls": {
    "runtime": {"ruby": "3.3"},
    "hidden_cases": "external-only"
  },
  "provenance": {
    "manifest_sha256": "…",
    "verifier_sha256": "…",
    "fixture_registry_sha256": "…",
    "fixtures_sha256": "…"
  },
  "repetitions": 3,
  "evaluations": {
    "triplet-sum": {
      "fixture_sha256": "…",
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

`fixture_sha256` digests the starting workspace for one evaluation (every file's relative path and bytes); `fixtures_sha256` digests the selected evaluations' fixture digests. Results are comparable only when `campaign_version` and these digests match. Changing a fixture's starting state or verifier semantics also requires bumping the campaign `version`.

Allowed status keys are `pass`, `fail`, and `not_evaluated`.