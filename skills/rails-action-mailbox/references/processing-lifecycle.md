# Processing boundary, lifecycle states, callbacks, failures, and transactions

Reference for the `rails-action-mailbox` skill. Load it on demand when a change alters mailbox processing, processing states, bounce/failure handling, or transactional and asynchronous work. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Mailbox processing boundary

A mailbox should behave like an application boundary, not a miniature controller.

Typical flow:

~~~
InboundEmail
-> parse mailbox
-> validate sender/recipient context
-> resolve domain owner
-> authorize operation
-> perform bounded domain change
-> enqueue follow-up work after durable state is established
~~~

Use inbound_email.mail for parsed email data and inbound_email.source only when raw RFC822 content is specifically required.

Keep the mailbox responsible for orchestration, not unrelated domain policy.

Prefer:

- small mailbox classes;
- domain services/policies for complex rules;
- transaction boundaries at the authoritative data owner;
- explicit failure classifications;
- idempotent domain side effects.

Avoid:

- large parsing libraries embedded in every mailbox;
- direct cross-tenant writes;
- network calls hidden in callbacks;
- unbounded loops over attachments;
- irreversible side effects before duplicate detection.

## Lifecycle and processing states

Rails tracks inbound processing through:

- pending;
- processing;
- delivered;
- failed;
- bounced.

Processed states are delivered, failed, and bounced, after which the inbound record is scheduled for incineration.

Treat those framework states as operational evidence, not as a complete business state machine.

If the product needs states such as accepted, classified, linked, imported, rejected, quarantined, or replayed, store them in the domain model or an explicit processing record.

Do not overload Action Mailbox status with unrelated business state.

## Callbacks and failure semantics

Use before_processing for cheap, deterministic prerequisites that should prevent process.

Use process for the actual mailbox operation.

Use after_processing for bounded lifecycle work that is safe after the main operation.

Use around_processing only when a cross-cutting boundary genuinely needs wrapping semantics.

Rails supports bounce_with, bounce_now_with, bounced!, and rescue_from for mailbox-specific failure handling. bounce_with marks the inbound email bounced and enqueues the outbound message; bounce_now_with delivers immediately.

Classify failures:

| Failure | Typical handling |
|---|---|
| malformed/unsupported input | reject or quarantine |
| sender not eligible | bounce/reject |
| recipient not routable | backstop or bounce |
| authorization failure | reject; never mutate protected state |
| transient provider/domain dependency | bounded retry |
| duplicate business message | acknowledge as already handled |
| poison message | quarantine and alert |
| programmer defect | fail and surface through observability |

Never use a broad rescue that turns programmer defects into successful delivery.

## Transactions and asynchronous work

Use the authoritative domain transaction for business invariants.

~~~
validate / authorize
-> transaction
   -> domain state
   -> durable outbox or transactional enqueue
-> commit
-> async follow-up
~~~

Do not enqueue work that assumes a database record exists before it is durably committed unless the queue semantics explicitly provide the required guarantee.

Do not make external network calls inside a database transaction unless the transaction contract truly requires it and latency/failure behavior is bounded.

Coordinate with rails-active-job, rails-database-engineering, and rails-event-driven-messaging.
