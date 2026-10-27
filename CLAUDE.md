# CLAUDE.md — Claude Code orientation for ruby-agent-skills

This file is the **Claude Code entry point** for the `ruby-agent-skills` skill pack. Claude Code reads `CLAUDE.md` first when entering a repository; this file tells Claude Code where the canonical contract lives and how to use this pack alongside its companions.

## What this repository is

`ruby-agent-skills` is a portable skill pack of agent-executable Ruby and Ruby on Rails engineering knowledge. It is **not a runnable application** — it has no Ruby entry point, no web server, no background workers. It is consumed by AI coding assistants (Claude Code first; also Cursor, Codex, Continue, Aider) via the `skills/<name>/SKILL.md` convention.

The pack ships **103 skills** + **452 implementation patterns** + **621 evaluation cases** + **116 system/contract tests**, organized so an agent can classify a task, inspect a Rails repository, select skills and patterns, implement a bounded change, verify behavior, and report evidence.

## Read these before making non-trivial changes

In this order:

1. **`AGENTS.md`** (repo root) — the canonical engineering contract. 15 sections covering the operating sequence, context rules, routing quality, design rules, stack minimality, CI toolchain, verification, skill precedence, companion packs, install, benchmark, release, evaluation, and repository completeness. **Everything in `AGENTS.md` is binding for any agent working in this pack.**
2. **`docs/CROSS_PACK_SCHEMA.md`** — the v3 cross-pack manifest schema that this pack and `node-agent-skills` both speak. Read this before adding or changing any `cross_pack:` entry.
3. **`docs/CLAUDE_CODE_INTEGRATION.md`** — how to install and wire this pack into Claude Code (`~/.claude/skills/`, `~/.claude/CLAUDE.md`, MCP, `/skills` slash command).
4. **`docs/SKILL_CONTRACT.md`** — the frontmatter + section template + 500-line cap for every `SKILL.md`.
5. **`router/ROUTING.md`** — the cross-stack routing matrix; especially the "Rails and React cross-stack routing" section (existing) and "Rails and Node cross-stack routing" section (v3 addition).

This file is a Claude Code pointer. The canonical contract lives in `AGENTS.md`. To bind a project to the contract, drop a `./CLAUDE.md` in the project root with:

```markdown
@import ./path/to/ruby-agent-skills/AGENTS.md
```

## Skill content standard (binding for any change)

Every `SKILL.md` in this pack must:

- Start with YAML frontmatter containing `name:` (matches the parent directory name) and `description:` (one sentence starting with "Use when"). The optional `license:` field defaults to `MIT`.
- Include the 8 mandatory sections (per `docs/SKILL_CONTRACT.md`): `## Purpose`, `## Activate when`, `## Repository inspection`, `## Decision rules` (or `## Critical invariants`), `## Implementation or review procedure`, `## Anti-patterns / failure modes`, `## Verification`, `## Source foundation`. Domain skills may add a `## <Domain> changes` section (e.g. `## Rails Active Record changes`).
- Stay under 500 lines / ~5,000 tokens (hard cap; the size gate is enforced by `bin/skill-pack-verify` and `bin/validate`).
- Reference companion-pack skills by fully-qualified name (`react-agent-skills/browser-authentication`, `node-agent-skills/node-ruby-integration`) — never copy companion content into this pack.

## Runtime files (Claude Code may invoke these)

| File | Purpose |
|---|---|
| `bin/install` | Installer. `bash bin/install --agent claude --scope user` installs to `~/.claude/skills/`. `--scope project --project ./my-rails-app` installs to `./.claude/skills/`. Always pass `--ref <tag>` for reproducibility (the default is `main`, which drifts). |
| `bin/skill-pack-verify` | Verifier. `ruby bin/skill-pack-verify --root ~/.claude/skills` checks manifest SHA, skill count, pattern inventory, tool inventory. Run after every install and every upgrade. |
| `bin/skill-pack-doctor` | Higher-level wrapper. `ruby bin/skill-pack-doctor --root ~/.claude/skills` checks metadata + embedded verifier + agent layout + scope. |
| `bin/verify-change` | After a Rails change, `bin/verify-change` produces an evidence report (tests, validators, scope, contracts). Documented in `docs/VERIFY_CHANGE.md`. |
| `bin/cross-pack-verify` | **NEW in v3.** `ruby bin/cross-pack-verify --root ~/.claude/skills --companions ~/.claude/skills` checks `schema_version: 3` is declared, the `cross_pack:` section is well-formed, companion snapshots are not stale, name collisions match the recomputed intersection, and seam skills exist on both sides. Run after installing or upgrading any companion pack. |
| `bin/mcp-server` | **NEW in v3.1.** MCP server (stdio JSON-RPC 2.0, stdlib only). Tools: `list_skills`, `get_skill`, `route_prompt` (with optional `file` for v3 language-aware boosting), `list_companions`, `route_cross_pack` (routes across this pack AND companion packs discovered from `AGENT_SKILLS_PACKS` / sibling directories). Honors `RUBY_AGENT_SKILLS_ROOT` for the pack root. Registration snippet in `docs/CLAUDE_CODE_INTEGRATION.md`. |
| `lib/ruby_agent_skills/skill_pack.rb` | Loader. Parses `skill-manifest.yml` with `YAML.safe_load`; consumes `skills`, `patterns`, `compatibility`. v3-aware: when `schema_version: 3` is present, also exposes `pack`, `cross_pack`, and per-skill `language`/`category`/`version`/`companion_owners` fields (all additive — existing call sites unchanged). |
| `skill-manifest.yml` | The pack's contract. v3-aware as of this version: top-level `schema_version: 3`, `pack:` envelope, and `cross_pack:` section are additive. Existing v2 consumers see no change. |

## Tests

The Ruby test suite uses `bin/validate` and `bin/test` (Minitest system tests). Before pushing a change to this pack:

```bash
bin/validate                      # runs the full system test suite
ruby bin/cross-pack-verify        # v3 cross-pack contract check
ruby bin/mcp-server < mcp-smoke.jsonl   # optional MCP smoke test
```

For the consumer's Rails project (not this pack), the project's own test suite (`bin/rails test`, `bin/rails test:system`) is authoritative; this pack's `bin/verify-change` integrates evidence from the project's suite into the change report.

## Cross-pack integration (binding)

This pack declares three companion packs in `skill-manifest.yml`'s `cross_pack:` section:

| Companion | Boundary | This pack's seam skill | Companion's seam skill |
|---|---|---|---|
| `node-agent-skills` | Rails ↔ Node backend | `rails-node-integration` | `node-ruby-integration` |
| `react-agent-skills` | Rails ↔ React client | `rails-react-integration` | `browser-authentication` |
| (none for Ruby-only projects) | — | — | — |

**Claude Code routing rule**: when a task touches a Rails + Node boundary, load both seam skills (this pack's `rails-node-integration` and the companion's `node-ruby-integration`) plus the owning domain skills on each side. When only this pack is installed, do the Rails side and the seam, then report the Node-side follow-up with the owning companion skill (`node-ruby-integration` for the seam, `node-rest-api-design` / `node-postgresql-persistence` for the domain). **Never improvise Node guidance from this pack.**

The 8 documented name collisions with `react-agent-skills` are listed in `data/cross-pack/react-agent-skills.snapshot.yml` (`documented_name_collisions`). `ruby-agent-skills` and `node-agent-skills` share **zero** name collisions (the node pack prefixes every skill with `node-`); see `data/cross-pack/node-agent-skills.snapshot.yml`.

## Commit discipline

- Bisectable commits. One logical change per commit.
- No `Co-Authored-By` trailers in this repo's history.
- `bin/validate` and `bin/skill-pack-verify --root .` must pass before push.
- After adding a new skill, also add: a `skills/<name>/SKILL.md`, an entry in `skill-manifest.yml`'s `skills:` block (under the matching `family:`), a row in `router/ROUTING.md`'s routing matrix, a row in `router/ROUTING_CASES.yml` if the skill has adversarial overlap, and an eval case file under `evals/<domain>/`.
- After changing `skill-manifest.yml`, recompute `data/cross-pack/*.snapshot.yml` `documented_name_collisions` if you added or removed a skill name that might collide with a companion.

## What this pack is NOT

- Not a Rails app generator. Use `rails new` for that.
- Not a RuboCop config. Use `rubocop` and `rubocop-rails` for that. The `.rubocop.yml` at this repo's root lints **this pack's Ruby code**, not the consumer's Rails app.
- Not a tutorial. Read the Rails guides and the Ruby docs first; this pack assumes you know Ruby and Rails.

## See also

- `AGENTS.md` — canonical engineering contract (read this first).
- `docs/CLAUDE_CODE_INTEGRATION.md` — install + wiring guide.
- `docs/CROSS_PACK_SCHEMA.md` — v3 manifest schema.
- `docs/INSTALLATION.md` — install/verify/companion instructions.
- `docs/REACT_AGENT_SKILLS_MIGRATION.md` — 9-skill React deprecation migration.
- `router/ROUTING.md` — cross-stack routing matrix.
- `INTEGRATION_LAYER.md` (top-level, ships alongside this pack's tarball) — how to use this pack alongside `node-agent-skills` in a Claude Code session.
