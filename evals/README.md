The evaluation layer measures whether an AI coding agent can apply the skills, not whether it can repeat Ruby/Rails terminology.

## Evaluation dimensions

Each case defines:

- task prompt
- expected behavior
- relevant skill IDs
- optional implementation patterns
- constraints
- deterministic behavioral cases
- quality expectations
- verification dimensions

## Scoring model

Evaluations are machine-checkable where possible.

### Functional correctness
Does the implementation produce the required behavior?

### Contract correctness
Does it preserve the stated return shape, errors and side effects?

### Engineering quality
Does it follow repository conventions and keep responsibilities focused?

### Test quality
Does the agent add useful tests instead of testing implementation trivia?

### Constraint adherence
Does the solution satisfy explicit complexity, algorithm or API requirements?

### Scope control
Did the agent avoid unrelated refactors?

Do not collapse these dimensions into one opaque score. Preserve individual signals so regressions are diagnosable.

## Evaluation corpus

The initial benchmark source is the uploaded Allerin Ruby assessment. The current public corpus contains nine Ruby training cases covering selection sort, recursive selection sort, smallest missing number, shopping cart, triplet sum, majority element, distinct elements, power-of-two detection and Chocolate Feast.

The assessment explicitly requires OOP concepts across the programs, so OOP/design is evaluated separately from functional output.

## Runner

Phase 6 adds the provider-neutral benchmark runner:

    ruby bin/eval list
    ruby bin/eval show triplet-sum
    ruby bin/eval packet triplet-sum --output /tmp/triplet-sum.json
    ruby bin/eval run triplet-sum --workspace /path/to/fixture --agent-command 'agent ...' --verify-command 'verifier ...'

See `docs/BENCHMARK_RUNNER.md` and `docs/EVAL_RESULT_SCHEMA.md`.

The runner copies the source workspace into a disposable directory, captures the agent process, captures the resulting patch, optionally runs a verifier, and records dimension-level check results.

## Public versus hidden cases

The YAML cases in this repository are public benchmark definitions. Truly hidden cases must remain outside the repository and be injected by a private benchmark harness using the same schema.

## Validation

`bin/validate` validates skills, implementation patterns and evaluation definitions. CI also runs the benchmark runner smoke test.

## Phase 7 benchmark campaign

Fixtures and a deterministic verifier now live under `benchmarks/ruby-training/`. The campaign CLI can run the same evaluation against two explicit agent commands and produce side-by-side dimension results:

    ruby bin/benchmark compare triplet-sum \\
      --baseline-command 'BASELINE_AGENT_COMMAND' \\
      --skills-command 'SKILL_ENABLED_AGENT_COMMAND'

The comparison preserves individual evidence rather than collapsing the result into a single score. Hidden benchmark packs remain external.
