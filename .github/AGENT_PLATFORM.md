# Agent Platform

The agentic layer of the Autonomous Engineering Platform. Three agent
platforms are wired up, each with a defined role. Deterministic CI remains
the single source of truth for merge decisions; agents inform, propose,
and repair within hard bounds.

## 1. Platforms and roles

| Platform | Engine | Source format | Role in this repo | Needs |
| -------- | ------ | ------------- | ----------------- | ----- |
| GitHub Copilot cloud agent | GitHub-hosted (Agentic Workflows preview) | `agent-*.md` -> `gh aw compile` -> `agent-*.lock.yml` | Issue triage | Copilot licence on the org; no repo secret |
| Claude Code | `anthropics/claude-code-action` (SHA-pinned) | Conventional workflow | CI failure investigation + repair engine + PR review fallback | `ANTHROPIC_API_KEY` secret |
| Codex CLI | `openai/codex-action` (SHA-pinned) | Conventional workflow | PR review + repair engine | `OPENAI_API_KEY` secret |

## 2. Source files vs compiled workflows

The `agent-*.md` files are the **authoritative instructions** in the GitHub
Agentic Workflows preview format (YAML front-matter + natural-language
body). When the `gh aw` extension is installed, regenerate the compiled
workflows with:

    gh aw compile

The shipped `agent-*.lock.yml` files are hand-authored **conventional
implementations** of the same instructions (they run today with only
`GITHUB_TOKEN` plus an optional model key, with graceful degradation).
If you enable the Agentic Workflows preview, `gh aw compile` will replace
the lock files - review the diff, then keep the guard steps from this
platform's versions (secret guard, bounded budget, path guard).

## 3. Graceful degradation matrix

Every agent workflow starts with a deterministic capability guard:

| Condition | Behaviour |
| --------- | --------- |
| No model API key configured | Notice posted to the job log, exit 0, no side effects |
| Model API returns errors / rate-limits | Action retries per its own policy, then the job fails **advisorily** (never blocks CI-required checks) |
| Agent exceeds its timeout budget | Job cancelled; `agent:budget-exceeded` label applied where applicable; escalation comment on the PR/issue |
| GitHub Agentic Workflows preview enabled | `.md` sources compile over the lock files; same bounds documented here still apply |

## 4. Bounded autonomy

| Agent | Budget | Hard caps | Escalation |
| ----- | ------ | --------- | ---------- |
| Issue triage | 1 run per issue event | 10 min timeout; labels + one comment only; cannot close/reopen | None needed (stateless) |
| CI investigator | 1 run per failed `workflow_run` | 15 min; read-only repo access + one summary comment | Labels `ci-failure-investigated` |
| PR reviewer | 1 run per PR push | 15 min; comments only; cannot approve; cannot touch branch | `ai-review-complete` label |
| Bounded repair | Max 3 attempts per PR (label-enforced) | 30 min per attempt; repair branch only; forbidden paths enforced by diff guard | `agent:escalate` label + issue comment at cap |

## 5. Forbidden actions (enforced)

Agents can never:

1. Modify `.github/workflows/**`, `.github/CODEOWNERS`, `.github/GOVERNANCE.md`,
   or `.github/AGENT_PLATFORM.md`. The bounded-repair workflow runs a
   deterministic `git diff --name-only` guard that fails the repair job if
   any protected path changed.
2. Approve pull requests (no `pull-requests: write` approval path is used;
   code-owner approval is human-only via branch protection).
3. Access production or registry credentials (agents never receive
   environment secrets; see GOVERNANCE.md section 5).
4. Merge, tag, or release (no permissions granted).

## 6. Secrets checklist (before enabling agentic workflows)

- [ ] `ANTHROPIC_API_KEY` - repo secret, read by `claude-code-action` jobs.
- [ ] `OPENAI_API_KEY` - repo secret, read by `codex-action` jobs.
- [ ] Neither key is referenced by any non-agent workflow (verified by the
      `permissions-audit` job's no-secret-leak pattern).
- [ ] Copilot licence enabled on the org **or** the `gh aw` extension
      installed for the Agentic Workflows preview (optional; the lock-file
      implementations work without it).
- [ ] Input names verified against the pinned action versions: the two
      actions evolve their input schemas; confirm `prompt`,
      `allowed_tools` (claude-code-action) and `prompt`, `sandbox`
      (codex-action) still match the pinned SHAs during the Batch 1 review.

## 7. Verification checklist (what "done" looks like)

- [ ] Open a test issue: triage agent applies exactly one type label, one
      priority label, area labels, and posts one comment.
- [ ] Break a test on a branch: investigator agent posts a failure
      analysis on the run/PR within one workflow_run.
- [ ] Open a PR: reviewer agent posts inline comments (no approval).
- [ ] Let repair run 4 times on a broken PR: attempts 1-3 execute, the 4th
      is refused with `agent:escalate`.
- [ ] Delete both API keys: all four agent workflows post a notice and
      exit 0; `ci-summary` is unaffected.

## 8. Batch 4 - Release, deploy, and rollback

Batch 4 wires up the release pipeline, build provenance, and a deterministic
rollback path. The release job is the only place that holds `contents: write`
plus `id-token: write` (the latter for OIDC-backed provenance attestation).
The security.yml audit was widened to permit `release.yml`,
`release-provenance.yml`, and `rollback.yml` for these specific permissions,
with a documented reason per file (see the audit job's inline comment).

| Workflow | Trigger | Permissions | Role |
| -------- | ------- | ----------- | ---- |
| `release.yml` | `push: tags: v*` or `workflow_dispatch` | `contents: write`, `id-token: write`, `attestations: write` | Build reproducible tarball + SHA256SUMS, publish GitHub Release, call `release-provenance.yml` |
| `release-provenance.yml` | `workflow_call` from `release.yml` | `id-token: write`, `attestations: write`, `contents: read` | Generate SLSA-style provenance attestation for the tarball; verifiable via `gh attestation verify` |
| `rollback.yml` | `workflow_dispatch` only | `contents: write` | Re-publish a prior release's assets under a new `vX.Y.Z-rollback.N` tag. Deterministic: no code is rebuilt |

### Staging vs production

For a skill-pack repo, "staging" = the open PR branch (covered by CI on
every push); "production" = a release tag on `main`. The release.yml
workflow is the production deploy step. There is no live service to
roll forward; rollback is purely about re-publishing a prior verified
tarball under a new tag for consumers that pin to a fixed major.minor.

## 9. Batch 5 - Autonomous ops

Batch 5 adds two scheduled workflows that operate the platform without any
AI agent involvement. Both are advisory - they only open tracking issues
when they observe real drift or sustained failure trends; otherwise they
exit 0 silently.

| Workflow | Schedule | Permissions | Role |
| -------- | -------- | ----------- | ---- |
| `ops-weekly.yml` | Monday 06:00 UTC | `contents: read`, `issues: write` | Manifest hash drift detection, cross-pack snapshot check, workflow inventory diff, permissions-audit replay. Opens a labelled tracking issue with findings |
| `ops-health-check.yml` | Daily 09:00 UTC | `contents: read`, `actions: read`, `issues: write` | Inspects the last 24h of CI runs on the default branch. If the same workflow name failed >=3 times, opens (or appends to) a tracking issue. Otherwise silent |

### Issue labels

Both ops workflows use the `ops` label plus a sub-label (`drift-audit`
or `health-check`). Configure the labels in advance (Settings > Labels)
or the workflows will create them on demand (the GitHub REST API
auto-creates labels on issue creation when the actor has `issues: write`).

### State files

The weekly drift audit persists state under `.github/ops-state/`. The
manifest baseline lives at `data/cross-pack/manifest.sha256`. Neither
path is touched by any agent workflow (verified by the CODEOWNERS rule
on `/.github/` and `/data/cross-pack/`).
