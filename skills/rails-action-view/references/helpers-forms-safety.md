# Helpers, forms, tag helpers, output safety, and localization

Reference for the `rails-action-view` skill. Load it on demand when a change adds or alters helpers, forms or tag helpers, html_safe/raw/sanitize, or localized templates. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Helper boundary

Helpers should be presentation-focused and composable.

Good helper responsibilities include formatting, HTML tag generation, link/button construction, view-specific predicates, and small representation decisions.

Avoid helpers that load collections, write to the database, call external providers, decide business authorization, mutate global/application state, or become unbounded orchestration layers.

When helper logic becomes domain logic, move it to an owning domain object/service/policy and leave a thin presentation adapter in the view layer.

## Forms and tag helpers

Action View form and tag helpers produce HTML and commonly encode security behavior such as CSRF tokens for non-GET forms.

Compose with rails-action-controller for parameter/response contracts, rails-validations for validation errors, and rails-authentication or rails-security for authorization and CSRF boundaries.

Do not treat hidden inputs, disabled fields, DOM attributes, or generated HTML as authorization.

Verify successful and failed render paths, including validation error state and accessibility-critical labels when the repository tests them.

## Output safety and sanitization

Rails escapes dynamic template output by default. raw bypasses escaping, and sanitize removes unsafe HTML using configured sanitizer rules.

Treat HTML safety as a security contract.

Review user-controlled strings, translated/interpolated content, raw, html_safe, safe_join, sanitize, custom allowlists, URLs and protocols, Action Text output, and helpers returning SafeBuffer.

Never mark user input HTML-safe merely because it is expected to contain markup.

Do not weaken the sanitizer allowlist to fix a presentation defect without a security review.

Use sanitize or escaping at the owning rendering boundary when untrusted HTML is intentionally allowed.

## Localization

Action View can resolve locale-specific templates before falling back to the non-localized template.

Use rails-i18n for locale context and policy.

Define locale source, supported locale contract, fallback, template naming, translation interpolation, and locale-sensitive fragment cache identity.

Do not use locale-specific templates as an authorization mechanism.

Do not duplicate business logic across localized templates. Prefer shared structure plus localized presentation data.
