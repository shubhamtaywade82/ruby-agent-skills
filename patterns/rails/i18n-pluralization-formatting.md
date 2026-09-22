---
name: i18n-pluralization-formatting
description: Use Rails I18n pluralization and locale-aware date/time/number formatting instead of hand-built language rules or presentation strings.
family: rails
---

# I18n Pluralization & Formatting

## Problem

Manual singular/plural logic and hard-coded number/date formatting break across languages and regional conventions.

## Use when

- localizing counts;
- changing date/time/number/currency presentation.

## Do not use when

- values are canonical storage data rather than localized presentation.

## Repository inspection

Inspect locale formats, supported locale differences, count contracts, timezone handling, and presentation helpers.

## Implementation procedure

1. Identify canonical value.
2. Identify locale context.
3. Use pluralization rules with count.
4. Use locale-aware format helpers.
5. Keep timezone separate from locale.
6. Test representative grammar/format differences.

## Failure modes

- count == 1 in application code;
- localized strings persisted as domain data;
- timezone inferred from locale;
- one format assumed for every locale.

## Testing

Cover pluralization and at least one materially different formatting locale.

## Review checklist

- [ ] canonical data
- [ ] locale context
- [ ] pluralization
- [ ] formatting
- [ ] timezone separation
- [ ] tests

## Related skills

rails-i18n, rails-views, rails-activerecord
