---
name: validation-custom-validator
description: Use when a coherent Rails validation rule is genuinely reusable across model types.
family: rails
---

# Custom Validator Contract

## Problem
Custom Validator Contract needs an explicit contract so validation does not drift between model logic, database integrity, and consumers.

## Use when
- one coherent validation rule is reused across model types;
- configuration is part of the reusable contract.

## Do not use when
- the rule is one simple local predicate;
- validator performs I/O or persistence.

## Repository inspection
- existing validators;
- domain vocabulary;
- options;
- error types/translations;
- consumers.

## Implementation procedure
1. Confirm real reuse.
2. Choose ActiveModel::Validator or ActiveModel::EachValidator.
3. Keep execution deterministic and side-effect free.
4. Define stable error types/options.
5. Test every consuming model.

## Failure modes
- validator exists only for indirection;
- external calls during validation;
- hidden mutable state.

## Testing
- each consumer;
- option combinations;
- valid/invalid;
- repeated execution.

## Review checklist
- [ ] reuse justifies abstraction
- [ ] no side effects
- [ ] options are explicit

## Related skills
- rails-validations
- rails-active-record
- rails-database-engineering
- rails-testing
