# Changelog

## Iteration 146 — Deprecation Governance

- Add `docs/DEPRECATION_GOVERNANCE.md` as the operational contract for skills retained during migration but excluded from new standalone work.
- Add `scripts/validate_deprecations.rb` to require explicit deprecated status, migration scope, replacement, migration documentation, and exactly five removal gates.
- Register the nine migrated React/TypeScript skills in `skill-manifest.yml` and prevent duplicate replacement ownership.
- Add `test/deprecation_governance_system_test.rb` and wire the validator into `bin/validate`.
- Keep removal evidence-driven: the repository does not infer adoption, dates, or completion from the existence of the replacement repository.

## Iteration 145 — Executable Runtime Compatibility Gate

- Add `RubyAgentSkills::VersionConstraint`, using RubyGems version/requirement semantics for deterministic compatibility checks.
- Extend `SkillPack` with compatibility reporting and enforcement for selected skills and pattern frontmatter. Known `unsupported`/`conflict` material is rejected; strict mode also rejects unknown runtime evidence.
- Bind `EvalRunner` to the target workspace runtime profile so compatibility evidence travels with evaluation results.
- Add `bin/skill-pack-compatibility` for project-side compatibility checks and ship/verify it through installer and release integrity surfaces.
- Add three Rails 8.1 version-bound patterns: `active-job-continuation-contract`, `structured-event-reporting`, and `credentials-fetch-contract`.
- Validate pattern/manifest compatibility requirements and add system/unit coverage.
- No model benchmark result is claimed; this iteration hardens deterministic version safety only.

## Iteration 144 — Agent Skills Frontmatter Contract Validation

- Extend `scripts/validate_skills.rb` to enforce the current Agent Skills frontmatter constraints for `name`, `description`, `compatibility`, `metadata`, and `allowed-tools`.
- Enforce skill names at most 64 characters using lowercase letters, numbers, and single hyphens; descriptions must be non-empty strings of at most 1024 characters; compatibility is optional but must be a non-empty string of at most 500 characters when present.
- Validate optional metadata as a string-to-string mapping and reject non-string `allowed-tools` values.