# TODO

Open items from the Iteration 149 recheck, verified against `origin/main` at `ccbf4bb` (Iteration 179) and PR #80 on GitHub. Completed items are omitted.

## Main branch health

- [ ] Restore a green `main`. The latest `Validate skills` run on `ccbf4bb` fails (run 38165049567). The only failing step is `test/corpus_quality_system_test.rb`: `evals/database/isolation-level.yml` has 4 cases with no benchmark campaign and no `coverage: static-only` label, so the audit reports `unbenchmarked: 1 files (4 cases)` and the test expects 0. Choose one: add campaign coverage, classify the file with a justified label, or change the test expectation. Then rerun the gate.
- [ ] Land the Iteration 180 branch `ccr-e296aa76-m5ev39` on `main` after the item above is resolved. It removes the duplicate `bin/validate` commands and adds the per-condition callback-cascade verification.
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
