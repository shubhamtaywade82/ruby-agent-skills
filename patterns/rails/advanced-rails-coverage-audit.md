---
name: advanced-rails-coverage-audit
description: "Audit a Rails skill pack against advanced Rails capabilities: classify each as fully covered, partially covered, missing, or insufficiently tested; recommend depth-fill and behavioral-validation gaps without duplicating skills."
family: rails
---

# Advanced Rails Coverage Audit

## Problem
An agent reviewing a Rails skill pack (this one, or a fork) needs to verify that the pack is genuinely ready for advanced Rails development, not merely that it has the right filenames. A skill exists per topic; whether the skill has a `references/` dir, a dedicated eval family, a system test, and concrete coverage of advanced subtopics (isolation levels, sagas, outbox, partitioning, advisory locks) is a separate question. This pattern is the cross-reference audit that maps advanced Rails capabilities to their existing enforcement points and flags depth gaps without prescribing new skills.

## Use when
- reviewing the pack for adoption readiness against an advanced Rails roadmap
- extending the pack and verifying that new content closes a real gap rather than duplicating an existing skill
- onboarding an engineer or agent to the pack's advanced Rails coverage
- cutting a release that claims advanced Rails readiness

## Do not use when
- auditing the pack against a non-Rails stack (use `ruby-clean-code`, `ruby-oop`, and `ruby-domain-modeling` directly)
- the audit is to be used to justify creating a new skill for a topic that already has a routing destination — see "Do not create new skills" below

## Repository inspection
Before applying this audit:

1. Resolve the upstream commit and tag (`git rev-parse HEAD`, latest tag).
2. Count skills, patterns, eval files, eval cases, system tests, and benchmark campaigns.
3. List skills with `references/` dirs and count reference files per skill (depth signal).
4. List eval families (`evals/<family>/`) and count cases per family (behavioral-validation signal).
5. List patterns per family (`patterns/<family>/`) and count.
6. List system tests (`test/*_system_test.rb`).
7. For each advanced Rails topic in the matrix below, grep for the specific advanced subtopics (`advisory lock`, `outbox`, `saga`, `LISTEN`, `NOTIFY`, `BRIN`, `GIN index`, `materialized view`, `partitioned table`, `Fiber.scheduler`, `:aggregate_failures`, `pg_advisory`, `:serializable`).
8. Read the latest `CHANGELOG.md` and `docs/ITERATIONS.md` to understand recent depth additions.

## Implementation procedure (the 4-step audit hierarchy)

Run this hierarchy in order. Stop at the first step that resolves the question; descend only when the previous step cannot answer.

1. **Identify the routing destination.** Confirm a skill exists for the advanced topic. If none, the topic is missing — propose a new skill (rare; only when no existing skill owns the boundary).
2. **Identify the depth signal.** Count reference files in the skill's `references/` dir (zero means all content lives in the always-loaded SKILL.md, which is a depth-gap candidate for skills over 250 lines).
3. **Identify the behavioral-validation signal.** Confirm a dedicated eval family exists for the topic (not the generic `evals/rails/` family). If no dedicated family, the skill is structurally covered but insufficiently tested.
4. **Identify the advanced-subtopic coverage.** Grep for the specific advanced strings; if absent, the skill's activation triggers may mention the concept but the corpus does not cover it.

## Mapping table: advanced Rails topics → existing enforcement points

The matrix below classifies each topic as: **fully covered** (skill + references + dedicated eval + pattern + system test), **partially covered** (some enforcement exists but a depth or empirical-validation gap remains), **insufficiently tested** (skill + references + no relevant eval), **missing** (no skill at all). A static-only evaluation family closes a contract-definition gap, not an empirical-performance gap.

| Advanced topic | Owning skill | Skill lines | Refs | Dedicated eval family | Patterns | System test | Verdict |
|---|---|---:|---:|---|---:|---|---|
| Ruby internals + metaprogramming | `ruby-core`, `ruby-metaprogramming`, `ruby-concurrency` | 158 / 131 / 295 | 0 / 0 / 0 | `concurrency` (1 case) | 1 | 1 | Partial — skill content sound, no `references/` for metaprogramming, no eval for metaprogramming |
| Active Record + database engineering | `rails-active-record`, `rails-database-engineering`, `rails-associations`, `rails-validations`, `rails-data-modeling` | 219 / 441 / — | 7 / 1 / — | `database` (5 cases), `rails` (28 cases) | 18+ | 5 | Fully covered structurally; partial depth — `rails-database-engineering/references/` has only `seed-data.md` |
| Rails internals (Rack, Zeitwerk, initializers) | `rails-rack-middleware-engineering`, `rails-zeitwerk`, `rails-initialization-configuration-engineering` | 310 / 193 / 113 | 0 / 0 / 0 | `zeitwerk` (2 cases) | 5+ | 4 | Partial — none have `references/`; the three skills deserve progressive disclosure |
| Application architecture | `rails-architecture`, `rails-staff-principal-architecture` | 266 / 185 | 0 / 0 | `rails` (28 cases) | 6+ | 1 (new in iter 176) | Strong — iter 175 + 176 closed the cross-reference gap with the `the-rails-way` pattern |
| Background jobs + distributed systems | `rails-active-job`, `rails-distributed-systems`, `rails-event-driven-messaging` | 172 / 220+ / 170+ | 4 / 3 / 4 | `active-job` (4), `distributed-systems` (3), `event-driven-messaging` (4 in Iteration 183) | 8+ | 3 | Partial — dedicated contracts now exist, but messaging evaluations are static-only until a controlled campaign supplies empirical evidence |
| Performance + caching | `rails-performance`, `ruby-performance`, `rails-caching` | 302 / 302 / 352 | 4 / 0 / 0 | `performance` (2 cases) | 8+ | 2 | Partial — `rails-caching` is the largest skill without `references/`; memory profiling tools well-registered in `data/performance/tools.yml` |
| Security + authorization | `rails-security-engineering`, `rails-authorization`, `rails-authentication`, `rails-cross-boundary-authorization-security` | 392 / 271 / 281 / 166 | 0 / 0 / 5 / 0 | `security` (2 cases) | 12+ | 3 | Partial — `rails-authentication` is the model (5 refs); three other skills need `references/` |
| Testing + TDD | `rails-test-engineering`, `ruby-tdd-refactoring` | 233 / 174 | 6 / 1 | `test-engineering` (7 cases, including `rspec-request-contract`) | 21 | 1 | Fully covered — iter 153 + 159 closed the RSpec/betterspecs gap |
| Production operations | `rails-production-runtime`, `rails-observability`, `rails-release-engineering`, `rails-incident-engineering` | 272 / 214 / 446 / 334 | 0 / 0 / 0 / 0 | `runtime` (5 cases), `observability` (4 cases) | 15+ | 4 | Partial — three of four skills lack `references/`; Solid Queue, Kamal, Solid Cache mentioned but not deep |

## Anti-patterns (what NOT to do)

The audit explicitly forbids these defaults:

| Approach | Better default |
|---|---|
| Creating a new `rails-sidekiq` skill to group Sidekiq operational concerns | Add a `sidekiq-adapter.md` reference under the existing `rails-active-job` skill; Active Job is the routing destination |
| Creating an `advanced-rails` umbrella skill to group "advanced" topics | Route to the focused skills; deepen them with `references/` instead of duplicating |
| Setting isolation levels globally in `database.yml` | Use per-transaction `transaction(isolation: :serializable)` with retry |
| Adding a Sidekiq eval family that tests Sidekiq-specific retry/discard | Test Active Job's retry contract; Sidekiq is the adapter, not the boundary |
| Adding an eval family for every advanced topic without measuring abort rate | Measure first; only add a dedicated eval family when the generic `rails/` family does not exercise the contract |
| Treating "skill exists" as "skill is ready for advanced work" | Apply the 4-step audit hierarchy; depth signal + eval family + subtopic grep are required |

## Example: auditing the Sidekiq gap (this pack, pre-iter-179)

The audit was applied to the Sidekiq topic before iter 179 added `skills/rails-active-job/references/sidekiq-adapter.md`:

1. **Routing destination** — `rails-active-job` exists. ✓
2. **Depth signal** — `rails-active-job/references/` had 4 files, none Sidekiq-specific. ✗
3. **Behavioral-validation signal** — `evals/active-job/` has 4 cases (concurrency-control, idempotent-side-effect, retry-policy, transactional-enqueue), none Sidekiq-specific. ✗
4. **Advanced-subtopic coverage** — grep for `sidekiq_options`, `Sidekiq::Web`, `redis-client`, `pg_advisory`, `sidekiq-cron` returns only the generic `data/active_job/tools.yml` registration. ✗

Verdict before iter 179: Sidekiq operational surface is **missing** despite the routing destination existing. The correct fix (per the anti-pattern table) is **not** a new skill — it is a reference file under the existing `rails-active-job` skill. Iter 179 added `sidekiq-adapter.md` exactly this way.

## Failure modes

- Treating the audit as a one-time event rather than a re-runnable pattern. Re-run after every iteration that adds content; the matrix drifts.
- Using the audit to justify a new skill when an existing skill already owns the boundary. The audit's job is to identify gaps, not to prescribe new routing destinations.
- Counting eval files instead of eval cases. A family with 1 file and 7 cases is stronger than a family with 5 files and 0 cases.
- Treating `references/` count as depth. A `references/` dir with one 50-line file is weaker than no `references/` dir and a 350-line SKILL.md. Inspect file sizes too.
- Skipping the advanced-subtopic grep. The skill may activate on "isolation behavior" without ever covering isolation levels.
- Setting isolation levels globally based on the audit's recommendation. The audit identifies the gap; per-transaction isolation is the right granularity.

## Testing

The audit pattern itself is exercised by the system-test suite. To audit a downstream Rails project's skill pack, run:

```bash
# Live counts
find skills -maxdepth 2 -type d -name references | wc -l
find evals -mindepth 1 -maxdepth 1 -type d | xargs -I{} sh -c 'echo "{}: $(ls {} | wc -l) files, $(grep -c "^  - name:" {}/*.yml | awk -F: "{s+=\$2} END {print s}") cases"'

# Advanced subtopic coverage
grep -ril "sidekiq_options\|pg_advisory\|outbox\|saga\|LISTEN\|NOTIFY\|materialized view\|BRIN\|GIN index\|Fiber.scheduler" \
  --include="*.md" --include="*.yml" --include="*.rb" .

# Canonical validation
bash bin/validate
```

The audit's counts must match `bin/validate`'s counts. If they don't, the audit is stale or the validator has drifted.

## Review checklist

- [ ] Every advanced topic in the matrix has a routing destination (skill exists)
- [ ] Each deep skill (250+ lines) has a `references/` dir or has been deliberately kept as a single SKILL.md (documented)
- [ ] Each advanced topic with deep content has a dedicated eval family (not only the generic `rails/` family)
- [ ] The advanced-subtopic grep finds expected strings (e.g. `pg_advisory`, `outbox`, `saga`, `LISTEN`, `Fiber.scheduler`) somewhere in the corpus
- [ ] New skills are only proposed when no existing skill owns the boundary
- [ ] The audit has been re-run after the latest iteration (matrix is not stale)
- [ ] Counts match `bin/validate`'s reported inventory

## Related skills
rails-architecture, rails-database-engineering, rails-active-job, rails-distributed-systems, rails-reliability-engineering, rails-event-driven-messaging, rails-caching, rails-authorization, rails-security-engineering, rails-production-runtime, rails-observability, stack-minimality
