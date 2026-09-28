# GitHub Issues tracker

Reference for the `planning-tracker` skill. Load it on demand when the resolved backend is GitHub Issues. The item model, backend resolution, and invariants stay in the skill's `SKILL.md`.

## Before the first write

- Confirm the target `owner/repo` and that this session can write issues, with the `gh` CLI or GitHub MCP tools.
- Get the user's confirmation before the first issue is created, edited, labelled, or closed, unless the repository's `## Planning tracker` declaration authorizes publishing.
- List existing labels and reuse them. Create a missing label only after confirmation.

## Mapping

| Item field | GitHub representation |
|---|---|
| `id` | issue number |
| `title` | issue title |
| `kind` | label `kind:map`, `kind:decision`, `kind:spec`, or `kind:ticket` |
| `status` | issue state: open or closed |
| `labels` | issue labels, such as `ready-for-agent` and `needs-decision` |
| `parent` | a native sub-issue link when the tools in use support it; otherwise a `Parent: #N` line at the top of the body |
| `blocked_by` | a `Blocked by: #N, #M` line at the top of the body, kept current when blockers change |
| `assignee` | issue assignee; assign before starting work |
| comments | issue comments |

Keep the `Parent:` and `Blocked by:` lines even when native links exist. They are what a tool without native support, and a human skimming the body, can read.

## Common operations with the gh CLI

```bash
gh issue create --repo OWNER/REPO --title "Decide the refund ledger entry" \
  --label kind:decision --label needs-decision --body-file item.md
gh issue edit 42 --repo OWNER/REPO --add-label ready-for-agent
gh issue comment 42 --repo OWNER/REPO --body "Decision: one ledger entry per tax line."
gh issue close 42 --repo OWNER/REPO --reason completed
gh issue list --repo OWNER/REPO --state open --label kind:decision --json number,title,body
```

When GitHub MCP tools are available instead, use their equivalent create, update, comment, and list operations with the same fields.

## Frontier

GitHub has no single frontier query for body-line blockers. Compute it:

1. list open issues in the effort (children of the map, or issues carrying the effort's label);
2. for each, read its `Blocked by:` line;
3. keep issues whose every blocker is closed (view each blocker's state);
4. exclude `kind:map` and issues that already have an assignee.

## Naming and references

Refer to issues by title with the link inside it, such as "[Decide the refund ledger entry](#42)", never as a bare list of numbers.
