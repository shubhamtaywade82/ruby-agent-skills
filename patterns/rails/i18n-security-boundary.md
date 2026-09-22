---
name: i18n-security-boundary
description: Review Rails localization inputs, translated HTML, interpolation values, locale administration, and localized caches for security and privacy risks.
family: rails
---

# I18n Security Boundary

## Problem

Localization can become an XSS, data-exfiltration, authorization, or cache-isolation boundary when locale input or translation content is trusted incorrectly.

## Use when

- accepting user-selected locale;
- allowing translation administration;
- rendering translated HTML;
- localizing private/tenant data.

## Do not use when

- translations are entirely static and already protected by repository conventions.

## Repository inspection

Inspect locale input sources, HTML-safe translation paths, authorization, interpolation data, translation admin, cache keys, and logs.

## Implementation procedure

1. Validate locale input.
2. Separate locale from authorization.
3. Review translated HTML/escaping.
4. Review interpolation sensitivity.
5. Secure translation editing.
6. Review cache isolation.
7. Add negative security tests.

## Failure modes

- arbitrary locale selection used as access control;
- user HTML trusted as translation;
- secrets in interpolated translations/logs;
- cross-tenant localized cache.

## Testing

Test unsupported locale input, unsafe translation HTML, sensitive interpolation, translation-admin authorization, and locale cache separation.

## Review checklist

- [ ] locale validated
- [ ] authorization separate
- [ ] HTML escaped
- [ ] interpolation safe
- [ ] admin secured
- [ ] cache isolated

## Related skills

rails-i18n, rails-security, rails-security-engineering, rails-caching
