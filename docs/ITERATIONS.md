# Iterations

> **Current milestone:** Iteration 148 — Validation Gate Integrity Preflight


The repository is built in numbered iterations. This file is the ordered history, oldest first: one section per iteration with a short summary. `CHANGELOG.md` keeps the itemized changes, newest first.

## Iteration 144 — Agent Skills Frontmatter Contract Validation

Extended skill validation to enforce Agent Skills frontmatter constraints for name, description, compatibility, metadata, and allowed-tools. Added a focused system test and tied routing campaign run-count documentation to the campaign manifest.

## Iteration 145 — Executable Runtime Compatibility Gate

Turned runtime compatibility into executable infrastructure: RubyGems-based requirements, selected skill/pattern compatibility reports, materialization enforcement, target-runtime evidence in evaluations, a compatibility CLI, and three explicit Rails 8.1 version-bound patterns.

## Iteration 146 — Deprecation Governance

Added a machine-readable deprecation registry for the React/TypeScript migration boundary, deterministic validation of status/scope/replacement/migration evidence/removal gates, and dedicated system coverage.

## Iteration 147 — Executable Framework Drift Detection

Added a bounded framework-drift registry backed by official Rails release notes and an executable detector for Ruby code fences in skills and patterns. Findings include exact file/line locations; intentional historical examples require an explicit in-block suppression directive.

## Iteration 148 — Validation Gate Integrity Preflight

Added an independent CI preflight that checks the validation gate itself before running it, preventing truncation or repository-path corruption from hiding later validation checks.

---

## Final Release and Public-Readiness Hardening

The repository retains an explicit public-release boundary covering contribution/security entry points, versioned release metadata, inventory consistency, generated benchmark-artifact exclusion, and executable release-readiness verification. This section is intentionally non-numbered so the numbered iteration history remains strictly ascending.

