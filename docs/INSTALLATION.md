# Installation and Verification

The repository ships a provider-neutral installer for the agent-facing skill pack.

## Install

From a cloned checkout:

    bash bin/install --agent agents

Supported layouts are:

- `agents` / `codex`
- `claude`
- `copilot`

User scope installs into the corresponding user skill directory. Project scope installs into the selected project's agent skill directory.

Example:

    bash bin/install \
      --scope project \
      --agent claude \
      --project /path/to/your/rails-app

A release can be pinned by branch, tag, or commit:

    bash bin/install --ref v1.0.0 --agent claude

For local testing, the source repository can be overridden with `RUBY_AGENT_SKILLS_REPO`.

## Offline install from a release archive

A GitHub Release archive can be installed without git or network access. Extract the archive and run the installer from inside it (the installer detects the pack directory it lives in and uses it as the source):

    tar xzf ruby-agent-skills-vX.Y.Z.tar.gz
    cd ruby-agent-skills-vX.Y.Z
    bash bin/install --agent claude

The installer detects a plain local directory containing `skill-manifest.yml` (and `RELEASE.json` provenance) and installs directly from it. The recorded requested ref and resolved Git SHA come from the archive's `RELEASE.json`, so the installed pack still carries release provenance. Verify the downloaded archive against the published `SHA256SUMS` before installing.

Running the installer from a repository checkout likewise defaults to that checkout (its committed state); set `RUBY_AGENT_SKILLS_REPO` to install from a different source.

## Installed layout

The installer keeps the agent-visible skills at the target root:

    <agent-skill-root>/
    ├── rails-.../
    ├── ruby-.../
    └── .ruby-agent-skills/
        ├── INSTALLATION.json
        ├── skill-manifest.yml
        ├── ROUTING.md
        ├── AGENTS.md
        ├── docs/
        └── patterns/

The hidden support directory contains the manifest, routing contract, reusable patterns, and immutable installation provenance without polluting the agent's normal skill namespace.

## Verification

Verify an installed pack:

    ruby bin/skill-pack-verify --root ~/.claude/skills

Run the higher-level installation doctor:

    ruby bin/skill-pack-doctor --root ~/.claude/skills

The verifier checks:

- installation protocol;
- skill manifest SHA-256;
- routing-contract SHA-256;
- exact installed skill set;
- exact installed pattern set;
- recorded inventory counts;
- SHA-256 for every installed skill and pattern file.

A successful installation prints the source repository, requested ref, resolved Git SHA, and installed inventory.

## Doctor contract

`skill-pack-doctor` verifies the installation metadata, supported agent/scope values, exact recorded skill set, embedded verifier, and then runs the embedded integrity verifier. It is a local installation smoke test; it does not claim that a particular coding agent has loaded or executed a skill.

## Operational rule

Treat installed skills as code. Review the source/ref before installation, pin a trusted ref for reproducibility, and verify the resulting installation before enabling it in a controlled agent benchmark.

## Retired skills

When skills are merged, the old name is recorded under `retired_skills` in `skill-manifest.yml` with the skill that absorbed it. Re-running the installer over an existing installation removes the retired directory and prints the replacement, for example:

    Removed retired skill rails-testing (merged into rails-test-engineering).

Update any project instructions that name a retired skill to use its replacement.

| Retired | Use instead |
|---|---|
| `rails-activerecord` | `rails-active-record` |
| `rails-controllers` | `rails-action-controller` |
| `rails-views` | `rails-action-view` |
| `rails-testing` | `rails-test-engineering` |
| `rails-best-practices` | `rails-architecture` |
| `rails-deployment` | `rails-release-engineering` |
