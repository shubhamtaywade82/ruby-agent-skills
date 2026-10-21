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
      --output benchmark-results/design-patterns-public-v2

The design-pattern campaign includes 24 public cases and five independent verifier dimensions, including `pattern_selection` and `scope_control`.


## Design-pattern restraint expansion

The public design-pattern campaign now includes **24 cases**: the original 18 pattern/implementation cases plus six explicit negative-selection cases (`service-object-not-needed`, `strategy-not-needed`, `factory-not-needed`, `repository-not-needed`, `value-object-not-needed`, and `presenter-not-needed`). These cases measure whether the agent can decline a pattern when the responsibility, variation, ownership, or lifecycle boundary has not been earned.

## Incremental campaign coverage

A benchmark family may cover a deliberate subset of its public evaluation corpus. The validator checks that campaign evaluation IDs are public and that fixture registration is exact; audit_benchmark_quality.rb reports the remaining public evaluations without campaigns. This makes benchmark coverage measurable without falsely labeling unrun evaluations as benchmarked.

## Rails framework campaign

The Rails campaign is defined at `benchmarks/rails/campaign.yml` and covers all **28 public Rails evaluation files** in the current corpus. The campaign is configured with `require_all_public_evaluations: true`, so an omitted public Rails evaluation is a validation error rather than an implicit unmeasured case.

The Rails corpus currently contains **268 cases**. Campaign configuration supplies the empirical measurement protocol; it does not imply that a real model has already produced results. Actual model execution still requires an external agent adapter.

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


## Ruby platform foundation campaigns

The Ruby platform foundation evaluations now have dedicated controlled benchmark families:

| Family | Public evaluation | Fixture/reference | Repetitions |
| --- | --- | --- | ---: |
| `ruby-toolchain` | `ruby-toolchain-contract` | independent disposable fixture + pristine reference | 3 |
| `ruby-gem-development` | `ruby-gem-development-contract` | independent disposable fixture + pristine reference | 3 |

Both campaigns enforce paired skills-disabled/skills-enabled execution, fresh workspaces, the same fixture and verifier, the same agent command, explicit Ruby 3.3 runtime control, and `hidden_cases: external-only`.

## Event-driven messaging campaign

The event-driven messaging evaluations have a dedicated controlled benchmark family:

| Family | Public evaluations | Fixture/reference | Repetitions |
| --- | --- | --- | ---: |
| `event-driven-messaging` | `event-envelope-compatibility`, `consumer-idempotency-and-acknowledgement`, `retry-dead-letter-replay`, `ordering-and-consumer-capacity` | independent disposable fixture + pristine reference | 3 |

Each fixture is a deterministic pure-Ruby simulation of broker semantics — versioned envelopes with stable identity and unknown-field tolerance, transactional deduplication with commit-then-acknowledge ordering, bounded retries with dead-letter diagnostics and replay safety, and per-key ordering with capacity and buffer limits — so the verifier measures behavior without external infrastructure. The campaign enforces paired skills-disabled/skills-enabled execution, fresh workspaces, the same fixture and verifier, the same agent command, explicit Ruby 3.3 runtime control, and `hidden_cases: external-only`.

## Distributed systems campaign

The distributed-systems evaluations have a dedicated controlled benchmark family:

| Family | Public evaluations | Fixture/reference | Repetitions |
| --- | --- | --- | ---: |
| `distributed-systems` | `outbox-atomicity`, `inbox-deduplication`, `saga-compensation` | independent disposable fixture + pristine reference | 3 |

Each fixture is a deterministic pure-Ruby simulation of coordination semantics — a transactional inbox whose insert and side effect commit or roll back together, a transactional outbox whose relay publishes only after commit and whose crash-after-publish retry is deduplicated by the broker, and a durable saga state machine that resumes from the last committed step, compensates in reverse order idempotently, and records failed compensations once — so the verifier measures behavior without external services. The campaign enforces paired skills-disabled/skills-enabled execution, fresh workspaces, the same fixture and verifier, the same agent command, explicit Ruby 3.3 runtime control, and `hidden_cases: external-only`.

## Reliability campaign

The reliability evaluations have a dedicated controlled benchmark family:

| Family | Public evaluations | Fixture/reference | Repetitions |
| --- | --- | --- | ---: |
| `reliability` | `bulkhead-saturation`, `circuit-breaker-open`, `load-shed-threshold`, `slo-budget-exhaustion` | independent disposable fixture + pristine reference | 3 |

Each fixture is a deterministic pure-Ruby simulation of overload semantics — permit-based bulkheads with bounded admission queues and clock-driven wait metrics, a circuit breaker whose scripted gateway proves short-circuits make no outbound calls and that timeouts count as failures while 4xx does not, a load shedder whose hysteresis bounds prevent flapping while every shed decision emits an event, and an error budget that freezes non-essential work at exhaustion while essential work stays allowed — so the verifier measures behavior without threads, sleeps, or external infrastructure. The campaign enforces paired skills-disabled/skills-enabled execution, fresh workspaces, the same fixture and verifier, the same agent command, explicit Ruby 3.3 runtime control, and `hidden_cases: external-only`.

## Transaction isolation campaign

The transaction-isolation evaluation joined the existing database-engineering campaign family, completing controlled campaign coverage of the public corpus:

| Family | Public evaluations | Fixture/reference | Repetitions |
| --- | --- | --- | ---: |
| `database-engineering` (extended) | `expand-contract`, `concurrent-index`, `database-constraint`, `batched-backfill`, `transaction-lock`, `isolation-level` | independent disposable fixture + pristine reference | 3 |

The isolation fixture is a deterministic pure-Ruby simulation of PostgreSQL transaction semantics — per-transaction `SET LOCAL` isolation configuration, ascending `SELECT ... FOR UPDATE` row-lock order, commit-time serialization aborts and lock-time deadlock aborts with automatic rollback, and armed concurrent transfers that either defer behind held row locks or clobber stale unlocked reads — so the verifier measures behavior without a database server, threads, sleeps, or randomness. The campaign enforces paired skills-disabled/skills-enabled execution, fresh workspaces, the same fixture and verifier, the same agent command, explicit Ruby 3.3 runtime control, and `hidden_cases: external-only`.

The repository's fixture-control tests verify both negative controls (the unmodified fixture must fail) and positive controls (the independent reference must pass). This establishes benchmark integrity, not model-quality results.

Run one of these families with a real coding-agent adapter:

    ruby bin/benchmark campaign \
      --manifest benchmarks/ruby-toolchain/campaign.yml \
      --agent-command 'YOUR_AGENT_ADAPTER_COMMAND'

    ruby bin/benchmark campaign \
      --manifest benchmarks/ruby-gem-development/campaign.yml \
      --agent-command 'YOUR_AGENT_ADAPTER_COMMAND'

The remaining empirical gap is **actual external-agent execution and evidence capture**. The repository already contains the campaign definitions, disposable fixtures, independent references, verifier scripts, provenance controls, and CI integrity checks needed to conduct that measurement.

## Recorded model campaign

The first real-model campaign runs through the recorded-agent transport. The `agent-recordings/recorded-model-campaign-v1/` set captures the workspace edits a real model made while responding to the materialized task context — prompt, fixture, and, for skills-enabled runs, the selected skill/pattern pack — without access to the benchmark repository root, the verifiers, or the pristine references. `adapters/recorded_agent.rb` replays those edits inside the disposable workspace through the ordinary protocol seam, after verifying the prompt digest, the complete workspace file manifest, and the materialized skill/pattern selection against the recording's fingerprints, so a recording cannot be replayed against a different task. `bin/recorded-agent-benchmark` drives the paired campaign machinery for the whole set and aggregates a summary:

    ruby bin/recorded-agent-benchmark --recordings recorded-model-campaign-v1

The set covers seven evaluations across the ruby-toolchain, ruby-gem-development, and database-engineering families in both configurations. Its provenance is stated in `recording-set.yml`: the acting model is the repository's maintaining model, so the campaign validates the end-to-end protocol — adapter, runner, verifier, evidence capture — rather than neutral third-party model difficulty, and `isolation-level` is deliberately left unrecorded because the same model authored that fixture. `test/recorded_agent_campaign_system_test.rb` exercises the transport in CI on every validation run, and the `recorded-campaign` workflow captures full-set evidence as workflow artifacts; the result files themselves are never committed.

