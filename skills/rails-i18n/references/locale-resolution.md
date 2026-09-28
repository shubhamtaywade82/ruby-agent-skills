# Locale contract, resolution, and negotiation

Reference for the `rails-i18n` skill. Load it on demand when a change alters supported locales, how a locale is chosen, or Accept-Language negotiation. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Locale contract

Define supported locales explicitly.

The contract should include:

- canonical locale identifiers;
- default locale;
- allowed locale sources;
- fallback behavior;
- invalid-locale behavior;
- persistence of user preference;
- URL representation where applicable;
- locale behavior for async jobs;
- locale behavior for system-generated messages.

Use I18n.available_locales as the application-level allowlist where appropriate.

Do not let arbitrary request input become a locale merely because a translation file happens to exist.

Normalize locale identifiers at the boundary and map browser/region variants to supported application locales intentionally.

## Locale resolution

Locale selection should happen once at a well-defined boundary.

Common sources:

- explicit URL path;
- domain/subdomain;
- authenticated user preference;
- trusted account/tenant setting;
- accepted language headers;
- explicit API parameter.

Define precedence.

Example:

```text
explicit URL locale
-> authenticated user preference
-> account/tenant default
-> negotiated request locale
-> application default
```

The exact order is application-specific. Inspect existing behavior before changing it.

Never trust a locale source blindly.

Reject or normalize unsupported values before entering the application locale context.

## Locale negotiation

When deriving locale from browser headers or similar signals:

1. parse the external value;
2. normalize it;
3. map to supported application locales;
4. apply repository precedence;
5. fall back deterministically.

Do not expose the full browser locale space directly to the application.

For region-specific behavior, decide explicitly whether the application supports region-qualified locales such as en-US versus language-only en.

Rails' I18n approach permits locale forms beyond simple language identifiers, but the application must choose and configure its supported locale set intentionally.
