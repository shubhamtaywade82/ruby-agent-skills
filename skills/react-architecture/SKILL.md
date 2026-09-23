---
name: react-architecture
description: Use when designing React application boundaries, feature modules, dependency direction, shared UI infrastructure, and frontend architecture.
---

# React Architecture

## Purpose
Define stable frontend boundaries so features can evolve without turning the UI into a shared mutable dependency graph.

## Activate when
- reorganizing React feature structure;
- introducing shared hooks, contexts, components, or services;
- setting dependency direction between UI, domain, and infrastructure;
- evaluating monolithic component or state structures.

## Repository inspection
Inspect source layout, feature boundaries, import graph, routing, state/query infrastructure, design-system ownership, build tooling, and test boundaries.

## Decision rules
- Keep dependency direction explicit.
- Feature code should depend inward on stable contracts rather than importing arbitrary implementation details from unrelated features.
- Shared modules need a demonstrated reuse boundary; do not create a common folder by default.
- Keep server state, local UI state, and domain transformations distinguishable.
- Avoid barrel exports when they obscure ownership or create cycles.
- Prefer incremental migration over whole-tree restructuring without evidence.

## Implementation procedure
1. Map current dependency edges.
2. Identify the stable ownership boundary.
3. Define public module APIs.
4. Move code in small slices.
5. Add import-cycle and integration checks where tooling permits.
6. Verify affected features after each architectural change.

## Anti-patterns / failure modes
- global context as the default escape hatch;
- cross-feature imports into private implementation files;
- shared utility modules that become dumping grounds;
- architecture-only refactors with no measurable reduction in coupling.

## Verification
Run typecheck, tests, lint, dependency/cycle checks when available, and inspect the final import graph for unintended coupling.

## Source foundation
- React Learn: https://react.dev/learn
- TypeScript Modules: https://www.typescriptlang.org/docs/handbook/2/modules.html
