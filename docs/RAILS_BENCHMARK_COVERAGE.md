# Rails Benchmark Coverage

## Purpose

Iteration 49 extends the controlled benchmark system from the existing Ruby/design/runtime families into the deep Rails evaluation corpus.

The first campaign is intentionally incremental. It does not claim that every Rails evaluation is already measured.

## Current coverage

The Rails corpus contains **27 public evaluation files** covering **263 cases**.

The first public campaign covers:

| Evaluation | Cases |
|---|---:|
| Action Controller | 9 |
| Active Record | 9 |
| Routing | 10 |
| Validations | 10 |
| **Measured in Iteration 49** | **38** |

The remaining **23 Rails evaluation files / 225 cases** are reported by the benchmark-quality audit as public but unbenchmarked.

## Campaign contract

The Rails campaign uses:

- three repetitions;
- paired skills-disabled and skills-enabled runs;
- fresh workspaces;
- the same fixture and verifier for both sides;
- explicit runtime and hidden-case controls;
- deterministic fixture tests;
- independent scope and contract verification.

The benchmark runner remains provider-neutral. Actual model execution requires an external agent adapter.

## Why coverage is incremental

A public evaluation is useful independently of a measured campaign. The repository therefore keeps evaluation registration separate from benchmark registration.

validate_evals.rb verifies that every campaign references valid public evaluations and that every campaign fixture is registered. audit_benchmark_quality.rb reports public evaluations that do not yet belong to a campaign.

This avoids two incorrect extremes:

1. treating every public evaluation as already benchmarked;
2. requiring every evaluation family to reach full fixture coverage in one change.

## Next coverage batches

The remaining Rails benchmark work should prioritize the highest-risk deep framework boundaries next: Authentication, Authorization, Action Cable, Active Storage, Action Mailer/Mailbox, Action View/Text, Active Support/Model, asset/build infrastructure, initialization, Rack/middleware, engines/Railties, encryption/credentials, serialization/Global IDs, operational maintenance, cross-boundary authorization, staff architecture, and repository completeness.

Do not optimize campaign coverage for raw case count alone. Prefer representative fixtures that expose real implementation tradeoffs and have independent behavioral verification.
