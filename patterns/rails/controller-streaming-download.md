---
name: controller-streaming-download
description: Use when a controller serves large files or long-lived response streams.
family: rails
---

# Controller Streaming and Download

## Problem

Large or long-lived responses can consume memory, file descriptors, threads, workers, database connections, and external-provider capacity.

## Use when

- serving large files
- generating CSV/export streams
- implementing live output
- reviewing send_data, send_file, or ActionController::Live.

## Do not use when

- a normal bounded response is small enough
- a durable export job is more appropriate.

## Repository inspection

Inspect authorization, file ownership, storage layer, response headers, worker/thread model, database query behavior, disconnect handling, and tests.

## Implementation procedure

1. Authorize the source resource before opening it.
2. Define content type and disposition.
3. Decide buffering versus streaming from measured size/workload.
4. Bound query batches and producer work.
5. Ensure resources close on normal and exceptional paths.
6. Account for connection duration in capacity.
7. Prefer asynchronous export generation for long-running work when appropriate.

## Failure modes

- streaming an unbounded query
- holding a database transaction for the whole download
- reading entire files into memory
- leaking file descriptors
- external provider streams without timeout/error handling
- omitting authorization because the URL is hard to guess.

## Testing

Test authorization, content disposition/type, bounded output, cleanup, and disconnect/error paths where supported.

## Review checklist

- [ ] source is authorized
- [ ] buffering/streaming decision is justified
- [ ] resources are bounded and closed
- [ ] concurrency cost is understood
- [ ] output headers are correct

## Related skills

rails-action-controller, rails-active-storage, rails-performance, rails-production-runtime, rails-test-engineering
