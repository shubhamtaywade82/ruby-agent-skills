---
name: ruby-metaprogramming
description: Use when reflection or runtime code generation is explicitly useful, including send, define_method, method_missing, open classes and controlled dynamic dispatch.
---

# Ruby Metaprogramming

## Default policy
Prefer ordinary Ruby first. Metaprogramming must provide a concrete benefit such as eliminating repetitive declarations or implementing controlled framework-style behavior.

## Risk model
Evaluate discoverability, debugging, stack traces, tooling, test coverage and security before adding runtime behavior.

## Reflection
Use respond_to?, method, public_send and send deliberately.
Prefer public_send when invoking a public API from dynamic names. Never dispatch unchecked untrusted method names.

## method_missing
Treat method_missing as an advanced protocol. Constrain accepted names and implement respond_to_missing? consistently.

## define_method
Use only when methods are generated from a trusted and deterministic set of definitions. Prefer ordinary methods when they are clearer.

## Open classes and monkey patching
Avoid changing core/library classes unless there is a strong compatibility reason and the project explicitly accepts the risk.

## Review question
Would a competent Ruby developer understand this faster if the implementation were explicit? If yes, prefer explicit Ruby.

## Source foundation
Based on the metaprogramming/reflection chapters of The Ruby Workshop, constrained by the simplicity and maintainability principles in Clean Ruby.