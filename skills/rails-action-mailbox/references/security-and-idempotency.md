# Authenticity, idempotency, and tenant association

Reference for the `rails-action-mailbox` skill. Load it on demand when a change trusts sender identity, deduplicates deliveries, or associates email with tenants or resources. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Authenticity and security

Treat inbound email as hostile input.

Separate these questions:

~~~
Was the ingress request authenticated?
Was the provider message authentic?
Is the claimed sender eligible?
Is the recipient authorized?
Is this operation allowed for this tenant/resource?
Is the content safe to parse/store/render?
~~~

Review:

- ingress authentication;
- SPF/DKIM/DMARC evidence when product policy requires it;
- provider signature/token validation;
- sender normalization;
- recipient/alias authorization;
- tenant isolation;
- header injection;
- HTML content;
- URL schemes;
- attachments;
- archive/privacy policy;
- secrets and credentials in message content;
- log redaction.

Do not trust From, Reply-To, Return-Path, or arbitrary headers as authentication merely because they parse successfully.

If sender identity is required for authorization, define the authoritative identity proof explicitly.

Never log full raw email bodies by default.

## Idempotency and duplicate delivery

Inbound email can be repeated by providers, retries, users, forwards, or operational replay.

Do not assume one InboundEmail row means the business effect has happened exactly once.

Define a domain idempotency key where duplicate effects matter. Preferred evidence can include:

- stable Message-ID;
- provider event/message identifier;
- repository-owned ingestion identifier;
- domain-specific immutable fingerprint when no stable identifier exists.

Store the idempotency decision at the same durable owner as the business side effect.

~~~
inbound evidence
-> idempotency lookup/constraint
-> domain transaction
-> durable result
~~~

For replay:

- preserve original message identity;
- record replay attempt/operator context;
- prevent replay from bypassing authorization;
- make duplicate handling deterministic.

Compose with the `inbox-deduplication` pattern for asynchronous-consumer-like workflows.

## Tenant and resource association

Resolve the domain owner through authoritative application state.

Examples:

- recipient alias -> tenant;
- verified sender -> user;
- reply token/address -> thread;
- mailbox alias -> project.

Do not derive authorization solely from:

- mailbox class name;
- recipient local-part;
- arbitrary custom header;
- message body;
- signed-looking but unverified token.

For multi-tenant systems:

1. resolve tenant;
2. verify sender/operation within that tenant;
3. authorize the target resource;
4. perform the mutation under that tenant boundary;
5. test cross-tenant rejection.

Keep tenant identity explicit in downstream jobs/events created from inbound mail.
