---
name: e2e-rails-server-environment
description: "Boot Rails for Playwright in a dedicated e2e environment that keeps CSRF protection on, with a health-checked webServer and a guard test."
family: react-typescript
---

# E2E Rails Server Environment

## Problem
Browser tests pointed at `RAILS_ENV=test` run with `allow_forgery_protection = false`, so a React client that never sends `X-CSRF-Token` passes the whole suite and fails in production. Suites that assume a server is already running also drift between machines and CI.

## Use when
Playwright drives a React client served by, or calling, a Rails application in the same repository.

## Do not use when
The UI is Rails-rendered and covered by Capybara system tests (see `system-test-contract`), or the client talks to a deployed environment rather than a locally booted server.

## Repository inspection
Inspect `config/environments/test.rb`, `config/database.yml`, the health route in `config/routes.rb`, the asset build command, and any existing `webServer` block in `playwright.config.ts`.

## Implementation procedure
1. Add `config/environments/e2e.rb` that requires `test`, turns `allow_forgery_protection` back on, and opts into the local secret. A custom environment otherwise fails at boot with "Missing `secret_key_base`".
2. Add an `e2e:` database entry so the suite never shares the unit-test database.
3. Point `webServer` at the build, `db:prepare`, and `rails server` commands with `RAILS_ENV=e2e`, and wait on `/up`.
4. Set `reuseExistingServer: !process.env.CI`.
5. Add a guard test that posts without a CSRF token and expects 422.

## Example

Runs green with `@playwright/test` 1.63 against Rails 8.0.5.1. With a client that omits the CSRF header, the UI tests fail under `e2e` and pass under `test`, where only the guard catches it.

```ruby
# config/environments/e2e.rb
# Test settings, but with the request protections a real browser exercises.
require_relative "test"

# Rails generates tmp/local_secret.txt only for development and test; opt this
# throwaway environment into the same mechanism instead of committing a secret.
ENV["SECRET_KEY_BASE_DUMMY"] ||= "1"

Rails.application.configure do
  config.action_controller.allow_forgery_protection = true
end
```

```ts
// playwright.config.ts (webServer excerpt)
webServer: {
  command: `npm run build && bin/rails db:prepare && bin/rails server -p ${port} -b 127.0.0.1`,
  env: { RAILS_ENV: "e2e" },
  url: `${baseURL}/up`,
  reuseExistingServer: !process.env.CI,
  timeout: 120_000,
},
```

```ts
// e2e/csrf-guard.spec.ts
import { expect, test } from "@playwright/test";

test("the e2e server rejects a write without a CSRF token", async ({ page }) => {
  const response = await page.request.post("/notes", {
    headers: { Accept: "application/json" },
    data: { note: { body: `forged ${test.info().testId}` } },
  });
  expect(response.status()).toBe(422);
});
```

## Failure modes
A custom environment that boots only on machines with `config/master.key`, reusing `RAILS_ENV=test`, sharing the unit-test database, reusing a stale local server in CI, waiting on `/` (which may redirect to sign-in) instead of a health route, and forgetting to rebuild assets before boot.

## Testing
The guard test fails if forgery protection is disabled, and a client with its CSRF header removed fails at least one UI test.

## Review checklist
Is CSRF protection on for the E2E server, is there a guard test, and does CI always boot a fresh server?

## Related skills
react-e2e-testing,rails-react-integration,rails-security
