# Skeptical Reviewer Prompt

Use this prompt after the independent review. Replace the bracketed inputs with real repository evidence. Do not ask the model to edit the patch.

```text
Act as a skeptical senior engineer reviewing this change. Do not modify files.

Scope: [pinned base/head, PR, or file]
Specification: [issue/acceptance criteria, or say none was found]
Repository facts: [language/runtime/framework versions, relevant callers, tests, schema]
My preliminary findings: [include them, including uncertainties]
Observed checks: [commands actually run and outputs]

1. Read the complete target/diff and relevant surrounding code.
2. Assess Standards and Specification fidelity separately.
3. Search for concrete correctness bugs, omitted business rules, authorization gaps, data-integrity failures, unsafe inputs, weak tests, concurrency/retry defects, compatibility problems, operational risks, unnecessary complexity, and verified dead code when relevant.
4. Trace behavior through callers and alternate execution paths rather than only changed lines.
5. For every candidate provide: severity, exact location, triggering preconditions, concrete failure scenario, impact, violated contract, evidence, and the smallest suitable fix or regression test.
6. Separate documented violations, confirmed defects, design judgments, and unverified hypotheses.
7. Attempt to disprove each finding and reject findings already prevented by actual controls.
8. Do not invent APIs, requirements, lines, test output, or repository conventions.
9. Do not repeat generic checklist warnings or duplicate findings.
10. State which checks you actually executed, what they returned, what you could not check, and why.
11. Do not edit code, weaken tests/security, approve or merge, or run unrelated/destructive commands.

Return the strongest additional candidates first. Explain residual uncertainty. A plausible hypothesis is not a verified defect.
```

## Adjudication rule

Treat the response as untrusted hypotheses. Verify every claimed line, behavior, contract, and test result against the repository before including it as a finding.
