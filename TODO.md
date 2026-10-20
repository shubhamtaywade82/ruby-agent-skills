## Current work — Iteration 183

- [x] Register four event-driven messaging evaluation contracts: envelope/schema compatibility, consumer idempotency and acknowledgement ordering, bounded retry/dead-letter/replay, and ordering/consumer capacity.
- [x] Refresh the advanced Rails coverage matrix so it recognizes the new dedicated messaging evaluation family.
- [ ] Run `bash bin/validate` and `bundle exec rubocop` in a repository checkout; update inventory counts from actual validator output if the audit reports different numbers.
- [ ] Replace static-only messaging contracts with controlled fixture/reference campaigns before claiming empirical model performance.
- [ ] Recheck remaining messaging-specific coverage against the owning skill and patterns; do not create duplicate skills where existing routing ownership is clear.

# TODO

Historical recheck notes from Iterations 149–174 are retained below. Current repository state was refreshed for Iteration 183; do not treat historical branch/PR statuses in older entries as current.

Legend:
- `[x]` done. Items marked "on branch" are committed here and reach `main` when PR #100 merges.
- `[ ]` open. Each open item says whether it is blocked and by what.

## Main branch health

- [x] PR #100 is merged into `main` (verified from GitHub; Iteration 180 is present in the current changelog).
- [x] Current main has progressed through Iteration 182; the current inventory and evaluation families must be taken from the manifest and current validation output, not the older iteration notes.
- [ ] Run the full local validation gate against the Iteration 183 branch and preserve the result in the pull request. This execution environment can edit GitHub files but does not provide the repository checkout and runtime needed to claim `bin/validate` passed.

## PR #80 (Iterations 144–148)

- [x] Treat PR #80 as closed, not open. Verified closed and unmerged; its 233 commits are not on `main`.
- [x] Decide whether to re-land Iterations 144–148. Decision: superseded, not re-landed. All 43 files it touches exist on `main`. The 20 identical files and the 23 changed ones carry its added lines, or later replacements of them. The Iteration 144–148 entries are in `docs/ITERATIONS.md` and `CHANGELOG.md`.
- [x] If re-landed, run the full gate. Not applicable: nothing was re-landed.

## Validation coverage and documentation

- [x] Register or retire the two unscheduled tests. Done on branch. `test/react_agent_skills_deprecation_test.rb` and `test/version_constraint_test.rb` are in `bin/validate`. `audit_repository_completeness.rb` now requires every `test/*_test.rb` file to be invoked.
- [x] Remove the duplicate `bin/validate` invocations. Done on branch. No duplicate `ruby` commands remain, and `test/validation_gate_integrity_system_test.rb` rejects new ones.
- [x] Update stale README counts. Done on branch. README now says 450 patterns, 506 cases, and 108 system tests.
- [x] Update stale `docs/IMPLEMENTATION_HANDOFF.md` line 27. Done on branch. It now says 139 files / 506 cases, with the unbenchmarked exception stated.
- [ ] Do a manual provenance review. Partly done: a scan of the README, `RELEASE.md`, `docs/INSTALLATION.md`, `docs/PUBLISHING.md`, and `docs/SOURCE_COVERAGE.md` for present-tense claims found no stale ones. The handoff's Iteration 155 bullet now carries the v1.2.0 archive follow-up. Still open: the Iteration-level prose in `docs/ITERATIONS.md` and `CHANGELOG.md` is historical and was not reviewed line by line.

## Scheduled recheck

- [ ] Confirm the "Recheck Ruby Agent Skills" scheduled task is active. Blocked: `CronList` reports no jobs and no enabled routines are listed. The task may be stored by the Cowork desktop app, which these tools don't list. Check it in that app.

## Release record

- [x] Correct the Iteration 162 changelog entry. Done on branch. A follow-up bullet records that the v1.2.0 archive and `SHA256SUMS` were published on 2026-10-09. The original text is kept.

## Cross-pack documentation

- [x] Correct the `docs/INSTALLATION.md` collision wording. Done on branch. It now names the eight pinned collisions and the two deprecated skills that do not collide.

## Coding adapters (Iteration 173)

- [x] P1: Gate the unsafe coding defaults. Done on branch. Cursor, Antigravity, and OpenCode coding adapters refuse to start unless `RUBY_AGENT_UNSANDBOXED_CODING=1` is set exactly. The check runs before any CLI process starts. The bypass flags are unchanged inside the gate. Making coding use the providers' sandboxed modes is open: it needs live CLI verification (see the live smoke-test item).
- [x] P1: Document the disposable-environment requirement and residual risk. Done on branch in `docs/LOCAL_BENCHMARKING.md`, with a per-provider table, and linked from `docs/AGENT_ADAPTER_PROTOCOL.md`.
- [x] P1: Add tests for the safety gate. Done on branch. Tests assert that coding refuses without the opt-in, that the opt-in must be exactly `1`, and that refusal happens before the CLI is invoked. The tests do not prove filesystem confinement, which no adapter-level test can establish.
- [ ] P1: Run one-case live smoke tests for each provider. Blocked: this sandbox has `claude` but not `cursor`, `agent`, `agy`, or `opencode`, and no provider is authenticated here. Run it where those CLIs are installed and logged in, and preserve CLI version, model id, invocation, exit status, sanitized output, validation result, and verifier-isolation evidence.

## Routing output validation (Iteration 173)

- [x] P2: Validate response shape before normalization. Done on branch. `lib/ruby_agent_skills/headless_selection.rb` requires a non-empty string primary skill, an array of strings for secondary skills, and a non-empty reason. It replaces the `Array(...).map(&:to_s)` coercion.
- [x] P2: Add malformed-response regression tests for every provider. Done on branch. Eight malformed cases run against cursor, antigravity, and opencode, and each must fail without writing a result file.

## Provenance

- [ ] P2: Pin the `addyosmani/agent-skills` commit SHA. Blocked: the external pack is not installed in this sandbox (`~/.agents/skills` is absent), and no SHA is recorded anywhere in the repository. The SHA has to come from wherever the pack was installed.

## Benchmark integrity (Iteration 174)

- [x] Link the modeled bulk-import behavior to official Rails documentation. Done on branch. The eval's provenance comment cites the Rails 8.1.4 guide, "Active Record Callbacks", section "Skipping Callbacks", which names `insert_all`. The API reference page I checked does not document `insert_all`, so I did not link to it.
- [ ] After PR #100 merges, confirm the negative controls and the scope wording on `main`. Blocked on the merge. On the branch, the per-condition test passes: reference passes both conditions, naive fails both, and partial fails only `import_skips_hooks`. The eval title and prompt state successful-path scope only.

## Roadmap (issue #94)

- [x] P0: Build the repository fact gate. Done on branch. `lib/ruby_agent_skills/fact_manifest.rb` evaluates the four fact classes and blocks on task-critical inferred or unknown facts. `skills/agent-workflow/references/fact-gate.md` documents the contract. Limit: the library enforces the rule when a manifest is evaluated. Nothing in this repository makes an agent run it.
- [x] P0: Write the unified execution-control contract. Done on branch as `skills/agent-workflow/references/execution-control.md`, with six sections, each giving contract, mechanism, and evidence. It states which mechanisms this repository does not enforce, such as token budgets and host isolation.
- [ ] P0: Add the six remaining adversarial fixtures. Not started. Each needs a reference, withheld checks, negative controls, an eval contract, registration, and count updates. This is multi-day work and is not in this change.
- [ ] P2: Run the real routing and coding campaigns, baseline-versus-skills experiments, the multi-model campaign, and the hidden benchmark. Blocked: this needs authenticated provider CLIs and model access, which this environment does not have.
