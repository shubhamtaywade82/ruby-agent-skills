# Analysis, variants, previews, and background processing

Reference for the `rails-active-storage` skill. Load it on demand when a change alters analysis, variants, previews, processing dependencies, or processing jobs. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Analysis

Active Storage can analyze uploaded files asynchronously and persist metadata.

Treat analysis as eventually completed state.

Ask:

- does the business flow require analysis before use?
- what happens when analysis fails?
- which metadata is required?
- who owns analyzer configuration?
- what happens for unsupported/malformed files?
- does downstream logic distinguish "uploaded" from "analyzed"?

Do not assume upload completion means all metadata is already available.

When analysis is security-sensitive, gate access or downstream processing on the appropriate completion state.

## Variants and previews

Variants/previews are derived representations, not original assets.

Define:

- transformation contract;
- accepted source types;
- output format;
- size/dimensions;
- processing cost;
- caching/variant reuse;
- authorization;
- failure behavior.

Prefer stable, named variant transformations over scattered ad hoc processor options.

Do not allow user-controlled transformation parameters to create unbounded CPU/memory work.

For known hot representations, consider preprocessed variants and capacity implications.

## Processing dependencies

Image/video/PDF transformations may require external tools such as libvips/ImageMagick, ffmpeg, or PDF utilities.

Verify:

- installed versions;
- production availability;
- licensing;
- resource limits;
- security posture;
- failure behavior;
- container/package reproducibility.

Do not assume a transformation works in production because it works on a developer laptop.

## Background processing

Analysis and variant generation can enqueue Active Job work.

Compose with `rails-active-job` for:

- queue selection;
- retry/discard;
- idempotency;
- transaction semantics;
- concurrency;
- shutdown;
- observability.

Do not duplicate job retry logic inside attachment callbacks.

A large media workload must be sized against worker capacity and external processing limits.
