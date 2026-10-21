# Single-File or Snippet Review

The unit of review is one file or pasted snippet, not a whole PR. Read the entire target, then inspect callers, tests, schema, configuration, and neighboring conventions needed to understand its contract.

## Inputs and uncertainty

Capture the file path or snippet, the intended behavior, the relevant framework/runtime version, and specification source. If context is missing, perform a bounded best-effort review and list assumptions under Remaining Uncertainty. Ask only when the file cannot be identified or the missing fact materially changes the review.

## Procedure

1. State what the code should do from the specification, callers, and tests.
2. Read the entire file and trace direct callers and side effects.
3. Walk representative inputs: normal, nil/empty, invalid, boundary, and failure paths relevant to the code.
4. Identify the owner of each invariant and whether a different caller can bypass it.
5. Inspect tests for the target behavior. Determine whether they would fail for a plausible defect.
6. Use an independent AI challenger only after your initial hypotheses are recorded.
7. Validate each candidate against a real line and concrete execution path.
8. Report Standards and Specification separately; if there is no specification, state that explicitly.

## Report

For each finding include severity, classification, line, preconditions, concrete scenario, impact, violated contract, evidence, and the smallest reasonable correction or regression test. Label unverified hypotheses and do not present them as confirmed defects.

Do not claim the whole system is safe based on one file. State which callers, tests, and boundaries were inspected and which remain unknown.
