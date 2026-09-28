# Sanitization and links

Reference for the `rails-action-text` skill. Load it on demand when a change alters allowed tags/attributes, sanitization, or link and URL handling. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Sanitization boundary

Action Text sanitizes rich text before safe rendering.

That does not remove the need to reason about the input boundary.

Review:

- allowed tags;
- allowed attributes;
- links and URL schemes;
- custom renderers;
- custom sanitizers;
- `html_safe`/raw usage around content;
- translation/interpolation into rich text;
- pasted or imported HTML;
- custom attachment partials.

Never mark raw user HTML safe merely because it came from a Trix editor.

Do not bypass Action Text's sanitization without documenting the exact trusted content model and security review.

If a custom sanitizer is used, test both permitted formatting and malicious payload rejection.

Coordinate with `rails-security` for XSS and content-security review.

## Links and URLs

Rich text can contain hyperlinks.

Define and review:

- allowed URL schemes;
- external versus internal links;
- host restrictions when required;
- tracking parameters;
- target/rel attributes where applicable;
- link rendering policy.

Treat pasted links as untrusted.

Do not assume a link is safe because the editor generated the anchor element.

If application-specific URL rewriting is used, keep it deterministic and tested.
