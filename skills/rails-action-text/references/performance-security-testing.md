# Performance, caching, resource limits, security, and testing

Reference for the `rails-action-text` skill. Load it on demand when a change has N+1, caching, content-size, security/privacy, or test-strategy impact. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Performance and N+1

Rich text rendering can load associated RichText and embedded attachments.

Rails provides preloading scopes such as:

- `with_rich_text_<name>`;
- `with_rich_text_<name>_and_embeds`.

Use the appropriate preload when rendering collections.

Before optimizing:

1. measure query count;
2. identify whether RichText or embeds cause the N+1;
3. choose the narrowest preload;
4. measure again.

Do not preload every rich-text and every embed on every query merely because one page needs them.

For large content or high-fanout pages inspect rendering size, attachment transformations, cache behavior, and memory.

Compose with `rails-performance`, `rails-active-record`, and `ruby-performance`.

## Caching rendered rich text

Rendered HTML may be cached, but its cache identity must include all correctness dimensions.

Review:

- locale;
- resource/content version;
- attachment/variant state;
- permission/public-private scope;
- sanitizer/configuration changes;
- custom attachable rendering;
- deployment compatibility.

Do not cache private rich text across users/tenants.

Do not assume a cache key based only on owner ID is sufficient when rich-text content or rendering dependencies vary.

Compose with `rails-caching` and `rails-i18n`.

## Content size and resource limits

Rich text can become a resource-exhaustion vector through:

- huge bodies;
- many embeds;
- deeply nested markup;
- repeated transformations;
- large attachment sets;
- expensive rendering.

Define practical limits where the product permits:

- maximum content length;
- maximum embedded attachments;
- maximum attachment size;
- allowed markup complexity;
- transformation constraints.

Server-side enforcement is authoritative.

Do not rely solely on Trix editor limits.

## Security and privacy

Rich text is user-controlled content that can contain links, embedded files, and references to application objects.

Review:

- XSS/sanitization;
- link schemes;
- attachable authorization;
- tenant isolation;
- sensitive attachment rendering;
- signed Global ID usage;
- public/private visibility;
- logs/errors;
- cache isolation;
- translation/admin content;
- API exposure.

A sanitized body can still render a private attached resource incorrectly if attachment authorization is wrong.

Never treat successful sanitization as proof that the user was authorized to reference every embedded object.

## Testing

Test at the smallest owning boundaries:

- rich-text association;
- editor submission;
- permitted attribute;
- authorization;
- sanitization;
- malicious HTML/link handling;
- attachment embedding;
- attachable SGID authorization;
- missing attachable fallback;
- HTML rendering;
- plain-text extraction;
- API representation;
- localized rich-text behavior;
- preload/query behavior;
- cache identity;
- delete/lifecycle behavior;
- background processing when applicable.

Use deterministic Action Text/Active Storage test support and fixture data.

Do not make ordinary tests depend on external cloud storage or a browser session unless that behavior is the actual contract.

For XSS/security regressions, add negative tests containing representative malicious markup and URL schemes.
