# Evaluation Schema

Each benchmark case is a machine-readable YAML document.

## Required top-level fields

- `id`: unique kebab-case identifier.
- `version`: schema version.
- `title`: human-readable case title.
- `category`: benchmark category.
- `source`: source corpus identifier.
- `skills`: skill IDs the case is intended to exercise.
- `patterns`: optional implementation patterns.
- `prompt`: task presented to the agent.
- `constraints`: explicit requirements that can be checked.
- `checks`: independent evaluation dimensions.
- `cases`: deterministic behavioral cases.
- `grading`: dimension-specific expectations.

## Constraint model

Constraints are descriptive and machine-checkable where possible:

```yaml
constraints:
  time_complexity: O(n^2)
  auxiliary_space: O(1)
  forbidden_constructs:
    - "/"
    - "%"
  required_design:
    - object-oriented design
```

Do not invent a complexity contract when the source does not state one.

## Case model

A behavioral case has:

```yaml
cases:
  - name: sample
    input: ...
    expected: ...
  - name: edge-empty
    input: ...
    expected: ...
```

Cases should include source examples plus independent edge cases. Do not encode an implementation-specific answer where the source only specifies behavior.

## Grading model

Keep signals independent:

- functional correctness
- contract correctness
- complexity/constraint adherence
- OOP/design adherence
- test quality
- edge-case coverage
- scope control

The benchmark must preserve individual failures instead of collapsing them into a single opaque score.

## Hidden evaluations

Public cases are intentionally visible. Truly hidden cases must live outside this public repository and be injected by the benchmark runner. A directory committed here cannot be treated as a secret benchmark.
