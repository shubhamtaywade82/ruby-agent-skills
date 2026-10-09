# Retry, discard, retry storms, and error reporting

Reference for the `rails-active-job` skill. Load it on demand when a change alters retry_on/discard_on, backoff, failure classification, or error reporting. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Retry policy

Use `retry_on` for transient failures where re-execution can reasonably succeed.

Specify:

- exception class
- attempts
- delay/backoff
- queue/priority changes when justified
- jitter where supported
- terminal behavior after retries
- error reporting

Rails' current API documents `retry_on` with configurable wait, attempts, queue, priority, jitter, reporting, and a terminal block. 

Example:

```ruby
class SyncCustomerJob < ApplicationJob
  retry_on ExternalServiceTimeout,
    wait: :polynomially_longer,
    attempts: 5,
    report: true

  def perform(customer_id)
    # ...
  end
end
```

Do not retry deterministic bugs, malformed input, authorization failures, or permanent domain-invalid states.

## Discard policy

Use `discard_on` when the work is no longer meaningful and retrying cannot make it valid.

Typical examples include deserialization of an object that has been deliberately removed, or a domain condition where the work is permanently obsolete.

Rails documents `discard_on` separately from `retry_on`; it performs no retry attempts for matching exceptions. 

Do not use discard as a substitute for fixing an unknown production failure.

Report discarded failures when operational visibility matters.

## Retry storm prevention

A retry is a capacity decision.

Before adding retries, determine:

```text
failure frequency
x
retry attempts
x
backoff duration
x
job concurrency
=
additional system load
```

Protect dependencies from amplification.

Use backoff/jitter and appropriate concurrency/queue isolation rather than immediate repeated retries.

## Error reporting

Job failures need operational visibility.

Prefer the repository's existing error reporter/logging infrastructure.

A common pattern is reporting exceptions through `Rails.error` and then re-raising so the queue backend retains failure semantics.

Do not rescue `StandardError` and silently return success.

## Handler ordering

`retry_on` and `discard_on` each register a `rescue_from` handler, and handlers are matched **last registered first**. Declaration order therefore decides which policy an exception gets.

Source evidence:

- `activesupport` `active_support/rescuable.rb` appends each handler with the comment *"Put the new handler at the end because the list is read in reverse"* and matches it with `rescue_handlers.reverse_each.detect`.
- `activejob` `active_job/exceptions.rb` implements both `retry_on` and `discard_on` as calls to `rescue_from`.

A broad handler declared after a narrow one shadows it silently:

```ruby
# WRONG: the timeout handler is unreachable.
retry_on Net::OpenTimeout, wait: :exponentially_longer, attempts: 5  # registered first
retry_on StandardError, wait: 5.seconds, attempts: 3                 # matches first
discard_on ActiveRecord::RecordNotFound                              # still wins: last
```

`Net::OpenTimeout` is a `StandardError`, and that handler was registered later, so it matches first. The exponential backoff and five attempts never run; every transient failure instead gets three attempts at five seconds with no visible warning. `discard_on` still works here because it is registered last.

Declare the broadest handler first, or declare no broad handler at all.

Do not `retry_on StandardError`. It re-runs deterministic bugs — `NoMethodError`, `TypeError`, malformed input, authorization failures — multiplying load precisely when the code is already broken. Retry specific, transient exception classes only.
