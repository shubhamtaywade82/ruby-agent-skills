# Caching, translation files, missing translations, fallbacks, and backends

Reference for the `rails-i18n` skill. Load it on demand when a change alters localized caching, translation file layout, missing-translation handling, fallbacks, backends, or translation administration. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Caching and locale

Locale is part of the cache identity whenever the rendered or computed result changes by locale.

Inspect:

- translation-dependent fragment caches;
- low-level caches returning localized strings;
- API response caches;
- CDN/Vary behavior;
- cache key dimensions.

A localized representation must not be served to a different locale merely because the resource identity matches.

Compose with rails-caching.

Do not add locale to every cache key by default if the cached value is deliberately locale-independent.

## Translation file organization

Choose a predictable locale tree.

Common dimensions:

- locale;
- domain/component;
- view/model/controller context.

Keep locale files small enough to review and merge safely.

Use a stable naming convention across teams.

Do not duplicate the same semantic key across multiple files with conflicting definitions without knowing load-order behavior.

Rails automatically includes .rb and .yml files from config/locales in the translation load path by convention.

When customizing I18n.load_path, verify ordering and override semantics.

## Missing translations

Define the production contract for missing keys.

Possible approaches:

- fail loudly in development/test;
- report missing translations;
- deterministic fallback;
- explicit placeholder;
- custom exception handler.

Do not silently hide large classes of missing translations in CI.

A missing translation in a security, billing, compliance, or transactional message may be more serious than a cosmetic missing string.

Instrument repeated/missing key patterns when operationally useful.

Never log sensitive interpolation values while diagnosing missing translations.

## Fallback behavior

Fallback is a product and correctness decision.

Define:

- fallback locale;
- fallback chain;
- locale-specific fallback;
- behavior for missing pluralization forms;
- behavior when locale is unsupported;
- whether fallback is permitted for all domains.

Do not assume the default locale is always a safe fallback for every message.

For high-risk user-facing workflows, test the actual fallback path.

## Custom backends

Rails supports replacing the default I18n backend with another backend, including database-backed or GetText-like stores.

Use a custom backend only when repository requirements justify it.

Inspect:

- read latency;
- caching;
- deployment consistency;
- write/update lifecycle;
- invalidation;
- versioning;
- availability;
- failure behavior;
- security/authorization for translation administration.

Do not move translation lookup into a database without understanding the runtime dependency introduced into rendering/request paths.

## Translation administration

If translations are editable by privileged operators, treat them as application configuration/data with authorization controls.

Review:

- who can edit;
- audit history;
- approval/review;
- rollback;
- locale/key validation;
- HTML safety;
- interpolation variable validation;
- publication semantics.

Do not let arbitrary users inject HTML into trusted translation contexts.
