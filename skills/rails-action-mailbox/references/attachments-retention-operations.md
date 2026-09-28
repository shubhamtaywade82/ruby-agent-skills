# Attachments, retention, operations, capacity, and provider compatibility

Reference for the `rails-action-mailbox` skill. Load it on demand when a change stores attachments, alters retention or incineration, or affects operations, capacity, or provider/MTA behavior. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Attachments and Active Storage

Action Mailbox stores the original email source through Active Storage, and parsed mail can include attachments.

Compose with rails-active-storage for storage, access, processing, purge, and deterministic test behavior.

For business attachments define:

- allowed types;
- maximum size/count;
- malware/content scanning requirements;
- tenant ownership;
- retention;
- synchronous versus asynchronous extraction;
- failure behavior;
- purge lifecycle.

Avoid downloading every attachment into memory in the mailbox process.

## Retention, privacy, and incineration

Rails schedules processed inbound emails for automatic incineration; the documented default is 30 days via config.action_mailbox.incinerate_after.

Treat retention as a privacy/data-governance decision.

Define:

- required forensic/debug window;
- legal/compliance retention;
- sensitive-content handling;
- tenant/account deletion behavior;
- raw email retention;
- derived domain data retention;
- attachment retention;
- replay window;
- purge verification.

Do not extend raw-message retention merely because debugging is convenient.

Do not assume incinerating InboundEmail also deletes every domain record or derived attachment created by your mailbox.

## Observability and operations

Record low-cardinality lifecycle telemetry such as provider, mailbox class, route, outcome, processing duration, retry count, attachment count/size bucket, queue age, and quarantine count.

Preserve correlation/causation identifiers across:

~~~
ingress request
-> InboundEmail
-> mailbox
-> domain transaction
-> job/event
-> outbound reply
~~~

Do not emit raw email body, full MIME source, credentials, authorization headers, or sensitive attachment contents.

Distinguish ingress rejection, routing failure, mailbox failure, queue backlog, dependency failure, duplicate/replay volume, and quarantine volume.

## Capacity and performance

Measure:

- ingress request rate;
- MIME payload size;
- parsing CPU;
- attachment count/size;
- mailbox processing latency;
- Active Job queue age;
- database writes;
- Active Storage bandwidth;
- downstream dependency calls.

Bound body size, attachment count/size, parser work, per-message network calls, job concurrency, and retry frequency.

Do not increase mailbox worker concurrency without checking database, storage, CPU, and downstream capacity.

## Provider and MTA compatibility

Treat each ingress as an adapter boundary.

Document:

- provider endpoint;
- authentication;
- raw message format;
- signature validation;
- maximum payload;
- retry behavior;
- duplicate behavior;
- timeout/response expectations;
- deployment rotation procedure.

Keep provider-specific parameters at the ingress boundary. The mailbox should consume InboundEmail rather than provider-specific request shapes.
