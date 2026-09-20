---
name: ruby-debugging
description: Use when diagnosing Ruby or Rails exceptions, incorrect behavior, production issues, logging problems or unexplained state.
---

# Ruby Debugging

## Principle
Debug from evidence rather than intuition.

## Loop
~~~
text
reproduce
  -> observe
  -> isolate
  -> inspect state
  -> identify root cause
  -> patch
  -> add regression coverage
  -> verify
~~~

## First pass
Collect the exact exception, stack trace, input/state, Ruby/Rails version, relevant logs, recent changes and reproduction steps.

Do not change code before forming a concrete hypothesis.

## Stack traces
Distinguish the location where the exception surfaced from the location that created the invalid state.

## Logging
Useful logs expose the operation, identifiers and relevant state. Never log secrets or credentials.

## Interactive debugging
Use the project's supported debugger such as debug, byebug or IDE debugging to inspect locals, instance variables, receiver, stack and branch state.

## Fix discipline
Fix root cause rather than masking the symptom. Add or strengthen regression coverage where practical.

## Source foundation
Based on logging/debugging material in The Ruby Workshop and readability/simplicity principles in Clean Ruby.