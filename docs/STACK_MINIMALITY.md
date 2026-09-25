# Stack Minimality

This repository adapts the minimality discipline used by Ponytail to a Ruby + Rails + React + TypeScript + PostgreSQL stack.

## Source concepts retained

The source project uses a progressive minimality ladder, a persistent implementation mode, a focused over-engineering review, a whole-repository audit, a debt ledger, an evidence-oriented impact view, and a help reference. Its own rules explicitly keep security, validation, error handling, and accessibility outside the scope of simplification. https://ponytail.dev/

## Stack-aware adaptation

The project-specific ladder is:

1. no change;
2. reuse an existing repository boundary;
3. framework or platform primitive;
4. Ruby or TypeScript language/runtime primitive;
5. an already-installed dependency;
6. direct implementation;
7. new abstraction or dependency only when the contract earns it.

For this stack, framework and database primitives include Rails conventions, Active Record, browser APIs, React primitives, CSS, and PostgreSQL constraints, indexes, transactions, and query capabilities.

## Ownership

Minimality is a modifier, not a replacement for domain expertise:
- Rails skills own request, persistence, job, security, deployment, and framework contracts.
- React and TypeScript skills own component, state, runtime validation, accessibility, and frontend testing contracts.
- PostgreSQL and Rails database skills own schema, constraint, migration, locking, and query-plan contracts.
- Architecture skills own dependency direction, boundaries, ownership, and migration strategy.

Minimality can remove unnecessary work. It cannot remove a required guarantee.

## Debt markers

Use a marker when a deliberately simple solution has a known ceiling:

Ruby/Rails:
# stack-minimality: ceiling; revisit when trigger

TypeScript/React/CSS:
// stack-minimality: ceiling; revisit when trigger

SQL/migrations:
-- stack-minimality: ceiling; revisit when trigger

The debt skill collects these markers so that deliberate tradeoffs remain visible.

## Evidence

This repository already has its own evaluation and routing infrastructure. External Ponytail benchmark results are source context only; they are not this repository's measurements.

Use stack-minimality-evidence for actual diff, dependency, test, build, or query-plan measurements.

## Recommended composition

For implementation:

stack-minimality
+ relevant Ruby/Rails/React/TypeScript/PostgreSQL skill
+ ruby-clean-code
+ ruby-tdd-refactoring for behavior changes

For review:

stack-minimality-review
+ relevant domain review skill

For repository simplification:

stack-minimality-audit
+ architecture/security/performance review as applicable
