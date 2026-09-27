import { expect, test } from "@playwright/test";

test("sign-in page loads", async ({ page }) => {
  await page.goto("/session/new");
  await page.waitForTimeout(1000);
  await expect(page.locator("h1")).toHaveText("Sign in");
  await expect(page.locator("form input[type=submit]")).toBeVisible();
});
