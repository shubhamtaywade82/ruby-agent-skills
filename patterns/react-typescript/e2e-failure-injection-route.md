---
name: e2e-failure-injection-route
description: "Use Playwright page.route only to inject server failures or stub third-party origins, keeping the application's own Rails API real."
family: react-typescript
---

# E2E Failure Injection Route

## Problem
Error paths such as 503s and timeouts are hard to trigger from a real server. The shortcut of stubbing the application's own API everywhere removes the Rails contract the end-to-end suite exists to prove.

## Use when
A journey must show how the client behaves when a request fails, or a third-party origin (payments, analytics, maps) must not be called.

## Do not use when
The goal is to test the success path against Rails, or when a Rails validation failure (422) can be produced with real input.

## Repository inspection
Inspect existing `page.route` calls, which origins they match, and whether any stub the application's own endpoints on success paths.

## Implementation procedure
1. Match the narrowest URL and method that must fail.
2. Fulfil with the failure status or abort the request; call `route.fallback()` for everything else.
3. Assert the user-visible error and that user input is preserved.
4. Produce validation failures with real input instead of stubbed 422s.

## Example

Runs green with `@playwright/test` 1.63 against Rails 8.0.5.1. The GET that loads the list still reaches Rails.

```ts
import { expect, test } from "@playwright/test";

test("reports a server failure without losing the draft", async ({ page }) => {
  await page.route("**/notes", (route) =>
    route.request().method() === "POST" ? route.fulfill({ status: 503 }) : route.fallback(),
  );
  await page.goto("/notes");
  const body = `Draft ${test.info().testId}`;

  await page.getByRole("textbox", { name: "Note" }).fill(body);
  await page.getByRole("button", { name: "Add note" }).click();

  await expect(page.getByRole("alert")).toHaveText("Could not save note. Try again.");
  await expect(page.getByRole("textbox", { name: "Note" })).toHaveValue(body);
});
```

## Failure modes
Broad `**/*` routes that stub everything, `route.continue()` where `fallback()` is needed to reach other handlers, stubbed 422s that drift from the Rails error shape, and success-path stubs that hide API contract breaks.

## Testing
Removing the client's error handling fails the test, and the unstubbed success-path tests still exercise Rails.

## Review checklist
Does every `page.route` inject a failure or isolate a third-party origin, and does everything else reach the real server?

## Related skills
react-e2e-testing,rails-react-integration
