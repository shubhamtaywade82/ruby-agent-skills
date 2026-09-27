# Task T7: Add browser tests for signing in and adding a note

The notes app has a Rails 8 backend and a React notes island. The only browser test is a smoke check of the sign-in page. Add Playwright tests for the main journey:

1. a user signs in with email and password and lands on their notes;
2. they add a note and it is still there after a reload;
3. saving an empty note shows the validation message next to the field.

## Requirements

- Tests run in CI on every pull request with several parallel workers.
- Keep the suite fast; the sign-in journey will be used by many future tests.
- The existing `npm run e2e` command should keep working.

## Notes

- `playwright.config.ts` already starts the Rails server.
- There is a `POST /__test__/login` endpoint that a previous developer added to speed up browser tests.
