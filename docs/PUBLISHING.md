# Publishing and end-to-end evaluation

How this pack meets the Agent Skills standard, how it reaches users, and the staged evaluation to run before calling a release ready for global use. Every requirement below was checked against the cited source or by running the tool against this repository.

## What the standard requires

| Requirement | Source | Status in this repository |
|---|---|---|
| Each skill is a directory with `SKILL.md` and optional `references/`, `scripts/`, `assets/` | [agentskills.io/specification](https://agentskills.io/specification) | Enforced by `scripts/validate_skills.rb` |
| Frontmatter fields: only `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools` | Same; the official `skills-ref` validator rejects anything else | All 96 skills pass the pinned `skills-ref` (`bin/skills-spec-check`), in CI too. Every skill declares `license: MIT` |
| `name` matches the directory, lowercase, single hyphens, at most 64 characters; `description` at most 1024 characters | Same | Enforced by `scripts/validate_skills.rb` |
| `SKILL.md` under 500 lines; references one level deep | Same (progressive disclosure) | Enforced by `scripts/validate_skills.rb` |
| A skill works when installed on its own | `npx skills add <repo> --skill <name>` copies only that skill's directory | No skill links outside its own folder or names a repository path; other skills and patterns are named, not linked. Enforced by `scripts/validate_skills.rb` and checked by the `cli_install` readiness check |

Not part of the standard, so not adopted: top-level `version`, `triggers`, or `paths` frontmatter (`skills-ref` rejects them), a root router skill that fetches other skills over the network, and a re-index API call (none is documented).

## How users install it

- **One skill, or a few:** `npx skills add shubhamtaywade82/ruby-agent-skills --skill rails-active-record`.
  - Use `--list` to browse first, and `-a claude-code` (or another agent) to choose where it goes.
  - Agents load only each skill's name and description at startup, then the full `SKILL.md` when the skill is used.
- **The full pack** (skills plus the 446-pattern catalog, the routing contract, and provenance verification): `bin/install` from a release tag (see `docs/INSTALLATION.md`).
  - Skills refer to patterns by name. With a CLI install the pattern catalog is absent; the skills still apply, but without those implementation shapes.

## Publishing channels

| Channel | How it works | Who acts |
|---|---|---|
| skills.sh / `npx skills` | No submission. The public repository is installable as is; the directory ranks repositories by CLI installs. Users can opt out of the CLI's telemetry with `DISABLE_TELEMETRY=1` | Nothing to do beyond a public release |
| Tessl registry | `tessl login`, then `tessl skill import <skill-dir> --workspace <ws>` (generates `.tessl-plugin/plugin.json`), then `tessl skill lint` and `tessl skill publish ... --public`. Each skill is its own package. Tessl's docs reviewed for this guide do not cover CI authentication | The maintainer, under their Tessl account |
| Curated lists (for example `VoltAgent/awesome-agent-skills`) | A pull request to that repository following its `CONTRIBUTING.md` | The maintainer, publicly |

## End-to-end evaluation before publishing

Run the stages in order; a later stage is meaningless if an earlier one fails. Record each stage's output as release evidence, never as a summary from memory.

### Stage 1: deterministic readiness (no model, no account)

```bash
ruby bin/publish-readiness --out tmp/publish-readiness.md
```

| Check | What it proves |
|---|---|
| `validate` | The full repository gate: skill, pattern, and evaluation schemas, audits, and every system test |
| `spec` | All 96 skills pass the official `skills-ref` validator |
| `cli_list` | `npx skills` discovers exactly the skills in the manifest |
| `cli_install` | Every skill installs alone for Claude Code with no broken relative links |
| `release_archive` | The release archive builds, installs offline, and passes `skill-pack-verify` and `skill-pack-doctor` |

A missing tool (`npx`, `uvx`/`skills-ref`) reports `unavailable` and the result is `NOT READY`. It is never treated as a pass.

### Stage 2: routing quality (real model)

Does an agent pick the right skill for a task? The public campaign is 31 cases × 3 repetitions = 93 routing decisions.

```bash
export CLAUDE_MODEL=<full model name>
ruby bin/routing-eval --command "ruby $(pwd)/bin/routing-agent-claude" \
  --provider anthropic --model "$CLAUDE_MODEL" \
  --router router/ROUTING.md --output benchmark-results/routing-claude
ruby bin/routing-analyze benchmark-results/routing-claude/campaign.json

The same campaign accepts `bin/routing-agent-cursor`, `bin/routing-agent-antigravity`, or `bin/routing-agent-opencode`. Set that CLI's model variable and pass the matching `--provider` and `--model`. See `docs/LOCAL_BENCHMARKING.md`.
```

Decide the acceptance thresholds before running (for example, primary-skill accuracy and repetition stability), and record them with the results. Investigate every confusion pair the analysis reports. A rerun after a routing fix must use a fresh output directory.

### Stage 3: effectiveness (paired baseline versus skills)

Do the skills improve the code an agent writes? Each campaign runs every evaluation with and without the skills, three repetitions each, with identical fixtures and verifiers (`docs/BENCHMARK_CAMPAIGN.md`).

```bash
ruby bin/agent-benchmark --command "ruby $(pwd)/bin/coding-agent-claude" \
  --manifest benchmarks/rails/campaign.yml \
  --provider anthropic --model "$CLAUDE_MODEL" \
  --timeout 300 --continue-on-failure --output benchmark-results/rails-claude
```

- Start with the small `ruby-toolchain` and `ruby-gem-development` campaigns (6 model runs each) to prove the adapter, then the Rails campaign (168 runs), then the remaining families.
- Read the per-dimension paired report (`bin/benchmark report`) and the individual run files. A campaign is evidence for the model and pack revision it ran on, not for later revisions.
- Families graded statically (for example `test-engineering`) show structural conformance, not executed behavior (`docs/BENCHMARK_QUALITY_AUDIT.md`).

### Stage 4: activation in each target agent

The CLI installs the files; each agent decides when to use a skill. For every agent you intend to support (for example Claude Code, Codex, Cursor):
1. Install a handful of skills with `npx skills add ... --skill <name> -a <agent>` into a scratch Rails app.
2. Give the agent three or four prompts from `router/ROUTING_CASES.yml`, including one that must *not* activate the installed skills.
3. Record which skill the agent loaded for each prompt.

This is manual, but it is the only check of the descriptions as real agents read them.

### Stage 5: release

1. Merge to `main` with CI green.
2. Tag `vX.Y.Z` from `main`. The release workflow builds and verifies the archive, and the GitHub release notes include `docs/releases/vX.Y.Z.md`.
3. After the release, run `npx skills add shubhamtaywade82/ruby-agent-skills --list` from a clean machine to confirm the public repository installs.
