# Release Cut Checklist (Tier 0)

## Why this exists

The published `v1.0.1` release advertises 91 skills / 431 patterns and predates
the skill merge (Iteration 128). `v1.1.0` is cut from commit `3ce8a2b`
(Iteration 133, 85 skills / 432 patterns) and the README quick-start points at
it. Skills added after that commit — `rails-react-integration` (Iteration 134)
and `react-frontend-security` and `react-frameworks` (Iteration 135) — ship in
the next minor release.

This checklist is the Tier 0 gate from the frontend/full-stack completion
program. Run it for every release cut so the published artifact, the README
quick-start, and the release notes match the implementation line, and so the
EARP baseline runs against a synchronized release rather than a moving target.

## Pre-cut verification

Run every item below from a clean `main` checkout. Any failure blocks the cut.

- [ ] `bin/validate` passes (skills + patterns + evals).
- [ ] `ruby scripts/audit_skill_routing.rb` passes.
- [ ] `ruby scripts/audit_release_readiness.rb` passes.
- [ ] `ruby scripts/audit_repository_completeness.rb` passes.
- [ ] `ruby scripts/audit_ci_toolchain.rb` passes.
- [ ] `ruby scripts/audit_provenance_hygiene.rb` passes.
- [ ] `ruby scripts/audit_documentation_consistency.rb` passes.
- [ ] `ruby scripts/audit_corpus_quality.rb` passes.
- [ ] `ruby scripts/audit_benchmark_quality.rb` passes.
- [ ] CI is green on `main` for the latest commit.
- [ ] `skill-manifest.yml` skill count matches `ls skills/ | wc -l`.
- [ ] `CHANGELOG.md` has an entry for every skill added/removed since `v1.0.1`.

## Skill count reconciliation

Before tagging, reconcile the published `v1.0.1` metadata against current `main`:

1. List skills in `v1.0.1` release notes.
2. List skills in current `skill-manifest.yml`.
3. Produce a diff: added, removed, renamed.
4. The diff becomes the body of the release notes for the new tag. Do not
   summarize it as "various changes" — name every skill that moved.

If the diff is non-empty (it will be), the new release is a **minor** bump
(`v1.1.0`) under SemVer, not a patch bump. The skill set changed; that is a
public API change for a skill pack.

## README quick-start update

The README currently points at `v1.0.1`. Update every install snippet to the
new tag. Specifically:

- [ ] The `curl` / `wget` install one-liner references the new tag.
- [ ] The `bin/install` example uses the new tag.
- [ ] The "Skills included" count matches the new manifest count.
- [ ] The "Patterns included" count matches the current `patterns/` tree.
- [ ] Any badge or shield in the README references the new tag.
- [ ] The `RELEASE.md` quick-start section is updated to match.

## Tag and release

- [ ] Tag is annotated: `git tag -a v1.1.0 -m "..."`.
- [ ] Tag message lists the skill delta from `v1.0.1`.
- [ ] Tag is signed if the repository has a signing key configured.
- [ ] `git push origin v1.1.0`.
- [ ] GitHub Release is created from the tag.
- [ ] Release body is the skill delta + the validator evidence summary
      (which audits passed, on which commit SHA).
- [ ] Release assets include the release archive produced by
      `ruby scripts/build_release_archive.rb`.
- [ ] Release archive SHA256 is recorded in the release notes.

## v1.0.1 retirement

- [ ] `v1.0.1` release notes on GitHub get a banner: "Superseded by v1.1.0.
      Install v1.1.0 instead."
- [ ] Do **not** delete the `v1.0.1` tag. Users may have pinned to it.
- [ ] Do **not** mark `v1.0.1` as a "pre-release". It was a real release; it is
      now superseded, not withdrawn.

## Post-cut

- [ ] Verify a clean install from the new tag in a fresh directory:
      `bin/install` from the new tarball, then `bin/skill-pack-verify`.
- [ ] Record the new tag in `CHANGELOG.md` under an entry for the cut date.
- [ ] Open an issue to schedule the first EARP baseline run (see
      `docs/AGENT_ROUTING_EVAL_PROTOCOL.md`) against the new tag.

## What this checklist does NOT do

- It does not add new skills. That is Tier 1.
- It does not run the EARP baseline. That happens after the cut, against the
  new tag.
- It does not modify the install verifier or the skill contract. Those are
  stable.
