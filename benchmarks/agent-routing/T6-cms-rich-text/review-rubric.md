# T6 Review Rubric

Score each axis 0-3. Justify any score below 3 with a quoted line from the diff
or transcript.

## Axis 1: Correctness (0-3)

- **3**: `body_html` renders as formatted rich text; null case renders nothing;
  no regressions to existing page behavior.
- **2**: Renders correctly but with a minor issue (e.g., missing key on a list,
  console warning).
- **1**: Renders but breaks an existing behavior (e.g., related-articles sidebar
  stops working).
- **0**: Does not render `body_html`, or renders it as a raw string.

## Axis 2: Skill adherence — security (0-3)

- **3**: HTML is sanitized through an explicit allowlist; rendering goes through
  a single branded site; no `dangerouslySetInnerHTML` outside that site.
- **2**: Sanitization present but allowlist is permissive (e.g., allows `style`
  attributes, `href` on any tag) or no branded type.
- **1**: Sanitization attempted but bypassable (e.g., denylist approach, or
  sanitization only on some render paths).
- **0**: Raw `dangerouslySetInnerHTML`, or no sanitization.

## Axis 3: Routing (0-3)

- **3**: Agent explicitly invokes `react-frontend-security` (or, pre-skill,
  synthesizes equivalent rules and cites them in the transcript).
- **2**: Agent invokes a related skill (`react-component-engineering`) and
  addresses security without naming the security skill.
- **1**: Agent addresses security ad hoc, no skill reference.
- **0**: Agent does not recognize the security boundary at all.

## Axis 4: Ambient awareness (0-3) — T6-specific axis

- **3**: Agent identifies at least two of D1/D2/D3 and either fixes or explicitly
  flags them in the transcript or a follow-up note.
- **2**: Agent identifies one of D1/D2/D3.
- **1**: Agent touches one of the ambient files but does not articulate why.
- **0**: Agent tunnel-visions on `ArticlePage.tsx` and ignores the surrounding
  code.

## Axis 5: Test coverage (0-3)

- **3**: Adds a test that asserts sanitized output (e.g., script tag in input is
  stripped in output) and a test for the null case.
- **2**: Adds a smoke test that renders `body_html` but does not assert
  sanitization.
- **1**: Adds a test that does not exercise the new behavior.
- **0**: No tests added.

## Composite

Sum the five axes (max 15). Convert to 0-12 for cross-task comparability:

```
normalized = round(score * 12 / 15)
```

## Scoring the baseline (pre-skill) run

When T6 is run against current `main` (no `react-frontend-security` skill), the
expected baseline outcomes are:

- **Routing**: near 0. The agent cannot invoke a skill that doesn't exist. The
  interesting question is whether it *synthesizes* equivalent rules. Most
  current agents will produce `dangerouslySetInnerHTML` with no sanitization,
  or with a naive `DOMPurify.sanitize()` call inline — neither matches the
  skill's single-site, branded-type rule.
- **Skill adherence (security)**: typically 1 — sanitization attempted but
  bypassable or unbranded. Rarely 0 (most agents know raw HTML is risky),
  rarely 2 or 3 (the single-site rule is non-obvious without the skill).
- **Ambient awareness**: typically 0-1. Agents tunnel-vision on the named file.

After `react-frontend-security` ships, the re-run should show:

- **Routing**: 3 (skill exists and is invoked).
- **Skill adherence**: 2-3 (single-site + branded type + allowlist).
- **Ambient awareness**: 1-2 (the skill's CSP / `target="_blank"` / source-map
  rules prompt the agent to look at the surrounding code).

That delta — baseline vs. post-skill — is the empirical evidence that the skill
changed agent behavior. If the delta is small, the skill is not pulling its
weight and needs revision. If the delta is large, the skill is doing its job.
