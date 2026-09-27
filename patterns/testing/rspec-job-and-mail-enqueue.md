---
name: rspec-job-and-mail-enqueue
description: "Assert Active Job and mailer enqueueing with rspec-rails block matchers, and job behaviour with perform_now."
family: testing
---

# RSpec Job and Mail Enqueue

## Problem
Job and mailer enqueue assertions fail in confusing ways: `have_enqueued_mail` only works in block form, matchers need the `:test` queue adapter, and asserting enqueue alone never proves the job does the right thing.

## Use when
An RSpec suite must prove that a request or domain action enqueues a job or email, and that the job's `perform` is correct and safe to repeat.

## Do not use when
The repository uses Minitest; use `assert_enqueued_with` and `perform_enqueued_jobs` from `ActiveJob::TestHelper`.

## Repository inspection
Inspect the test-environment queue adapter (Rails 7.2+ defaults to `:test` in tests; an override to `:solid_queue`, `:sidekiq`, or `:inline` breaks the matchers), job arguments, queues, retry/discard rules, and existing job specs.

## Implementation procedure
1. Assert enqueueing with block form: `expect { action }.to have_enqueued_job(Job).with(args).on_queue("name")` and `have_enqueued_mail(Mailer, :method)`.
2. Chain related expectations with `.and`.
3. Test `perform` directly with `perform_now` against real records.
4. Add a duplicate-run example: a second `perform_now` must not change state again.
5. Test discard and early-return paths.

## Example

Runs green with rspec-rails 8.0 on Rails 8.0.

```ruby
require "rails_helper"

RSpec.describe FulfilOrderJob, type: :job do
  it "is enqueued on the fulfilment queue with the order" do
    order = create(:order)

    expect { described_class.perform_later(order) }
      .to have_enqueued_job(described_class).with(order).on_queue("fulfilment")
  end

  it "marks a pending order paid when performed" do
    order = create(:order)

    described_class.perform_now(order)

    expect(order.reload.status).to eq("paid")
  end

  it "is idempotent: a second run leaves a paid order unchanged" do
    order = create(:order, :paid)

    expect { described_class.perform_now(order) }.not_to(change { order.reload.updated_at })
  end

  it "leaves cancelled orders alone" do
    order = create(:order, :cancelled)

    described_class.perform_now(order)

    expect(order.reload.status).to eq("cancelled")
  end
end
```

## Failure modes
Non-block `have_enqueued_mail` (raises `ArgumentError`), asserting enqueue without testing `perform`, `perform_later` in a spec with the inline adapter hiding ordering bugs, and no idempotency example for a retried job.

## Testing
Run with the `:test` adapter; mutate the job (remove a guard) and the enqueue call and confirm each is caught.

## Review checklist
Is both the enqueue and the job's behaviour, including a second run, asserted?

## Related skills
rails-test-engineering,rails-active-job,rails-action-mailer
