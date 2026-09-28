# Translation keys, interpolation, pluralization, and safe HTML

Reference for the `rails-i18n` skill. Load it on demand when a change adds or alters translation keys, interpolation, pluralization, or _html translations. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Translation key contract

Translation keys are application APIs.

Prefer stable semantic keys:

```yaml
en:
  accounts:
    lock:
      title: "Account locked"
      body: "..."
```

Avoid keys tied only to English source text unless the repository has an established convention.

Define ownership by domain/component where possible.

Do not scatter unrelated translations under generic global keys such as messages.success when multiple contexts require different semantics.

A key should have one clear responsibility.

Do not silently reuse a key because two English strings happen to be identical.

## Interpolation

Interpolation values are part of the translation contract.

Define:

- required variables;
- variable names;
- type/format expectations;
- escaping expectations;
- behavior when values are missing.

Keep translators responsible for grammar/order while application code supplies semantic values.

Prefer:

```yaml
en:
  greeting: "Hello %{name}"
```

over concatenating localized fragments in Ruby.

Do not build sentences by concatenating independently translated words when language grammar may differ.

Never expose secrets or sensitive identifiers through translation interpolation or logs.

## Pluralization

Pluralization is language-dependent and must be delegated to I18n pluralization rules.

Avoid count == 1 ? "item" : "items" when translated output is required.

Provide the count interpolation expected by the locale's pluralization rule.

Use explicit pluralization keys and test every supported locale's required forms.

Do not assume all locales have only singular/plural forms.

## Safe HTML translations

Translations can contain HTML markup in supported Rails view contexts.

Treat translated HTML as code that requires an explicit trust decision.

Do not mark arbitrary translated/user-provided strings as HTML-safe.

Keep trusted static markup in translation files only when repository conventions and escaping behavior make the contract clear.

Never combine translated strings with unescaped user input merely because the translation itself is trusted.

Coordinate with rails-security for XSS/escaping review.
