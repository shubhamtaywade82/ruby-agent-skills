---
name: autonomous-engineering-platform
description: "Design and govern an autonomous software engineering platform on GitHub Actions: AI agents propose changes; deterministic workflows enforce correctness, security, and deployment policy. Production never depends on an AI agent deciding its own work is safe."
family: rails
---

# Autonomous Engineering Platform

## Problem
An autonomous software engineering platform on GitHub Actions has two surfaces that look similar but have different safety properties: (1) AI coding agents that reason, propose changes, and open PRs; (2) deterministic workflows that enforce tests, security gates, merge policy, and deployment. The failure mode is to conflate them — letting an agent's "looks good" verdict substitute for the deterministic gate, or letting an agent modify its own CI security controls. Production must not depend on an AI agent deciding whether its own work is safe.

## Use when
- building a reusable CI/CD platform for a portfolio of Ruby/Rails/Node/TypeScript repositories
- adding AI agent automation (issue triage, CI failure investigation, PR review, autonomous coding) on top of an existing CI/CD pipeline
- auditing an existing autonomous platform for governance gaps (missing CODEOWNERS, no `permissions:` blocks, long-lived cloud credentials, unpinned actions, unbounded agent retries)
- onboarding an engineer or agent to the platform's safety model

## Do not use when
- a single repository's CI does not yet exist — start with a basic GitHub Actions workflow and adopt this pattern when the second repository needs the same policy
- the team has not yet committed to AI agent automation — the deterministic half of the platform (CODEOWNERS, dependabot, security workflow, least-privilege permissions) is valuable on its own and can ship first; the agentic half can be added when the team is ready
- the platform is being built for a non-GitHub Actions environment — the principles transfer but the specific mechanisms (reusable workflows, environment protection rules, OIDC, artifact attestations) are GitHub-specific

## Repository inspection
Before applying this pattern:

1. List `.github/workflows/*.yml` and check each for an explicit `permissions:` block (default permissive `permissions: write-all` is a security smell).
2. Check for `.github/CODEOWNERS` and inspect which paths have owner rules.
3. Check for `.github/dependabot.yml` and inspect update cadence for `github-actions`, `bundler`, `ruby-version`, `npm`, and `docker` ecosystems.
4. List external actions used and verify each is pinned to a full commit SHA (not a floating tag like `@v7` — tags are mutable).
5. Check for `pull_request_target` trigger usage (high-risk; runs in the base branch's context with the default token).
6. Inspect environment protection rules for `staging` and `production` (required reviewers, deployment branches, wait timer).
7. Inspect secret usage — long-lived cloud credentials vs OIDC trust conditions.
8. Inspect artifact retention policy and provenance attestations.
9. List agent-driven workflows (`.github/workflows/agent-*.md` + generated `.lock.yml`) and check the agent's repair budget, tool permissions, and isolation.
10. Inspect branch protection on `main`: required checks, required code-owner review, dismiss-stale-reviews, require linear history.

## Platform architecture

```text
Work intake (GitHub Issues, PR comments, schedules, security alerts, workflow failures)
        │
        ▼
AI planning and task orchestration (triage, inspect repository, plan, identify required changes and tests)
        │
        ▼
Isolated implementation (coding agent on a feature branch → tests → pull request)
        │
        ▼
Quality and security gates (deterministic, never agent-judged)
   ├─ Quality:  tests, lint, type checks, coverage
   ├─ Security: SAST, dependencies, secrets, permissions
   ├─ AI review: correctness, edge cases, test gaps (advisory, never authoritative)
   ├─ Policy:   required checks, branch rules, ownership
   ├─ Failure:  diagnose → bounded repair → rerun checks
   └─ Success: enforce merge policy → build immutable release
        │
        ▼
Deployment and feedback (staging → smoke tests → protected production → monitoring → rollback or incident)
```

The critical distinction: **AI agents handle reasoning and code changes; deterministic workflows enforce correctness, security, and deployment policy.** An agent may propose, never approve. An agent may not modify its own CI security controls, bypass failed checks, access production credentials, or approve its own PR.

## Implementation procedure (the 5-batch delivery plan)

Deliver the platform in five batches, with validation at each stage. Do not skip ahead; each batch is the foundation for the next.

### Batch 1 — Foundation and governance

1. Add `.github/CODEOWNERS` with explicit ownership rules for `.github/`, `skills/`, `patterns/`, `evals/`, `bin/`, `scripts/`, and `test/`.
2. Add `.github/dependabot.yml` with update ecosystems for `github-actions` (weekly), `bundler` (weekly), and `ruby-version` (when the file changes).
3. Add an explicit `permissions:` block to every workflow. Default to `contents: read`; grant `contents: write` only to jobs that publish releases or push tags.
4. Pin every external action to a full commit SHA, not a floating tag. (GitHub's security hardening guide.)
5. Add `.github/workflows/security.yml` running Brakeman, bundler-audit, CodeQL, and secret scanning on every PR and push.
6. Add branch protection on `main`: required checks (`Validate skills`, `Security and supply chain`), required code-owner review, dismiss-stale-reviews, require linear history.
7. Add `scripts/audit_github_governance.rb` and wire it into `bin/validate` so the audit runs locally and in CI.

### Batch 2 — Production-grade CI

1. Extract the shared Ruby/Rails CI shape into `.github/workflows/reusable-ruby-ci.yml` with `workflow_call`.
2. Extract the shared Node/TypeScript CI shape into `.github/workflows/reusable-node-ci.yml`.
3. Move database-backed integration tests to a service-container job (Postgres, Redis) with explicit version pins.
4. Add quality gates: RuboCop, RSpec, Minitest, type checks (Sorbet/RBS where applicable), coverage threshold, build verification.
5. Add cache keys for `bundler`, `npm`, and `actions` so the same commit produces the same artifacts.
6. Test the workflows themselves — negative security tests, permission drift, action pin drift.

### Batch 3 — Agentic engineering

1. Add `agent-issue-triage` workflow: GitHub Issue triggers → agent categorizes, labels, identifies priority and missing information → posts a structured comment.
2. Add `agent-ci-investigator` workflow: CI failure triggers → agent reads sanitized logs (no secrets) → proposes a bounded fix as a comment. **Propose-only, never apply**: the investigator posts diagnosis + proposed patch; a human applies it through the normal PR flow with CODEOWNERS review. This keeps the least-privilege rule intact (`contents: write` only on `release.yml`, enforced by the governance audit).
3. Add `agent-pr-reviewer` workflow: PR opened → agent reviews for correctness, edge cases, test gaps → posts advisory comments. **Never authoritative.** Required reviews come from CODEOWNERS, not the agent. Diffs touching `.github/` or `scripts/` are flagged for mandatory human review of the CI security surface.
4. Bound every agent: cap retries (3 default, `AGENT_MAX_ATTEMPTS`), tool permissions (read-only by default), runtime (`timeout-minutes: 15` in the workflow, `AGENT_TIMEOUT` seconds in the dispatcher), cost (per-job spend limit). Stop and escalate when limits are reached.
5. Run all agents in isolated, ephemeral execution environments (separate GitHub-hosted runners). Never let agent-generated code share a runner with production deployment jobs.
6. Audit agent actions: `scripts/agent_dispatch.rb` appends one JSON line per attempt to the audit log (role, exit code, duration, output size) so every prompt and result is reviewable. The dispatcher owns the file handle; the agent cannot rewrite its own history.

**Implementation status (Iteration 197):** all three workflows ship as gated conventional workflows (`.github/workflows/agent-issue-triage.yml`, `agent-ci-investigator.yml`, `agent-pr-reviewer.yml`) that call the bounded dispatcher `scripts/agent_dispatch.rb`. Each is gated on an explicit repository variable (`vars.AGENT_*_ENABLED`) so untrusted events never trigger an unconditional agent run; each declares `timeout-minutes: 15`; the governance audit rejects an agent workflow that lacks a timeout, lacks a gate, or contains an approval command. The dispatcher fails safe when `AGENT_COMMAND` is unset (exit 0 with a skip message), sanitizes secret-shaped strings from every payload before it reaches a prompt, bounds retries with backoff, escalates on exhaustion, and writes the append-only audit trail. `test/agent_dispatch_system_test.rb` and the extended `test/github_governance_system_test.rb` pin all of this in `bin/validate`.

### Batch 4 — Release and deployment

1. Version: tag-driven (`vX.Y.Z`); the tag is the only version marker.
2. Build once: record the source commit, build metadata, and source tree hash in `RELEASE.json`. Promote the same artifact through environments; never rebuild for production.
3. Generate release notes from `CHANGELOG.md` and per-version notes (`docs/releases/vX.Y.Z.md`).
4. Publish: GitHub Release with the artifact, `SHA256SUMS`, and Sigstore/cosign attestations when supported.
5. Staging deployment: automatic after the Release workflow passes. Smoke tests + health checks before production promotion.
6. Production deployment: environment protection rules (required reviewers, deployment branches restricted to release tags, wait timer).
7. OIDC for cloud authentication: prefer short-lived, narrowly-scoped trust conditions over long-lived cloud credentials stored as secrets.

### Batch 5 — Autonomous operations

1. Scheduled maintenance: weekly dependency audit, monthly release-health check, quarterly incident-review follow-up.
2. Automated dependency updates: Dependabot PRs land in a queue; an agent triages them; a human approves.
3. Failed-deployment recovery: deployment health drops below threshold → automatic rollback → incident issue created → verified findings fed into the engineering backlog.
4. Continuous improvement: monthly platform retrospective. What failed? What did agents get wrong? What policies need tightening?

## Capability / autonomy matrix

| Capability | What the automation does | Autonomy |
|---|---|---|
| Issue triage | Categorize bugs, label issues, identify priority and missing information | High |
| Task planning | Analyze code, map affected files, propose an implementation plan | High |
| Autonomous coding | Implement an issue on an isolated branch and open a PR | Bounded |
| Test generation | Add unit, integration, and regression tests | High, subject to CI |
| CI failure recovery | Analyze logs, propose or apply a bounded fix, rerun checks | Bounded |
| Code review | Detect defects, security issues, missing tests, risky changes | High, with independent gates |
| Dependency maintenance | Detect vulnerable or outdated dependencies, create update PRs | High |
| Release engineering | Version, build, publish, generate release notes | Policy-controlled |
| Staging deployment | Deploy verified artifacts, execute smoke tests | High |
| Production deployment | Deploy approved, verified artifacts | Protected |
| Post-deployment response | Detect failures, initiate rollback, create incident records | Automated under defined policy |

"Bounded" means the agent acts within a strict budget (retries, runtime, tool permissions, scope) and escalates when limits are reached. "Protected" means a human must approve. "Policy-controlled" means the workflow enforces the policy; the agent cannot override it.

## Security rules for autonomous agents

These rules are non-negotiable. A successful test suite does not prove an agent's changes are safe.

| Rule | Required behavior |
|---|---|
| Least privilege | Start with `permissions: contents: read`. Grant `contents: write` only to jobs that publish releases or push tags. Never use `pull_request_target` for untrusted PRs. |
| Untrusted pull requests | Never expose production credentials or privileged deployment tokens to untrusted contributions. Fork-PR builds get a read-only token by default. |
| Isolated execution | Use isolated, preferably ephemeral execution environments for untrusted or agent-generated code. Never share a runner with production deployment jobs. |
| Trusted dependencies | Pin external actions to full commit SHAs. Keep dependencies updated via Dependabot. Audit new action introductions in CODEOWNERS. |
| Cloud authentication | Prefer OIDC with narrowly scoped trust conditions over long-lived cloud credentials stored as secrets. Rotate any long-lived secrets quarterly. |
| Merge protection | Required authoritative CI checks, branch rules, code-owner review. Agent review is advisory, never authoritative. |
| Artifact integrity | Use build provenance and artifact attestations (Sigstore/cosign) when supported by the release and deployment environment. |
| Bounded autonomy | Cap agent retries (3), tool permissions (read-only by default), runtime (15 minutes), cost (per-job spend limit). Stop and escalate when limits are reached. |
| Audit trail | Every prompt, every tool call, every diff the agent produces is logged and reviewable. Logs are immutable; agent may not modify its own audit trail. |
| Fail-safe | If an AI service is unavailable, exceeds its budget, returns invalid output, or repeatedly fails to fix an issue, the workflow fails closed. It does not skip the gate. |

## Repository structure

```text
.github/
├── workflows/
│   ├── ci.yml                          # consumer workflow; calls reusable-ruby-ci or reusable-node-ci
│   ├── security.yml                    # Brakeman, bundler-audit, CodeQL, secret scanning
│   ├── reusable-ruby-ci.yml            # shared Ruby/Rails CI shape (workflow_call)
│   ├── reusable-node-ci.yml            # shared Node/TypeScript CI shape (workflow_call)
│   ├── release.yml                     # tag-triggered release
│   ├── deploy-staging.yml              # post-release staging deployment
│   ├── deploy-production.yml           # protected production deployment
│   ├── agent-issue-triage.md           # Agentic Workflow instruction source
│   ├── agent-issue-triage.lock.yml     # compiled GitHub Actions workflow (reviewed)
│   ├── agent-ci-investigator.md
│   ├── agent-ci-investigator.lock.yml
│   ├── agent-pr-reviewer.md
│   └── agent-pr-reviewer.lock.yml
├── CODEOWNERS
└── dependabot.yml
```

The `.md` files define the agentic workflow instructions; the generated `.lock.yml` files contain the compiled GitHub Actions workflows. Generated files should be reviewed and kept synchronized with their source definitions. The audit script (`scripts/audit_github_governance.rb`) enforces that the lock files match the source.

## Current limitation: GitHub Agentic Workflows are in public preview

GitHub Agentic Workflows can run natural-language instructions through GitHub Actions, suitable for issue triage, CI failure investigation, documentation updates, and test-coverage improvements. They are in public preview. Use them for AI-assisted automation, but **keep core release, test, and deployment guarantees in conventional GitHub Actions workflows** until the relevant capabilities meet production requirements. The deterministic half of the platform (Batch 1, Batch 2, Batch 4) does not depend on Agentic Workflows.

## Failure modes

- Letting an AI agent modify its own CI security controls, approve its own PR, bypass failed checks, or access production credentials. Workflow changes should pass their own independent review and policy gates.
- Pinning actions to floating tags (`@v7`) instead of full commit SHAs. Tags are mutable; a compromised maintainer account can move `@v7` to a malicious commit.
- Using `pull_request_target` to run workflows against untrusted PRs. It runs in the base branch's context with the default token. Use `pull_request` with `paths-ignore` for sensitive paths.
- Sharing a runner between agent-generated code and production deployment jobs. A compromised agent can read deployment credentials from the runner's filesystem or environment.
- Treating agent review as authoritative. Agent review is advisory; required reviews come from CODEOWNERS.
- Skipping Batch 1 (foundation) and going straight to Batch 3 (agentic). The agentic batch depends on the deterministic batch for safety.
- Bounded autonomy without an escalation path. If the agent hits its retry or budget cap, the workflow must fail closed AND surface a human-actionable issue. Silent failure is unacceptable.
- Monitoring and rollback without observable application health. GitHub Actions alone is not a substitute for application observability. The deployment workflow needs health-check endpoints, error-rate signals, and rollback criteria.
- Long-lived cloud credentials stored as secrets. Prefer OIDC. Rotate any long-lived secrets quarterly.

## Testing

The platform itself must be tested, not just the code it ships. Add tests for:

1. **Workflow schema validation**: every `.github/workflows/*.yml` parses and has the required `permissions:` block.
2. **Action pinning**: every external action is pinned to a full commit SHA. (Run `scripts/audit_github_governance.rb`.)
3. **CODEOWNERS coverage**: every protected path has an owner. (Run `scripts/audit_github_governance.rb`.)
4. **Dependabot coverage**: every ecosystem in the repository (github-actions, bundler, npm, ruby-version) has an update policy.
5. **Negative security tests**: a workflow that drops `permissions:` fails `audit_github_governance.rb`. A workflow that uses `pull_request_target` fails the audit.
6. **Agent boundary tests**: the agent's tool permissions, retry cap, runtime cap, and cost cap are enforced. An agent that exceeds any cap fails closed.
7. **Rollback drill**: a production deployment that fails the post-deploy health check triggers rollback within a documented SLO.
8. **Fail-safe drill**: an AI service that returns invalid output or is unavailable fails the workflow closed; no gate is skipped.

## Review checklist

- [ ] Every workflow has an explicit `permissions:` block (default `contents: read`)
- [ ] Every external action is pinned to a full commit SHA
- [ ] `.github/CODEOWNERS` exists and covers protected paths
- [ ] `.github/dependabot.yml` exists and covers `github-actions`, `bundler`, and `ruby-version` ecosystems
- [ ] `.github/workflows/security.yml` runs Brakeman, bundler-audit, CodeQL, and secret scanning
- [ ] Branch protection on `main`: required checks, code-owner review, dismiss-stale-reviews
- [ ] No `pull_request_target` for untrusted PRs
- [ ] Agent workflows are bounded (retries, runtime, tool permissions, cost)
- [ ] Agent actions are logged and the log is immutable
- [ ] Production deployment requires environment protection rules (reviewers, deployment branches, wait timer)
- [ ] Cloud authentication uses OIDC; no long-lived credentials
- [ ] `scripts/audit_github_governance.rb` runs locally and in CI
- [ ] `bin/validate` includes the governance audit and the system test
- [ ] Workflow changes pass their own independent review and policy gates (a workflow that modifies CI security controls cannot self-approve)

## Related skills
rails-release-engineering, rails-security-engineering, rails-incident-engineering, rails-observability, rails-production-runtime, agent-workflow, change-review, stack-minimality
