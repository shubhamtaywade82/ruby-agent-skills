# Final Release and Public-Readiness Hardening

Iteration 48 verifies that the public repository surface is complete after the engineering, evaluation, and benchmark milestones.

## Required public surface

- README, AGENTS, LICENSE, CONTRIBUTING, SECURITY, and CHANGELOG
- canonical manifest and router
- evaluation, pattern, benchmark, and source-coverage schemas
- validation, evaluation, and benchmark entry points
- release-readiness audit

## Release checks

`scripts/audit_release_readiness.rb` fails on missing public metadata, stale inventory markers, a milestone mismatch between README and CHANGELOG, inventory/count drift in README, or tracked generated benchmark results.

The documented inventory covers skills, implementation patterns, evaluation cases, and dedicated system/contract tests.

`bin/validate` remains the canonical engineering verification command; the release audit is an additional publication guardrail.

## Evidence policy

Release readiness means repository consistency and verification are present. It does not claim that an external coding model achieves any particular benchmark result.

Run:

    ruby scripts/audit_release_readiness.rb
