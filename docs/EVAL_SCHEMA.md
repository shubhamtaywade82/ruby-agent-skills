# Evaluation Case Schema

Evaluation cases are structured YAML documents. They are benchmark definitions, not skill instructions.

## Required top-level fields

```yaml
id: unique-kebab-case-id
version: 1
title: Human-readable title
category: ruby-training
source: source-corpus-id
skills:
  - ruby-oop
patterns: []
prompt: |
  Task shown to the agent.
constraints: {}
checks:
  - functional
  - tests
  - contract
cases:
  - name: deterministic-case
    input: ...
    expected: ...
grading: {}
```

## Field rules

- `id` must be unique and kebab-case.
- `version` identifies the evaluation schema version.
- `title` and `prompt` describe the benchmark task.
- `source` identifies the source corpus.
- `skills` must reference skills registered in `skill-manifest.yml`.
- `patterns` may reference registered pattern names. Patterns are optional.
- `constraints` records explicit requirements from the source or benchmark contract.
- `checks` lists independent evaluation dimensions. Every evaluation requires `functional` and `tests`; `oop` is required only when the task contract explicitly requires object-oriented design. Other dimensions such as `contract`, `packaging`, `complexity`, and `scope_control` are optional.
- `cases` contains deterministic input/expected pairs.
- `grading` explains what each dimension means for the case.

## Constraint model

Use explicit constraints only when the source or benchmark contract requires them:

```yaml
constraints:
  time_complexity: O(n^2)
  auxiliary_space: O(1)
  forbidden_constructs:
    - division operator
    - modulo operator
  required_algorithm:
    - sort
    - two pointers
  required_design:
    - object-oriented design
```

Do not invent a complexity target merely because an algorithm could be optimized.

## Behavioral cases

Every case must provide `name`, `input`, and `expected`.

Include source examples and independent edge cases. A case may use `expected: null` or boolean/numeric values when those are part of the contract.

The expected value describes behavior, not implementation.

## Independent checks

Keep these signals separate:

- functional correctness
- contract correctness
- complexity
- auxiliary-space constraints
- forbidden constructs
- OOP/design adherence
- test quality
- edge-case coverage
- security boundary adherence
- scope control

A runner can score these dimensions independently and preserve exact failure reasons.

## Hidden evaluations

Public YAML files are visible benchmark definitions. Hidden cases must be stored outside the public repository and injected by the runner. Never treat a committed public file as a hidden test.

## Runner contract

Phase 6 implements the provider-neutral runner documented in `docs/BENCHMARK_RUNNER.md`.

A run:

1. materializes the case prompt and YAML into a disposable workspace
2. invokes the explicit agent command
3. captures stdout/stderr and process status
4. captures git status and patch evidence
5. optionally invokes an explicit verifier command
6. consumes verifier JSON for declared check dimensions
7. records an overall status without discarding the individual signals
