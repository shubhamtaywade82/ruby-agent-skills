# Reviewer Training Curriculum

This eight-week curriculum is intended to improve human review judgment while using AI assistance responsibly. It is a practice plan, not a requirement to run every phase on every code change.

| Week | Focus | Practice | Artifact |
|---|---|---|---|
| 1 | Review scope, specifications, evidence, false positives | Review two small PRs independently before AI critique | Baseline review ledger |
| 2 | Ruby semantics, control flow, boundaries, exceptions | Inspect deliberately flawed snippets and reproduce the defect | Defect examples |
| 3 | Test quality and regression analysis | Find tests that pass despite wrong behavior; try controlled mutation | Test-review checklist |
| 4 | Active Record, data integrity, migrations, concurrency | Trace writes, callbacks, transactions, constraints, and races | Persistence checklist |
| 5 | Security, authorization, trust boundaries, tenant isolation | Examine unauthorized IDs, malformed input, and alternate access paths | Abuse-case catalogue |
| 6 | Async jobs, external APIs, retries, idempotency, recovery | Review timeout, duplicate-delivery, and partial-failure scenarios | Failure-mode matrix |
| 7 | Architecture, API/client contracts, maintainability | Review a cross-layer change and identify actual versus hypothetical abstraction | Architecture notes |
| 8 | AI-assisted review and capstone | Three unfamiliar changes: independent pass, AI challenge, adjudication | Three completed review reports |

## Daily loop (45–60 minutes)

1. Study one narrow concept from the skill or framework guide.
2. Review a bounded real PR or known-flawed fixture without AI.
3. Ask AI to challenge your findings after recording them.
4. Verify suggestions against code and tests.
5. Record missed defects, false positives, and the rule to remember.

## Completion signals

Use a known-answer training corpus where possible. Aim for defensible findings, improving high-severity recall, fewer false positives, accurate severity, and findings that lead to regression tests or durable checklist improvements. Numerical thresholds should be treated as personal learning targets, not industry benchmarks.
