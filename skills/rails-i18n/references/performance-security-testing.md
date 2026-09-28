# I18n performance, security, and testing

Reference for the `rails-i18n` skill. Load it on demand when a change has I18n performance, security/privacy, or test-strategy impact. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Performance

Translation lookup is usually cheap, but high-cardinality dynamic backends or excessive repeated interpolation can become a measurable cost.

Measure before optimizing.

Inspect:

- backend calls per request;
- database-backed translation queries;
- translation cache hit rate;
- eager versus lazy loading;
- large locale files;
- repeated formatting work.

Do not memoize translations in request-global or process-global state without locale awareness.

## Security and privacy

Localization can become a data-exfiltration path when translated content contains sensitive interpolation values or privileged administrative content.

Review:

- translated HTML;
- interpolation values;
- locale-selection input;
- translation administration;
- custom backend authorization;
- logs/error reports;
- cache keys and localized content;
- tenant/account-specific translations.

A locale is presentation context, not authorization.

Never use locale choice to select tenant access or privileged data without an independent authorization boundary.

## Testing

Test the localization contract at the smallest relevant boundaries:

- supported/unsupported locale resolution;
- request locale isolation;
- translation lookup/key presence;
- interpolation requirements;
- pluralization;
- date/time/number formatting;
- model validation error translations;
- localized routes/URLs;
- mailer locale behavior;
- job locale propagation;
- API locale behavior;
- cache locale isolation;
- missing-translation handling;
- fallback behavior;
- custom backend failure when applicable.

Run locale-sensitive tests without leaking global locale between examples.

Test at least the representative locale variants whose grammar/formatting differs from the default locale.

Do not assert entire translated documents when a stable key/semantic fragment is sufficient.
