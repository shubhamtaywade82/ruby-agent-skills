# Code Review Suite

## Purpose

`ai-code-review` is the repository's orchestration skill for risk-based Ruby/Rails review. It supports single-file/snippet review, PR/branch/diff review, and whole-repository audits. The skill enforces specification fidelity, evidence-backed findings, skeptical AI-assisted adjudication, explicit uncertainty, and a read-only review boundary.

## Design

- `ai-code-review` selects scope and coordinates review steps.
- `change-review` owns the two-axis Standards/Specification assessment.
- Existing Ruby/Rails owner skills remain authoritative for security, authorization, persistence, tests, asynchronous workflows, performance, and minimality.
- References under `skills/ai-code-review/references/` provide review-specific procedures, defect prompts, risk zones, comment examples, training, and a ledger template.
- Helper scripts under `skills/ai-code-review/scripts/` validate and format findings and gather repository/test context.

## Usage

Install the skill through the existing installer or the Agent Skills CLI:

```bash
bash bin/install --agent claude
```

Or install just this skill with the compatible CLI:

```bash
npx skills add shubhamtaywade82/ruby-agent-skills --skill ai-code-review -a claude-code
```

When reviewing a change, first establish the target and base/head. Read the specification and repository instructions. Complete the independent pass before using the skeptical reviewer prompt, adjudicate candidate findings against real code and observed tests, and report only evidence actually gathered.

Example report-tool commands (run from the installed skill directory):

```bash
python scripts/format_findings.py findings-input.json --output-dir review-output
python scripts/audit_findings.py audit-findings.json --output-dir audit-output
bash scripts/git_context.sh app/models/example.rb main
bash scripts/repo_inventory.sh
bash scripts/run_focused_tests.sh test/models/example_test.rb
```

The focused-test helper refuses to guess when the test runner cannot be identified. Follow the repository's documented command when it declines.

## Safety and limitations

- A clean review is not proof that code is defect-free. Report reviewed scope and residual uncertainty.
- Do not edit reviewed code while acting as reviewer.
- Do not run production/destructive operations or merge/release changes as part of a review.
- Treat AI output as hypotheses; validate it against the repository.
- Whole-repository audits must document sampling and exclusions rather than claiming unachievable exhaustive coverage.
