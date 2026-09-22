# Evaluation Result Schema

A benchmark result is JSON with these core fields:

    {
      "protocol_version": 1,
      "evaluation": "triplet-sum",
      "agent": {
        "command": "...",
        "exit_code": 0,
        "timed_out": false,
        "stdout": "...",
        "stderr": "...",
        "duration_seconds": 12.3
      },
      "verification": {
        "configured": true,
        "command": "...",
        "exit_code": 0,
        "timed_out": false
      },
      "patch": {
        "git_repository": true,
        "status": "...",
        "diff_stat": "...",
        "diff": "..."
      },
      "checks": {
        "functional": { "status": "pass" }
      },
      "overall": "passed"
    }

## Check statuses

A check status is one of:

- `pass`
- `fail`
- `not_evaluated`

Additional verifier metadata is allowed inside each check mapping.

## Result semantics

The result preserves evidence separately from interpretation. The runner records process outcomes and patch evidence; the verifier provides dimension-level judgments.

`overall` is computed from those independent signals and must not replace them.
## Benchmark configuration

Phase 8 adds an explicit configuration block:

```json
{
  "configuration": {
    "skills_enabled": true,
    "skills": ["ruby-oop", "ruby-tdd-refactoring"],
    "patterns": ["two-pointers"]
  }
}
```

When skill support is disabled, `skills` and `patterns` are empty.

The agent result may also contain `agent.metadata` supplied by the adapter. This should identify provider/model/version/tool mode when available, without storing secrets.