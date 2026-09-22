---
name: agent-workflow
description: Use for any non-trivial change in this repository when an agent must discover applicable skills, manage context, select patterns, implement incrementally, test, review, simplify, and verify the result.
---

# Agent Workflow

## Purpose

Provide the repository-local execution contract for agent-assisted Ruby/Rails engineering. This skill adapts the external Agent Skills workflow to this repository's skill, pattern, evaluation, and validation system.

## Activate when

- starting a non-trivial task
- multiple repository skills may apply
- a design pattern or abstraction is being considered
- a cross-file change is planned
- an agent is reviewing or modifying another agent's work
- benchmark/evaluation infrastructure is changing

## Repository inspection

Before implementation, inspect:

- `skill-manifest.yml`
- relevant `skills/*/SKILL.md`
- relevant `patterns/*`
- tests and validators
- runtime/version configuration
- existing repository conventions
- benchmark/evaluation contracts when evaluation infrastructure is involved

## Workflow

```text
discover
  -> inspect
  -> clarify assumptions/conflicts
  -> choose smallest design
  -> implement incrementally
  -> test
  -> review
  -> simplify
  -> verify
```

Do not skip discovery merely because the requested change appears obvious.

## Skill selection

Select the smallest set of skills that covers the task.

Always consider:

- `ruby-clean-code`
- `ruby-tdd-refactoring`

Add focused skills for the actual behavior. For cross-layer Rails changes, include `rails-architecture` and the relevant Rails boundary skill.

Patterns are optional. Select a pattern only when repository evidence or task requirements justify it.

## Routing quality

- Treat activation triggers as signals, not automatic routing verdicts.
- Select a **Primary skill** that owns the dominant engineering boundary.
- Add **Secondary skills** for dependent constraints or additional execution boundaries.
- Do not choose a skill only because a trigger token appears.
- Inspect the repository and consult router/ROUTING.md before resolving overlapping ownership.
- Use router/ROUTING_CASES.yml as adversarial routing guidance for high-risk boundary overlaps.
- Do not create a new skill merely because a task crosses two existing boundaries.

## Pattern-selection rule

Use this evidence order:

1. explicit task requirement
2. existing repository pattern
3. framework/runtime constraint
4. focused skill guidance
5. repository pattern catalog
6. generic design preference

If the direct implementation is simpler and satisfies the contract, prefer the direct implementation.

## Change discipline

- Keep each slice independently verifiable.
- Do not mix unrelated cleanup with feature work.
- Do not create generic Manager/Processor/Service abstractions without a concrete responsibility.
- Keep public interfaces explicit.
- Preserve compatibility unless intentionally changing it.

## Review

Review the implementation across:

- correctness
- readability/simplicity
- architecture
- security
- performance
- scope

Then ask whether every abstraction earns its complexity.

## Agent review checklist

- [ ] applicable skills discovered
- [ ] repository inspected before implementation
- [ ] ambiguity resolved
- [ ] smallest justified pattern selected
- [ ] focused tests run
- [ ] validators/CI-equivalent checks run
- [ ] final diff reviewed
- [ ] unrun checks disclosed

## Verification

Run:

1. focused tests
2. applicable repository validators
3. affected broader tests/CI-equivalent checks
4. final diff inspection

If a check cannot be run, state that instead of inferring success.

## Source foundation

This repository-local workflow is based on the external Agent Skills methodology, adapted to the Ruby/Rails skill library and its existing validation/evaluation architecture. It is workflow guidance rather than source-book content.
