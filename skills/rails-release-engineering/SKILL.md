---
name: rails-release-engineering
description: "Use when designing, reviewing, validating, or operating Rails releases across CI/CD, artifact promotion, deployment gates, progressive delivery, environment compatibility, rollback or roll-forward, and release verification."
---

# Rails Release Engineering

## Purpose
Treat a production release as a controlled change-propagation system rather than a single deploy command.

This skill sits above the existing deployment and runtime mechanics:
- rails-deployment owns basic hosting/deployment readiness;
- rails-production-runtime owns process topology, Puma/Solid Queue lifecycle, shutdown, readiness, and schema/runtime compatibility;
- rails-database-engineering owns migration safety;
- rails-reliability-engineering owns reliability objectives and recovery controls;
- rails-incident-engineering owns operational response after a release causes or exposes an incident.

This skill owns the release lifecycle: change risk -> artifact -> verification -> promotion -> deployment gates -> progressive exposure -> health verification -> rollback/roll-forward -> release evidence.

Core flow:
change scope -> risk classification -> reproducible artifact -> pre-release verification -> compatibility gate -> promotion -> controlled exposure -> health gate -> full rollout -> release record

## Activate when
- preparing or reviewing a production release;
- designing CI/CD release gates;
- changing artifact build or promotion behavior;
- introducing progressive delivery, canary, staged rollout, or feature-flag release controls;
- reviewing rollback versus roll-forward strategy;
- validating environment parity or configuration drift;
- defining release health checks and automated abort conditions;
- reviewing release evidence or release-readiness criteria;
- coordinating application, migration, worker, and infrastructure compatibility during release;
- diagnosing failures introduced by a recent deployment.

Do not activate merely because a Rails application must be deployed once. Use rails-deployment for straightforward deployment mechanics unless the change has a release-management concern.

## Repository inspection
Inspect:
1. CI/CD workflows and required status checks;
2. build scripts, Dockerfile/buildpacks, lockfiles, and artifact generation;
3. deployment tooling and platform/process manager;
4. staging/production environment configuration and secret handling;
5. release versioning, tags, commits, or artifact digests;
6. migrations and expand/contract conventions;
7. web/worker/scheduler process compatibility;
8. feature flags, traffic splitting, canary/staged rollout capabilities;
9. readiness/health/SLI signals and alerting;
10. rollback and roll-forward procedures;
11. audit/change records and approval requirements;
12. incident/runbook conventions for failed releases.

Do not invent a second release mechanism, artifact identity, environment taxonomy, or rollback process when the repository already has one.

## Change risk classification
Classify the release before choosing gates.

Consider:
- code-only versus schema/data change;
- reversible versus irreversible change;
- request-path versus asynchronous behavior;
- security boundary impact;
- external API/message contract impact;
- state migration/backfill;
- process topology or capacity impact;
- blast radius and expected duration;
- dependency changes;
- operational control changes.

High-risk releases require stronger evidence and narrower exposure. Do not use a single universal gate set for every change.

## Reproducible artifacts
A release artifact must be identifiable and reproducible enough to answer:
- what source produced it?
- what dependency lock state was used?
- what build inputs were used?
- which commit/version is running?
- which artifact digest was promoted?
- which environment received it?
- what verification was performed?
- who or what authorized promotion?

Prefer immutable artifact promotion over rebuilding independently for every environment.

Do not treat a successful local build as evidence that the production artifact is identical.

## Pre-release verification
Verify the artifact and release plan before promotion:

- automated unit/integration/system tests;
- static/security checks appropriate to the change;
- boot/eager-load/runtime configuration checks;
- migration compatibility;
- queued-job compatibility;
- API/message contract compatibility;
- dependency installation and asset/build correctness;
- artifact identity and provenance;
- expected observability and rollback controls.

Use the focused skills for the technical checks. This skill decides how those checks become a release gate.

## Deployment gates
A gate should have a defined input, pass condition, owner, and failure consequence.

Typical gates:
pre-merge -> build -> test -> security -> migration compatibility -> staging verification -> approval -> production canary -> health/SLI gate -> rollout

For each gate define:
- signal/evidence;
- threshold or rule;
- required status;
- timeout/window;
- abort behavior;
- override authority if overrides are allowed;
- audit record.

Do not create mandatory gates whose signal has no reliable evidence or whose failure has no defined operator response.

## Progressive delivery
When the platform supports controlled exposure, use the smallest rollout that provides meaningful risk reduction.

Possible sequence:
small canary -> verify health/user-impact signals -> expand -> verify -> full rollout

Gate on user-impact and resource signals relevant to the change, not only process health.

Define automatic abort criteria where possible:
- error-rate regression;
- latency regression;
- saturation/capacity regression;
- failed health/readiness;
- queue growth;
- dependency failure;
- correctness/data-integrity signal.

Do not call a rollout progressive merely because servers update one at a time. There must be controlled exposure and an explicit decision gate.

## Environment parity
Keep environments similar enough that release evidence transfers meaningfully.

Compare:
- Ruby/Rails/runtime versions;
- dependency lock state;
- build process;
- database engine/features;
- queue/broker behavior;
- environment variables and feature flags;
- external providers;
- proxy/load-balancer behavior;
- resource limits;
- process topology.

Not every environment must be identical. Differences should be deliberate, documented, and tested for release relevance.

Do not dismiss staging-only or production-only differences when they alter behavior exercised by the release.

## Migration and worker compatibility
Assume overlap during rolling deployment.

Model:
old web + new web + old jobs + new jobs + pre/post-migration state

Schema changes must remain compatible with active application versions until the cutover point.

Queued jobs may outlive the release that created them. Verify serialization, constants, arguments, side effects, and retry behavior remain compatible.

Use rails-database-engineering and rails-production-runtime for detailed compatibility mechanics.

Never assume application rollback can reverse an irreversible database change.

## Rollback versus roll-forward
Choose the recovery direction before or during release planning.

Rollback is preferred when the previous application artifact remains compatible with the current durable state and restoring it is safer than changing forward.

Roll-forward is required when the durable state or external contract makes application rollback unsafe or impossible.

For every release define:
- rollback trigger;
- rollback target artifact;
- database compatibility limitation;
- external side effects already emitted;
- queued work implications;
- data reconciliation requirement;
- owner and authority;
- verification after recovery.

Do not make "rollback" a checkbox if the real recovery action is a forward fix plus compatibility handling.

## Release health verification
Release completion requires evidence at multiple levels:

process health AND readiness AND user-impact SLI AND dependency behavior AND queue/backlog stability AND no known correctness/data-integrity regression

Use a defined observation window appropriate to the release risk.

Compare against a baseline or pre-release window rather than accepting absolute health alone.

A healthy process with degraded user outcomes is not a successful release.

## Release evidence and audit trail
Record enough evidence to reconstruct the release:
- source revision;
- artifact identity/digest;
- migration version/state;
- environment;
- start/end time;
- gate results;
- exposure stage;
- health evidence;
- approvals/overrides;
- rollback/roll-forward actions;
- final release state.

A release record should be machine-readable where the repository already supports this.

Do not store secrets in release records.

## Failed release handling
Treat a failed release as an operational event:
1. stop further exposure;
2. establish affected scope;
3. preserve deployment/gate evidence;
4. decide rollback versus roll-forward;
5. execute the smallest safe recovery;
6. verify user-impact and system recovery;
7. link to incident engineering when user impact exists;
8. convert material findings into durable engineering changes.

Do not overwrite evidence by immediately rebuilding and redeploying without preserving the failed artifact/version and observed failure.

## Reference example

Release gates as an executable script: the same checks that gate the tag are the ones a human would otherwise re-type.

```ruby
# bin/release-verify - run before tagging a release
GATES = [
  "bin/rails zeitwerk:check",
  "bin/rails db:migrate:status",     # fails on pending/down migrations
  "bin/rails test",
  "bin/rails assets:precompile"
].freeze

GATES.each do |gate|
  puts "== #{gate}"
  system(gate) or abort("release gate failed: #{gate}")
end

puts "all release gates passed"
# Tag only after this exits 0; the tag records the exact commit that passed.
```

## Agent review checklist
- [ ] change risk classified
- [ ] artifact identity/provenance established
- [ ] pre-release verification covers the touched contracts
- [ ] migration/worker compatibility assessed
- [ ] deployment gates have evidence and consequences
- [ ] progressive exposure is meaningful where used
- [ ] environment differences are understood
- [ ] rollback versus roll-forward is explicit
- [ ] release health uses user-impact and system signals
- [ ] release evidence is retained
- [ ] secrets are excluded
- [ ] failed-release recovery path is executable
- [ ] final release state is observable

## Anti-patterns
- rebuilding different artifacts for each environment;
- promoting an artifact whose source/dependency identity is unknown;
- using process health as the only release gate;
- calling sequential server replacement progressive delivery without decision gates;
- deploying irreversible migrations with incompatible application code;
- assuming application rollback reverses database/data changes;
- relying on staging evidence despite undocumented behavioral drift;
- allowing gate overrides without authorization or auditability;
- deleting failed release evidence;
- declaring release success before the observation window completes.

## Verification
For release-engineering changes, verify the smallest owning contract first, then run repository validators and the focused system test.

For operational release changes, verify the actual artifact, gate behavior, deployment stage, health signals, rollback/roll-forward behavior, and final release evidence.

Never claim a release is safe merely because CI passed. CI proves only the checks it actually executed.

## Source foundation
- Rails Guides: https://guides.rubyonrails.org/configuring.html
- Rails Guides: https://guides.rubyonrails.org/active_job_basics.html
- Rails Guides: https://guides.rubyonrails.org/active_record_migrations.html
- Puma deployment/restart documentation: https://puma.io/
- Repository skills: rails-deployment, rails-production-runtime, rails-database-engineering, rails-reliability-engineering, rails-incident-engineering.