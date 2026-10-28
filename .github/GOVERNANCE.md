# Platform Governance

This repository runs on the Autonomous Engineering Platform: deterministic
GitHub Actions enforce correctness, security, and deployment policy, while
AI agents handle reasoning-heavy work (triage, investigation, review,
bounded repair) inside hard capability bounds. AI output is never treated
as proof that a change is safe - only CI is authoritative.

Read this file before changing any workflow. Read `.github/AGENT_PLATFORM.md`
before touching any agent workflow.

## 1. Responsibilities

| Layer | Owner | Examples |
| ----- | ----- | -------- |
| Deterministic gates | GitHub Actions (`ci.yml`, `security.yml`, `codeql.yml`) | Tests, lint, validation suites, secret scanning, dependency review, CodeQL |
| Agentic layer | `.github/workflows/agent-*.md` + `agent-*.lock.yml` | Issue triage, CI failure investigation, PR review comments, bounded repair |
| Policy | `CODEOWNERS`, branch protection, environments | Required checks, human approval, merge rules |
| Release | `release.yml` (existing, untouched by this batch) | Tagged release artifacts |

## 2. Branch protection (configure in repo settings)

Branch protection cannot be expressed in-repo; the platform documents the
required configuration here. Apply it to `main` (and, while open, to
`v3-cross-pack-integration`):

- Require a pull request before merging; dismiss stale approvals on new pushes.
- Require review from a **code owner** for changes under `/.github/` - this is
  what guarantees an AI reviewer can never waive platform changes (the
  AI agents post comments only; they cannot approve).
- Required status checks (require branches to be up to date):
  - `ci-summary` (from `ci.yml`)
  - `secrets-scan`, `permissions-audit` (from `security.yml`)
  - `analyze (ruby)` (from `codeql.yml`)
- Require linear history; forbid force pushes and deletions.
- Do NOT require the agentic workflows as status checks: agents are
  advisory, and their absence must never block a merge.

The required-check names above are the workflow-level names as GitHub
renders them; after the first CI run on this branch, confirm the exact
check-run names under **Settings > Branches > Add rule > status checks**
and adjust if GitHub appends matrix qualifiers.

## 3. Token permission policy

- Every workflow declares a top-level `permissions:` block (enforced
  deterministically by the `permissions-audit` job in `security.yml`).
- The default `GITHUB_TOKEN` permission set for the repository should be
  **read-only** (Settings > Actions > General > Workflow permissions).
- `contents: write` is reserved for `release.yml`; the permissions-audit
  job hard-codes that exception and fails on any other workflow.
- Agentic workflows request the minimum they need (`issues: write` for
  triage, `pull-requests: write` for review comments) and never receive
  deployment or registry credentials.

## 4. Third-party action pinning

Every third-party action is pinned to a full commit SHA with the release
tag in a trailing comment, e.g.:

    uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1

Dependabot keeps the pinned actions current (grouped weekly PRs). When a
PR bumps an action, review the diff between the old and new commit SHAs
on github.com before approving.

## 5. Environments (Batch 4 - documented now, wired later)

- `staging`: auto-deployment target for the default branch after CI;
  no manual approval; smoke tests run as deployment verification.
- `production`: requires a human reviewer (environment protection rule),
  restricts deployment to protected tags/branches, holds registry
  credentials (RubyGems / npm) as environment-scoped secrets.
- Deployment workflows are **not part of this batch**; this section pins
  the policy so the future Batch 4 workflows inherit it unchanged.

## 6. What agents may never do

Enforced by a combination of workflow permissions, deterministic diff
guards, and CODEOWNERS. An AI agent must never:

1. Modify its own CI security controls (`.github/workflows/security.yml`,
   `codeql.yml`, the `permissions-audit` job, or any `permissions:` block).
2. Approve a pull request (agents post review comments only; code-owner
   approval is human-only by branch protection).
3. Bypass or waive a failed check (agents may re-run CI after a repair,
   but the checks themselves decide).
4. Access production credentials or registry tokens (agents receive
   `GITHUB_TOKEN` and their own model API key, nothing else).
5. Merge, close, or tag anything (no such permissions are granted).

## 7. Fail-safe behaviour

Every agentic workflow begins with a capability guard: if the model API
key it needs is not configured (or the GitHub Agentic Workflows preview
is not enabled), the workflow posts a notice and exits 0. CI never
depends on an agent being available; agents are additive.

## 8. Required checks quick reference

| Check | Source | Purpose |
| ----- | ------ | ------- |
| `ci-summary` | `ci.yml` | All matrix + full-validation jobs passed |
| `secrets-scan` | `security.yml` | No leaked credentials |
| `dependency-review` | `security.yml` | No vulnerable/malicious dependency deltas |
| `permissions-audit` | `security.yml` | Least-privilege token policy holds |
| `analyze (ruby)` | `codeql.yml` | No new CodeQL alerts |
