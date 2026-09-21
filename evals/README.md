# Agent Evaluations

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

Do not collapse these dimensions into a single opaque score. Preserve individual signals so regressions are diagnosable.

## Evaluation categories

```text
evals/
├── ruby-training/
│   ├── selection-sort.yml
│   ├── recursive-selection-sort.yml
│   ├── smallest-missing.yml
│   ├── shopping-cart.yml
│   ├── triplet-sum.yml
│   ├── majority-element.yml
│   ├── distinct-elements.yml
│   ├── power-of-two.yml
│   └── chocolate-feast.yml
├── algorithms/
├── oop/
└── rails/
```

## Initial benchmark source

The uploaded Allerin assessment is the first benchmark source. It specifies selection sort, recursive selection sort, smallest missing number, shopping-cart behavior, triplet sum, majority element, distinct elements, power-of-two detection and Chocolate Feast. It also explicitly requires OOP concepts across the programs.

The benchmark therefore evaluates both output and design, not output alone.

## Public versus hidden cases

The YAML files in this repository are public benchmark definitions. They contain source examples plus independently chosen edge cases.

Truly hidden cases must be injected by a benchmark runner from outside the public repository. A public file cannot be treated as a secret test.

## Evaluation schema

See `docs/EVAL_SCHEMA.md`.

Each case records:

```text
prompt
  -> constraints
  -> deterministic cases
  -> independent checks
  -> dimension-specific grading
```

The schema intentionally separates functional correctness from complexity, OOP/design, test quality and scope.

## Validation

`bin/validate` validates:

1. all skill contracts
2. all implementation patterns
3. all evaluation YAML documents

The evaluation validator verifies that referenced skills and patterns exist in the manifest and that every case has deterministic `input` and `expected` fields.

## Future runner contract

A runner should:

1. materialize the case repository
2. present only the task prompt and available agent tools
3. capture the patch
4. run deterministic tests
5. run quality and constraint checks
6. store structured results
7. preserve exact failure signals for regression analysis

Never mutate the benchmark's expected answer to fit the agent output.
