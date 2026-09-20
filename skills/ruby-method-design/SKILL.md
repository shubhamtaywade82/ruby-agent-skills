---
name: ruby-method-design
description: Use when creating, reviewing, or refactoring Ruby methods with meaningful parameters, return contracts, branching, nesting, comments, or responsibilities.
---

# Ruby Method Design

## Purpose

Design methods that hide useful implementation detail while keeping their contract easy to understand and test.

## Activate when

- adding a new method
- a method has many parameters or branches
- callers depend on inconsistent return types
- nesting makes the method hard to read
- comments are compensating for unclear code
- refactoring a long or multi-responsibility method

## Repository inspection

Before changing a method:

1. inspect callers
2. inspect tests
3. inspect public/private visibility
4. inspect related domain objects
5. check whether the method is an API boundary
6. identify compatibility constraints

## Parameter rules

Parameters increase flexibility but also complexity.

Prefer fewer, meaningful parameters. When several parameters travel together, ask whether they represent:

- a real configuration object
- a domain value
- an options object
- an accidental data bundle

Do not create a wrapper object merely to satisfy an arbitrary parameter-count rule.

Avoid boolean flags when one method is being made into several unrelated behaviors.

## Return contracts

A method should have a predictable family of return values.

Avoid APIs such as:

```ruby
value_or_false_or_error_hash
```

unless that mixed contract is deliberate and established.

Document or test important nil/error behavior.

## Guard clauses

Use guards to expose preconditions and reduce nesting when that makes the happy path easier to read.

## Method length and extraction

Do not extract methods purely to make a method shorter.

Extract when the new method:

- has a coherent responsibility
- has a meaningful name
- is independently testable
- removes distracting detail
- can evolve without forcing unrelated callers to change

## Boolean logic

When a condition tells a meaningful domain story, name it:

```ruby
if can_send_promo?(user)
  ...
end
```

The caller should not require the reader to parse every low-level boolean clause.

## Comments

Prefer code that explains itself.

Keep comments for:

- domain constraints
- compatibility reasons
- non-obvious external behavior
- intentional trade-offs

Delete comments that merely narrate syntax.

## Refactoring procedure

1. characterize current behavior
2. identify callers and contract
3. separate responsibilities
4. simplify parameters/returns
5. extract only cohesive behavior
6. preserve visibility/API behavior
7. add or strengthen tests
8. run focused and regression suites

## Anti-patterns

- do-everything methods
- generic `process`/`handle` names
- boolean flags causing unrelated modes
- multiple unrelated return types
- deep nesting
- comments explaining obvious code
- extraction with no meaningful abstraction

## Agent review checklist

- [ ] one primary responsibility
- [ ] parameters carry meaningful information
- [ ] return contract is predictable
- [ ] guards clarify preconditions
- [ ] names reveal intent
- [ ] comments explain constraints rather than syntax
- [ ] public API remains stable unless intentionally changed

## Verification

Test normal, boundary, invalid, and failure behavior appropriate to the method's contract. Re-run callers/regression tests after public method refactors.

## Source foundation

Strongly grounded in Chapter 3 of *Clean Ruby*, which focuses on parameters, return values, guard clauses, length, comments, and nesting, and supported by Ruby method material from *The Ruby Workshop*.
