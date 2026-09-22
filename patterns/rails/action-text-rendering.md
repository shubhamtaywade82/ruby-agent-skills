---
name: action-text-rendering
description: Use the Rails Action Text rendering path for sanitized HTML, attachables, layouts, and plain-text extraction without duplicating rich-text parsing.
family: rails
---

# Action Text Rendering

## Problem

Custom rendering can accidentally bypass sanitization, attachable fallback behavior, or framework output contracts.

## Use when

- customizing Action Text HTML;
- adding attachable partials;
- extracting plain text.

## Do not use when

- default rendering already satisfies the contract and no rendering change is required.

## Repository inspection

Inspect Action Text layouts, blob partials, attachable partials, sanitizer behavior, and consumers of HTML/plain text.

## Implementation procedure

1. Identify required presentation change.
2. Preserve framework RichText rendering.
3. Customize narrow templates/partials.
4. Define missing-attachable behavior.
5. Treat to_plain_text as a separate non-HTML-safe representation.
6. Test HTML and plain-text outputs.

## Failure modes

- raw HTML-safe bypass;
- parsing RichText manually;
- missing attachable exceptions;
- plain text rendered as HTML.

## Testing

Assert safe HTML structure, attachment rendering, missing fallback, and plain-text content.

## Review checklist

- [ ] framework rendering preserved
- [ ] narrow customization
- [ ] fallback
- [ ] HTML safety
- [ ] plain text semantics

## Related skills

rails-action-text, rails-views, rails-security
