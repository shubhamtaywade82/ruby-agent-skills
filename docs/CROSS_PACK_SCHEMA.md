# Cross-Pack Manifest Schema v3

**Status**: additive, backward-compatible with v1 (node-agent-skills) and v2 (ruby-agent-skills).
**Audience**: skill-pack authors, cross-pack loader/router authors, AI coding assistants (Claude Code first).

## Why v3

`ruby-agent-skills` (manifest v2) and `node-agent-skills` (manifest v1) ship two **incompatible** `skill-manifest.yml` shapes:

| Aspect | ruby-agent-skills (v2) | node-agent-skills (v1) |
|---|---|---|
| `skills:` shape | YAML mapping keyed by name | YAML sequence of entries |
| Per-skill required fields | `family`, `path`, `triggers` | `name`, `category`, `triggers` |
| Per-skill `version` | absent | present (decorative; not consumed) |
| Per-skill `path` | required | absent (loader derives from name) |
| Per-skill `compatibility` | optional (consumed by `VersionConstraint`) | absent |
| Per-skill `language` | absent (only `pack.language`) | absent (only `pack.language`) |
| Top-level `pack:` envelope | absent (flat `name:` instead) | present |
| Cross-pack section | absent | absent |
| Loader parser | `YAML.safe_load` (Ruby stdlib) | line-regex (zero-dep ESM) |

The result: a single cross-pack tool cannot parse both manifests without writing two code paths, and trigger collisions across packs (e.g. `migration`, `architecture`, `validation`) resolve alphabetically — biasing whichever pack's skill names sort first.

v3 closes that gap with a **strict superset**: every v1 and v2 manifest remains valid; new optional fields are added; a new `cross_pack:` top-level section makes companion-pack relationships machine-checkable.

## Compatibility contract

1. **No field is renamed or removed.** Existing v1 and v2 parsers see no change.
2. **No field's type changes.** A field that was a string stays a string; a list stays a list.
3. **New fields are all optional.** A v1 or v2 manifest without them is still valid v3.
4. **New top-level key `schema_version`** is distinct from the legacy `version` field. v3-aware loaders check for `schema_version: 3`; if absent, fall back to legacy behavior.
5. **Both `skills:` shapes (mapping and sequence) remain valid in v3.** A v3-aware loader detects the shape by YAML node type.

## v3 schema

### Top-level keys

| Key | Type | Required | Notes |
|---|---|---|---|
| `schema_version` | `int` | optional | `3` for v3-aware manifests. Absent in v1/v2. |
| `version` | `int` | optional | Legacy manifest schema version. ruby uses `2`, node uses `1`. Unchanged. |
| `pack` | `object` | optional | Envelope. node already has this; ruby may adopt it additively. |
| `name` | `string` | optional | Legacy flat name (ruby uses this). Unchanged. |
| `installation` | `object` | optional | ruby only. Unchanged. |
| `defaults` | `object` | optional | ruby only. Unchanged. |
| `framework_drift` | `object` | optional | ruby only. Unchanged. |
| `routing` | `object` | optional | ruby only. Unchanged. |
| `retired_skills` | `object` | optional | ruby only. Unchanged. |
| `relocated_skills` | `object` | optional | ruby only. Unchanged. |
| `deprecations` | `object` | optional | ruby only. Unchanged. |
| `patterns` | `object` | optional | ruby only. Unchanged. |
| `runner` | `object` | optional | ruby only. Unchanged. |
| `benchmarks` | `object` | optional | ruby only. Unchanged. |
| `evaluations` | `object` | optional | ruby only. Unchanged. |
| `skills` | `mapping` OR `sequence` | required | Either shape is valid in v3. |
| `adapters` | `mapping` | optional | node only. Mapping of adapter-name → `{path, version_scope, source}`. |
| `adapter_skills` | `sequence` | optional | node only. Sequence of skill-shaped entries that were previously misplaced under `adapters:`. v3 separates them so the manifest is valid YAML. |
| `cross_pack` | `object` | optional | **NEW in v3**. Cross-pack relationships. See below. |

### `pack:` envelope

| Field | Type | Required | Notes |
|---|---|---|---|
| `name` | `string` | yes | e.g. `ruby-agent-skills`, `node-agent-skills`. |
| `language` | `string` | yes | Primary language: `ruby`, `typescript`, `javascript`, `python`, `go`, `rust`, `multi`. |
| `runtime` | `string` | yes | e.g. `MRI 3.2`, `Node.js 20.x`, `Bun 1.x`. |
| `homepage` | `string` (URL) | optional | Repository URL. |
| `license` | `string` (SPDX) | optional | e.g. `MIT`, `Apache-2.0`. |

### Per-skill entry (v3 superset)

A v3-aware loader accepts **all** of the following fields on each skill entry. Existing v1/v2 fields are marked. New v3 fields are additive and optional.

| Field | Type | Required in v3? | Source | Notes |
|---|---|---|---|---|
| `name` | `string` | yes (sequence form) | node v1 | Required when `skills:` is a sequence. Absent in mapping form (key is the name). |
| `family` | `string` | optional | ruby v2 | Coarse category. v3 loader can derive from `category` if absent. |
| `category` | `string` | optional | node v1 | Free-form tag. v3 loader can derive from `family` if absent. |
| `path` | `string` | optional | ruby v2 | Path to `SKILL.md` from repo root. v3 loader derives `skills/<name>/SKILL.md` if absent. |
| `triggers` | `list[string]` | yes | both | Activation keywords. Inline `[a, b, c]` form preferred for line-regex compatibility. |
| `version` | `string` (semver) | optional | node v1 (decorative) | Per-skill version. Meaningful in v3; was decorative in v1. |
| `language` | `string` | optional | NEW v3 | Per-skill language tag. Defaults to `pack.language` if absent. Enables cross-pack routing without name-prefix heuristics. |
| `compatibility` | `object` | optional | ruby v2 | Version constraints consumed by `VersionConstraint`. |
| `schema_version` | `int` | optional | NEW v3 | Per-skill v3 marker. If `3`, the entry is v3-aware. |
| `description` | `string` | optional | NEW v3 | Prose summary. Recommended for v3 entries (mirrors SKILL.md frontmatter). |
| `companion_owners` | `list[string]` | optional | NEW v3 | Companion-pack skill names that own related territory. e.g. ruby's `rails-active-record` might list `node-postgresql-persistence` as a companion owner for shared database concepts. |

### `cross_pack:` section (NEW in v3)

```yaml
cross_pack:
  schema_version: 3
  companions:
    - pack: ruby-agent-skills            # companion pack name
      repo: https://github.com/shubhamtaywade82/ruby-agent-skills
      pinned_ref: v1.5.0                # tag, branch, or SHA; recommend pinning
      snapshot: data/cross-pack/ruby-agent-skills.snapshot.yml  # path within THIS repo
      seam_skill: rails-node-integration  # this pack's seam skill for the boundary
      language: ruby
    - pack: react-agent-skills
      repo: https://github.com/shubhamtaywade82/react-agent-skills
      pinned_ref: main
      snapshot: data/cross-pack/react-agent-skills.snapshot.yml
      seam_skill: rails-react-integration
      language: typescript
  name_collisions:
    - skill_name: agent-workflow        # skill name that exists in multiple packs
      this_pack_owner: skills/agent-workflow/SKILL.md
      companion_pack: react-agent-skills
      companion_owner: skills/agent-workflow/SKILL.md
      resolution: companion_wins        # install order: companion installed after this pack
      rationale: |
        react-agent-skills is the standalone frontend authority; its agent-workflow
        supersedes this pack's copy for React/TypeScript work. For pure Ruby/Rails
        work, this pack's agent-workflow is authoritative and the companion is not
        installed.
  seam_contracts:
    - boundary: rails-to-node-backend
      primary_in_this_pack: rails-node-integration
      secondary_in_this_pack: [rails-active-record, rails-action-controller]
      companion_pack: node-agent-skills
      companion_side: node-agent-skills/skills/node-ruby-integration
      routing_doc: router/ROUTING.md#rails-and-node-cross-stack-routing
      eval_cases: evals/rails/node-backend-seam.yml
```

### `cross_pack.companions[]` entry shape

| Field | Type | Required | Notes |
|---|---|---|---|
| `pack` | `string` | yes | Companion pack name. |
| `repo` | `string` (URL) | yes | Companion repository URL. |
| `pinned_ref` | `string` | yes | Tag / branch / SHA. **Strongly recommend pinning a tag** for reproducibility. |
| `snapshot` | `string` (path) | optional | Path within THIS repo to a companion snapshot file. |
| `seam_skill` | `string` | optional | This pack's skill that owns the cross-pack boundary. |
| `language` | `string` | yes | Companion pack's primary language. |

### `cross_pack.name_collisions[]` entry shape

| Field | Type | Required | Notes |
|---|---|---|---|
| `skill_name` | `string` | yes | Skill name that exists in both packs. |
| `this_pack_owner` | `string` (path) | yes | Path to this pack's copy. |
| `companion_pack` | `string` | yes | Companion pack name. |
| `companion_owner` | `string` (path) | yes | Path to companion pack's copy. |
| `resolution` | `string` (enum) | yes | One of: `this_pack_wins`, `companion_wins`, `context_dependent`, `split_by_language`. |
| `rationale` | `string` | optional | Why this resolution. |

### `cross_pack.seam_contracts[]` entry shape

| Field | Type | Required | Notes |
|---|---|---|---|
| `boundary` | `string` | yes | Human-readable boundary name (kebab-case). |
| `primary_in_this_pack` | `string` | yes | This pack's primary seam skill. |
| `secondary_in_this_pack` | `list[string]` | optional | This pack's secondary skills. |
| `companion_pack` | `string` | yes | Companion pack name. |
| `companion_side` | `string` | yes | Companion pack's seam skill (fully qualified `<pack>/<skill>`). |
| `routing_doc` | `string` | optional | Anchor in this pack's ROUTING.md describing the boundary. |
| `eval_cases` | `string` (path) | optional | Path to eval cases for this seam. |

## Detection rules for v3-aware loaders

A v3-aware loader detects the manifest shape as follows:

1. Parse `skill-manifest.yml` (any YAML parser).
2. If top-level `schema_version: 3` is present → v3 mode.
3. In v3 mode:
   - If `skills` is a YAML mapping → use the keyed form (ruby-style).
   - If `skills` is a YAML sequence → use the list form (node-style).
   - Either is valid; the loader must support both.
4. If `schema_version` is absent → legacy mode; consult `version`:
   - `version: 2` → ruby v2 behavior.
   - `version: 1` → node v1 behavior.
5. In v3 mode, the loader reads optional fields (`path`, `family`, `category`, `language`, `compatibility`, `version`, `companion_owners`) and uses them when present; falls back to derivation rules when absent:
   - `path` absent → derive `skills/<name>/SKILL.md`.
   - `family` absent → derive from `category` via a shared vocabulary map (see `docs/CROSS_PACK_FAMILY_MAP.md`).
   - `category` absent → derive from `family` via the same map.
   - `language` absent → inherit `pack.language`.

## Cross-pack routing priority (NEW in v3)

When a v3-aware cross-pack router receives a prompt and both packs are installed:

1. **Language tag wins.** If a skill's `language:` field matches the file extension of the file currently being edited (`.rb` → `ruby`; `.ts`/`.tsx`/`.js`/`.jsx`/`.mjs`/`.cjs` → `typescript`/`javascript`), boost its trigger-match score by 2x AND demote non-matching skills by 0.5x. Boost-only would leave ties that alphabetical pack order resolves (`node-` < `rails-`) — the exact cross-pack bias the language field exists to remove. TypeScript and JavaScript are one family (they match each other).
2. **Seam skill wins on cross-stack tasks.** If the prompt routes to a seam skill (`rails-node-integration` or `node-ruby-integration`), the router returns the seam contract and the agent loads BOTH sides.
3. **Companion ownership is consulted.** If the routed skill's `companion_owners` list contains a companion-pack skill name AND the companion pack is installed, the router returns both — the agent loads this pack's skill as primary and the companion skill as a secondary reference.
4. **Name collisions are explicit.** When a skill name exists in both packs (per `cross_pack.name_collisions`), the loader applies the `resolution` policy. `context_dependent` requires the agent to inspect the task; `split_by_language` uses the active file's language.

## Validation hooks

A v3-aware verifier (see `bin/cross-pack-verify` in either pack) checks:

1. **Structural validity**: `skill-manifest.yml` parses as valid YAML (catches the v1 `adapters:` block anomaly).
2. **Schema version coherence**: if `schema_version: 3` is declared, per-skill `schema_version` (when present) is also `3`.
3. **Skill count parity**: the number of `skills/<name>/SKILL.md` files on disk equals the number of manifest skill entries.
4. **Companion snapshot freshness**: each `cross_pack.companions[].snapshot` file exists, names a `pinned_ref`, and the recorded `captured_at` date is within the staleness window (default 90 days; configurable).
5. **Collision registry accuracy**: `cross_pack.name_collisions` lists every skill name that actually appears in both this pack and a companion (computed by set intersection).
6. **Seam skill existence**: every `cross_pack.seam_contracts[].primary_in_this_pack` resolves to a `skills/<name>/SKILL.md` on disk.
7. **Companion seam symmetry**: if `cross_pack.seam_contracts[].companion_side` is `node-agent-skills/skills/node-ruby-integration`, the verifier (when the companion pack is also installed locally) checks that the companion's `cross_pack.seam_contracts` has a mirror entry pointing back at this pack.

## Implementations (v3.1)

The routing priority above is now **implemented** on both sides:

| Capability | node-agent-skills | ruby-agent-skills |
|---|---|---|
| Language-aware single-pack routing | `routePrompt(prompt, repo, {activeFile / language})` in `lib/skill-loader.mjs` (MCP `route_prompt` `file` arg; CLI `route --file`) | `route_prompt` tool in `lib/ruby_agent_skills/mcp_server.rb` (`file` arg) |
| Cross-pack routing | `routeCrossPack` in `lib/cross-pack-router.mjs` (MCP `route_cross_pack` tool; CLI `cross-route`) | `route_cross_pack` tool in `lib/ruby_agent_skills/mcp_server.rb` (packs from `AGENT_SKILLS_PACKS` env or sibling dirs) |
| Shared parsers (both manifest forms, cross_pack, snapshots, language maps) | `lib/cross-pack-manifest.mjs` | mirrored line parser inside `lib/ruby_agent_skills/mcp_server.rb` (`pack_skills`) |
| Structural v3 validation | `lib/v3-schema.mjs` (wired into `bin/cross-pack-verify.mjs`) | checks inside `bin/cross-pack-verify` |
| MCP server | `lib/mcp-server.mjs` — 5 tools incl. `route_cross_pack` | `bin/mcp-server` + `lib/ruby_agent_skills/mcp_server.rb` — 5 mirrored tools |

Pack-root override env vars: `NODE_AGENT_SKILLS_ROOT` (node) and `RUBY_AGENT_SKILLS_ROOT` (ruby); companion roots additionally from the shared `AGENT_SKILLS_PACKS` env var (colon- or comma-separated) and sibling-directory discovery.

## What v3 does NOT change

- The `SKILL.md` file format (frontmatter + sections) is unchanged. v3 is a manifest-layer concern.
- The `bin/install`, `bin/skills.mjs`, `bin/skill-pack-verify`, `bin/skill-pack-doctor` CLIs are unchanged in their existing flag surface. New `bin/cross-pack-verify` and the `cross-route` subcommand are additive.
- The eval YAML schema is unchanged.
- The router YAML/markdown schema is unchanged. New cross-stack sections are appended, not replaced.

## Migration path for an existing pack

1. Add `schema_version: 3` at the top of `skill-manifest.yml`.
2. Add `pack:` envelope (or keep flat `name:`).
3. Optionally add `language:`, `path:`, `family:`, `version:` to existing skill entries. The existing parser continues to ignore fields it doesn't know.
4. Add `cross_pack:` section listing all companion packs and seam contracts.
5. Run `bin/cross-pack-verify` (after writing it for your pack). Fix any reported issues.
6. No changes to existing SKILL.md files required.

## Out of scope for v3

- Per-skill semver enforcement (`version` field is advisory in v3).
- Centralized skill registry / namespacing authority (the `cross_pack.name_collisions` registry is per-pack, not centralized).
- Automatic companion-pack discovery (companions are declared explicitly in `cross_pack.companions`; no auto-discovery).
- Cross-pack eval unification (each pack keeps its own eval schema).
