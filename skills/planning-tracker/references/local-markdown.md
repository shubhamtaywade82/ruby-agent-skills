# Local Markdown tracker

Reference for the `planning-tracker` skill. Load it on demand when the resolved backend is local Markdown. The item model, backend resolution, and invariants stay in the skill's `SKILL.md`.

## Layout

All items live directly in one directory, `docs/planning/` unless the repository declares another root:

```text
docs/planning/
├── README.md                          # optional; ignored by the tracker
├── 0001-refunds-map.md                # kind: map
├── 0002-decide-refund-tax-split.md    # kind: decision, parent: 1
├── 0003-decide-refund-ledger-entry.md # kind: decision, parent: 1, blocked_by: [2]
└── 0004-partial-refunds-spec.md       # kind: spec
```

Only files named `NNNN-slug.md` (four or more digits, then a lowercase kebab-case slug) are items. Everything else in the directory is ignored.

## Item file

```markdown
---
id: 3
title: Decide the refund ledger entry
kind: decision
status: open
labels: [needs-decision]
parent: 1
blocked_by: [2]
---

## Question

Should a partial refund create one ledger entry or one per tax line?

## Notes

- 2026-09-28: Finance needs per-line entries for VAT returns.
```

Rules:

- `id` equals the number in the file name and never changes;
- take the next id from `ruby scripts/tracker.rb next-id --root <root>`, never by guessing;
- claim an item by setting `assignee:` to the session or person working it, before starting;
- `labels`, `parent`, `blocked_by`, and `assignee` are optional; omit them rather than writing empty values when unused;
- the slug may change when a title changes, the id may not;
- comments are dated entries appended under `## Notes`.

## The tracker script

`scripts/tracker.rb` (relative to this skill's directory) uses only the Ruby standard library:

| Command | Result |
|---|---|
| `validate --root DIR` | exits 1 and lists every error: bad front matter, id and file-name mismatch, unknown kind or status, duplicate ids, missing parents or blockers, self-blocks, and blocking cycles |
| `list --root DIR [--status S] [--parent ID] [--kind K] [--json]` | items matching every filter |
| `frontier --root DIR [--parent ID] [--kind K] [--include-claimed] [--json]` | open, unclaimed, non-map items whose blockers are all closed |
| `next-id --root DIR` | the next free id, zero-padded |

Run `validate` after every batch of edits and before committing.

## Committing

Local items are repository files. Commit them with the change that creates or resolves them, so the history of each decision sits beside the code it shaped. Never commit an item that holds a secret or personal data.
