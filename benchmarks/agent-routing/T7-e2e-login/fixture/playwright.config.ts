import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "e2e",
  retries: 2,
  use: { baseURL: "http://127.0.0.1:3100" },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
  webServer: {
    command: "npm run build && bin/rails db:prepare && bin/rails server -p 3100 -b 127.0.0.1",
    env: { RAILS_ENV: "test" },
    url: "http://127.0.0.1:3100/up",
    reuseExistingServer: true,
  },
});
