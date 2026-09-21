---
name: action-text-preload-performance
description: Control Rails Action Text RichText and embedded-attachment queries with measured preloading and bounded rendering work.
family: rails
---

# Action Text Preload & Performance

## Problem

Rendering collections with rich text can create N+1 RichText or embedded-attachment queries and large rendering/memory costs.

## Use when

- rendering collections with rich text;
- diagnosing Action Text query or rendering latency.

## Do not use when

- no measurable rich-text performance issue exists.

## Repository inspection

Inspect query counts, with_rich_text scopes, embed usage, attachment processing, render size, cache behavior, and workload.

## Implementation procedure

1. Measure baseline.
2. Identify RichText/embed query source.
3. Use the narrowest appropriate preload.
4. Inspect generated attachment queries.
5. Measure memory/render size.
6. Cache only where semantics permit.

## Failure modes

- no preload;
- preload all rich text unnecessarily;
- expensive attachment transformations;
- cache isolation ignored.

## Testing

Use query-count/performance tests where the repository has a stable performance boundary.

## Review checklist

- [ ] baseline
- [ ] query source
- [ ] narrow preload
- [ ] attachment cost
- [ ] memory/render size
- [ ] cache semantics

## Related skills

rails-action-text, rails-activerecord, rails-performance, ruby-performance, rails-caching
