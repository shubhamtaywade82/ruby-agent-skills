---
name: e2e-parallel-data-isolation
description: "Keep Playwright tests independent under parallel workers against one Rails database by writing data only each test can match."
family: react-typescript
---

# E2E Parallel Data Isolation

## Problem
The browser and the Rails server are separate processes, so transactional rollback cannot isolate end-to-end tests. Parallel workers sharing one database collide on fixed records, count assertions, and mid-run truncation.

## Use when
Playwright runs with `fullyParallel` or several workers against one Rails server and database.

## Do not use when
The test is a Rails request or system test that already runs inside a rolled-back transaction.

## Repository inspection
Inspect worker settings, existing seeds, assertions on totals or list lengths, and any `beforeEach` that deletes rows.

## Implementation procedure
1. Derive unique values from `test.info().testId` and a timestamp.
2. Scope assertions to the record the test created (`filter({ hasText })`), never to totals.
3. Seed shared reference data once, idempotently, in the setup project.
4. Reset the database only before the server boots (`db:prepare` in `webServer`), never between tests.

## Example

Runs green with `@playwright/test` 1.63 with two workers against Rails 8.0.5.1.

```ts
import { expect, test } from "@playwright/test";

function uniqueBody(label: string): string {
  return `${label} ${test.info().testId} ${Date.now()}`;
}

test("adds a note that survives a reload", async ({ page }) => {
  await page.goto("/notes");
  const body = uniqueBody("Buy milk");

  await page.getByRole("textbox", { name: "Note" }).fill(body);
  await page.getByRole("button", { name: "Add note" }).click();

  const notes = page.getByRole("list", { name: "Notes" });
  await expect(notes.getByRole("listitem").filter({ hasText: body })).toBeVisible();

  await page.reload();
  await expect(notes.getByRole("listitem").filter({ hasText: body })).toBeVisible();
});
```

## Failure modes
`toHaveCount(n)` on shared lists, fixed emails, `beforeEach` truncation, order-dependent tests, and relying on a record another test created.

## Testing
The suite passes with `--workers` above one and with `--repeat-each=3`.

## Review checklist
Could any assertion observe another worker's data, and does any test depend on another test's writes?

## Related skills
react-e2e-testing,rails-test-engineering
