---
name: react-e2e-testing
description: Use when writing or repairing browser end-to-end tests (Playwright) for a React/TypeScript client served by or talking to a Rails backend — booting the Rails server for the suite, seeding data, reusing an authenticated session, choosing locators, injecting network failures, and diagnosing flaky runs.
---

# React End-to-End Testing

## Purpose
Prove user journeys through a real browser, a real Rails server, and a real database, with results that are deterministic under parallel workers and that fail when the production contract breaks. Component and hook behavior stays with `react-testing-engineering`; Rails-rendered UI tested with Capybara stays with `rails-test-engineering`.

Composes with:
- `rails-react-integration` for the CSRF, session, and 422 contracts the journeys cross;
- `rails-authentication` for the sign-in flow the setup project drives;
- `react-accessibility-performance` for the accessible names the locators depend on.

## Activate when
- adding a Playwright test for a login, checkout, form, or other multi-page journey;
- a React client must be proven against the running Rails server rather than mocks;
- E2E tests are flaky, slow, order-dependent, or pass while production is broken;
- setting up Playwright in CI for a Rails + React repository.

## Repository inspection
- Existing E2E tooling: `playwright.config.*`, `@playwright/test` in `package.json`, `e2e/` or `tests/`; Capybara system tests in `test/system` or `spec/system` and their driver (Selenium, Cuprite). Extend what exists; do not add a second browser framework.
- How Rails boots for tests: `config/environments/test.rb` (note `allow_forgery_protection = false` there by default), `config/database.yml`, `bin/dev`/`Procfile`, and the health route (`/up` in Rails 7.1+).
- How assets are built (`vite_ruby`, `jsbundling-rails`, esbuild, importmap) and whether the suite must build before the server starts.
- Authentication flow and any existing seed or factory entry points (`db/seeds.rb`, `bin/rails runner` scripts).
- CI: runner image, browser install step, artifact upload, and whether retries are configured.

## Decision rules
- **Framework.** If Rails renders the UI and the repository already runs Capybara system tests, extend them under `rails-test-engineering`. Use Playwright when it is already present or the React client is a separate application.
- **Environment.** Run the server in a dedicated `e2e` Rails environment that loads `test.rb` and turns `allow_forgery_protection` back on. Under `RAILS_ENV=test`, a client that never sends `X-CSRF-Token` passes every browser test. Give it its own database. A custom environment gets no generated `secret_key_base`, because Rails 8.0 generates `tmp/local_secret.txt` only when `Rails.env.local?`. Set `SECRET_KEY_BASE_DUMMY` in `e2e.rb` rather than committing a secret.
- **Server lifecycle.** Playwright's `webServer` starts Rails, waits on the health URL, and builds assets first. Set `reuseExistingServer: !process.env.CI`, so CI always boots a fresh server.
- **Data.** The browser and the server are separate processes, so transactional rollback cannot isolate tests. Seed through Rails itself (`bin/rails runner`, seeds) from a setup project. Every test creates data only it can match, for example text containing `test.info().testId`, and never asserts on totals or truncates tables while workers run. Do not add a test-only HTTP route for seeding. If one is unavoidable, mount it only in the `e2e` environment and prove it is absent in production.
- **Authentication.** Sign in once through the real form in a setup project and save `storageState`. Authenticated projects depend on it; anonymous journeys run in a project without it. Keep `playwright/.auth/` out of Git and use test-only credentials.
- **Locators.** Use `getByRole` with an accessible name. `getByLabel` and `getByText` match substrings unless `exact: true`: a label "Note" also matches `aria-label="Notes"` and fails strict mode. Use `data-testid` only for elements with no accessible name. Never use CSS classes or XPath for behavior.
- **Waiting.** Use web-first assertions (`await expect(locator).toBeVisible()`, `toHaveURL`, `toHaveValue`) that retry. Never use `waitForTimeout` or fixed sleeps.
- **Network.** Use `page.route` only to inject failures the real server cannot produce on demand (503, timeouts) or to stub third-party origins. Stubbing your own Rails API turns the test into a slower component test. Call `route.fallback()` for requests you do not handle.
- **Flakes.** Allow one retry in CI to capture a trace (`trace: "on-first-retry"`) and set `failOnFlakyTests` so a pass-on-retry still fails the run. Diagnose from the trace; never raise retries or timeouts to get green.
- **Guard the environment.** Keep one test that proves a write without a CSRF token is rejected, so a later configuration change cannot silently disable the protection the suite relies on.

## Implementation procedure
1. Name the journey and its observable outcomes (URL, visible text, persisted state after reload).
2. Add or confirm the `e2e` environment, database, health route, and `webServer` command.
3. Seed accounts idempotently through Rails in the setup project, sign in through the UI, and save `storageState`.
4. Write each test with role-based locators, unique data, and web-first assertions. Cover the success path, a Rails validation failure, and an injected server failure.
5. Add the CSRF guard test if the suite has none.
6. Run the suite with CI settings (`CI=1`) locally, then break the contract on purpose (drop the CSRF header, stop mapping the 422) and confirm a test fails.
7. In CI, install the browser version that matches `@playwright/test`, and upload the HTML report and traces as artifacts.

## Anti-patterns / failure modes
- running E2E against `RAILS_ENV=test` with CSRF protection off;
- stubbing the application's own API with `page.route` and calling it end-to-end;
- signing in through the UI in every test instead of reusing `storageState`;
- shared records, fixed emails, or count assertions across parallel workers;
- `page.waitForTimeout`, `sleep`, or raised timeouts to hide races;
- CSS-class or XPath selectors, and substring label matches that pick the wrong element;
- test-only seeding routes that ship to production;
- CI retries without `failOnFlakyTests`, which hide flakes as passes;
- committing `playwright/.auth/*.json` session files.

## Reference example

Runs green with `@playwright/test` 1.63 against Rails 8.0.5.1 (Puma, SQLite) and a React 19 island bundled with esbuild, including 3 repetitions across 3 workers. The config and specs type-check with `tsc --strict`, `noUncheckedIndexedAccess`, and `exactOptionalPropertyTypes`. Dropping `X-CSRF-Token` from the client fails two tests. With the same broken client, `RAILS_ENV=test` passes every UI test, and only the CSRF guard fails.

```ruby
# config/environments/e2e.rb — plus an e2e: entry in config/database.yml
require_relative "test"

# Rails generates tmp/local_secret.txt only for development and test; opt this
# throwaway environment into the same mechanism instead of committing a secret.
ENV["SECRET_KEY_BASE_DUMMY"] ||= "1"

Rails.application.configure do
  config.action_controller.allow_forgery_protection = true
end
```

```ts
// playwright.config.ts
import { defineConfig, devices } from "@playwright/test";

const port = Number(process.env.E2E_PORT ?? 3100);
const baseURL = `http://127.0.0.1:${port}`;

export default defineConfig({
  testDir: "e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0, // only to capture a trace
  failOnFlakyTests: !!process.env.CI, // a pass-on-retry still fails
  use: { baseURL, trace: "on-first-retry", screenshot: "only-on-failure" },
  projects: [
    { name: "setup", testMatch: /.*\.setup\.ts/ },
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"], storageState: "playwright/.auth/user.json" },
      dependencies: ["setup"],
      testIgnore: /.*\.anonymous\.spec\.ts/,
    },
    { name: "chromium-anonymous", use: { ...devices["Desktop Chrome"] }, testMatch: /.*\.anonymous\.spec\.ts/ },
  ],
  webServer: {
    command: `npm run build && bin/rails db:prepare && bin/rails server -p ${port} -b 127.0.0.1`,
    env: { RAILS_ENV: "e2e" },
    url: `${baseURL}/up`,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
```

```ts
// e2e/notes.spec.ts — runs in the authenticated "chromium" project
import { expect, test } from "@playwright/test";

// Workers share one database, so each test writes data only it can match.
function uniqueBody(label: string): string {
  return `${label} ${test.info().testId} ${Date.now()}`;
}

test.beforeEach(async ({ page }) => {
  await page.goto("/notes");
});

test("adds a note that survives a reload", async ({ page }) => {
  const body = uniqueBody("Buy milk");
  await page.getByRole("textbox", { name: "Note" }).fill(body);
  await page.getByRole("button", { name: "Add note" }).click();

  const notes = page.getByRole("list", { name: "Notes" });
  await expect(notes.getByRole("listitem").filter({ hasText: body })).toBeVisible();
  await page.reload();
  await expect(notes.getByRole("listitem").filter({ hasText: body })).toBeVisible();
});

test("shows the Rails validation error on the field", async ({ page }) => {
  await page.getByRole("button", { name: "Add note" }).click();

  const field = page.getByRole("textbox", { name: "Note" });
  await expect(field).toHaveAttribute("aria-invalid", "true");
  await expect(field).toHaveAccessibleDescription("Note can't be blank");
});

test("reports a server failure without losing the draft", async ({ page }) => {
  await page.route("**/notes", (route) =>
    route.request().method() === "POST" ? route.fulfill({ status: 503 }) : route.fallback(),
  );
  const body = uniqueBody("Draft");
  await page.getByRole("textbox", { name: "Note" }).fill(body);
  await page.getByRole("button", { name: "Add note" }).click();

  await expect(page.getByRole("alert")).toHaveText("Could not save note. Try again.");
  await expect(page.getByRole("textbox", { name: "Note" })).toHaveValue(body);
});

test("the e2e server rejects a write without a CSRF token", async ({ page }) => {
  const response = await page.request.post("/notes", {
    headers: { Accept: "application/json" },
    data: { note: { body: uniqueBody("forged") } },
  });
  expect(response.status()).toBe(422);
});
```

The setup project (`e2e/auth.setup.ts`) runs `bin/rails runner e2e/seed_user.rb` with `RAILS_ENV=e2e` to upsert the account, signs in through the form, and calls `page.context().storageState({ path: "playwright/.auth/user.json" })`. The `e2e-authenticated-storage-state` pattern holds the full file.

## Agent review checklist
- Does the server run in an environment with CSRF protection on, and does a guard test prove it?
- Is data unique per test, with no count assertions and no mid-run truncation?
- Is sign-in done once through the UI, with `storageState` ignored by Git?
- Are locators role-based with exact accessible names?
- Is every wait a web-first assertion, with no timeouts or sleeps?
- Is `page.route` used only for failure injection or third-party origins?
- Do CI retries capture traces while `failOnFlakyTests` keeps flakes red?
- Was a deliberate contract break observed to fail the suite?

## Verification
Run `npx playwright test` with `CI=1` so the CI settings apply. Run `tsc --noEmit` on the config and specs. Introduce one contract break (drop the CSRF header or the 422 mapping) and confirm a test fails before calling the suite effective. Report the Playwright and browser versions used.

## Source foundation
- Playwright: https://playwright.dev/docs/intro
- Playwright authentication: https://playwright.dev/docs/auth
- Playwright web server: https://playwright.dev/docs/test-webserver
- Playwright locators: https://playwright.dev/docs/locators
- Playwright network: https://playwright.dev/docs/network
- Rails configuration (forgery protection): https://guides.rubyonrails.org/configuring.html
