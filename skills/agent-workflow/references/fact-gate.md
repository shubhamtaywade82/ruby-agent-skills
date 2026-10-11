# Pre-activation fact gate

Load this before implementation when a change depends on repository facts: framework or runtime versions, the owning boundary, configuration, data shape, or the behavior of an external system.

The gate does not prove a fact is true. It forces every task-critical fact to declare the evidence class it rests on, and it blocks implementation while any task-critical fact is unevidenced.

## Fact classes

| Class | Meaning | Required field |
|---|---|---|
| `observed` | read directly from the repository, a command's output, or the user's message | `source`: the file path, command, or quoted message |
| `derived` | computed from observed facts by a stated rule | `source`: the observed facts and the rule applied |
| `inferred` | likely, but not checked | `basis`: the reasoning, and the check that would promote it to `observed` |
| `unknown` | not established | none |

## Manifest format

The manifest is a YAML mapping with a `facts` list. Each fact has:

- `id`: a unique, non-empty string.
- `class`: one of `observed`, `derived`, `inferred`, `unknown`.
- `task_critical`: `true` or `false`. Set it before evaluating, never after.
- `source` (observed and derived) or `basis` (inferred).
- `statement`: the fact in one sentence.

```yaml
facts:
  - id: ruby-version
    class: observed
    task_critical: true
    source: .ruby-version
    statement: The runtime is Ruby 3.3.6.
  - id: rails-major
    class: derived
    task_critical: true
    source: "Gemfile.lock rails entry; rule: the major version of the rails gem"
    statement: Rails 8 governs the controller contract.
  - id: queue-adapter
    class: inferred
    task_critical: true
    basis: "no queue_adapter line in config/; assumed to be the Rails 8 default. Promote by reading config/environments/production.rb."
    statement: Jobs run on Solid Queue.
  - id: replica-topology
    class: unknown
    task_critical: false
    statement: Whether production has a read replica.
```

Evaluated against this manifest, the result is `blocked` with `queue-adapter` as the blocking fact. `replica-topology` is non-critical, so it is reported as unverified rather than blocking.

## Gate rule

1. Validate the manifest. A malformed manifest is `blocked`, with every error listed. Never evaluate a partly valid manifest.
2. Any task-critical fact whose class is `inferred` or `unknown` blocks implementation. List its `id`.
3. Non-critical `inferred` or `unknown` facts do not block. Restate each one in the final report as unverified.
4. While blocked, read files and run read-only inspection commands only. Do not edit files. Verify the blocking fact, or ask the user for it.
5. Once every task-critical fact is `observed` or `derived`, the gate is `proceed`.

## Where the gate runs

After discovery, routing, and repository inspection, and before the implementation loop. A change that reveals a new task-critical fact during implementation returns to the gate.

## Failure modes

- Promoting an `inferred` fact to `observed` without a readable source.
- Marking a task-critical fact `task_critical: false` to get past the gate.
- Deriving a fact from facts that were never observed.
- Treating a passing gate as proof that the implementation is correct. The gate governs what may be assumed, not whether the code works.

## Verification

`lib/ruby_agent_skills/fact_manifest.rb` implements the rule. `test/agent_workflow_contracts_system_test.rb` evaluates this example, rejects malformed manifests, and checks that task-critical inference blocks while non-critical unknowns do not.
