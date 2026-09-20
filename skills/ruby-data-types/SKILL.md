---
name: ruby-data-types
description: Use when choosing or reviewing Ruby scalar values, strings, symbols, ranges, numbers, nil, hashes or other core data representations.
---

# Ruby Data Types

## Purpose

Choose data representations that make the domain and behavior explicit.

## Inspect first

Determine:
- supported Ruby version
- existing value conventions
- nilability expectations
- serialization/parsing boundaries
- whether the value is scalar data or a domain concept

## Decision rules

- Use a simple value when identity and behavior are not needed.
- Use strings for textual values; do not encode structured state into ad-hoc strings.
- Use symbols when the repository treats a small closed set as symbolic identifiers.
- Use hashes for keyed data when the keys and value shape are clear.
- Use ranges when representing a bounded interval or sequence is clearer than paired endpoints.
- Treat nil as an explicit state; do not silently convert "missing" into false or an empty value.
- Preserve numeric meaning; do not use strings for numeric computation unless the boundary requires it.
- Prefer domain objects when a value has meaningful validation, behavior or lifecycle.

## String handling

At input boundaries:
1. identify encoding/format assumptions
2. normalize only when required by the contract
3. validate required content
4. preserve meaningful whitespace unless the business rule says otherwise

Do not add arbitrary strip/downcase/transliteration behavior just because it is convenient.

## Hashes and structured data

Before using a hash, identify:
- required keys
- optional keys
- value types/shapes
- mutation expectations

If a hash has become a stable domain object with substantial behavior, consider a class instead of adding more implicit structure.

## Verification

Test nil, empty values, representative values and boundary values whenever the distinction matters.

## Source foundation

Derived from the data-type and operation material in The Ruby Workshop, reinforced by the representation and naming principles of Clean Ruby.
