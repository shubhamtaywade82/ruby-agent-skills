# Three-Pass Review Method

The reviewer must form independent hypotheses before using AI. AI is a challenger that broadens the search, not an authority that supplies the verdict.

## Pass A — Independent assessment

1. Read the specification, full target/diff, surrounding code, callers, tests, schema/configuration when relevant.
2. Summarize expected behavior and protected invariants in your own words.
3. Trace concrete execution paths with meaningful inputs and state transitions.
4. Write preliminary hypotheses, including questions where evidence is missing.
5. Check whether existing tests would catch the defects you suspect.

## Pass B — AI challenge

Supply the pinned scope, specification, repository facts, relevant domain skills, preliminary hypotheses, and observed test output. Ask the model to identify additional failure scenarios and to challenge each preliminary finding. Explicitly require it not to modify files, invent repository facts, or present guesses as verified issues.

Ask it to consider omitted requirements, alternate callers, authorization, invalid input, boundary values, exceptions, concurrency, retries, persistence, public interfaces, and migration or deployment behavior where relevant.

## Pass C — Adjudication

For every candidate—human or AI-generated:

- Verify the file and line in the actual reviewed revision.
- Reconstruct a concrete precondition and execution sequence.
- Identify the violated specification, invariant, or documented contract.
- Inspect whether another control prevents the alleged failure.
- Seek confirming or refuting evidence with tests, a reproduction, call-site tracing, or tool output.
- Classify it as confirmed, hypothesis, or rejected.
- Remove duplicates and preferences without concrete impact.

Only confirmed findings belong in the confirmed-findings section. Unresolved questions go under uncertainty with the exact evidence needed to resolve them.

## Failure modes

- Consulting AI first and inheriting its blind spots.
- Asking AI to fix the code before the defect has been established.
- Accepting plausible but fabricated APIs, line numbers, requirements, or test results.
- Treating no findings as proof of safety.
- Re-running unchanged tests to create an impression of more evidence.

## Exit condition

The review is complete when scope is pinned, both assessments are recorded, findings are adjudicated and actionable, observed verification is honest, and material uncertainty is visible.
