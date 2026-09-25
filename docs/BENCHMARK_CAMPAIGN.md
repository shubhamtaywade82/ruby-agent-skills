# Benchmark Campaign

Phase 8 turns the benchmark runner into a controlled repeated campaign.

## Controlled experiment

For each evaluation, the campaign executes paired runs:

```text
same evaluation
same fixture
same verifier
same runtime
same agent configuration
      │
      ├── skills disabled
      └── skills enabled
```

The skill-enabled side receives only the skills and patterns declared in the evaluation YAML.

## Repetitions

The public campaign manifest uses three repetitions per evaluation.

A repeated campaign is important for stochastic agents. Individual JSON files are retained; the campaign summary only reports dimension-level status counts.

Run the complete public campaign:

    ruby bin/benchmark campaign \
      --agent-command 'YOUR_AGENT_ADAPTER_COMMAND' \
      --output benchmark-results/ruby-training-public-v1

Run one evaluation:

    ruby bin/benchmark campaign \
      --agent-command 'YOUR_AGENT_ADAPTER_COMMAND' \
      --evaluation triplet-sum \
      --output benchmark-results/triplet-sum

Use different provider commands only when intentionally comparing different adapters:

    ruby bin/benchmark campaign \
      --baseline-command 'BASELINE_ADAPTER' \
      --skills-command 'SKILL_ADAPTER'

## Agent adapter

See `docs/AGENT_ADAPTER_PROTOCOL.md`.

The adapter is the only component that knows how to invoke the actual AI coding agent.

## Results

Each evaluation receives:

```text
baseline-1.json
baseline-2.json
baseline-3.json

skills-1.json
skills-2.json
skills-3.json
```

The root `campaign.json` reports counts per dimension.

Example shape:

```json
{
  "dimensions": {
    "functional": {
      "baseline": {"pass": 2, "fail": 1},
      "skills_enabled": {"pass": 3}
    }
  }
}
```

This is descriptive reporting, not a single benchmark score.

## Hidden evaluation pack

Public benchmark definitions are useful for reproducibility but can be optimized against.

A private hidden pack should use the same evaluation and result schemas, remain outside this repository, and be executed by the same adapter protocol.

## Experimental hygiene

Do not vary runtime, tool permissions, adapter code, model version, prompt, timeout or fixture between paired runs.

Do not load unrelated global skills during the skill-enabled configuration.

Do not commit generated results.

## Phase 8 boundary

The repository now supplies the controlled campaign machinery. A real campaign requires an external agent adapter command connected to an actual coding model/runtime.

## Design-pattern campaign

The same paired-run machinery can execute the design-pattern corpus:

    ruby bin/benchmark campaign \\
      --manifest benchmarks/design-patterns/campaign.yml \\
      --agent-command 'YOUR_AGENT_COMMAND' \\
      --output benchmark-results/design-patterns-public-v1

The design-pattern campaign includes 18 public cases and five independent verifier dimensions, including `pattern_selection` and `scope_control`.


## Design-pattern restraint expansion

The public design-pattern campaign now includes **24 cases**: the original 18 pattern/implementation cases plus six explicit negative-selection cases (`service-object-not-needed`, `strategy-not-needed`, `factory-not-needed`, `repository-not-needed`, `value-object-not-needed`, and `presenter-not-needed`). These cases measure whether the agent can decline a pattern when the responsibility, variation, ownership, or lifecycle boundary has not been earned.

## Incremental campaign coverage

A benchmark family may cover a deliberate subset of its public evaluation corpus. The validator checks that campaign evaluation IDs are public and that fixture registration is exact; audit_benchmark_quality.rb reports the remaining public evaluations without campaigns. This makes benchmark coverage measurable without falsely labeling unrun evaluations as benchmarked.

## Rails framework campaign

The Rails campaign is defined at benchmarks/rails/campaign.yml and now covers nine evaluations: Action Controller, Active Record, Routing, Validations, Authentication, Authorization, Cross-Boundary Authorization, Encryption/Credentials, and Serialization/Global ID. The campaign intentionally leaves the remaining 20 public Rails evaluations unbenchmarked until fixture and verifier quality are added.

## Multiple campaign families

The campaign runner accepts a manifest, so book-derived evaluations can use the same paired-run machinery:

    ruby bin/benchmark campaign \
      --manifest benchmarks/ruby-workshop/campaign.yml \
      --agent-command 'YOUR_AGENT_ADAPTER_COMMAND' \
      --output benchmark-results/ruby-workshop-public-v1

This manifest supplies its own fixture root and verifier. The runner uses the manifest values for both baseline and skills-enabled sides.

## Real agent adapter

For a concrete provider-neutral command adapter:

    ruby bin/agent-benchmark \
      --command 'YOUR_AGENT_COMMAND' \
      --provider your-provider \
      --model your-model

The adapter is intentionally outside model-specific launch logic. Authentication and provider-specific harness code remain external.
