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
## Rails Active Support changes

For Active Support and cross-cutting Rails utility changes:
- inspect the Rails/Ruby/Active Support version, existing requires, concerns, class configuration, CurrentAttributes, callback definitions, Notifications events/subscribers, Time.zone conventions, inflections, dynamic constantization, observability, and tests before implementing;
- classify the boundary as loading, concern composition, inherited configuration, request/execution context, callbacks, instrumentation, time semantics, inflection, or framework testing;
- choose the narrowest Active Support API that satisfies the contract; do not use active_support/all inside focused reusable libraries without justification;
- keep ActiveSupport::Concern modules cohesive, document host contracts, and make dependencies explicit; do not create god concerns;
- treat class_attribute as inherited configuration, not mutable request/tenant state; control mutable defaults and test parent/subclass isolation;
- keep CurrentAttributes small and request/execution scoped; define setters, reset behavior, concurrency semantics, and explicit background-job propagation;
- never assume CurrentAttributes automatically propagates across background jobs, threads, or process boundaries;
- use ActiveSupport::Callbacks only for explicit lifecycle protocols; prefer explicit methods/services for significant business workflows and external side effects;
- define ActiveSupport::Notifications event names, payload schemas, cardinality, units, privacy, and subscriber ownership; notification payload is observational telemetry, not the business event bus;
- use monotonic timing when elapsed-duration accuracy matters and keep Time.zone/timezone choices separate from authorization or tenant identity;
- review Active Support inflection and constantization as compatibility/security boundaries; external type names require explicit allowlists;
- keep autoloading/constant ownership in rails-zeitwerk rather than hiding structural loading problems with dynamic constantization;
- isolate global/context state in tests and restore CurrentAttributes, timezone, inherited configuration, and subscriptions;
- never claim framework-state isolation, instrumentation correctness, or context propagation without tests proving the relevant lifecycle boundary.

## Rails Active Model changes

For Active Model and Rails-facing non-persisted model changes:
- treat ActiveModel::Model as an explicit Rails-facing model protocol, not a generic base class;
- inspect the Rails/Ruby version, current Active Model usage, neighboring POROs/form objects/services, Active Record boundaries, form/view consumers, routes, validations, translations, serialization, callbacks, and tests before implementing;
- decide explicitly whether the object should remain a PORO, use Active Model, or become Active Record; do not add Active Model merely because the class has attributes or validations;
- choose the smallest Active Model modules required by actual consumers;
- keep persistence, database constraints, querying, and database lifecycle in Active Record/database boundaries when persistence is intrinsic;
- define typed/default attribute behavior separately from semantic validation; casting success is not domain validity;
- keep validation separate from authorization, transaction orchestration, external API success, and database integrity;
- validation is authorization-independent and is never an authorization mechanism;
- never treat validation as authorization;
- treat to_model, to_key, to_param, and model_name as Rails-facing conversion contracts and never derive authorization from URL parameters;
- treat ActiveModel::Dirty as change tracking rather than persistence and define apply/reset/rollback semantics explicitly;
- use ActiveModel::Callbacks only for intrinsic lifecycle hooks; prefer explicit methods/services for significant workflows and external side effects;
- define serialization fields explicitly and exclude secrets/private state from serializable representations;
- compose ActiveModel::Translation with rails-i18n and preserve stable error/attribute translation contracts;
- use Active Model lint/protocol tests for reusable Rails-facing model objects and test actual form/view/route consumers at focused integration boundaries;
- never claim Rails model compatibility from valid? alone; verify the specific protocol required by the consumer.

## Rails Associations changes

For deep Active Record association changes:
- inspect the Rails version, both association directions, foreign-key columns, primary keys, nullability, uniqueness, database foreign keys, scopes, inverse_of, dependent options, callbacks, through/join models, polymorphic types, autosave, counter/touch behavior, tenant ownership, loading paths, and relationship tests before implementation;
- classify the boundary as cardinality/ownership, collection mutation, through join, polymorphic target, inverse/autosave, dependent lifecycle, counter/touch, association callback, loading, or association testing;
- do not infer database integrity from association declarations; use rails-database-engineering for foreign keys, unique constraints, indexes, nullability, and transaction/locking mechanics;
- when has_one means exactly one row, verify database uniqueness rather than relying only on the association declaration;
- keep belongs_to presence/optional semantics aligned with the actual foreign-key and domain contract;
- inspect both sides of every changed relationship; custom foreign_key, class_name, scopes, and through associations can affect inverse inference, autosave, validation, and duplicate queries;
- use inverse_of explicitly when automatic inverse detection is not reliable and verify the resulting identity/autosave behavior;
- treat has_many :through as a join-model contract; do not assume changing a through collection destroys target records;
- prefer a join model over HABTM when the relationship carries attributes, validations, callbacks, authorization, or lifecycle behavior;
- restrict polymorphic target types to an explicit allowed set and never trust client-provided type names for arbitrary constantization;
- treat dependent as lifecycle behavior that must be reconciled with database cascading, foreign-key nullability, attachment cleanup, audits, and transaction boundaries;
- verify asynchronous dependent destruction against the actual Active Job/runtime and database foreign-key contract;
- make autosave/nested persistence ownership explicit; test parent success/failure and associated-record validation failures;
- treat counter_cache and touch as denormalized coupling requiring authoritative-source and reconciliation reasoning;
- keep before_add/after_add/before_remove/after_remove callbacks narrow and deterministic; do not hide external workflows or authorization engines inside them;
- choose association loading from the actual traversal path; review inverse behavior before adding broad eager loading and compose with rails-active-record strict-loading/query guidance;
- keep association validity separate from authorization and tenant isolation; a valid relationship can still cross a security boundary;
- test cardinality, both directions, collection mutation, through changes, polymorphic targets, dependent behavior, autosave failure, security isolation, and representative loading behavior;
- never claim association-performance improvements without measured query/runtime evidence.
## Rails Active Record changes

For deep Active Record changes:
- inspect the resolved Rails/Active Record version, ApplicationRecord inheritance, model/schema/migrations, associations, validations, callbacks, scopes, default_scope, query consumers, loading conventions, bulk operations, security/tenant rules, performance evidence, and tests before implementation;
- classify the boundary as model ownership, Relation semantics, query composition, scope/default_scope, loading, persistence lifecycle, callbacks, bulk writes/deletes, or Active Record testing;
- keep rails-active-record focused on Active Record object/Relation semantics while delegating schema, indexes, constraints, transactions, locking, isolation, and query-plan mechanics to rails-database-engineering;
- treat ActiveRecord::Relation as a query description until an intended terminal/materializing operation; do not change a composable Relation into an Array or scalar result without preserving the caller contract;
- make ordering and cardinality explicit whenever a query is part of a contract; joins, distinct, grouping, and projections can change result shape;
- use scopes for composable named semantics and treat default_scope as high-risk implicit behavior; never use default_scope as an authorization mechanism;
- choose preload/includes/eager_load/joins/strict_loading from the actual consumer path; do not globally preload graphs or disable strict loading to silence regressions;
- use pluck/pick and other projections only when the caller actually needs scalar data; projection is a contract change, not a generic optimization;
- inspect the exact persistence method before changing it because validations, callbacks, timestamps, dirty state, and transactions differ across write APIs;
- use model callbacks only for lifecycle behavior intrinsic to the record; keep multi-record workflows, authorization, and external integrations outside callbacks;
- use after_commit or after_rollback when an effect depends on transaction outcome, and retain idempotency/correlation for retried external effects;
- do not assume bulk update/delete/import/upsert operations execute per-record validations or callbacks; review database constraints and audit/event semantics before using them;
- do not replace destroy_all with delete_all solely for speed; inspect dependent, callback, storage, auditing, and database-cascade behavior;
- do not treat in-memory model state as authoritative database state after independent or concurrent writes; reload or query authoritative state when required;
- keep tenant predicates and authorization authoritative outside hidden scope assumptions and review unscoped/raw SQL/dynamic identifiers as security boundaries;
- for large datasets, prefer bounded batch processing such as find_each/find_in_batches when their ordering and concurrency semantics fit the workload;
- test Relation type/composition, persistence success/failure, callback commit/rollback, bulk lifecycle, strict loading, deletion/dependents, and tenant boundaries at the owning test layer;
- never claim an Active Record query or loading optimization improved performance without query/runtime evidence.
## Rails Action Controller changes

For Action Controller and deep controller-boundary changes:
- inspect the Rails/Ruby version, routes, controller inheritance, ApplicationController callbacks, authentication/authorization, parameter filtering, request/response formats, session/cookie configuration, exception handling, cache validators, download/streaming code, observability, and request tests before implementation;
- classify the boundary as request input, response contract, session/cookie state, callback lifecycle, content negotiation, conditional response, streaming/download, or controller exception handling;
- use the smallest supported strong-parameter API for the resolved Rails version; prefer params.expect where supported and locally adopted, otherwise use require plus permit;
- treat every request value, header, cookie, session-derived identifier, redirect target, and file name as untrusted until its owning boundary validates or authorizes it;
- never forward raw params into persistence or domain code; strong parameters are an input boundary, not authorization;
- keep controller response contracts explicit: status, format, body/rendering, headers, redirects, empty-body semantics, and error representation;
- remember that redirect_to does not terminate Ruby execution; return when continuing the method could produce side effects or another response;
- preserve Rails open-redirect protections and never enable cross-host redirects for untrusted input;
- keep session/cookie payloads minimal, treat signed versus encrypted storage deliberately, and never use session/cookie presence as the authorization source;
- keep controller callbacks narrow and action-scoped; use them for request prerequisites, not business workflows, transactions, or large orchestration graphs;
- define supported response formats explicitly and compose API wire contracts with rails-api-integration;
- use ETag/Last-Modified only when validator identity covers every representation dimension such as tenant, permission, locale, and other private variants;
- distinguish HTTP 304 transport behavior from application-state correctness and coordinate shared/private caching with rails-caching;
- authorize downloads before opening the source, bound producer/database work, and account for long-lived streams in request concurrency and runtime capacity;
- do not stream unbounded database/provider work directly from a controller without bounded production, timeout, disconnect, and cleanup semantics;
- use rescue_from only for expected errors with a stable HTTP contract and do not rescue StandardError broadly to hide programmer defects;
- coordinate error reporting with rails-observability rather than building one-controller global error handling;
- test status, content type, headers, redirect behavior, parameter rejection, authorization, callback scope, conditional 304 behavior, session/cookies, downloads, and expected/unexpected exception paths as applicable;
- never claim a controller contract is safe or performant without request-level evidence or focused regression tests.
## Rails Action View changes

For Action View and rendering changes:
- inspect the Rails/Action View version, template engines, view paths, partial/layout conventions, helpers, presenters, localization, caching, output-safety rules, and view/request/system tests before implementing;
- classify the boundary as template lookup, partial contract, layout, helper, output safety, localization, caching, or rendering performance;
- keep domain authorization, persistence, and external side effects outside templates and helpers; rendering receives already-authorized/prepared data;
- define partial locals explicitly and use strict locals when the partial has a stable interface and the repository Rails version supports it;
- treat changes to required/default locals as caller-contract changes and audit all callers;
- keep layout selection deterministic and never derive a layout path from untrusted input;
- keep helpers presentation-focused; do not let helpers become hidden service objects, query orchestrators, authorization engines, or external API clients;
- preserve Action View's default escaping for untrusted strings; review raw, html_safe, safe_join, sanitize, and custom sanitizer allowlists as security-sensitive operations;
- never mark user input HTML-safe and never expand sanitizer allowlists merely to bypass a rendering defect;
- use rails-i18n for locale context and keep localized templates free of duplicated domain rules; test canonical fallback behavior;
- coordinate fragment and collection caching with rails-caching, including locale/tenant/permission identity when rendered output varies;
- measure template, partial, query, allocation, cache, and output costs before making performance claims;
- do not solve view N+1s by blindly caching private output or globally preloading unrelated records;
- use deterministic view/request/system tests and targeted XSS/unsafe-URL regressions rather than relying only on large snapshots;
- never claim a rendering optimization improved performance without workload evidence or a demonstrated structural property.

## Rails Action Mailbox changes

For inbound email and Action Mailbox changes:
- inspect the configured ingress, provider/MTA setup, ApplicationMailbox routes, mailbox classes, Active Job queue behavior, InboundEmail schema/storage, authorization rules, Active Storage behavior, retention configuration, observability, and mailbox tests before implementing;
- classify the boundary as external ingress, mailbox routing, mailbox processing, or downstream asynchronous work;
- keep ingress authentication separate from sender identity, recipient authorization, and tenant/resource authorization;
- treat the From header, Reply-To, Return-Path, custom headers, HTML, links, and attachment metadata as untrusted input until the owning boundary verifies them;
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

## Rails Validations changes

For deep Rails validation changes:
- inspect resolved Rails/Ruby/adapter versions, model/object definition, schema constraints, indexes, associations, callbacks, validation contexts, custom validators, error consumers, direct/bulk write paths, and tests;
- classify the boundary as lifecycle, validator semantics, condition/context, error contract, association validation, uniqueness/invariant enforcement, custom validator, strict failure, validation callback, or bypass path;
- keep ownership explicit: model validation answers whether state is acceptable at that boundary; database constraints own invariants that must survive concurrency and alternate writers;
- never use validation as authorization, tenant access control, transaction orchestration, external API success handling, or durable workflow;
- inspect all relevant write APIs because direct/bulk operations can bypass validations; use rails-database-engineering for authoritative constraints;
- treat on, except_on, if, unless, allow_nil, allow_blank, and strict as explicit contract choices and test their interactions;
- use custom validation contexts only for named operations with explicit callers; do not make ordinary save silently accept invalid domain state;
- prefer the narrowest built-in validator and justify reusable validator classes;
- keep validation callbacks local and deterministic; never hide external effects, authorization, or multi-step workflow in them;
- treat ActiveModel::Errors as a structured contract and preserve attribute/type/detail identity;
- keep associated validation graphs bounded and coordinate with inverse/autosave/nested-persistence ownership;
- pair application uniqueness validation with database enforcement when the invariant is authoritative, including tenant/scope/normalization semantics;
- use strict validation only when callers explicitly expect fail-fast exceptions;
- test lifecycle, contexts, conditions, error shape, persistence conflicts, associated failures, and bypass writers at their owning boundaries;
- treat direct/bulk writers as a validation bypass audit surface and make intentional validation bypasses explicit;
- never claim validation safety from valid? alone when alternate writers or database-level enforcement matter.

## Rails Routing changes

For deep Rails routing changes:
- inspect resolved Rails/Ruby versions, the effective route table, route-loader files, controller namespaces, helper call sites, constraints, authentication/authorization conventions, localized/host-aware routing, and routing/request tests;
- classify the boundary as precedence, resource hierarchy, nested/shallow routing, namespace/scope, constraint, helper generation, concern, direct/resolve mapping, mounted endpoint, redirect/catch-all, or route testing;
- treat route declaration order as executable behavior because the first matching route wins; inspect generic dynamic routes before adding literal/static routes;
- use nested routes only when parent identity is part of the public addressing contract and evaluate shallow member routes when child identity is sufficient;
- keep namespace, path, controller module, and helper-name dimensions explicit instead of assuming namespace is always the desired scope;
- keep segment/request/custom constraints cheap, deterministic, side-effect free, and separate from authorization and business validation;
- treat generated path/url helpers and polymorphic/direct/resolve generation as public application contracts when callers depend on them;
- use routing concerns only for stable shared route capabilities and inspect their expanded route surface;
- review mounted Rack/engine boundaries for ownership, route precedence, helpers/proxies, authentication, authorization, and failure behavior;
- keep wildcard/catch-all routes last or explicitly ordered and test important negative cases;
- use route assertions for generation/recognition and request/system tests for cross-layer dispatch behavior;
- do not claim routing correctness from routes.rb source alone; verify the effective route table and important dispatch/generation contracts.


## Rails authorization changes

For authorization changes:
- resolve the Ruby/Rails and authorization-library versions and identify the repository's authoritative mechanism before implementation;
- keep authentication and authorization separate; authentication establishes identity while authorization establishes permission;
- inspect resource lookup and collection scopes for IDOR and cross-tenant enumeration before adding policy checks;
- treat tenant/account membership as a security boundary and never trust a client-supplied tenant identifier as proof;
- reuse the existing Pundit, CanCanCan, custom policy, or capability mechanism instead of creating a parallel policy engine;
- authorize services, jobs, APIs, and Action Cable independently when they can be invoked outside the original controller request;
- re-resolve mutable membership/resource state in background jobs and fail closed when authorization is stale;
- keep strong parameters, validation, and authorization as distinct controls;
- review TOCTOU windows when authorization depends on mutable state and coordinate with transactions, locks, and database constraints;
- include tenant, actor, action, resource, and relevant permission version in authorization cache identity and define invalidation;
- never log credentials or sensitive policy inputs merely to explain an authorization decision;
- add deterministic allow/deny, cross-tenant, collection-scope, direct-service, job, API/realtime, and IDOR regression tests;
- verify the actual repository contract and report only observed validation evidence.

## Rails asset/build changes

For Rails asset/build changes:
- resolve Ruby/Rails, asset-pipeline, package-manager, and JavaScript/CSS runtime versions before changing tooling;
- inspect the actual development, CI, and production build commands rather than inferring the toolchain from package files;
- classify the boundary as asset pipeline, Importmap, JS bundling, CSS bundling, development process, dependency/runtime, artifact/cache, or release build;
- choose the smallest repository-consistent asset strategy; do not migrate toolchains merely because another tool is familiar;
- treat lockfiles, runtime versions, build scripts, and install hooks as executable dependency contracts;
- make `bin/dev`/Procfile.dev process ownership and failure propagation explicit;
- require reproducible dependency installation and production-like asset builds for release-relevant changes;
- ensure CI executes the actual release-relevant asset/precompile path;
- review dependency install scripts, private registries, build-time secrets, source maps, CDN dependencies, and generated client artifacts as supply-chain/security boundaries;
- ensure dependency/build caches are invalidated by relevant lockfile/source/runtime changes;
- distinguish development watchers from successful production builds;
- add deterministic clean-build/precompile/system verification and inspect CI evidence;
- do not claim production parity or reproducibility from a single local build.

## Rails Hotwire changes

For Hotwire changes:
- resolve the Ruby/Rails and turbo-rails/Stimulus versions and inspect the JavaScript loading strategy before implementation;
- classify the interaction as Turbo Drive, Frame, Stream, morph/refresh, Stimulus lifecycle, or a cross-boundary composition;
- preserve server-side authentication, authorization, validation, CSRF, status, redirect, and caching semantics;
- treat frame IDs, DOM IDs, stream targets, and client data attributes as identifiers, not authorization;
- keep Turbo Frame and Stream responses stable and explicit; audit partial/DOM contracts when IDs or target structure change;
- make Stimulus controllers cohesive and make connect/disconnect cleanup idempotent for listeners, timers, observers, subscriptions, and widgets;
- review morphing/refresh for DOM identity and client-state preservation rather than assuming rerendering is harmless;
- preserve progressive enhancement and semantic HTML for critical workflows;
- review accessibility for focus, errors, live updates, keyboard behavior, and loading states;
- isolate private frame/stream HTML in cache identity and tenant/resource broadcast channels;
- coordinate Turbo Stream broadcasts with Action Cable and durable eventing rather than treating browser updates as the source of truth;
- add deterministic request/system/JavaScript tests for the protocol and lifecycle boundary;
- do not claim Hotwire correctness from manual browser success alone.

## Rails authentication changes

For authentication changes:
- resolve the Ruby/Rails version and identify the actual mechanism in use before implementation;
- inspect generated Rails authentication, Devise, custom concerns, middleware, session stores, token stores, and alternate authentication paths;
- keep authentication and authorization separate and preserve the repository's authoritative policy boundary;
- treat credential material, password reset tokens, session cookies, and bearer tokens as secrets that must not enter logs, jobs, events, or telemetry;
- model authentication as explicit state transitions: credential verification, session/token establishment, request context, logout, expiry, and revocation;
- verify session fixation resistance and fresh session state after successful login;
- define current-session, per-device, global revocation, password-change, and compromise semantics where applicable;
- treat password recovery as a bounded one-time/expiring authentication protocol with enumeration-safe responses;
- separate browser session authentication from API/service credentials and verify CSRF semantics rather than disabling protection broadly;
- propagate actor/tenant attribution without serializing live authentication credentials and re-evaluate authorization at asynchronous boundaries;
- require fresh authentication for security-sensitive credential/privilege changes when the product/security contract requires it;
- add deterministic tests for success and rejection paths, expiry, revocation, fixation, recovery replay, and abuse controls;
- run bin/validate and security tooling, and report only observed verification evidence.


## Rails Rack/middleware changes

For Rack and middleware changes:
- resolve Ruby, Rails, Rack, server, and proxy/runtime versions before implementation;
- inspect the actual middleware stack in relevant environments and use `bin/rails middleware` or equivalent evidence;
- treat middleware order as behavior, not formatting;
- keep custom middleware narrowly cross-cutting and out of domain authorization/business-rule ownership;
- preserve the Rack `[status, headers, body]` contract and body lifecycle;
- make short-circuit responses explicit about downstream execution, headers, telemetry, and security;
- preserve intentional exception ownership and do not use broad middleware rescue as a generic error sink;
- keep request state local and review shared state for thread/fiber/process safety;
- reuse the repository's authoritative request-ID/correlation and telemetry mechanisms;
- treat forwarded/proxy headers as untrusted until the deployment trust boundary establishes their authority;
- ensure rate limiting accounts for worker/process/instance topology and bounded shared state;
- test middleware directly and test registration/order when stack composition is contractual;
- verify environment-specific stacks and production proxy behavior where relevant;
- report measured verification evidence rather than claiming correctness from static inspection.


## Rails initialization/configuration changes

For Rails boot and configuration changes:
- resolve Ruby/Rails versions and inspect actual boot/configuration files before implementation;
- identify configuration ownership and actual precedence across defaults, application config, environment, credentials, and deployment settings;
- treat initializer dependencies as lifecycle contracts rather than incidental filename ordering;
- choose boot, preparation, or runtime execution deliberately;
- coordinate reload-sensitive setup with Zeitwerk and make repeated registration safe;
- minimize network/database/filesystem work during boot and bound any required external dependency;
- make required boot invariants fail fast with actionable, secret-free diagnostics;
- keep credentials and server-only configuration out of logs and client-visible bundles;
- inspect development/test/production configuration independently;
- test configuration precedence, initializer registration, boot failure, reload behavior, and production-like startup where applicable;
- measure boot-time performance before optimizing;
- report observed validation evidence and do not claim boot correctness from static inspection.


## Rails Engine/Railtie changes

For Rails Engine, Railtie, plugin, or mountable-extension changes:
- resolve Ruby/Rails/Bundler and engine gem versions before implementation;
- classify the extension as Engine, mountable Engine, Railtie-only plugin, or ordinary gem;
- inspect engine/railtie files, gemspec, namespace, mounts, routes, initializers, generators, tasks, assets, migrations, and dummy application;
- keep host application authority explicit; do not leak engine internals into host behavior without a supported contract;
- use namespace isolation when ownership requires it and do not confuse isolation with authorization;
- treat engine mounts/routes as explicit exposure and security boundaries;
- define engine configuration as a public namespaced contract rather than reading arbitrary host globals;
- coordinate Engine/Railtie lifecycle with initialization/configuration and Zeitwerk rules;
- review gemspec Ruby/Rails constraints and supported compatibility matrices;
- prefer supported host extension points over undocumented monkey patches;
- test engine boot, dummy-host integration, routes/mounting, autoloading, configuration, and changed generators/tasks/assets;
- do not claim Engine compatibility or isolation without executable evidence.
