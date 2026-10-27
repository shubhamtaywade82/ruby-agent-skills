# Claude Code Integration Guide

**Audience**: developers using Claude Code (https://claude.com/claude-code) as their AI coding assistant, who want to wire this skill pack in so Claude Code can discover and apply the pack's skills automatically.

This guide is **pack-agnostic**: it works identically for `ruby-agent-skills`, `node-agent-skills`, and `react-agent-skills`. Where the steps differ, the differences are called out in a per-pack table.

## What Claude Code looks for

Claude Code auto-loads agent context from the following locations (in order; later entries do NOT override earlier ones — they compose):

| Location | Purpose | Who writes it |
|---|---|---|
| `~/.claude/CLAUDE.md` | User-global agent instructions | You (the developer) |
| `./CLAUDE.md` (project root) | Project-specific agent instructions | Project maintainer |
| `./.claude/CLAUDE.md` | Project-local overrides | Project maintainer |
| `~/.claude/skills/<name>/SKILL.md` | User-global skill files | Skill pack installers |
| `./.claude/skills/<name>/SKILL.md` | Project-local skill files | Skill pack installers |
| `~/.claude/mcp.json` | MCP server registrations | You (the developer) |
| `./.mcp.json` | Project-local MCP server registrations | Project maintainer |

The `/skills` slash command in Claude Code lists every skill discoverable from the `skills/` paths above.

## Why this pack doesn't auto-load

Most skill packs (including this one) ship `AGENTS.md` as their canonical agent contract, not `CLAUDE.md`. Claude Code reads `CLAUDE.md` first, so out of the box the pack's contract is invisible to Claude Code.

**Fix**: install the pack with its native installer (see below) AND add a one-line `@import` to your `./CLAUDE.md` so Claude Code sees the pack's contract. The pack's installer may write a `CLAUDE.md` for you; if not, the manual content is below.

## Install paths by pack

| Pack | Installer command | Default install location | Verifier |
|---|---|---|---|
| `ruby-agent-skills` | `bash bin/install --agent claude` | `~/.claude/skills/` (user scope) or `./.claude/skills/` (project scope) | `ruby bin/skill-pack-verify --root ~/.claude/skills` |
| `node-agent-skills` | `npx skills add shubhamtaywade82/node-agent-skills -a claude-code` OR `node bin/skills.mjs` (in-repo) | `~/.claude/skills/` | `npm test && npm run validate` (in-repo) |
| `react-agent-skills` | `npx skills add shubhamtaywade82/react-agent-skills -a claude-code` | `~/.claude/skills/` | (per companion pack's own verifier) |

**Install order matters when packs share skill names.** See [Name collisions](#name-collisions-and-install-order) below.

## Recommended `./CLAUDE.md` content

For a project that uses this pack, drop the following into `./CLAUDE.md` (or `./.claude/CLAUDE.md` for a project-local override). Replace `<pack-name>` with this pack's actual name:

```markdown
# Project agent contract

This project uses the `<pack-name>` skill pack. Before making non-trivial changes:

1. Read `AGENTS.md` for the full engineering contract (this file is a Claude Code pointer).
2. Use the `/skills` slash command to list available skills. Activate the smallest set that covers the task.
3. For tasks that span Ruby and Node (or React), consult `router/ROUTING.md`'s cross-stack section first.
4. After implementing, run the pack's verifier to confirm no contract regression.

@import ./AGENTS.md
```

The `@import` directive is Claude Code-native: it pulls the contents of the imported file into the agent's context window as if they were inline. This means the pack's `AGENTS.md` becomes part of the project's `CLAUDE.md` automatically — no copy-paste, no drift.

## MCP server registration

**Both packs ship MCP servers** (Model Context Protocol, JSON-RPC 2.0 over stdio). The node pack exposes 5 tools (`get_skill`, `route_prompt`, `route_cross_pack`, `list_skills`, `list_adapters`); the ruby pack mirrors 5 tools (`list_skills`, `get_skill`, `route_prompt`, `list_companions`, `route_cross_pack`).

To register the **node pack's** server with Claude Code, add the following to `~/.claude/mcp.json` (user-global) or `./.mcp.json` (project-local):

```json
{
  "mcpServers": {
    "node-agent-skills": {
      "command": "node",
      "args": ["/absolute/path/to/node-agent-skills/lib/mcp-server.mjs"],
      "env": {
        "NODE_AGENT_SKILLS_ROOT": "/absolute/path/to/node-agent-skills",
        "AGENT_SKILLS_PACKS": "/absolute/path/to/ruby-agent-skills"
      }
    }
  }
}
```

To register the **ruby pack's** server:

```json
{
  "mcpServers": {
    "ruby-agent-skills": {
      "command": "ruby",
      "args": ["/absolute/path/to/ruby-agent-skills/bin/mcp-server"],
      "env": {
        "RUBY_AGENT_SKILLS_ROOT": "/absolute/path/to/ruby-agent-skills",
        "AGENT_SKILLS_PACKS": "/absolute/path/to/node-agent-skills"
      }
    }
  }
}
```

The `*_ROOT` env vars let either server resolve its pack without relying on script-relative paths, so the server binary can be installed anywhere. `AGENT_SKILLS_PACKS` (colon- or comma-separated) tells `route_cross_pack` where companion packs live; sibling directories named after declared companions are also discovered automatically (e.g. `/repos/node-agent-skills` finds `/repos/ruby-agent-skills`). If the env vars are absent, both servers fall back to script-relative roots (legacy behavior; unchanged).

After registering, restart Claude Code. Verify with `/mcp` in the Claude Code prompt — you should see both servers listed with 5 tools each.

### The `route_cross_pack` tool (v3.1)

Both servers expose `route_cross_pack`, which routes a prompt across every installed pack:

```json
{
  "name": "route_cross_pack",
  "arguments": {
    "prompt": "the Node BFF calls the Rails orders API and maps 422 validation errors into problem json",
    "file": "src/bff.ts"
  }
}
```

The `file` argument enables language-aware scoring: skills whose language matches the file's extension are boosted (x2) and non-matching skills are demoted (x0.5), so `app/models/order.rb` routes to `ruby-agent-skills/rails-active-record` while `src/order.ts` routes to `node-agent-skills/node-postgresql-persistence` for the same prompt. When the task crosses a pack boundary, the response's `seam` field names both sides to load:

```json
{
  "seam": {
    "recommended": true,
    "boundary": "rails-to-node-backend",
    "this_pack_seam": "rails-node-integration",
    "companion_side": "node-agent-skills/skills/node-ruby-integration",
    "reason": "task routes to a cross-pack seam skill; load the companion side with it"
  },
  "companion_owners": ["node-agent-skills/node-ruby-integration", "..."]
}
```

## Cross-pack setup (Claude Code + multiple skill packs)

If your project uses more than one pack (e.g. Rails backend + Node service + React frontend), install them in **this order** to avoid silent name-collision overrides:

```bash
# 1. Ruby/Rails pack first (its agent-workflow is the server-side baseline).
bash bin/install --agent claude

# 2. Node pack second (its skills don't collide by name with ruby's; all node- prefixed).
npx skills add shubhamtaywade82/node-agent-skills -a claude-code

# 3. React pack last (resolves the documented agent-workflow + 7 React/TS skill name collisions in ruby's favor per the ruby pack's INSTALLATION.md; react wins).
npx skills add shubhamtaywade82/react-agent-skills -a claude-code
```

After installing, run the cross-pack verifier (shipped with each pack as of v3):

```bash
# From the ruby-agent-skills checkout:
ruby bin/cross-pack-verify --root ~/.claude/skills --companions ~/.claude/skills

# From the node-agent-skills checkout:
node bin/cross-pack-verify.mjs --root ~/.claude/skills --companions ~/.claude/skills
```

The verifier checks:
- Both manifests declare `schema_version: 3`.
- `cross_pack.companions[]` lists the other pack with a pinned ref.
- `cross_pack.name_collisions[]` matches the actual set intersection of installed skill names.
- `cross_pack.seam_contracts[]` entries reference seam skills that exist on both sides.

## Name collisions and install order

The ruby pack documents 8 name collisions with `react-agent-skills` in its `data/cross-pack/react-agent-skills.snapshot.yml`:

- `agent-workflow`
- `react-architecture`
- `react-component-engineering`
- `react-data-fetching`
- `react-testing-engineering`
- `typescript-core-engineering`
- `typescript-runtime-contracts`
- `typescript-type-design`

`ruby-agent-skills` and `node-agent-skills` have **zero** name collisions today (the node pack prefixes every skill with `node-`). This is by design; do not introduce a `node-`-prefixed skill name into the ruby pack or vice versa.

## Activating skills from a Claude Code session

Three ways to bring a skill into the agent's context window:

1. **`/skills` slash command** — opens a searchable list of every installed skill. Selecting one inserts its `## Purpose` and `## Activate when` sections into the conversation as a context block. The agent then knows the skill exists and can ask to load more.

2. **`@skills/<name>/SKILL.md`** — explicit reference. Inserts the full skill file content. Use when you know exactly which skill applies.

3. **MCP `route_prompt` / `route_cross_pack` tools** — call `route_prompt` with the task description (plus the active file as `file` for language-aware boosting); the server returns the primary + secondary + candidates. For a task that may cross a language boundary, call `route_cross_pack` and load both sides named by the returned `seam` contract. The agent uses the returned `path` field to `@`-reference the resolved skill.

For the ruby pack without its MCP server registered, the agent reads `skill-manifest.yml` and matches `triggers:` against the task description. The ruby pack's `router/ROUTING.md` has a 116-row routing matrix that handles common Rails tasks; the agent should consult it before falling back to trigger matching.

## Per-pack quick-start

### ruby-agent-skills

```bash
# Clone & install (user scope)
git clone https://github.com/shubhamtaywade82/ruby-agent-skills
cd ruby-agent-skills
bash bin/install --agent claude                 # installs to ~/.claude/skills/

# Verify
ruby bin/skill-pack-verify --root ~/.claude/skills
ruby bin/skill-pack-doctor --root ~/.claude/skills

# Project scope (recommended for reproducibility — pins to your repo's pinned ref)
bash bin/install --agent claude --scope project --project ./my-rails-app

# Cross-pack verifier (v3)
ruby bin/cross-pack-verify --root ~/.claude/skills --companions ~/.claude/skills
```

### node-agent-skills

```bash
# Install (user scope)
npx skills add shubhamtaywade82/node-agent-skills -a claude-code

# OR clone & use in-repo (developer)
git clone https://github.com/shubhamtaywade82/node-agent-skills
cd node-agent-skills
npm install
npm test                                        # contract tests
npm run validate                                # manifest + adapter checks

# CLI usage
node bin/skills.mjs route "add a Postgres transaction with an index" --repo .
node bin/skills.mjs list --category architecture
node bin/skills.mjs show node-architecture

# MCP server (recommended for Claude Code)
node lib/mcp-server.mjs                          # stdio JSON-RPC

# Cross-pack verifier (v3)
node bin/cross-pack-verify.mjs --root ~/.claude/skills --companions ~/.claude/skills
```

## What Claude Code does NOT do automatically

- **Pinned ref checking**: the ruby pack's `bin/install` defaults to `main` on the public GitHub repo. For reproducibility, pass `--ref v1.5.0` (or a SHA). Claude Code does not warn if the install ref drifts.
- **Cross-pack coherence**: if you install ruby and node packs from different dates, Claude Code does not detect that their companion-snapshot files might disagree. Run `bin/cross-pack-verify` after every install or upgrade.
- **Deprecated-skill suppression**: the ruby pack still ships 9 deprecated React/TypeScript skills (they trigger on `React state`, `TypeScript generics`, etc.). Claude Code's trigger-matching may activate them. The deprecated skills' bodies redirect to `react-agent-skills`; the agent should follow that redirect.
- **Seam routing**: when a task spans two languages (Rails + Node), Claude Code does not automatically know to load `rails-node-integration` or `node-ruby-integration`. The agent must consult `router/ROUTING.md`'s cross-stack section. The v3 `cross_pack.seam_contracts` section makes this machine-readable; future Claude Code skill-routing logic may consume it.

## Troubleshooting

### Claude Code says `/skills` is empty

- Check `~/.claude/skills/` exists and contains subdirectories with `SKILL.md` files.
- Run `ruby bin/skill-pack-verify --root ~/.claude/skills` (ruby pack) — it reports missing files.
- Restart Claude Code after install; the skill list is cached per session.

### `route_prompt` MCP tool returns the wrong primary

- The node-pack loader uses pure token overlap, so ambiguous prompts (e.g. "add a migration") may tie. Pass a more specific prompt, or pass `--repo` to `bin/skills.mjs route` so adapter detection can break the tie.
- The v3 `language:` field on skill entries (once added) will let a future loader break ties by file extension. Today, ties break alphabetically.

### `bin/cross-pack-verify` reports "stale snapshot"

- The companion snapshot file (`data/cross-pack/<companion>.snapshot.yml`) has a `captured_at` date older than 90 days. Re-capture: `ruby scripts/capture-companion-snapshot.rb --companion <pack>` (ruby pack) or `node scripts/capture-companion-snapshot.mjs --companion <pack>` (node pack). Until recaptured, the verifier still passes but warns.

### Claude Code does not see `AGENTS.md`

- Claude Code reads `CLAUDE.md`, not `AGENTS.md`. Add `@import ./AGENTS.md` to your `./CLAUDE.md`. The `CLAUDE.md` shipped with this pack (v3 addition) already contains this import; check it is installed.

## See also

- `AGENTS.md` — the canonical engineering contract for this pack.
- `docs/CROSS_PACK_SCHEMA.md` — the unified manifest schema (v3) that both packs use.
- `docs/INSTALLATION.md` (ruby) / `docs/RUNTIME_INTEGRATION.md` (node) — pack-native install docs.
- `router/ROUTING.md` — the cross-stack routing matrix.
- `INTEGRATION_LAYER.md` (top-level, ships alongside this pack's tarball) — how to use this pack alongside the other pack in a Claude Code session.
