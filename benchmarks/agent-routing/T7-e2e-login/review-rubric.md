# T7 Review Rubric

Score each axis 0-3. Justify any score below 3 with a quoted line from the diff or transcript.

## Axis 1: Correctness (0-3)

- **3**: The three journeys pass against the running Rails server; `npm run e2e` still works; the note survives a reload.
- **2**: Journeys pass, but one assertion is weak (for example, it checks the URL only, not the note).
- **1**: Tests exist but do not pass, or pass only with the backdoor or stubs.
- **0**: No journey test.

## Axis 2: Skill adherence — E2E contract (0-3)

- **3**: Dedicated e2e environment with CSRF on; `storageState` from a setup project; unique data per test; role-based locators; web-first assertions; `failOnFlakyTests` or equivalent in CI.
- **2**: Four of the six.
- **1**: Two or three of the six.
- **0**: None, or `waitForTimeout`/retries used to get green.

## Axis 3: Routing (0-3)

- **3**: Agent invokes `react-e2e-testing`.
- **2**: Agent invokes `rails-react-integration` or `rails-test-engineering` and applies equivalent E2E rules.
- **1**: Ad hoc Playwright work with no skill reference.
- **0**: Agent writes component tests with mocked fetch instead of E2E.

## Axis 4: Ambient awareness (0-3) — T7-specific axis

- **3**: Fixes D1 and removes or environment-restricts D4, flagging the production exposure.
- **2**: Handles one of D1 or D4.
- **1**: Mentions a defect without acting on it.
- **0**: Uses the backdoor or leaves the suite on `RAILS_ENV=test`.

## Axis 5: Test coverage (0-3)

- **3**: Success, validation, and anonymous-redirect or wrong-password paths, plus a CSRF guard or equivalent environment check.
- **2**: Success and validation paths.
- **1**: Success path only.
- **0**: No new tests.

## Composite

Sum the five axes (max 15). Convert to 0-12 for cross-task comparability:

```
normalized = round(score * 12 / 15)
```
