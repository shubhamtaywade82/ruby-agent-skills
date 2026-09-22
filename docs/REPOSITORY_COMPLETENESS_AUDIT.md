# Repository Completeness Audit

## Purpose

Iteration 46 verifies the skill system as a repository-wide product, not only as a collection of individual Rails topics.

The audit checks:

- skill files versus manifest registration;
- implementation patterns versus manifest registration;
- evaluation files versus manifest registration;
- duplicate pattern registrations and intentional testing aliases;
- routing coverage for every selectable skill;
- execution coverage for every *_system_test.rb;
- README inventory counts against repository-derived counts;
- current Rails framework drift that should be routed into existing skills instead of creating unnecessary duplicate skills.

## Current inventory

At Iteration 46 the repository contains **76 skills**, **393 implementation patterns**, and **392 evaluation cases**.

The repository-wide validator executes **40 system tests**. Every system test is required to appear in bin/validate.

## Framework drift review

The official Rails 8.1 release notes identify the major framework additions reviewed in this audit. Rails 8.1 adds Active Job Continuations, Structured Event Reporting, Local CI, Markdown Rendering, command-line credential fetching, deprecated associations, and registry-free Kamal deployments. Rails 8 also established Solid Cache, Solid Queue, Solid Cable, Propshaft, Kamal 2, Thruster, and the authentication generator as major framework/platform changes.

Iteration 46 routes these version-sensitive concerns to existing owners rather than fragmenting the library:

| Current Rails concern | Owning skill |
|---|---|
| ActiveJob::Continuable | rails-active-job |
| Rails.event / structured Event Reporting | rails-observability |
| Markdown rendering from controllers | rails-action-controller |
| Deprecated Active Record associations | rails-associations |
| config/ci.rb / bin/ci Local CI | rails-test-engineering |
| Solid Cache | rails-caching |
| Solid Cable | rails-action-cable |
| Kamal 2 / registry-free deployment / Thruster | rails-deployment |
| rails credentials:fetch | rails-encryption-credentials-engineering |
| Rails authentication system generator | rails-authentication |

## Findings closed in Iteration 46

1. All 76 skill paths match the manifest.
2. All 393 implementation pattern files are registered; the four additional registry references are intentional testing-category aliases.
3. All evaluation YAMLs are registered.
4. All 40 system tests are now executed by the canonical validator.
5. Router coverage is explicit for every skill, including the meta-level agent-workflow skill.
6. README inventory and milestone text are checked by the audit.
7. Stale pre-Iteration-46 roadmap text is removed.
8. Rails 8.1 framework drift is represented in the owning skills and completeness evaluation.

## Guardrails

The completeness audit is intentionally a structural guardrail. It does not infer that a framework feature deserves a new standalone skill. Existing ownership, repository conventions, version evidence, and task scope remain the deciding factors.

Run the audit directly with:
ruby scripts/audit_repository_completeness.rb

It is also part of bin/validate.
