# Release Guide

This document describes how the Ruby Agent Skills pack is cut, verified, and published as a release. The release process is deterministic and self-verifying: the same commit always produces the same archive, and every release artifact is checked by the same audits that gate `bin/validate`.

## Release definition

A release is a git tag `vX.Y.Z` on `main`. The tag is the only version marker; consumers pin installs with `--ref vX.Y.Z`, and the installer records the resolved commit SHA as provenance.

A release is **ready** when all of the following hold:

1. `bash bin/validate` exits zero (skill, pattern, evaluation, provenance-hygiene, routing, CI-toolchain, repository-completeness, benchmark-quality, and release-readiness audits plus the full system test suite).
2. The release archive builds reproducibly from the tagged commit.
3. An offline install from the extracted archive passes the embedded verifier and doctor.
4. The GitHub Release carries the archive and its SHA-256 checksum.

Static repository readiness is audited by `scripts/audit_release_readiness.rb`. Empirical routing readiness (`bin/routing-release-check`) is reported separately and honestly: without an externally executed public campaign it reports *pending* rather than inventing a result. Publishing the skill pack does not require empirical routing evidence; the two readiness tracks are documented in `docs/RELEASE_READINESS_AUDIT.md` and `docs/ROUTING_RELEASE_READINESS.md`.

## Cutting a release

From a clean `main` at the commit you want to release:

    bash bin/validate
    ruby scripts/build_release_archive.rb --version vX.Y.Z --self-test
    git tag -a vX.Y.Z -m "Ruby Agent Skills vX.Y.Z"
    git push origin main --tags

Pushing the tag triggers `.github/workflows/release.yml`, which:

1. Runs `bin/validate` and the smoke tests on the tagged commit.
2. Builds `ruby-agent-skills-vX.Y.Z.tar.gz` and verifies an offline install from it (install + verify + doctor).
3. Rebuilds the archive and asserts byte-identical output (reproducibility).
4. Creates the GitHub Release with the archive, `SHA256SUMS`, and generated release notes.

Pre-release tags (`vX.Y.Z-rc.1`, `-beta.`, `-alpha.`) are published as GitHub prereleases.

## Release archive contents

The archive carries the agent-facing surface only — no git history, no evaluation or benchmark infrastructure:

| Path | Purpose |
| --- | --- |
| `skills/` | 89 agent-executable skills (`SKILL.md` per skill) |
| `patterns/` | 447 implementation patterns |
| `skill-manifest.yml` | Canonical skill inventory and routing metadata |
| `router/ROUTING.md` | Routing contract |
| `AGENTS.md` | Agent-facing entry point |
| `docs/SKILL_CONTRACT.md` | Skill authoring contract |
| `bin/install` | Installer (git and offline archive modes) |
| `bin/skill-pack-verify`, `bin/skill-pack-doctor` | Installed-pack verification tools |
| `bin/stack-minimality` | Deterministic minimality evidence tool |
| `RELEASE.json` | Version, source git SHA, and inventory provenance |
| `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `LICENSE` | Public metadata |

## Installing from a release archive (offline)

Consumers who download the archive from the GitHub Release do not need git or network access:

    tar xzf ruby-agent-skills-vX.Y.Z.tar.gz
    cd ruby-agent-skills-vX.Y.Z
    bash bin/install --agent claude

The installer detects the plain extracted directory, reads `RELEASE.json`, and records the release version and the commit the archive was cut from in `INSTALLATION.json`.

## Verifying a downloaded archive

Check the archive against the published checksum before installing:

    sha256sum --check SHA256SUMS

After installing, verify the pack in place (the verifier is embedded in every installation; the doctor ships in the archive):

    ruby .agents/skills/.ruby-agent-skills/skill-pack-verify --root .agents/skills
    ruby bin/skill-pack-doctor --root .agents/skills

## Rollback

Installations are upgraded in place: `bin/install` removes skills that no longer exist in the new source and replaces the hidden support directory atomically. To roll back, reinstall from the older tag:

    bash bin/install --ref vX.Y.Z --agent claude
