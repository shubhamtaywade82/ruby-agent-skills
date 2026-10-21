# Review Ledger Template

Use one record per review exercise. Preserve both the initial independent judgment and the adjudicated result.

| Field | Value |
|---|---|
| Review ID / PR | |
| Date / reviewer | |
| Scope and base/head | |
| Specification source | |
| Change risk class | |
| Findings before AI | |
| AI-only candidates | |
| Confirmed findings | |
| Rejected findings and why | |
| Known seeded defects, if exercise | |
| Seeded defects detected | |
| False positives | |
| Missed defects | |
| Severity calibration notes | |
| Checks actually run | |
| Checks not run and why | |
| Learning note / new checklist item | |

## Metrics for a known-answer exercise

- **Precision** = confirmed findings / all findings reported.
- **Recall** = known seeded defects detected / all known seeded defects.
- Track high-severity recall separately.
- Track false positives and severity over-rating separately.
- Record a missed defect's cause: scope not inspected, wrong mental model, missing domain knowledge, weak test review, or over-reliance on AI.

These metrics are meaningful only when the exercise has a reliable answer key and the evaluation scope is fixed. Do not interpret a low count of findings as quality by itself.
