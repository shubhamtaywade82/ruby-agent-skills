# Agent Evaluations

The evaluation layer measures whether an AI coding agent can apply the skills, not whether it can repeat Ruby/Rails terminology.

## Evaluation dimensions

Each case should define:

- task prompt
- starting repository state
- expected behavior
- relevant skill IDs
- constraints
- required tests
- edge cases
- complexity requirements where relevant
- quality expectations
- forbidden shortcuts when necessary
- verification commands

## Scoring model

Evaluations should be machine-checkable where possible.

### Functional correctness
Does the implementation produce the required behavior?

### Contract correctness
Does it preserve public behavior, return shape, errors and side effects?

### Engineering quality
Does it follow the repository's conventions and keep responsibilities focused?

### Test quality
Does the agent add useful tests instead of testing implementation trivia?

### Constraint adherence
Does the solution satisfy explicit complexity, mutation, API or architectural requirements?

### Scope control
Did the agent avoid unrelated refactors?

Do not collapse these dimensions into a single vague score. Preserve the individual signals so regressions are diagnosable.

## Evaluation categories

```text
evals/
├── ruby-training/
├── algorithms/
├── oop/
└── rails/
```

## Initial benchmark source

The uploaded Allerin assessment is the first benchmark source.

The source explicitly expects object-oriented concepts to be used across the programs. The benchmark therefore evaluates both output and design, not output alone.

## Evaluation execution

A future runner should:

1. materialize the case repository
2. present only the task prompt and available agent tools
3. capture the patch
4. run deterministic tests
5. run quality/constraint checks
6. store structured results
7. preserve the exact failure signal for regression analysis

Never mutate the benchmark's expected answer to fit the agent output.
