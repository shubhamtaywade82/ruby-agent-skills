# Rendering, API, localization, and forms

Reference for the `rails-action-text` skill. Load it on demand when a change renders rich text, exposes it through an API, localizes it, or accepts it through forms. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Rendering boundary

Action Text rich content is presentation output.

Prefer the framework's RichText rendering path rather than:

- parsing HTML manually;
- calling raw `html_safe` on stored bodies;
- duplicating sanitizer logic;
- reconstructing Trix markup in controllers.

ActionText::RichText#to_s is designed to produce safe HTML for rendering, while `to_plain_text` is not HTML-safe and should not be rendered directly in a browser without sanitization.

Treat plain-text extraction as a separate representation contract.

## API boundary

Do not expose internal Action Text storage tables as a public API contract.

For APIs decide whether clients receive:

- rendered HTML;
- sanitized HTML plus plain text;
- editor/document representation;
- structured attachment metadata;
- stable content/version identifiers.

Define the representation explicitly.

For write APIs:

```text
request content
-> validate/authorize
-> persist RichText
-> respond with stable representation
```

Do not make API clients depend on internal RichText primary keys, attachment table rows, or Trix-specific implementation details unless intentionally part of the contract.

Coordinate with `rails-api-integration`.

## Rich text and localization

If rich text content is locale-dependent, define whether localization is:

- separate rich-text fields per locale;
- translation keys inside content;
- localized presentation around a shared body;
- external translation workflow.

Do not interpolate user-provided rich text into translation strings.

Do not assume a single RichText body can satisfy all language/grammar requirements when the actual content differs materially.

Use `rails-i18n` for locale context, locale resolution, and localized surrounding presentation.

## Forms and parameters

Permit rich-text attributes explicitly at the owning resource boundary.

Inspect:

- strong parameters;
- nested resources;
- form objects;
- API payload size limits;
- content upload handling.

Do not permit arbitrary RichText IDs or attachment IDs merely to simplify form submission.

Use `rails-action-controller` and `rails-validations` for request/input contracts.
