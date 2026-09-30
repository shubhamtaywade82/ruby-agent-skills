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
## Runtime and compatibility evidence

Skills-enabled evaluation results include the target repository's resolved runtime profile and the compatibility decision used during materialization:

    {
      "runtime_profile": {
        "schema_version": 1,
        "ruby": { "resolved": "3.3.12", "status": "resolved" },
        "rails": { "resolved": "8.1.4", "status": "resolved" }
      },
      "compatibility": {
        "status": "supported",
        "requirements": {}
      }
    }

Known `unsupported` or `conflict` compatibility is rejected before the agent runs. Unknown runtime evidence is preserved as `unknown`; callers that require fail-closed behavior can use strict compatibility mode.

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