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
