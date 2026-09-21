---
name: ruby-enumerables
description: Use when choosing or reviewing Ruby Enumerable transformations, filtering, grouping, counting, searching, lazy traversal, or multi-step collection pipelines.
---

# Ruby Enumerables

## Purpose

Use Enumerable methods to express collection intent clearly while preserving correctness, allocation behavior, ordering, and complexity.

## Activate when

- a collection is transformed or filtered
- several Enumerable operations are chained
- grouping or counting is needed
- a manual loop could be replaced by a standard operation
- a collection pipeline is suspected to be inefficient or opaque

## Repository inspection

Inspect:

- collection size and expected cardinality
- ordering guarantees
- mutation requirements
- Ruby version and available Enumerable APIs
- existing code style
- performance-sensitive callers/tests

## Decision rules

Use:

- map for one-to-one transformation
- select/filter for membership by predicate
- reject for inverse filtering
- find/find_index for first match
- group_by for partitioning by a key
- tally for frequency counting when the supported Ruby version allows it
- each_with_object for building one accumulator deliberately
- reduce when an accumulated value is the actual abstraction
- any?, all?, none?, one? for predicates
- lazy only when deferred traversal materially helps

Do not choose a shorter pipeline when it makes the domain operation harder to understand.

## Complexity and allocation

Count traversals.

A chain such as select(...).map(...).sort may be correct while still allocating intermediate collections. Preserve clarity, then optimize only when evidence requires it.

When an evaluation specifies an algorithm or auxiliary-space target, follow that contract instead of replacing it with a convenient Enumerable shortcut.

## Mutation

Prefer non-mutating Enumerable transformations unless the repository contract explicitly requires mutation.

Do not mutate a caller-owned collection merely because an Enumerable alternative exists on the same object.

## Failure modes

- repeated passes over a large collection without justification
- using reduce where sum, count, group_by, or another direct operation communicates intent better
- relying on incidental ordering
- hiding an O(n²) operation inside a block
- converting to arrays unnecessarily
- using Enumerable to bypass a benchmark's required algorithm

## Agent review checklist

- [ ] operation matches intent
- [ ] ordering is explicit
- [ ] mutation is explicit
- [ ] traversal/allocation cost is understood
- [ ] empty input behavior is correct
- [ ] repository/Ruby-version support is checked

## Verification

Cover empty, singleton, duplicate, ordering, and representative large-input cases. For performance-sensitive code, inspect traversal count and allocation behavior in addition to output.

## Source foundation

Grounded in the Enumerable, Array, Hash, and collection material in *Learn Rails 6* and reinforced by the collection/design material already represented in this repository.
