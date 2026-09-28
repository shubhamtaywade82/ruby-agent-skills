# Localized formatting, views, routes, models, APIs, and mail

Reference for the `rails-i18n` skill. Load it on demand when a change localizes dates/numbers/currency, templates, routes, model/validation messages, API responses, or mail. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Date, time, number, and currency localization

Localize presentation values rather than storing localized representations as domain data.

Examples include:

- date/time formats;
- decimal separators;
- currency symbols/format;
- number delimiters;
- distance/measurement presentation.

Persist canonical values and render them through the locale-specific formatter.

Do not store "1,25" instead of a numeric value merely because one locale displays that representation.

Define timezone and locale separately:

```text
timezone = temporal context
locale = presentation/language context
```

Do not use locale as a substitute for timezone.

## Localized views and templates

Use localized view lookup when multiple templates differ structurally by locale.

Prefer translation keys for text changes and localized templates for genuinely structural differences.

Do not duplicate an entire view tree solely because a few strings differ.

For locale-specific assets/content, inspect caching and deployment implications.

Compose with rails-action-view for rendering boundaries.

## Localized routes and URLs

When locale appears in URLs, make it part of the routing contract.

Options include:

- path scope such as /:locale;
- optional locale scope;
- domain/subdomain;
- query parameter.

Keep the representation consistent.

Rails supports locale path scoping and default_url_options for propagating locale through generated URLs.

If locale comes from a path/domain, validate it against supported locales before switching context.

Do not accept arbitrary route locale values that create unbounded routing/caching dimensions.

## Model and validation translations

Rails integrates I18n with model names, attributes, and validation/error messages.

Keep domain validation logic independent from human-language presentation.

Do not parse translated error strings to make business decisions.

Prefer structured validation errors internally, then translate them at the presentation boundary.

For APIs, define whether clients receive:

- stable machine error codes;
- localized messages;
- both.

Do not make frontend logic depend on exact translated English text.

## API localization

Treat localized API responses as a wire-contract decision.

Define:

- how locale is supplied;
- which fields are localized;
- whether error messages are localized;
- content negotiation behavior;
- cache variation;
- client compatibility.

Prefer stable error codes plus localized human-readable messages where clients need to act programmatically.

If response representation changes by locale, include locale in any cache key/vary semantics.

Do not silently change API schema by locale.

Compose with rails-api-integration.

## Action Mailer localization

Mailer subjects and bodies are user-facing localized output.

Define:

- locale source;
- whether locale is captured or re-read;
- fallback;
- locale-specific templates/subjects;
- queue semantics.

Rails' I18n support includes Action Mailer email subjects.

Compose with rails-action-mailer and rails-active-job.

Do not let mailer templates guess the locale independently from the message's business context.
