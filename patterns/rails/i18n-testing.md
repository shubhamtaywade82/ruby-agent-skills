---
name: i18n-testing
description: Test Rails localization deterministically across locale isolation, key coverage, interpolation, pluralization, formatting, fallback, URLs, jobs, and cache identity.
family: testing
---

# I18n Testing

## Problem

Localization regressions often pass default-locale tests while failing on locale resolution, grammar, formatting, async context, or cache isolation.

## Use when

- adding/changing localized behavior;
- reviewing translation coverage or fallback regressions.

## Do not use when

- the feature has no locale-dependent behavior.

## Repository inspection

Inspect test framework, locale fixtures, translation linting, supported locale list, request/job helpers, and cache tests.

## Implementation procedure

1. Scope locale per test.
2. Test resolution/unsupported values.
3. Test key/interpolation contracts.
4. Test pluralization and formatting.
5. Test localized URLs where applicable.
6. Test jobs/mailers/API behavior.
7. Test fallback/missing translations.
8. Test cache separation where applicable.

## Failure modes

- global locale leakage between tests;
- default-locale-only coverage;
- full-page string snapshots;
- missing async locale tests;
- missing cross-locale cache tests.

## Testing

Prefer semantic key/behavior assertions and representative locale variants. Always restore locale state.

## Review checklist

- [ ] isolated locale
- [ ] supported/unsupported
- [ ] key/interpolation
- [ ] pluralization/formatting
- [ ] async boundaries
- [ ] fallback
- [ ] cache isolation

## Related skills

rails-i18n, rails-test-engineering, rails-testing, rails-active-job, rails-caching
