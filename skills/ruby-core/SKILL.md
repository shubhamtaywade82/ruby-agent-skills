---
name: ruby-core
description: Use when implementing or reviewing Ruby language behavior, syntax, object semantics, typing, truthiness, strings, numbers, symbols, execution or method dispatch.
---

# Ruby Core

## Purpose
Write Ruby using Ruby's actual object model and language conventions rather than mechanically translating patterns from statically typed languages.

## Activate when
- implementing Ruby without a framework
- reasoning about Ruby syntax or runtime behavior
- debugging unexpected Ruby semantics
- reviewing code that treats Ruby like Java, C# or TypeScript

## Core rules
1. Treat values as objects and reason from the receiver's behavior.
2. Remember Ruby is dynamically typed; do not invent compile-time guarantees.
3. Use duck typing when the required interface is the important contract.
4. Only nil and false are falsey.
5. Prefer expressions and implicit returns when they improve clarity.
6. Use predicate names ending in ? for boolean intent.
7. Use ! only when mutation or stronger side effects justify it.
8. Respect the project's supported Ruby version.

## Procedure
1. Identify the Ruby/runtime version.
2. Inspect local style and nearby examples.
3. Determine the object and method contract.
4. Implement the smallest clear expression.
5. Run a focused test or reproduction.
6. Check version-specific behavior when relevant.

## Common traps
- treating empty strings, arrays or hashes as falsey
- unnecessary class/type checks
- confusing nil with false
- assuming newer syntax is available
- using metaprogramming for ordinary dispatch

## Verification
The behavior should be explainable directly from Ruby semantics and the repository's supported runtime.