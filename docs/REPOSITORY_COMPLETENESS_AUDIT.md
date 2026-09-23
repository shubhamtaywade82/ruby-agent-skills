# Repository Completeness Audit

## Purpose

Iteration 46–60 verify the skill system as a repository-wide product, not only as a collection of individual Rails topics.

The audit checks:

- skill files versus manifest registration;
- implementation patterns versus manifest registration;
- evaluation files versus manifest registration;
- duplicate pattern registrations and intentional testing aliases;
- routing coverage for every selectable skill;
- execution coverage for every *_system_test.rb;
- README inventory counts against repository-derived counts, including the dedicated system/contract test count and the manifest version, so any drift fails validation;
- current Rails framework drift that should be routed into existing skills instead of creating unnecessary duplicate skills.

## Current inventory

At Iteration 46 the repository contains **76 skills**, **393 implementation patterns**, and **392 evaluation cases**.

At Iteration 54, the repository-wide validator executes **46 system tests**. Every system test is required to appear in bin/validate.

## Framework drift review

The official Rails 8.1 release notes identify the major framework additions reviewed in this audit. Rails 8.1 adds Active Job Continuations, Structured Event Reporting, Local CI, Markdown Rendering, command-line credential fetching, deprecated associations, and registry-free Kamal deployments. Rails 8 also established Solid Cache, Solid Queue, Solid Cable, Propshaft, Kamal 2, Thruster, and the authentication generator as major framework/platform changes.

Iteration 46 routes these version-sensitive concerns to existing owners rather than fragmenting the library:

| Current Rails concern | Owning skill |
|---|---|
| ActiveJob::Continuable | rails-active-job |
| Rails.event / structured Event Reporting | rails-observability |
| markdown rendering from controllers | rails-action-controller |
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
4. All 43 system tests are now executed by the canonical validator.
5. Router coverage is explicit for every skill, including the meta-level agent-workflow skill.
6. README inventory and milestone text are checked by the audit.
7. Stale pre-Iteration-46 roadmap text is removed.
8. Rails 8.1 framework drift is represented in the owning skills and completeness evaluation.
9. Iteration 51 completes the public Rails benchmark campaign: all **27** Rails evaluations have disposable fixture seams and controlled campaign entries.

## Guardrails

The completeness audit is intentionally a structural guardrail. It does not infer that a framework feature deserves a new standalone skill. Existing ownership, repository conventions, version evidence, and task scope remain the deciding factors.

Iteration 52 adds CI toolchain-version validation to the canonical repository verification path.

Iteration 53 adds adversarial routing-case validation so overlapping skill boundaries are checked as explicit primary/secondary ownership contracts.

Iteration 54 adds a provider-neutral empirical routing evaluator and system test for measuring actual agent skill selection against those routing cases.

Iteration 55 upgrades the evaluator to repeated public-campaign execution with fresh run workspaces, completion enforcement, and primary-skill confusion metrics.

Iteration 56 adds a concrete Ollama routing adapter and verifies that routing gold labels are not exposed to the external agent workspace.

Iteration 57 adds the executable real-campaign wrapper and deterministic confusion analyzer, plus explicit model-availability gating so unavailable agents never produce synthetic routing evidence.

Iteration 58 adds an explicit before/after routing remediation policy and comparator with regression gates for aggregate metrics, confusion pairs, and per-case primary accuracy.

Iteration 59 adds a controlled baseline/candidate experiment runner that swaps only the routing-contract snapshot while keeping the agent invocation, model metadata, repetition count, and comparison gate consistent.

Iteration 60 adds auditable evidence packaging for completed routing experiments, including artifact hashes, repository revision, compatibility metadata, and replay information.

Run the audit directly with:
ruby scripts/audit_repository_completeness.rb

It is also part of bin/validate.
