# Ruby Agent Skills

A repository of **agent-executable Ruby and Ruby on Rails engineering knowledge**.

The goal is not to store passive notes. The repository turns engineering material into a system an AI coding agent can use to **classify a task, inspect a repository, select skills and patterns, implement a bounded change, verify behavior, and report evidence**.

## Quick start

Install the verified skill pack from a release archive (offline; no git required):

    curl -LO https://github.com/shubhamtaywade82/ruby-agent-skills/releases/download/v1.1.0/ruby-agent-skills-v1.1.0.tar.gz
    tar xzf ruby-agent-skills-v1.1.0.tar.gz
    cd ruby-agent-skills-v1.1.0
    bash bin/install --agent claude

Or from a git checkout:

    git clone https://github.com/shubhamtaywade82/ruby-agent-skills
    cd ruby-agent-skills
    bash bin/install --agent claude

Then verify the installed pack:

    ruby bin/skill-pack-verify --root ~/.claude/skills
    ruby bin/skill-pack-doctor --root ~/.claude/skills

Every release publishes a `SHA256SUMS` checksum alongside the archive. See [Installation](#installation) for scopes, agent layouts, pinned refs, and verification workflows.

---

## Agent installation verification

After installing the pack, run `ruby bin/skill-pack-doctor --root <agent-skill-root>` to verify the installed metadata, skill inventory, embedded verifier, and content integrity before using the pack in a controlled agent environment.

## Runtime compatibility

The pack includes a deterministic runtime compatibility gate for version-bound skills/patterns: Version-bound pattern requirements are checked against the target repository's resolved runtime evidence before materialization.

    ruby bin/skill-pack-compatibility /path/to/rails-app \
      --pattern patterns/rails/active-job-continuation-contract \
      --json

Known incompatibilities fail immediately. Missing runtime evidence is reported as `unknown`; add `--strict` when unknown evidence must block use. The evaluation runner records the target runtime profile and applies the same gate to materialized version-bound patterns.

## Framework drift audit

The pack includes a bounded, evidence-backed framework drift registry for high-confidence Rails API/configuration removals and deprecations. `bin/validate` runs the detector against Ruby code fences in skills and patterns and reports concrete file/line findings; intentional historical examples require an explicit in-block suppression directive.

    ruby scripts/audit_framework_drift.rb

The current registry is intentionally limited to findings backed by the Rails 6.1 and 8.1 release notes. It is not a complete Rails deprecation database.
## Routing evidence integrity

`bin/routing-compare` recomputes routing metrics from the recorded run data before applying the remediation gate. A campaign whose recorded metrics have been altered or drifted from its runs is rejected rather than treated as benchmark evidence.

## Routing campaign analysis

After a public routing campaign completes, the campaign finalization path regenerates the canonical routing analysis automatically. The analyzer remains directly runnable for independent inspection:

    ruby bin/routing-analyze ./routing-campaign-output/campaign.json \
      --output ./routing-campaign-output/analysis.json

The analyzer recomputes completion and routing metrics from the recorded runs and rejects structurally inconsistent or incomplete campaigns rather than filling missing measurements.

## What this repository contains

The skill system is built from five connected layers:

```text
                         ┌──────────────────────┐
                         │       Task           │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ Runtime / Repository │
                         │      Inspection      │
                         └──────────┬───────────┘
                                    │
                                    ▼
                    ┌──────────────────────────────┐
                    │      Skill Router            │
                    │ skill-manifest + ROUTING.md  │
                    └──────────────┬───────────────┘
                                   │
                     ┌─────────────┴─────────────┐
                     ▼                           ▼
              ┌─────────────┐             ┌─────────────┐
              │   Skills    │             │  Patterns   │
              │   What/Why  │             │  How/When   │
              └──────┬──────┘             └──────┬──────┘
                     └─────────────┬─────────────┘
                                   ▼
                         ┌──────────────────────┐
                         │ Implementation +     │
                         │ Focused Verification │
                         └──────────┬───────────┘
                                    ▼
                         ┌──────────────────────┐
                         │ Evaluations / System │
                         │ Tests / CI Evidence  │
                         └──────────────────────┘
```

### Skill layout and progressive disclosure

An agent loads a whole `SKILL.md` when the skill activates, so `SKILL.md` holds only what is needed to act: purpose, activation, repository inspection, decision rules, critical invariants, the domain change contract, review checklist, failure modes, and verification. Deep framework knowledge lives in skill-local `references/*.md` files that the agent loads only when the change touches that boundary. The `## References` table in each `SKILL.md` says when to load each file and which patterns to consult.

```text
skills/rails-active-record/
├── SKILL.md                 # operating playbook, always loaded on activation
└── references/              # loaded on demand, one level deep
    ├── relations-and-queries.md
    ├── persistence-lifecycle-and-callbacks.md
    └── ...
```

`scripts/validate_skills.rb` enforces the budget from the Agent Skills specification: at most 500 lines and about 5,000 estimated tokens per `SKILL.md`, reference files at most 500 lines, directly under `references/`, never linking to another reference, and every reference linked from `SKILL.md`. The repository target of 350 lines / about 3,500 tokens is reported but not enforced. Patterns stay in the shared `patterns/` catalog; a skill names the pattern to consult rather than copying it.

### Current validated inventory

| Capability | Count |
|---|---:|
| Skills | **93** |
| Implementation patterns | **446** |
| Evaluation cases | **476** |
| Dedicated system/contract tests | **97** |