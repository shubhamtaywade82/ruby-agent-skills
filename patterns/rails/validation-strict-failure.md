---
name: validation-strict-failure
description: Use when invalid Rails model state must raise a deliberate strict-validation exception.
family: rails
---

# Strict Validation Failure Contract

## Problem
Strict Validation Failure Contract needs an explicit contract so validation does not drift between model logic, database integrity, and consumers.

## Use when
- an invalid state must raise immediately and callers expect an exception boundary.

## Do not use when
- normal user input should return ordinary errors;
- callers already depend on valid? returning false.

## Repository inspection
- caller exception handling;
- form/API error flow;
- strict options;
- tests.

## Implementation procedure
1. State why fail-fast is required.
2. Select strict validation or a specific exception.
3. Update callers.
4. Add exception-path tests.
5. Verify normal validation remains ordinary elsewhere.

## Failure modes
- forms unexpectedly raise;
- broad rescue hides the exception;
- strict mode is used for a normal user-correction path.

## Testing
- strict invalid case;
- ordinary invalid case;
- controller/service integration.

## Review checklist
- [ ] exception is intentional
- [ ] caller contract is updated
- [ ] no broad rescue hides failure

## Related skills
- rails-validations
- rails-active-record
- rails-database-engineering
- rails-testing
