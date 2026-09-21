# Ruby Training Evaluations

These evaluations are derived from the uploaded Ruby training assessment material and are stored as machine-readable YAML cases.

## Cases

- `selection-sort.yml`
- `recursive-selection-sort.yml`
- `smallest-missing.yml`
- `shopping-cart.yml`
- `triplet-sum.yml`
- `majority-element.yml`
- `distinct-elements.yml`
- `power-of-two.yml`
- `chocolate-feast.yml`

The assessment covers selection sort, recursive selection sort, smallest missing number, shopping-cart behavior, triplet sum, majority element, distinct values, power-of-two detection and Chocolate Feast. It explicitly requires OOP concepts across the programs.

## Design constraint

A passing solution must satisfy the behavioral contract and the stated OOP requirement. For algorithm cases, explicit complexity and forbidden-operation constraints are evaluated separately from functional correctness.

## Case design

Each YAML document contains:

- the task prompt
- relevant skills
- optional implementation patterns
- explicit constraints
- deterministic behavioral cases
- independent checks
- dimension-specific grading

Source examples are included, but each case also contains edge cases so an agent cannot pass by hard-coding the examples.

## Hidden benchmark policy

The public YAML cases are visible by design. Hidden cases should be maintained outside the public repository and injected by the benchmark runner.
