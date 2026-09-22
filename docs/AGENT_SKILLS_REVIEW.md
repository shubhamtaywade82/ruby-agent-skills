# Agent Skills Review

## Scope

Reviewed all repository `SKILL.md` files on `feat/ai-skill-system-v2`, the skill manifest, validators, pattern catalog, benchmark/evaluation integration, and the repository's agent workflow.

The review used the Agent Skills workflow principles for:

- skill discovery and context control
- repository inspection
- incremental implementation
- test/verification discipline
- code review and simplification
- explicit interface boundaries
- pattern restraint

## Findings

### 1. Skill library was structurally strong

The existing skills already shared the required contract:

- YAML frontmatter
- Purpose
- Activate when
- Repository inspection
- decision/procedure guidance
- failure/anti-pattern guidance
- Agent review checklist
- Verification
- Source foundation

No wholesale rewrite was justified.

### 2. The major missing piece was repository-local agent governance

The library contained individual engineering skills but did not have a single repository-local execution contract governing how an agent should combine them.

**Fix:** added `AGENTS.md` and `skills/agent-workflow/SKILL.md`.

The workflow now explicitly governs:

```text
discover
  -> inspect
  -> clarify
  -> choose smallest design
  -> implement incrementally
  -> test
  -> review
  -> simplify
  -> verify
```

### 3. Pattern selection needed stronger routing boundaries

Several design skills overlapped around POROs, service objects, dependency injection, and composition.

**Fixes:**

- `ruby-poro` now explicitly describes PORO as an implementation substrate rather than a reason for abstraction.
- `ruby-service-objects` now defines its boundary against PORO, dependency injection, and API design.
- `ruby-object-composition` now contains an explicit pattern-selection guardrail.
- `rails-architecture` now delegates detailed decisions to the focused Rails skills.

### 4. Collection skills needed clearer separation

`ruby-collections` and `ruby-enumerables` overlapped.

**Fix:** their boundary is now explicit:

- `ruby-collections` → representation, data structure, mutation, indexing, algorithms, complexity.
- `ruby-enumerables` → traversal, transformation, pipeline semantics, allocation.

### 5. External integration skill had an incomplete dependency-inspection section

`ruby-gems-io-services` contained a dangling "inspect" heading before the actual dependency procedure.

**Fix:** completed the inspection guidance and clarified boundaries with service-object, dependency-injection, and API-design skills.

### 6. Ruby API skill contained a TypeScript-first example

The repository is a Ruby/Rails skill system, so the primary API example should communicate Ruby contracts directly.

**Fix:** added a Ruby contract example and explicitly separated typed consumer schemas from Ruby application API design.

## Agent Skills implementation

The external Agent Skills methodology is now implemented at the repository level rather than copied wholesale into every individual skill.

### Repository contract

`AGENTS.md` defines:

- discovery
- context management
- ambiguity handling
- pattern-selection precedence
- incremental implementation
- test discipline
- review dimensions
- simplification
- evidence-based verification
- benchmark integrity

### Meta skill

`skills/agent-workflow/SKILL.md` is registered in `skill-manifest.yml` and is the repository-local entry point for combining the individual Ruby/Rails skills.

### Skill precedence

```text
explicit task requirements
        ↓
repository architecture/conventions
        ↓
runtime/framework constraints
        ↓
focused domain skill
        ↓
design-pattern guidance
        ↓
generic style preference
```

This prevents generic Agent Skills guidance from overriding repository-specific Ruby/Rails conventions.

## Quality outcome

The goal was not to make every skill longer. The review found that most skills already had the necessary engineering discipline. The changes therefore focus on:

1. reducing overlap;
2. making skill selection more precise;
3. preventing pattern overuse;
4. establishing one agent execution contract;
5. keeping verification evidence-based.

## Remaining verification

The branch should still be validated through the repository's own `bin/validate` and CI workflow. This environment cannot clone the repository or execute its local files because outbound GitHub DNS/network access is unavailable, so no local validator result is claimed here.
