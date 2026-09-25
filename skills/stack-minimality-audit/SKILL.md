---
name: stack-minimality-audit
description: Audit an entire Ruby, Rails, React, TypeScript, and PostgreSQL repository for unnecessary complexity, dependencies, wrappers, and speculative abstractions without applying changes.
family: architecture-quality
---
# Stack Minimality Audit

## Purpose
Apply minimality review at repository scope so recurring complexity, dependency duplication, and unnecessary boundaries are visible beyond the current diff.

## Activate when
Use for repository-wide bloat audits, over-engineering audits, deletion candidate discovery, or simplification planning.

## Repository inspection
Scan source, tests, configuration, Gemfile and lockfiles, package manifests and lockfiles, Rails initializers, React shared modules, database schema and migrations, build tooling, and operational configuration. Confirm suspected single-use abstractions by searching callers.

## Decision rules
Prioritize concrete evidence:
1. dead or unreachable code;
2. wrappers around existing local or framework capabilities;
3. one-implementation abstractions;
4. unnecessary gems or packages;
5. duplicated state or data representations;
6. configuration that has no consumer;
7. unnecessary process or service boundaries;
8. safe local simplifications that preserve ownership.

Do not rank findings by aesthetic preference or theoretical elegance.

## Implementation procedure
1. Inventory abstraction and dependency hotspots.
2. Confirm actual usage.
3. Identify the true owner of repeated behavior.
4. Report the smallest safe replacement.
5. Estimate reductions only from observable repository evidence.
6. Make no changes.

## Anti-patterns / failure modes
- Mechanical DRY refactors.
- Deleting security, tenancy, persistence, observability, or external-integration boundaries.
- Replacing PostgreSQL invariants with Ruby conventions.
- Moving unrelated React features into a generic mega-component.
- Splitting or joining Rails domains only to reduce folder count.
- Calling code "dead" without checking runtime and indirect references.

## Agent review checklist
- [ ] Whole repository inspected.
- [ ] Usage confirmed before deleting abstractions or dependencies.
- [ ] Framework and database capabilities checked.
- [ ] Security, ownership, and observability boundaries preserved.
- [ ] Findings are independently actionable.
- [ ] No fixes applied.

## Verification
A clean audit means no concrete simplification was found. It does not prove mathematical minimality.

## Source foundation
- https://ponytail.dev/
- https://github.com/DietrichGebert/ponytail
- Repository architecture and stack conventions
