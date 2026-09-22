---
name: ruby-domain-modeling
description: Use when business concepts, invariants, or policies are becoming implicit in procedural code and need explicit domain boundaries.
---

# Ruby Domain Modeling

## Purpose

Turn meaningful business concepts and invariants into explicit, testable Ruby objects while keeping the model proportional to the domain.

## Activate when

- business rules are duplicated across controllers or services
- primitives carry hidden domain meaning
- conditionals encode a stable business concept
- an invariant lacks a clear owner
- several workflows manipulate the same conceptual state

## Repository inspection

Inspect Active Record models, domain methods, value objects, services, policies, validations, database constraints, naming conventions, and existing domain modules.

Determine whether the repository favors rich models, domain POROs, service orchestration, or another established style.

## Decision rules

Give each invariant a clear owner.

Use a model/domain object for state and invariants it naturally owns, a value object for a meaningful immutable value, a policy/specification for reusable decisions, a service/command for application workflows, and a strategy for interchangeable algorithms.

Do not create a domain layer merely because the label sounds desirable.

## Implementation procedure

1. Identify the business concept and invariant.
2. Find every current implementation of the rule.
3. Choose the narrowest responsible owner.
4. Introduce the object or method with a stable API.
5. Redirect callers without changing behavior.
6. Remove duplicated rule implementations.
7. Add focused examples for the invariant.
8. Add regression coverage around affected workflows.

## Failure modes

- anemic objects plus giant services
- duplicate validations
- generic DomainService or Manager classes
- excessive indirection around simple rules
- moving persistence behavior away from Active Record without evidence
- modeling every noun as a class

## Agent review checklist

- Is the business concept explicit?
- Is there one authoritative rule owner where practical?
- Does the abstraction reduce duplication?
- Is the API understandable without framework knowledge?
- Is the model proportional to actual complexity?

## Verification

Run focused domain tests and all workflows that consume the rule. Search for duplicated predicates or calculations after the change.

## Source foundation

This skill synthesizes the source material's emphasis on object responsibility, single responsibility, readable design, and refactoring. The domain-modeling taxonomy itself is repository guidance rather than a direct claim about a specific book chapter.
