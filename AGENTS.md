# Agent Engineering Contract

This repository is an agent-oriented Ruby/Rails skill library. Every coding agent working here must treat the skill library, pattern library, evaluation corpus, and validators as one system.

## Operating sequence

1. **Discover** the applicable repository skills from `skill-manifest.yml`.
2. **Inspect** the repository, current implementation, tests, runtime/version constraints, and existing conventions before proposing a design.
3. **Resolve ambiguity** before changing code. Do not silently choose between conflicting requirements.
4. **Select patterns only when earned.** Existing repository patterns take precedence over generic preferences. A pattern is guidance, not a mandatory abstraction.
5. **Implement incrementally** in the smallest coherent slice.
6. **Test behavior** at the boundary that owns the contract.
7. **Review the change** for correctness, simplicity, architecture, security, performance, and scope.
8. **Simplify** if an abstraction does not earn its complexity.
9. **Verify** with the repository's validators, focused tests, and applicable CI-equivalent checks.
10. **Report evidence**, not assumptions. Never claim a test, benchmark, CI run, or deployment passed unless it was actually observed.

## Context rules

- Read only the smallest useful source slice first; expand context when evidence requires it.
- Resolve Ruby/Rails versions from repository configuration rather than memory.
- Prefer official/source-backed guidance for framework-sensitive behavior.
- Treat external input and third-party responses as untrusted at boundaries.
- Never weaken a validator or test merely to make an agent run green.
- Preserve public contracts unless the task explicitly changes them.

## Design rules

- Prefer the simplest implementation satisfying the contract.
- Reuse an existing repository abstraction before introducing a new one.
- Introduce POROs, services, strategies, adapters, policies, presenters, factories, or other patterns only when the responsibility or variation justifies the boundary.
- Keep domain behavior out of controllers/views when it does not belong there.
- Keep persistence integrity in database constraints where application validation alone cannot guarantee it.
- Do not create abstractions solely to satisfy a pattern vocabulary.

## Verification contract

A change is complete only when:
- relevant tests pass;
- validators pass;
- no accidental scope expansion is present;
- public contracts are preserved or intentionally updated;
- unrun checks are explicitly disclosed.

## Skill precedence

When multiple skills apply:

1. explicit task requirements
2. repository architecture and existing conventions
3. runtime/framework constraints
4. focused domain skill
5. design-pattern guidance
6. generic style preferences

When skills conflict, stop and resolve the conflict rather than combining incompatible rules.

## Benchmark integrity

Evaluation fixtures and verifiers are measurement infrastructure. Do not make the evaluator easier by weakening constraints, accepting unverified output, or coupling the verifier to one agent's implementation. Public structural checks must be complemented by behavioral tests and, where appropriate, hidden/adversarial cases.
