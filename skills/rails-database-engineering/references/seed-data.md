# Seed data: idempotency, environments, and secrets

Reference for the `rails-database-engineering` skill. Load it on demand when a change touches `db/seeds.rb`, seed files it loads, or `bin/rails db:seed`. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Seeds must be rerunnable

`bin/rails db:seed` runs on fresh databases and again on existing ones (`db:setup`, `db:reset`, CI images, review apps). Every seed operation must converge to the same state when run twice:

- Use `find_or_create_by!(natural_key: ...)` for records with a natural key, passing the remaining attributes in the block. Use `upsert_all(..., unique_by: ...)` for bulk reference data backed by a unique index.
- Key lookups on a column with a unique index or constraint, so a concurrent or repeated run cannot create duplicates.
- Never `create!` unconditionally, never depend on auto-increment ids, and never delete and recreate rows that other tables reference.
- Use the bang forms so a validation failure stops the seed instead of silently skipping a row.

## Separate reference data from sample data

- **Reference data** (roles, plans, countries, feature defaults) is needed in every environment, production included. Keep it small and deterministic.
- **Development and demo data** is guarded by environment (`if Rails.env.development?`) or lives in a separate task. It never runs in production.
- **Data that fixes or transforms existing production rows** is a data migration or a one-off task with its own rollout, not a seed.

## Secrets never live in seeds

- Do not hardcode passwords, API keys, or tokens in `db/seeds.rb` or the files it loads.
- Read production secrets from encrypted credentials (`Rails.application.credentials`) or the deployment environment. Their management belongs to `rails-encryption-credentials-engineering`.
- Generate development-only passwords with `SecureRandom` and print them once, or read them from the environment. Do not commit a shared default password that could reach a deployed environment.
- A seeded administrator account in production is an access-control decision. Review it under `rails-authentication` and `rails-authorization`, not as data hygiene.

## Verification

Run `bin/rails db:seed` twice against the same database and assert that record counts and key attributes are identical after the second run. In CI, run seeds against a freshly loaded schema so a seed that depends on development-only state fails there.
