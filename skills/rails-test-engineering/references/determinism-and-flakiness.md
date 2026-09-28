# Determinism, flaky tests, order, and time

Reference for the `rails-test-engineering` skill. Load it on demand when a test is flaky or order-dependent, or depends on time, time zones, randomness, or external state. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Determinism
A deterministic test should not depend on:
- sleep durations;
- wall-clock time;
- random values without controlled seeds;
- global mutable state;
- test execution order;
- network availability;
- machine-specific filesystem layout;
- implicit timezone assumptions;
- leftover database records.

Use Rails time helpers such as travel_to when the behavior depends on current time. Rails documents ActiveSupport::Testing::TimeHelpers for this purpose.

Prefer condition-driven synchronization over sleeps.

## Flaky test diagnosis
Treat flakiness as a reproducibility problem.

Capture:
- exact test name;
- random seed;
- retry count;
- execution mode;
- parallel worker/thread configuration;
- environment/runtime versions;
- relevant logs;
- database state assumptions;
- network/time dependencies.

Then classify the source:

timing race
state leakage
order dependence
database transaction mismatch
parallel resource collision
timezone/clock issue
randomness
external dependency
environment/boot issue

Do not immediately add retries around flaky tests.

A retry can provide diagnostic information, but it does not prove the test is fixed.

## Test order
Tests should remain order-independent unless ordering is explicitly part of the contract.

Use randomized order where supported and investigate failures under the reported seed.

Never rely on a previous test to populate state used by a later test.

## Time and timezone
For time-sensitive behavior, control time explicitly.

Test both:
- application time zone;
- UTC/database serialization behavior where relevant.

Do not hard-code the machine's current timezone into tests.

Use boundary dates/times for daylight-saving-sensitive behavior where the application supports multiple time zones.
