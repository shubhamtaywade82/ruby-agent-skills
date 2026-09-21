# Agent Engineering Contract

This repository is an agent-oriented Ruby/Rails skill library. Every coding agent working here must treat the skill library, pattern library, evaluation corpus, and validators as one system.

## Operating sequence

1. **Discover** the applicable repository skills from `skill-manifest.yml`.
2. **Inspect** the repository, current implementation, tests, runtime/version constraints, and existing conventions before proposing a design.
3. **Resolve ambiguity** before changing code. Do not silently choose between conflicting requirements.
4. **Select patterns only when earned.** Existing repository patterns take precedence over generic preferences. A pattern is guidance, not a mandatory abstraction.
5. **Implement incrementally** in the smallest coherent slice.
6. **Test behavior** at the boundary that owns the contract.
7. **Lint the change** with the repository's RuboCop configuration when Ruby/Rails code is affected.
8. **Run security verification** for security-sensitive Ruby/Rails changes, using the configured scanners and abuse-case tests.
9. **Review the change** for correctness, simplicity, architecture, security, performance, and scope.
10. **Simplify** if an abstraction does not earn its complexity.
11. **Verify** with the repository's validators, focused tests, and applicable CI-equivalent checks.
12. **Report evidence**, not assumptions. Never claim a test, benchmark, CI run, or deployment passed unless it was actually observed.

## Context rules

- Read only the smallest useful source slice first; expand context when evidence requires it.
- Resolve Ruby/Rails versions from repository configuration rather than memory.
- Prefer official/source-backed guidance for framework-sensitive behavior.
- Treat `.rubocop.yml` as the executable Ruby/Rails style baseline; inspect plugin applicability before interpreting findings.
- Treat security scanner output as evidence requiring trust-boundary/data-flow analysis, not as an automatic verdict.
- Treat external input and third-party responses as untrusted at boundaries.
- Never weaken a validator or test merely to make an agent run green.
- Preserve public contracts unless the task explicitly changes them.

## Design rules

- Prefer the simplest implementation satisfying the contract.
- Reuse an existing repository abstraction before introducing a new one.
- Introduce POROs, services, strategies, adapters, policies, presenters, factories, or other patterns only when the responsibility or variation justifies the boundary.
- Keep domain behavior out of controllers/views when it does not belong there.
- Keep persistence integrity in database constraints where application validation alone cannot guarantee it.
- Do not create abstractions solely to satisfy a pattern vocabulary.

## Verification contract

A change is complete only when:
- relevant tests pass;
- validators pass;
- no accidental scope expansion is present;
- public contracts are preserved or intentionally updated;
- unrun checks are explicitly disclosed.

## Skill precedence

When multiple skills apply:

1. explicit task requirements
2. repository architecture and existing conventions
3. runtime/framework constraints
4. focused domain skill
5. design-pattern guidance
6. generic style preferences

When skills conflict, stop and resolve the conflict rather than combining incompatible rules.

## Benchmark integrity

Evaluation fixtures and verifiers are measurement infrastructure. Do not make the evaluator easier by weakening constraints, accepting unverified output, or coupling the verifier to one agent's implementation. Public structural checks must be complemented by behavioral tests and, where appropriate, hidden/adversarial cases.


## Performance-sensitive changes

For performance work:
- establish a workload and baseline before optimizing when practical;
- distinguish latency, throughput, CPU, allocations, GC, database, network, and contention costs;
- use profiling/benchmarking only to answer a concrete question;
- never claim a performance improvement without measurement or a demonstrated structural property;
- do not introduce caching without explicit freshness and invalidation semantics;
- do not increase concurrency without downstream capacity analysis;
- keep performance thresholds stable enough for CI.


## Zeitwerk/autoloading changes

For Ruby/Rails constants and file-layout changes:
- resolve the loader/runtime version first;
- verify path-to-constant and namespace ownership;
- inspect inflections and autoload roots;
- distinguish reloadable and once-loaded code;
- check initializer lifecycle;
- run Zeitwerk/eager-load verification when available;
- do not hide structural loading errors with arbitrary require/require_dependency calls.


## Active Job/background-job changes

For background-job changes:
- resolve the Rails/Active Job/queue-adapter versions first;
- inspect ApplicationJob and existing job conventions;
- make serialization and idempotency explicit;
- classify retryable versus permanent failures;
- inspect transaction/commit semantics when enqueueing from database transactions;
- analyze concurrency and downstream capacity;
- verify queue/worker configuration and shutdown behavior when operational behavior changes;
- test enqueue, perform, failure, retry/discard, and duplicate-execution behavior as applicable.


## Rails request lifecycle/observability changes

For request and production-diagnostics changes:
- resolve Rails version first;
- inspect existing HTTP error, logging, request-ID, and health conventions;
- keep exception-to-response mappings narrow;
- preserve correlation identifiers across request/job/dependency boundaries;
- filter sensitive data before logs/error context;
- use Rails.error for error reporting and ActiveSupport::Notifications for meaningful instrumentation;
- keep instrumentation subscribers observational;
- distinguish liveness from readiness and dependency health;
- verify request/error/health contracts with focused tests.


## Rails database/schema changes

For database changes:
- resolve Rails, adapter, and database versions first;
- inspect schema, existing indexes/constraints, data volume, and deployment order;
- treat migrations as rolling-deployment contracts;
- separate expand/backfill/cutover/contract when compatibility requires it;
- preserve database invariants with constraints where the database is the authoritative writer boundary;
- use bounded/idempotent backfills;
- make transaction, locking, isolation, and deadlock semantics explicit;
- size connection pools against aggregate application concurrency and database limits;
- require query-plan evidence for query/index performance claims;
- test migration and database behavior at the owning boundary.


## Rails production runtime changes

For deployment/runtime changes:
- resolve Rails, Ruby, Puma, Solid Queue, and platform/process-manager versions first;
- inspect actual Puma, container, process-manager, queue, health, and release configuration;
- size web/job concurrency against memory, CPU, database pools, and downstream capacity;
- verify restart mode against preload/plugin configuration;
- align graceful shutdown with the platform hard-kill deadline;
- preserve old/new schema and queued-job compatibility during rolling releases;
- protect runtime secrets and validate required configuration without printing values;
- distinguish application rollback from database/data rollback;
- verify boot, readiness, process lifecycle, and release ordering at the owning boundary.


## Rails test engineering changes

For testing changes:
- resolve the repository's test framework and conventions first;
- select the smallest boundary that proves the contract;
- keep fixtures/factories explicit and bounded;
- preserve deterministic time, randomness, network, and filesystem behavior;
- diagnose flaky tests from seed/order/parallel/runtime evidence instead of adding blind retries;
- treat parallel tests as an isolation and capacity problem;
- disable transactional tests only at the narrow case that requires independent transactions;
- test Active Job enqueue and execution at the relevant boundaries;
- measure test runtime before optimizing;
- keep CI coverage for system tests and eager-loading where the repository requires them.


## Rails API and integration changes

For API and integration changes:
- classify the boundary as inbound API, outbound provider, webhook, internal API, or asynchronous integration;
- resolve Rails/Ruby versions and existing routing, versioning, serializer, authentication, security, and error conventions;
- treat inbound and third-party payloads as untrusted;
- define request/response/error contracts explicitly;
- classify changes as additive or breaking before implementation;
- isolate provider-specific schemas behind adapters rather than leaking them into the domain;
- require bounded network timeouts for outbound HTTP;
- classify retryable versus permanent failures and never use unbounded retries;
- never retry ambiguous non-idempotent mutations without an idempotency mechanism;
- verify webhook authenticity before domain processing and make duplicate/replay behavior explicit;
- make idempotency key scope, persistence, fingerprinting, and duplicate-result semantics explicit;
- preserve correlation identifiers across request/dependency/job/webhook boundaries where applicable;
- exclude credentials, signatures, authorization headers, and sensitive payloads from logs/errors;
- test wire contracts and failure paths with fake transports/request tests;
- consider old/new client, worker, and webhook compatibility during rollout.


## Distributed systems and service architecture changes

For changes crossing process, service, host, queue, broker, or independent datastore boundaries:
- classify the boundary and name the authoritative owner of each invariant;
- inspect API/message schemas, transaction ownership, delivery guarantees, retry/dead-letter behavior, and deployment topology;
- never assume exactly-once execution; make at-least-once duplicate behavior explicit;
- use a database constraint, atomic update, row lock, keyed queue, or single authoritative writer before introducing distributed coordination;
- use an outbox when database commit and message publication must be coupled without a distributed transaction;
- use durable inbox/deduplication for duplicate message delivery and reuse existing idempotent-job semantics for queued execution;
- define acknowledgement timing, replay, ordering, and poison-message behavior;
- bound retries/backpressure across all layers instead of multiplying retry loops;
- make eventual consistency visible through explicit pending/stale semantics and reconciliation where applicable;
- use sagas only when independent transaction owners require cross-step compensation/recovery;
- justify distributed locks over simpler primitives and define lease, ownership, expiry, and fencing behavior when stale holders can mutate state;
- propagate correlation/causation identifiers and record state transitions, not only exceptions;
- preserve old/new message compatibility during rolling deploys;
- test duplicate, delayed, reordered, failed, replayed, and partially completed workflows.

      
## Event-driven messaging changes

For queue, broker, stream, event, and message changes:
- classify the message as command, event, notification, or retry/control message;
- resolve actual transport guarantees for delivery, ordering, retention, acknowledgement, and partitioning;
- define stable message identity, envelope metadata, schema version, correlation, and causation;
- preserve old/new message compatibility during rolling deployments and replay;
- choose routing/partition keys from ordering requirements and hot-key evidence;
- bound consumer concurrency against partitions, database pools, downstream API limits, CPU, and memory;
- make acknowledgement timing explicit and never acknowledge before required durable work;
- classify retryable versus permanent failures and terminate poison-message loops;
- define dead-letter ownership, retention, remediation, authorization, and controlled replay;
- preserve original message identity during retry/replay;
- instrument publish, queue age/lag, processing, retries, dead-letter, and replay state without logging sensitive payloads;
- test duplicate delivery, failures before/after side effects, schema compatibility, dead-letter routing, replay, ordering, and restart/rebalance behavior.


## Reliability engineering changes

For reliability, resilience, overload, or recovery work:
- identify the critical user journey before choosing infrastructure metrics;
- define user-visible SLIs, an evidence-based SLO/window, and the resulting error budget;
- classify dependencies as critical, degradable, optional, or asynchronous;
- bound timeout/retry/concurrency budgets across every layer instead of stacking independent retries;
- use circuit breakers only for justified dependency failure domains and exclude deterministic caller errors from health signals;
- use bulkheads to isolate genuinely shared resources and verify capacity fragmentation does not create a new bottleneck;
- define load-shed priorities and never silently discard durable business work;
- make graceful degradation explicit, including freshness, correctness, authorization, and recovery semantics;
- define RTO/RPO and verify restore, failover, reconciliation, and post-recovery invariants where recovery matters;
- resilience-test failure containment and recovery with deterministic, bounded fault injection;
- make reliability controls observable, reversible, and compatible with rolling deployment;
- report measured evidence and remaining assumptions instead of claiming resilience from structural patterns alone.


## Security engineering and threat-model changes

For architecture-level security changes:
- identify protected assets, actors, attacker capabilities, and trust boundaries before selecting controls;
- distinguish authentication, authorization, tenant isolation, input validation, and output encoding responsibilities;
- map alternate execution paths including controllers, jobs, events, webhooks, admin actions, exports, and direct service entry points;
- treat client, provider, broker, file, URL, build, and dependency inputs as untrusted until the owning boundary verifies them;
- place authorization at the resource/action boundary and verify cross-tenant access cannot bypass it;
- govern secrets by owner, storage, scope, rotation, revocation, and exposure surface;
- constrain arbitrary outbound network access against SSRF, redirect, DNS, private-network, credential-forwarding, and resource-exhaustion risks;
- review dependency, CI, build, and release surfaces as security boundaries;
- turn concrete vulnerabilities into deterministic abuse-case regression tests;
- use repository-configured security scanners as evidence, not as the complete security assessment;
- record accepted residual risk with ownership and review criteria rather than permanent broad scanner suppressions.


## Rails incident engineering changes

For production incident and operational-diagnostics changes:
- resolve the affected user/system contract before investigating individual exceptions;
- inspect existing observability, reliability, runtime, deployment, alerting, runbook, and access conventions before adding new operational mechanisms;
- distinguish symptom, trigger, contributing factor, hypothesis, and evidence-backed root cause;
- preserve existing request/job/message/dependency correlation identifiers instead of creating parallel IDs;
- make alerts actionable with an owner, diagnostic context, response, and recovery condition;
- prefer existing telemetry and bounded read-only diagnostics before production mutation;
- evaluate blast radius, privilege, reversibility, auditability, and user impact before every state-changing mitigation;
- verify recovery through user-impact SLIs and relevant dependency/backlog/data-integrity signals, not only process health;
- build incident timelines from durable timestamps and label hypotheses separately from observed facts;
- make runbooks executable, bounded, reversible, and explicit about stop conditions;
- convert material incidents into owned, testable changes to code, telemetry, alerts, runbooks, resilience controls, or architecture;
- do not disclose secrets or disable security boundaries as a generic incident response technique.


## Rails release engineering changes

For release-engineering and release-readiness changes:
- classify release risk from reversibility, blast radius, schema/data impact, contract impact, security impact, and runtime impact before choosing gates;
- inspect the existing CI/CD, artifact, deployment, migration, feature-flag, and rollback conventions before adding a new release path;
- preserve immutable source/artifact identity and promote the artifact that was actually verified;
- make each release gate evidence-backed, bounded, owned, and explicit about abort/override behavior;
- use progressive exposure only when the platform provides meaningful reduced exposure and a decision gate;
- treat staging/production differences as explicit release concerns when they affect behavior;
- assess old/new web, worker, schema, and message compatibility during rolling releases;
- choose rollback or roll-forward from durable-state and external-side-effect compatibility rather than assuming rollback is always safe;
- verify release health with user-impact, dependency, queue/backlog, readiness, and correctness signals over an appropriate observation window;
- preserve release evidence including source, artifact, gates, exposure, recovery actions, and final state without secrets;
- link failed-release response to incident engineering when user impact or production instability occurs;
- never claim release safety from CI success alone when deployment or runtime evidence has not been observed.

## Rails caching changes

For caching changes:
- establish the workload and bottleneck before introducing a cache;
- inspect the existing cache store, key/version conventions, invalidation mechanisms, authorization/tenant boundaries, deployment topology, and cache tests;
- define the cache layer and sharing scope explicitly;
- treat the key as a correctness/security contract and include every required identity/version dimension;
- define freshness and invalidation from the authoritative state transition instead of relying on scattered callers;
- reason about old/new application overlap and cached serialization across deployments;
- bound stampede, warming, eviction, and source fallback behavior;
- classify cache-store failure separately from source-of-truth failure;
- never cache secrets, authorization failures, or exceptions as successful values;
- keep cache metrics low-cardinality and payload-free;
- test hit/miss, isolation, invalidation, versioning, concurrency, failure, and deployment compatibility as applicable;
- require measured or structurally demonstrated evidence before claiming caching improved performance.
## Rails Action Mailer changes

For email and Action Mailer changes:
- inspect ApplicationMailer, mailer views/layouts, delivery configuration, provider dependencies, queue behavior, recipient rules, security controls, and mailer tests before implementing;
- define the recipient/authorization contract separately from message rendering;
- justify deliver_now versus deliver_later from latency, transaction, retry, and duplicate-delivery semantics;
- ensure asynchronous mail observes committed state when the message depends on transactional data;
- classify provider outcomes as retryable, permanent, or uncertain rather than assuming a failed network call means no email was sent;
- isolate provider-specific behavior and credentials from domain code;
- protect tenant/private data, security tokens, attachments, and email logs;
- use deterministic mailer/Active Job/provider tests rather than live SMTP/API calls;
- preserve delivery correlation without logging full message bodies or sensitive headers;
- use previews/interceptors/observers only for their intended rendering or cross-cutting lifecycle responsibilities;
- do not claim real-world delivery without provider/runtime evidence.
## Rails Action Mailbox changes

For inbound email and Action Mailbox changes:
- inspect the configured ingress, provider/MTA setup, ApplicationMailbox routes, mailbox classes, Active Job queue behavior, InboundEmail schema/storage, authorization rules, Active Storage behavior, retention configuration, observability, and mailbox tests before implementing;
- classify the boundary as external ingress, mailbox routing, mailbox processing, or downstream asynchronous work;
- keep ingress authentication separate from sender identity, recipient authorization, and tenant/resource authorization;
- treat From, Reply-To, Return-Path, custom headers, HTML, links, and attachment metadata as untrusted input until the owning boundary verifies them;
- define provider/MTA retry, duplicate, raw-message, body-size, timeout, and credential-rotation contracts at the ingress boundary;
- keep provider-specific payload handling out of mailbox/domain code;
- order mailbox routes from specific to general, define unmatched-message behavior, and test route collisions;
- keep mailbox classes focused on orchestration and delegate complex domain rules to the owning service/model/policy boundary;
- use before_processing for cheap deterministic prerequisites and keep framework status truthful; do not convert programmer defects into successful delivery;
- separate business-invalid messages, transient dependencies, poison messages, and programmer failures so retry/bounce/quarantine behavior is bounded and explicit;
- do not assume Action Mailbox provides exactly-once business effects; define durable domain idempotency for non-idempotent mutations and preserve message identity during replay;
- persist tenant/resource ownership through authoritative application state and propagate tenant context to downstream jobs/events;
- coordinate business mutations and follow-up jobs/events through the actual transaction/commit contract;
- use rails-active-storage for attachment/storage lifecycle and enforce server-side size/type/content limits;
- treat raw inbound mail as privacy-sensitive data; never log full raw messages or credentials by default;
- review config.action_mailbox.incinerate_after as a raw-message retention policy and distinguish it from lifecycle of derived domain data;
- use deterministic ActionMailbox test helpers and local/test storage/provider doubles; do not rely on live email providers for ordinary CI;
- add negative tests for spoofed senders, cross-tenant targets, duplicate delivery, unmatched routing, poison messages, and sensitive log output;
- never claim inbound email is authenticated as a business user merely because the ingress is authenticated, and never claim exactly-once processing without evidence from the domain idempotency contract.

## Rails Active Storage changes

For Active Storage changes:
- inspect attachment declarations, domain ownership, tenant rules, storage configuration, routes, direct-upload code, processing jobs, purge behavior, and tests before implementation;
- treat the uploaded file as untrusted data and the blob identifier as an object reference, not as authorization;
- define attachment cardinality, replacement/additive semantics, validation, retention, and purge behavior explicitly;
- keep production storage services and credentials environment-isolated and least-privileged;
- treat browser direct uploads as a staged lifecycle: upload, attach to an authorized resource, process/analyze, then clean up unattached blobs;
- review CORS, file-size/content policy, signed URLs, default Active Storage routes, proxy/redirect mode, and authenticated access for private files;
- bound download memory, transformation CPU/memory, processing concurrency, and background retry behavior;
- distinguish logical attachment removal from physical object purge;
- reconcile storage migrations/mirrors rather than assuming replication is atomic;
- use the Active Storage test service and deterministic fixtures for ordinary CI; avoid live cloud-provider dependence;
- never claim storage durability, complete migration, replication completeness, or file delivery success without provider/runtime evidence.
## Rails Action Cable changes

For Action Cable/realtime changes:
- inspect ApplicationCable::Connection, channel hierarchy, subscription parameters, stream naming, broadcast producers, client reconnect behavior, adapter/Redis configuration, process topology, capacity, and tests before implementation;
- keep WebSocket connection authentication separate from per-channel/resource authorization;
- treat all channel parameters and client actions as untrusted API input;
- authorize subscriptions through the owning resource/tenant and never treat a blob/resource ID or stream name as authorization;
- use bounded deterministic stream names and prefer framework resource primitives such as stream_for/broadcast_to when appropriate;
- treat broadcast payloads as versioned wire contracts and avoid serializing entire Active Record objects or sensitive fields;
- do not use Action Cable as durable messaging; define reconnect/refetch reconciliation when missed broadcasts matter;
- coordinate broadcasts with committed state and use outbox/durable event infrastructure when delivery correctness requires it;
- size WebSocket connections, subscriptions, message rate, payload bytes, Redis/pubsub, memory, CPU, and reconnect bursts separately from HTTP capacity;
- define degraded behavior when Redis/Action Cable is unavailable rather than making optional realtime delivery an accidental transaction dependency;
- review allowed origins, credential/session lifetime, tenant isolation, secrets, and sensitive payloads;
- avoid synchronized reconnect storms during deploys and test connection/channel/broadcast behavior with deterministic local adapters;
- never claim realtime delivery or capacity without runtime evidence.
## Rails I18n changes

For I18n/localization changes:
- inspect supported locales, default locale, locale resolution, translation file organization, route conventions, user/account locale preferences, jobs, mailers, APIs, caches, tests, and custom backends before implementation;
- define supported locales and precedence explicitly; normalize/reject untrusted locale input before entering the scoped locale context;
- use request-scoped I18n.with_locale rather than leaking mutable I18n.locale across requests or execution units;
- keep locale separate from authentication/authorization and timezone; locale is presentation context, not authorization.
- use semantic translation keys with explicit interpolation contracts; do not use human-readable translated text as machine-readable identifiers;
- delegate pluralization and locale-aware date/number/currency formatting to I18n rather than hand-building grammar or presentation strings;
- review localized routes/default_url_options and bound locale dimensions when locale participates in URLs;
- explicitly decide whether background work captures or re-reads locale and validate locale again at execution;
- include locale in cache identity only when the cached representation actually varies by locale;
- treat translated HTML, interpolation data, translation administration, and localized caches as security boundaries;
- keep canonical domain data locale-independent and translate at presentation/wire boundaries;
- define missing-translation and fallback behavior for development, test, and production;
- use deterministic locale-sensitive tests and restore locale state between examples;
- never claim localization coverage solely from translation-file presence; verify execution paths, formatting, fallback, and cross-boundary propagation.
## Rails Action Text changes

For Action Text/rich-text changes:
- inspect has_rich_text declarations, Action Text/Trix versions, RichText schema, editor integration, sanitization, custom partials, attachment/attachable behavior, APIs, locale behavior, query patterns, and tests before implementation;
- authorize editing through the owning domain resource; never treat ActionText::RichText IDs or Signed Global IDs as authorization by themselves;
- preserve Action Text server-side sanitization and review custom HTML/link/attachment rendering for XSS and privacy risks;
- treat Trix/client-side validation as usability only; server-side authorization and content controls remain authoritative;
- use rails-active-storage for embedded file storage/access lifecycle rather than duplicating storage-provider logic in Action Text code;
- restrict and explicitly authorize attachable object types, tenant scope, and rendering partials; define missing-record fallback;
- keep public API representations stable and avoid exposing internal RichText/attachment table structure unless explicitly contractual;
- measure RichText and embed query behavior before choosing `with_rich_text_*` preloads; use the narrowest preload justified by the rendering workload;
- review locale and cache identity when rendered rich text varies by locale, permission, content version, or attachment state;
- bound rich-text size, attachment count, and transformation work where product requirements allow;
- coordinate lifecycle/cleanup semantics across RichText and Active Storage instead of assuming external object deletion is transactional;
- add negative security tests for malicious HTML/URLs and unauthorized embedded resources;
- use deterministic local/test storage and avoid live cloud-provider dependencies in ordinary CI;
- never claim rich-text safety merely because the content came from Trix; verify sanitization, authorization, attachable resolution, and final rendering.