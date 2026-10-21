# Minimality, Readability, and Architecture Review

Use this reference after checking correctness and security, especially when code adds abstractions, dependencies, configuration, indirection, or duplicated responsibilities. Compose with ruby-clean-code, stack-minimality, and stack-minimality-review.

## Core rule

An abstraction should solve a demonstrated problem. Every layer creates navigation and maintenance cost; justify it with a real responsibility, repeated variation, second implementation, stability boundary, or operational need.

```ruby
# Potentially redundant wrapper when it has one caller and adds no contract.
class OrderTotalCalculator
  def initialize(order) = @order = order
  def call = @order.line_items.sum(&:amount_cents)
end
```

Do not delete the wrapper solely because it looks small. Inspect callers, consumers, test seams, and whether it owns domain behavior. If it only forwards one expression and has no real responsibility, a direct implementation may be simpler.

## Review questions

- Can a developer infer intent quickly from names and control flow?
- Does each method/class own a coherent responsibility?
- Are Boolean conditions, ternaries, nested branches, and flags harder to reason about than necessary?
- Does the same business rule exist in multiple places and risk drift?
- Is a new dependency duplicating a native language/framework/database capability?
- Does a generic interface, factory, strategy, repository, service, or configuration solve a current requirement?
- Is complexity hiding important behavior or failure semantics?
- Is code actually unreachable, or invoked via callbacks, reflection, dynamic dispatch, routes, autoloading, public APIs, scripts, or external consumers?

## Dead-code verification

Before deleting a candidate, inspect static references plus dynamic entry points, framework conventions, public compatibility, generated code, and external usage. A method with no in-repository call site is not automatically dead if it is a public library API or invoked dynamically.

## Safe simplification

Use the smallest change that preserves the real contract. Never remove required authorization, validation, database constraints, accessibility, observability, error handling, regression tests, data-loss protection, or recovery behavior merely to shrink the diff. Avoid mixing opportunistic cleanup with functional changes unless cleanup is necessary for correctness.

## Findings

- A concrete unnecessary dependency or pass-through layer can be a maintainability finding with call-site evidence and a simpler replacement.
- A style preference is a suggestion, not a bug.
- A hypothetical future requirement is not evidence that the current design is wrong.
- Fewer lines are not a safety, performance, or maintainability measurement by themselves.
