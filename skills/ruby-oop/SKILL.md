---
name: ruby-oop
description: Use when designing Ruby classes, domain objects, encapsulation boundaries, inheritance or polymorphic behavior.
---

# Ruby Object-Oriented Design

## Purpose
Use objects to group related state and behavior around meaningful concepts.

## Class decision model
Create a class when there is a clear concept with identity/lifecycle, state, behavior or a stable responsibility.

Use composition when behavior can be assembled from collaborators.

Use inheritance only when the subtype relationship is real and the parent contract is stable.

## Encapsulation
- keep internal representation private when practical
- expose behavior instead of leaking state
- keep public APIs small
- use private methods for implementation details
- avoid broad accessors that turn objects into data bags

## Inheritance
Ask whether the subtype is genuinely substitutable, whether shared behavior is stable, and whether composition expresses the relationship better.

## Polymorphism
Prefer stable interfaces over repeated type branching when the domain supports it.

## Constructors
Keep initialize straightforward. If construction requires many unrelated arguments, model the concept instead of hiding the complexity.

## Review checklist
- clear responsibility?
- correct state ownership?
- useful behavior here?
- private implementation details protected?
- inheritance actually needed?
- composition possible?

## Source foundation
Uses classes, inheritance and encapsulation from The Ruby Workshop and class-purpose/role guidance from Clean Ruby.