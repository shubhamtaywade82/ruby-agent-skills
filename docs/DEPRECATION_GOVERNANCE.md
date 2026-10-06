# Deprecation Governance

Deprecation is a controlled migration state, not a deletion shortcut.

The manifest's `deprecations` registry is the authoritative machine-readable boundary for skills that remain installed for compatibility but must not be selected for new work within their declared scope.

## Required fields

Each entry declares:

- `status: deprecated`
- `scope` — the work for which the deprecated skill should no longer be selected
- `replacement` — the destination skill/capability
- `migration_doc` — the evidence-backed migration contract
- `removal_gate` — the explicit conditions that must be satisfied before deletion

## Current boundary

The current registry covers the standalone React/TypeScript migration documented in `docs/REACT_AGENT_SKILLS_MIGRATION.md`.

The deprecated Ruby-pack frontend skills remain installed during the migration window to preserve existing installations and auditability. The cross-boundary `rails-react-integration` capability remains owned here.

## Removal rule

A deprecated entry must not be removed merely because the replacement repository exists. Removal requires all declared removal gates to be satisfied and independently verifiable.

While deprecated, a skill's `SKILL.md` description must start with `DEPRECATED` and name its replacement. Agents choose skills from that description, not from the manifest. No retained skill, pattern, evaluation, or routing case may depend on it.

When a deprecated skill is removed, move its entry from `deprecations:` to `relocated_skills:` with the same replacement. `scripts/validate_deprecations.rb` rejects a relocated skill that is still registered or still deprecated in place. `bin/install` then removes it from existing installations and prints where it moved.

The validator intentionally does not infer dates, adoption levels, or completion status. Those claims require explicit evidence.

## Verification

Run:

```bash
ruby scripts/validate_deprecations.rb
bash bin/validate
```

The repository validator rejects:

- unregistered deprecated skills;
- missing or invalid replacement paths;
- missing migration documentation;
- malformed removal gates;
- malformed deprecation metadata.

This keeps migration state deterministic for coding agents and release tooling.
