# Implementation Patterns

Patterns are concrete implementation shapes that agents can apply after selecting skills.

A skill answers:

> When and why should the agent use this approach?

A pattern answers:

> What is a safe, conventional implementation shape when that approach is appropriate?

Patterns are not mandatory templates. Repository evidence and task requirements always take precedence.

## Pattern contract

Each pattern should state:

- activation conditions
- problem
- when to use
- when not to use
- structure
- implementation sequence
- Ruby/Rails example
- failure modes
- testing strategy
- review checklist
- related skills

## Pattern families

### Ruby design

- value objects
- service/application objects
- strategy objects
- composition over inheritance
- adapters

### Rails

- query objects
- form objects
- policy boundaries
- transaction boundaries
- request flow

### Testing and algorithms

- regression tests
- two pointers
- frequency maps

## Selection rule

Do not introduce a pattern because its name sounds sophisticated.

Use the smallest pattern that:

1. solves the actual responsibility problem,
2. matches repository conventions,
3. improves testability or changeability,
4. does not create unnecessary indirection.

## Evidence order

1. explicit task requirement
2. existing repository pattern
3. framework/runtime constraints
4. skill guidance
5. these patterns
6. generic preference
