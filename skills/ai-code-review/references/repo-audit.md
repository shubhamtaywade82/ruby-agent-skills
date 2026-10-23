# Whole-Repository Audit Mode

Use only when the user asks for a repository-wide audit or systemic health/security assessment. This mode is broader and more expensive than reviewing one file or diff.

## Audit principles

- Inventory the repository before selecting targets.
- Divide the audit into risk zones and inspect representative entry points and execution paths.
- Distinguish systemic patterns from one-off findings. Mark a finding systemic only when multiple independent instances support that conclusion.
- Do not claim full coverage if files, dependencies, dynamic entry points, generated code, or external services were not inspected.
- Keep Standards and Specification assessments separate where a specification exists; for systemic audits without a feature spec, state that Specification is not applicable or not assessed.

## Risk zones

Use the risk-zone and audit checklists, plus the existing Ruby/Rails domain skills appropriate to the inspected files. Prioritize:
1. Authentication, authorization, and tenant isolation.
2. Persistence, Active Record, schema constraints, and migrations.
3. Async jobs, external calls, retries, and reliability.
4. Test quality and missing regression coverage.
5. Secrets, input/output trust boundaries, and dependencies.
6. Architecture, duplicated business rules, and maintainability.
7. Performance and operational readiness where evidence warrants it.

## Procedure

1. Establish repository root, default branch, language/framework versions, and repository instructions.
2. Generate or manually record a repository inventory; record exclusions.
3. Identify high-risk entry points: routes/controllers, jobs, webhooks, file import/export, admin actions, external integrations, data migrations.
4. Select a bounded sample per risk zone based on risk, not just file count.
5. Trace data/control flow and validate suspected systemic patterns against multiple instances.
6. Run focused checks when available; do not run destructive commands.
7. Aggregate findings with `scripts/audit_findings.py`; systemic findings require at least three concrete instances under the provided validator.
8. Report audited zones, sample/coverage limits, systemic and one-off findings, checks run, and residual uncertainty.

A repo audit is not a guarantee that no defects exist. If the repository is too large for a complete pass, define the sampled scope and offer a phased follow-up rather than implying exhaustive coverage.
