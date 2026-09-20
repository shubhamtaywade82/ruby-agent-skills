---
name: ruby-modules-mixins
description: Use for Ruby modules, shared behavior, namespaces, mixins and include/extend/prepend design.
---

# Ruby Modules and Mixins

## Purpose
Use modules for coherent reusable capabilities or namespaces, not as catch-all helper containers.

## Choose deliberately
Use a module for shared behavior, a coherent capability or namespacing. Use a class when the concept has identity, state or lifecycle.

## include, extend and prepend
- include adds instance methods through the ancestor chain
- extend adds behavior to the receiving object
- prepend changes lookup order so the module can intercept/augment class methods

When using these features, inspect and test the resulting method lookup order.

## Module cohesion
A module should answer: what single concept is grouped here? If the answer contains multiple unrelated concepts, split it.

Avoid utility modules containing unrelated behavior.

## Namespaces
Use namespaces to organize related constants and avoid collisions. Keep namespace depth proportional to the domain.

## Callback caution
Inclusion/extension callbacks introduce implicit behavior. Use them only when the integration contract is clear and tested.

## Review procedure
1. Identify the capability being reused.
2. Determine whether it is shared behavior or domain state.
3. Inspect existing ancestors.
4. Choose include/extend/prepend intentionally.
5. Add focused integration tests.

## Source foundation
Based on modules, mixins, namespaces and prepend material in The Ruby Workshop, with cohesion guidance from Clean Ruby.