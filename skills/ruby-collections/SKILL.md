---
name: ruby-collections
description: Use for arrays, hashes, Enumerable pipelines, filtering, mapping, grouping, deduplication and sorting.
---

# Ruby Collections

## Purpose
Use Ruby's collection abstractions to express data transformation clearly and safely.

## Preferred patterns
- map for transforming every element
- select for retaining matching elements
- reject for exclusion
- find for one matching element
- any?, all?, none? and include? for predicates
- each for side effects
- hashes for keyed lookup/counting when appropriate
- uniq, sort, group_by and tally when they match the project runtime and intent

## Algorithm discipline
Do not replace an algorithm with a shorter collection chain merely because the chain is shorter.

For algorithmic tasks record:
- input/output contract
- time complexity
- space complexity
- mutation behavior
- edge cases

Choose between an Enumerable expression and an explicit algorithm based on clarity and complexity.

## Mutation
Prefer non-mutating transformations unless mutation is part of the contract. Make mutation obvious.

## Readability
A multi-line pipeline is often clearer than a dense one-liner. If the reader must mentally reconstruct several intermediate concepts, expand the code.

## Review
Check semantic correctness, nil/duplicate/order behavior, mutation, complexity and whether an explicit loop would be clearer.

## Source foundation
Derived from the array/hash/Enumerable material in The Ruby Workshop, with readability and simplicity constraints from Clean Ruby.