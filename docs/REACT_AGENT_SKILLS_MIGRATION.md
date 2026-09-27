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

rails-react-integration is retained as a cross-boundary integration skill. It is not removed by this migration because it covers the Rails + React integration surface rather than replacing either pack's standalone frontend/backend ownership.

## Verification gate

Deletion is not part of this change. Removal should occur only after:
1. the React pack is merged and CI-verified;
2. the source-to-destination pattern/evaluation inventory is verified;
3. full-stack composition guidance is available;
4. a release note communicates the replacement paths;
5. downstream installation impact is reviewed.

## Audited source

The original migration inventory used ruby-agent-skills commit 3ce8a2bbfef174d83c161ff7399d47742289c4e6. The current Ruby pack may contain newer backend or integration skills; those are outside this frontend deprecation boundary.
