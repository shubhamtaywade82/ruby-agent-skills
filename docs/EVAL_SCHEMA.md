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
  - oop
  - tests
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
- `checks` lists independent evaluation dimensions.
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
- scope control

A runner can score these dimensions independently and preserve exact failure reasons.

## Hidden evaluations

Public YAML files are visible benchmark definitions. Hidden cases must be stored outside the public repository and injected by the runner. Never treat a committed public file as a hidden test.

## Runner contract

A future benchmark runner should:

1. materialize the case repository
2. present the task prompt and available agent tools
3. capture the resulting patch
4. run deterministic tests
5. inspect complexity/design constraints
6. record dimension-level results
7. preserve exact failure signals for regression analysis
