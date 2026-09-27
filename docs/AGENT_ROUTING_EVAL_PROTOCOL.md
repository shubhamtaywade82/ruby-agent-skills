# Empirical Agent-Routing Evaluation Protocol (EARP)

## Purpose

The repository's existing validators answer a **structural** question:

> Are the skill files well-formed, non-overlapping, and internally consistent?

This protocol answers a different, **behavioral** question:

> When a real coding agent (Claude Code, Codex, Copilot CLI, etc.) is given a
> realistic full-stack task inside a Ruby + Rails + React + TypeScript
> repository, does it actually select the right skills, follow them, and
> produce work that conforms to them?

A structural pass is necessary but not sufficient. A skill pack can validate
cleanly and still fail to route correctly in practice — because the trigger
phrases are too vague, the routing matrix has gaps, or the agent's
context-loading order causes a relevant skill to be missed.

EARP is the empirical layer that closes that gap. It produces a per-agent,
per-task measurement of routing accuracy and outcome quality, against a fixed
suite of realistic tasks, before and after each Tier 1 skill ships.

## Scope

**In scope for v1:**

- Routing accuracy — did the agent invoke the skills a human reviewer would expect?
- Skill adherence — does the produced code conform to the skills' rules?
- Outcome correctness — does the work pass the repo's own tests?

**Out of scope for v1:**

- Latency and token cost benchmarks.
- Cross-agent comparative ranking.
- Long-horizon multi-session tasks.

v1 is deliberately minimal: a 10-task suite against one or two agents, with a
structured rubric. The point is to establish a baseline **before** Tier 1 skills
ship, then re-measure after each Tier 1 addition.

## Task suite

The v1 suite is 10 tasks, each a self-contained prompt plus a small repository
fixture. Tasks span the four routing dimensions the pack claims to cover:

| # | Task | Primary skills expected | Layer |
|---|------|------------------------|-------|
| T1 | Add a Rails model with a validated unique email field and a Postgres partial index | `ruby-core`, `rails-active-record`, `rails-database-engineering` | Ruby/Rails |
| T2 | Add a JSON API endpoint with strong params, Pundit authorization, and a request spec | `rails-action-controller`, `rails-security`, `rails-test-engineering` | Rails |
| T3 | Refactor a fat controller into a service object with a unit spec | `rails-architecture`, `ruby-core`, `rails-test-engineering` | Rails |
| T4 | Add a React form with async server validation and a11y error messaging | `react-component-engineering`, `react-state-effects`, `react-accessibility-performance` | React |
| T5 | Fetch paginated data from a Rails API with TanStack Query; handle loading/error/empty | `react-data-fetching`, `react-state-effects`, `typescript-runtime-contracts` | React |
| T6 | Render server-provided HTML safely (no XSS) from a CMS field | `react-frontend-security` *(does not exist yet)* | React security gap |
| T7 | Add a Playwright E2E test for a login flow | `react-e2e-testing` *(does not exist yet)* | React testing gap |
| T8 | Add a Vite code-splitting config with bundle budget enforcement | `react-build-tooling` *(does not exist yet)* | React build gap |
| T9 | Add a Next.js server action that mutates data and revalidates a query | `react-frameworks` *(does not exist yet)* | Framework gap |
| T10 | Full-stack: Rails endpoint + React mutation with optimistic update, auth propagation, idempotency | `rails-react-contract` *(does not exist yet)*, `react-state-effects`, `rails-security` | Full-stack seam |

T1-T5 exercise existing skills and should produce high routing accuracy today.
T6-T10 are designed to expose gaps: an agent will either synthesize rules ad
hoc or produce work that violates the (currently non-existent) skill's expected
contract. This gives a **before/after measurement** for each Tier 1 skill.

## Per-task expected routing

Each task defines an **expected skill invocation set** in
`benchmarks/agent-routing/T<N>/expected.yaml`. The set is:

- `required` — skills a competent human reviewer would expect to see cited or applied.
- `bonus` — skills that could plausibly apply but aren't required.
- `wrong` — skills that are invoked but don't apply (false positives).

Expected sets are committed to the repo and reviewed by a human before any agent
runs. This prevents moving the goalposts.

## Metrics

Three metrics per task:

1. **Routing precision** = (correctly invoked skills) / (total skills invoked).
   Penalizes the agent for grabbing skills that don't apply.

2. **Routing recall** = (correctly invoked skills) / (expected skill set).
   Penalizes the agent for missing skills that should apply.

3. **Outcome quality** = rubric score on four axes (0-3 each, max 12):
   - **Correctness** — does the code do what the task asked?
   - **Skill adherence** — does the code conform to the skills the agent claimed to apply?
   - **Test coverage** — are the tests the skills require present and passing?
   - **Security** — are the security-relevant rules (XSS, authz, secrets, CSRF) honored?

v1 targets:

- Routing F1 >= 0.70 on existing-skill tasks (T1-T5).
- Outcome quality >= 8/12 average on T1-T5.

T6-T10 have no v1 target — they are baseline-only, re-measured after the
corresponding skill ships.

## Harness

The harness is intentionally low-tech: a shell script, not a framework.

```
benchmarks/agent-routing/
  README.md
  T1-cms-model/          # placeholder until fixture is written
    prompt.md
    fixture/
    expected.yaml
    review-rubric.md
  T6-cms-rich-text/      # first shipped fixture (this PR)
    prompt.md
    fixture/
    expected.yaml
    review-rubric.md
  harness/
    run-agent.sh         # invokes the agent CLI with the prompt + fixture
    collect-output.sh    # extracts agent transcript + produced code
    score.sh             # applies rubric + routing scoring
  results/
    <agent>-<date>-T<N>/
      transcript.json
      diff.patch
      scores.yaml
  reports/
    baseline-<date>.md
```

`run-agent.sh` is agent-agnostic: it takes an agent name and a task ID, copies
the fixture into a fresh working directory, runs the agent with the repo's
`AGENTS.md` and skill directory available, and captures output. One wrapper per
agent (Claude Code, Codex, Copilot CLI). Adding a new agent is a 30-line shell
script.

## Reproducibility controls

Three controls keep runs comparable:

1. **Pinned agent version.** Each report records the agent's version string.
   Re-running with a different version produces a new report, not an overwrite.
2. **Pinned fixture SHA.** Each task fixture is a git submodule pinned to a
   specific commit.
3. **No agent memory.** Each run starts from a clean agent state — no prior
   session, no carryover. This is non-negotiable; otherwise routing decisions
   from a prior task leak into the next.

A run that does not record all three is invalid and is discarded.

## Reporting

Each report answers four questions, in order:

1. **What was measured?** (agent version, task set, date, harness version)
2. **What was the routing accuracy?** (precision/recall/F1 per task + aggregate)
3. **What was the outcome quality?** (rubric breakdown per task + aggregate)
4. **What changed since the last report?** (delta vs. prior baseline, attributed
   to either a new skill or an agent version bump)

Reports are committed under `benchmarks/agent-routing/reports/`. The v1 baseline
is run against the current release tag (see `docs/RELEASE_CUT_CHECKLIST.md`)
with no Tier 1 skills. Each Tier 1 skill addition triggers a re-run of the
relevant task(s) only; full re-runs happen at each release cut.

## Acceptance gate for "1.0 complete"

Before tagging 1.0, the protocol must show:

- Routing F1 >= 0.75 across all 10 tasks (including previously-gap tasks, now
  served by shipped Tier 1 skills).
- Outcome quality >= 9/12 average across all 10 tasks.
- No task has a security rubric score of 0.
- At least two external agents evaluated.

This is the empirical claim that complements the structural claim the existing
validators already prove.

## Relationship to existing routing infrastructure

The repository already has substantial routing infrastructure under `router/`
and `bin/routing-*`. EARP is **not** a replacement for that infrastructure.
It is the **external validation** layer that consumes the same routing contract
but measures it against real agent behavior rather than against the repo's own
self-consistency checks.

Concretely:

- `router/ROUTING.md` and `router/ROUTING_CASES.yml` define the intended routing.
- `scripts/audit_skill_routing.rb` checks the routing contract is internally consistent.
- `bin/routing-eval` and `bin/routing-campaign` run routing against a model
  adapter for synthetic prompt sets.
- **EARP** runs routing against a real coding agent on a real codebase fixture,
  and measures both routing accuracy **and** outcome quality.

The existing routing infrastructure answers "is the routing contract coherent?"
EARP answers "does the routing contract actually guide agents correctly on
realistic tasks?" Both are needed.

## Status

- v1 protocol: defined (this document).
- T6 fixture: shipped (this PR).
- T1-T5, T7-T10 fixtures: pending. Each Tier 1 skill PR ships its own
  corresponding fixture.
- Harness scripts: pending. The first baseline run blocks on the harness.
- v1 baseline report: pending. Blocks on the harness and the release cut.
