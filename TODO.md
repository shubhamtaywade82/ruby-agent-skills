# TODO

Open items from the Iteration 149 recheck, verified against `origin/main` at `ccbf4bb` (Iteration 179) and PR #80 on GitHub. Completed items are omitted.

## Main branch health

- [ ] Restore a green `main`. The latest `Validate skills` run on `ccbf4bb` fails (run 38165049567). The only failing step is `test/corpus_quality_system_test.rb`: `evals/database/isolation-level.yml` has 4 cases with no benchmark campaign and no `coverage: static-only` label, so the audit reports `unbenchmarked: 1 files (4 cases)` and the test expects 0. Choose one: add campaign coverage, classify the file with a justified label, or change the test expectation. Then rerun the gate.
- [ ] Merge PR #100 (`ccr-e296aa76-m5ev39`, Iteration 180) into `main` after the item above is resolved. It is open. It carries the per-condition callback-cascade verification, the exactly-once scope narrowing, and the duplicate-command removal. It removes the duplicate `bin/validate` commands and adds the per-condition callback-cascade verification.
- [ ] Confirm the post-merge result for Iteration 149 (`d349a12`). The recheck reported the run as in progress, but that run is not among the five most recent `main` runs, so its result is unverified.

## PR #80 (Iterations 144–148)

- [ ] Treat PR #80 as closed, not open. It is closed and unmerged (closed 2026-10-03). Its head `4b4938e` is not an ancestor of `main`, and 233 of its commits are missing from `main`. Do not merge it as-is.
- [ ] Decide whether to re-land Iterations 144–148 as a new PR from current `main`, or record them as superseded. Some of their artifacts already exist on `main` (for example the frontmatter, validation-gate integrity, deprecation governance, and framework drift tests), so compare file by file before porting.
- [ ] If re-landed, run the full `bin/validate` gate on the combined tree.

## Validation coverage and documentation

- [ ] Register or retire two unscheduled tests. `test/react_agent_skills_deprecation_test.rb` (5 runs) and `test/version_constraint_test.rb` (9 runs) both pass, but neither appears in `bin/validate` or any workflow.
- [ ] Remove the duplicate `bin/validate` invocations on `main`: `scripts/audit_documentation_consistency.rb` and `test/routing_release_bundle_system_test.rb` each run twice. The fix is in `41e12aa` on the Iteration 180 branch, not on `main`.
- [ ] Update stale README counts. Line 36 says "448-pattern catalog" (current: 450). Line 516 says "502 cases" (current: 506).
- [ ] Update stale `docs/IMPLEMENTATION_HANDOFF.md` line 27. It says "138 evaluation files / 502 cases" (current: 139 / 506).
- [ ] Do a manual provenance review. The automated provenance audit passes, but nothing checks prose that still describes the pre-Iteration-149 repository state.

## Scheduled recheck

- [ ] Confirm the "Recheck Ruby Agent Skills" scheduled task is active. The session's `CronList` reports no scheduled jobs, and `list_triggers` with `enabled: true` returns none. The task may be stored by the Cowork desktop app, which these tools don't list. Check it there, and confirm its prompt covers the open items in this file.

## Release record

- [ ] Correct the Iteration 162 changelog entry in `CHANGELOG.md`. It still says `v1.2.0` has no attached archive and that its repair path remains open. The manual Release workflow published `ruby-agent-skills-v1.2.0.tar.gz` (791135 bytes, SHA-256 `7dd3d4d8…`) and `SHA256SUMS` on 2026-10-09. Add a follow-up note; do not rewrite the historical entry.

## Cross-pack documentation

- [ ] Correct `docs/INSTALLATION.md` line 97. It says "nine deprecated in-pack React/TypeScript skills share a directory name" with their replacements. The collision set is eight names: `agent-workflow` plus seven deprecated frontend skills. `react-state-effects` and `react-accessibility-performance` map to different replacement names, so they do not collide.

## Coding adapters (Iteration 173)

- [ ] P1: Remove or gate the unsafe coding defaults in `lib/ruby_agent_skills/headless_commands.rb`. Cursor coding passes `--force --trust --sandbox disabled`. Antigravity coding passes `--dangerously-skip-permissions`. OpenCode coding passes `--auto --standalone`. Make permission bypass an explicit operator opt-in, and prefer each provider's sandboxed mode.
- [ ] P1: Require a disposable container or VM with no host credentials, sensitive mounts, or unneeded network access for automated coding campaigns. Document the residual risk for each provider separately.
- [ ] P1: Add tests that assert the configured safety mode for each adapter and fail if an adapter silently becomes less restrictive. The current tests check argv only, not confinement.
- [ ] P1: Run a one-case routing smoke test and a one-case coding smoke test against each live provider before any campaign. Record the CLI version, exact model identifier, full invocation, exit status, sanitized output, validation result, and evidence that the agent did not access the verifier or reference solution. This environment has `claude` installed but not `cursor`, `agent`, `agy`, or `opencode`, so these runs must happen where those CLIs are authenticated.

## Routing output validation (Iteration 173)

- [ ] P2: In `lib/ruby_agent_skills/headless_output.rb`, `write_result` still normalizes `secondary_skills` with `Array(...).map(&:to_s)`, so a bare string is accepted. Validate the response shape before normalization: `primary_skill` is a non-empty string, `secondary_skills` is an array of strings, and `reason` is a non-empty string. `ROUTING_SCHEMA` is only passed to the CLI as `--json-schema`; nothing enforces it on the response.
- [ ] P2: Add malformed-response regression tests for every provider (cursor, antigravity, opencode).

## Provenance

- [ ] P2: Pin the `addyosmani/agent-skills` commit SHA used for the 25-skill reconciliation in `docs/SOURCE_COVERAGE.md` (external section, around line 204). No SHA is recorded.

## Benchmark integrity (Iteration 174)

- [ ] Link the bulk-import behavior modeled by the callback-cascade fixture to the official Rails `insert_all` API documentation. No such link exists on `main`.
- [ ] After PR #100 merges, confirm the negative controls still fail for their intended reasons and the exactly-once scope is recorded as successful-path only. Crash and retry recovery remains out of scope and unmodeled.

## Roadmap (issue #94)

- [ ] P0: Build the repository fact gate: a pre-activation manifest that classifies facts as observed, derived, inferred, or unknown, and blocks implementation when task-critical facts are missing. No such contract exists on `main`.
- [ ] P0: Write the unified execution-control contract covering destructive-command approval, credential and network access, checkpointing and recovery, verified undo of failed multi-file changes, token/tool-call/runtime/context budgets, and reproducibility and decision provenance. No such contract exists on `main`.
- [ ] P0: Add the six remaining adversarial fixtures, each with visible tests, withheld checks, controls, and routing regressions: unsafe migration, context/schema hallucination, RSpec isolation failure, STI and polymorphic boundaries, replica/shard consistency, and the agent context gate.
- [ ] P2: Run the real routing and coding campaigns with exact provider and model metadata. Run the baseline-versus-skills experiments, the multi-model campaign, and the hidden benchmark, and publish the reproducible evidence separately from static validation.
