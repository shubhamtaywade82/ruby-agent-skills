---
name: active-job-continuation-contract
description: Use Rails Active Job Continuable for resumable multi-step jobs when durable progress and restart semantics require explicit continuation boundaries.
family: rails
compatibility:
  rails: ">= 8.1"
---

# Active Job Continuation Contract

## Problem

A long-running job can lose progress when a worker stops between durable steps. Treat continuation as a restart boundary, not as a replacement for idempotency or retry design.

## Use when

- a job performs multiple durable steps;
- restartable progress is an explicit requirement;
- the repository is on a Rails version that provides `ActiveJob::Continuable`.

## Do not use when

- the job is already atomic and short;
- a simple retry policy is sufficient;
- the resolved Rails version does not satisfy the compatibility constraint.

## Repository inspection

Resolve the Rails version and job adapter first. Inspect existing retry, idempotency, persistence, and worker lifecycle conventions before adopting continuations.

## Example

```ruby
class ProcessImportJob < ApplicationJob
  include ActiveJob::Continuable

  def perform(import_id)
    step :process_records do |step|
      Import.find(import_id).records.find_each(start: step.cursor) do |record|
        record.process!
        step.advance! from: record.id
      end
    end
  end
end
```

## Implementation procedure

1. Define durable step boundaries and persisted progress.
2. Make each step safe to retry or resume.
3. Add continuation behavior only where restart semantics are actually needed.
4. Keep external side effects idempotent or explicitly reconciled.
5. Test interruption, resumption, retry, and final completion.

## Failure modes

- using continuation to hide non-idempotent side effects;
- treating step boundaries as transaction boundaries;
- resuming with stale or ambiguous progress;
- adopting the API on an unsupported Rails version.

## Testing

Verify normal completion, interruption/resume, repeated execution, failed steps, and external side-effect behavior.

## Review checklist

- [ ] Rails version satisfies `>= 8.1`
- [ ] progress is durable
- [ ] steps are restart-safe
- [ ] retries remain correct
- [ ] interruption/resume is tested

## Related skills

- skills/rails-active-job/SKILL.md
- skills/ruby-runtime-compatibility/SKILL.md
