# Evaluation Case Schema

Each evaluation case should be representable as structured data even when the task itself is written as Markdown.

Recommended fields:

```yaml
id: ruby-training-q1-selection-sort
title: Selection sort and missing value
category: algorithms

prompt: |
  The task shown to the agent.

repository:
  fixture: path-or-repository-snapshot
  ruby: "3.x"

skills:
  - ruby-control-flow
  - ruby-collections
  - ruby-oop
  - ruby-tdd-refactoring

requirements:
  functional:
    - required behavior
  complexity:
    time: "O(n^2)"
    auxiliary_space: "O(1)"
  design:
    - use cohesive objects where the task requires domain behavior

verification:
  commands:
    - bundle exec rspec

hidden_cases:
  - boundary input
  - empty input
  - duplicate input

quality_checks:
  - no hard-coded sample outputs
  - tests cover failure behavior
```

## Rules

- Keep requirements explicit.
- Keep functional and quality checks separate.
- Prefer deterministic verification.
- Preserve hidden cases outside the agent-visible prompt.
- Do not encode an implementation unless the task explicitly requires an algorithm.
- When the source specifies a complexity target, verify it separately from output correctness.
