# Agent-Routing Benchmarks

This directory holds the runnable task fixtures for the Empirical Agent-Routing
Evaluation Protocol (EARP), defined in
[`docs/AGENT_ROUTING_EVAL_PROTOCOL.md`](../../docs/AGENT_ROUTING_EVAL_PROTOCOL.md).

## What lives here

Each task is a self-contained directory:

```
T<N>-<slug>/
  prompt.md          # the task prompt given to the agent (no security telegraphing)
  fixture/           # a small, runnable codebase the agent modifies
  expected.yaml      # the expected skill invocation set (ground truth for routing)
  review-rubric.md   # the human reviewer rubric for outcome quality scoring
```

Fixtures are **versioned**. Once a fixture is committed and a baseline has been
run against it, the fixture is not silently modified. Changes require a new task
ID (`T6-v2-...`) so historical scores remain comparable.

## Status

| Task | Status | Notes |
|------|--------|-------|
| T1-cms-model | pending | Rails model + Postgres partial index |
| T2-api-endpoint | pending | Rails JSON API + Pundit + request spec |
| T3-controller-refactor | pending | Fat controller to service object |
| T4-react-form | pending | React form with async validation + a11y |
| T5-tanstack-query | pending | Paginated data fetching with TanStack Query |
| T6-cms-rich-text | **shipped** | CMS rich-text XSS gap; first fixture |
| T7-e2e-login | pending | Playwright E2E for login (blocks on `react-e2e-testing`) |
| T8-vite-splitting | pending | Vite code-splitting + bundle budget (blocks on `react-build-tooling`) |
| T9-nextjs-server-action | pending | Next.js server action + revalidation (blocks on `react-frameworks`) |
| T10-full-stack-mutation | pending | Rails + React optimistic mutation (blocks on `rails-react-contract`) |

## Harness

The harness scripts (`run-agent.sh`, `collect-output.sh`, `score.sh`) are
pending. The first baseline run blocks on the harness and on the release cut
(see [`docs/RELEASE_CUT_CHECKLIST.md`](../../docs/RELEASE_CUT_CHECKLIST.md)).

## Running a task manually

Before the harness lands, a task can be run manually:

1. Copy `T<N>-<slug>/fixture/` to a fresh working directory.
2. Make the repo's `AGENTS.md` and `skills/` directory available to the agent.
3. Feed the agent the contents of `T<N>-<slug>/prompt.md`.
4. Capture the agent's transcript and the `git diff` it produces.
5. Score the diff against `expected.yaml` (routing) and `review-rubric.md`
   (outcome quality).

Manual runs are not reproducible enough for the official baseline but are
useful for fixture development.
