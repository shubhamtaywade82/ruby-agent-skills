# PR / Diff Review Mode

Use this mode for a pull request, branch, commit range, or diff. The unit of review is the change; inspect surrounding code to identify regressions introduced by it.

## Establish the boundary

- Resolve base and head commits; use merge-base semantics for branch review where appropriate.
- Record the changed-file list, commit summary, and full diff.
- If the intended base is ambiguous, ask rather than guessing.
- Read the issue/ticket and PR description. If no specification exists, mark Specification assessment unassessed.

## Procedure

1. Inspect repository instructions and working-tree status.
2. Read the complete diff and relevant callers, tests, schema, migrations, configuration, and API consumers.
3. Perform Pass A independently, then Pass B with the skeptical reviewer prompt, then Pass C adjudication.
4. Focus on defects introduced by the change, while noting pre-existing defects only when they materially affect the changed path.
5. Check regression coverage and run focused tests first; expand checks when risk justifies it.
6. Assess Standards and Specification separately.
7. Run minimality review only after correctness and security.
8. Produce findings using `scripts/format_findings.py`.

## Merge disposition

- **Changes requested:** at least one confirmed finding blocks merge under the repository's policy.
- **No actionable findings identified:** no confirmed actionable issue was found in the inspected scope; list residual uncertainty.
- **Review incomplete:** scope, specification, or required evidence could not be established.

Do not approve or merge the PR as a side effect of reviewing it.
