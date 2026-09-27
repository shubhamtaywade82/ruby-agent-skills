---
name: e2e-authenticated-storage-state
description: "Sign in once through the real Rails form in a Playwright setup project and reuse the saved session in dependent projects."
family: react-typescript
---

# E2E Authenticated Storage State

## Problem
Signing in through the UI in every test multiplies runtime and flake surface, while bypassing sign-in with forged cookies or a backdoor route leaves the real authentication flow untested.

## Use when
Most journeys need a signed-in user of the Rails session-cookie authentication.

## Do not use when
The journey under test is sign-in itself or an anonymous flow; run those in a project without `storageState`.

## Repository inspection
Inspect the sign-in form labels, the session controller, how users are created (`db/seeds.rb`, runner scripts), and `.gitignore`.

## Implementation procedure
1. Upsert a test-only account through Rails (`bin/rails runner`) inside the setup project.
2. Sign in through the real form and assert the landing page.
3. Save `storageState` to `playwright/.auth/user.json` and ignore that directory in Git.
4. Make authenticated projects depend on `setup`; keep anonymous specs in a separate project.

## Example

Runs green with `@playwright/test` 1.63 against Rails 8.0.5.1 using `has_secure_password` and `User.authenticate_by`.

```ruby
# e2e/seed_user.rb — idempotent; run with RAILS_ENV=e2e
email, password = ARGV.fetch(0), ARGV.fetch(1)
user = User.find_or_initialize_by(email: email)
user.update!(password: password)
```

```ts
// e2e/auth.setup.ts
import { execFileSync } from "node:child_process";
import { expect, test as setup } from "@playwright/test";

const email = "e2e-user@example.test";
const password = process.env.E2E_PASSWORD ?? "e2e-only-password";

setup("sign in once and save the session", async ({ page }) => {
  // Create the account through Rails itself, never through a test-only HTTP route.
  execFileSync("bin/rails", ["runner", "e2e/seed_user.rb", email, password], {
    env: { ...process.env, RAILS_ENV: "e2e" },
    stdio: "inherit",
  });

  await page.goto("/session/new");
  await page.getByLabel("Email").fill(email);
  await page.getByLabel("Password").fill(password);
  await page.getByRole("button", { name: "Sign in" }).click();

  await expect(page.getByRole("heading", { name: "Notes" })).toBeVisible();
  await page.context().storageState({ path: "playwright/.auth/user.json" });
});
```

```ts
// playwright.config.ts (projects excerpt)
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
```

## Failure modes
Committed session files, production-like credentials in the repository, a seeding route reachable in production, anonymous specs accidentally inheriting the session, and sign-in failures surfacing as unrelated errors in every dependent test.

## Testing
An anonymous spec proves that `/notes` redirects to sign-in, and a wrong password shows the error. A dependent spec reaches the authenticated page without signing in.

## Review checklist
Is sign-in exercised once through the real form, is `playwright/.auth/` ignored, and are anonymous journeys isolated?

## Related skills
react-e2e-testing,rails-authentication
