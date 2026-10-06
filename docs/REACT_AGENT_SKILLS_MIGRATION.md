# React + TypeScript Frontend Skill Migration

The frontend engineering subsystem is being split into shubhamtaywade82/react-agent-skills.

## Deprecation boundary

The following Ruby-pack skills are deprecated for new standalone React/TypeScript work:

| Ruby pack skill | Replacement |
| --- | --- |
| typescript-core-engineering | react-agent-skills / typescript-core-engineering |
| typescript-type-design | react-agent-skills / typescript-type-design |
| typescript-runtime-contracts | react-agent-skills / typescript-runtime-contracts |
| react-component-engineering | react-agent-skills / react-component-engineering |
| react-state-effects | react-agent-skills / react-hooks-effects + react-state-management |
| react-data-fetching | react-agent-skills / react-data-fetching |
| react-testing-engineering | react-agent-skills / react-testing-engineering + frontend-e2e |
| react-accessibility-performance | react-agent-skills / react-accessibility + react-performance |
| react-architecture | react-agent-skills / react-architecture |

## Retention policy

These source directories and source evaluations remain in the Ruby pack during the deprecation window. They are retained to avoid breaking existing installations and to preserve auditability.

New frontend implementations should load the dedicated React pack. Rails, Ruby, PostgreSQL, security, API, and cross-boundary backend concerns remain owned by this repository.

rails-react-integration is retained as a cross-boundary integration skill. It is not removed by this migration because it covers the Rails + React integration surface rather than replacing either pack's standalone frontend/backend ownership. It now belongs to the `rails` family. Its patterns live in `patterns/rails/`, its evaluation in `evals/rails-react-integration/`, and its "Composing with react-agent-skills" section assigns each side of a full-stack change. No retained skill, pattern, evaluation, or routing case depends on a deprecated skill; `test/react_agent_skills_deprecation_test.rb` enforces this.

## Verification gate

Deletion is not part of this change. Removal should occur only after:
1. the React pack is merged and CI-verified;
2. the source-to-destination pattern/evaluation inventory is verified;
3. full-stack composition guidance is available;
4. a release note communicates the replacement paths;
5. downstream installation impact is reviewed.

## Audited source

The original migration inventory used ruby-agent-skills commit 3ce8a2bbfef174d83c161ff7399d47742289c4e6. The current Ruby pack may contain newer backend or integration skills; those are outside this frontend deprecation boundary.

## Gate status

| Gate | Status | Evidence |
| --- | --- | --- |
| 1. React pack merged and CI-verified | Repository published; CI result to be confirmed at removal time | react-agent-skills has a `validate.yml` workflow and ships every replacement skill named above |
| 2. Pattern/evaluation inventory verified | Open | Verify each removed pattern and evaluation has a react-agent-skills counterpart before deletion |
| 3. Full-stack composition guidance | Done | `skills/rails-react-integration/SKILL.md` "Composing with react-agent-skills"; `router/ROUTING.md` cross-stack table |
| 4. Release note with replacement paths | Done for v1.2.0 | `docs/releases/v1.2.0.md`, included in the generated GitHub release notes and checked by `test/release_archive_system_test.rb` |
| 5. Downstream installation impact | Done | `relocated_skills` in `skill-manifest.yml`; `bin/install` removes relocated skills from existing installations and prints the destination (`test/skill_pack_installer_system_test.rb`) |

## Removal checklist (a release after v1.2.0)

1. Confirm gates 1 and 2 against the current react-agent-skills `main`.
2. Delete the nine `skills/<name>/` directories, `patterns/react-typescript/`, and `evals/react-typescript/`.
3. Remove the nine entries from `skills:`, `deprecations:`, the `react-typescript` pattern family, and their `evaluations:` entries in `skill-manifest.yml`.
4. Add each skill to `relocated_skills:` with the same replacement it had under `deprecations:`.
5. Replace the deprecated-skill table in `router/ROUTING.md` with a pointer to react-agent-skills.
6. Update the system tests that enumerate the deprecated skills, patterns, and evaluations, plus the README inventory counts.
7. Write `docs/releases/<version>.md` announcing the removal, and verify with `bin/validate` and an install-over-previous-release run.
