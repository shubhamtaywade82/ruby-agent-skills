---
name: i18n-translation-key-contract
description: Define stable semantic Rails translation keys and interpolation contracts across views, models, mailers, and APIs.
family: rails
---

# I18n Translation Key Contract

## Problem

Translation keys become unstable when they mirror incidental English text or when interpolation semantics are implicit.

## Use when

- adding keys;
- reorganizing locale files;
- reviewing missing or conflicting translations.

## Do not use when

- localization is not involved.

## Repository inspection

Inspect locale tree, key naming conventions, components using translations, interpolation variables, and test/lint tooling.

## Implementation procedure

1. Define semantic scope.
2. Name the key by responsibility.
3. Define required interpolation values.
4. Keep domain-specific namespaces separate.
5. Add supported locale entries.
6. Test key availability and interpolation.

## Failure modes

- generic global keys with conflicting semantics;
- missing interpolation variables;
- English-source keys used as APIs;
- duplicated definitions with unclear load order.

## Testing

Test key presence, expected interpolation variables, and representative locale values.

## Review checklist

- [ ] semantic key
- [ ] ownership
- [ ] interpolation contract
- [ ] locale coverage
- [ ] tests

## Related skills

rails-i18n, rails-views, rails-validations, rails-action-mailer
