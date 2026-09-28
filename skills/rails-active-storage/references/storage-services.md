# Storage services, providers, failures, migration, and CDN

Reference for the `rails-active-storage` skill. Load it on demand when a change alters storage services, environments, provider credentials, failure handling, mirrors, or CDN/proxy delivery. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Storage service selection

Choose a storage service from workload and operational requirements:

- local disk for development/test or intentionally local deployments;
- object storage for production durability/scale;
- provider-specific services when the repository already standardizes on them;
- mirror services during controlled migration/replication scenarios.

Evaluate:

- durability;
- region/data residency;
- latency;
- egress cost;
- lifecycle/retention;
- encryption;
- access policy;
- provider limits;
- credentials/identity;
- backup/recovery;
- observability.

Do not choose public object storage merely because it makes URLs easy.

## Environment separation

Use environment-specific service selection and bucket/container separation where appropriate.

Verify:

- development cannot point at production data;
- test uses an isolated test service;
- staging cannot accidentally mutate production objects;
- bucket/container names encode environment where appropriate;
- credentials have least privilege;
- lifecycle policies match retention requirements.

Do not rely solely on convention such as "this config file is only used in staging."

## Provider boundary

Treat object storage as an external dependency.

Define:

- authentication method;
- bucket/container;
- region/endpoint;
- upload/download timeouts;
- retry behavior;
- provider rate limits;
- error classification;
- encryption options;
- lifecycle rules.

For S3-compatible providers, isolate provider-specific options in storage configuration.

Do not embed provider SDK calls in controllers/models when Active Storage can own the storage boundary.

Coordinate provider-specific HTTP behavior with `rails-api-integration`, `rails-reliability-engineering`, and `ruby-dependency-injection` where custom adapters are required.

## Storage failure semantics

Distinguish:

- database attachment state;
- object existence;
- upload completion;
- analysis completion;
- variant generation;
- download availability.

A successful database write does not prove the requested file is safely retrievable in every storage scenario.

Define behavior for:

- provider timeout;
- transient upload failure;
- missing object;
- permission denial;
- quota/rate limit;
- corrupted object;
- analysis failure;
- variant processing failure.

Do not retry every storage error blindly.

Use bounded retries for plausibly transient failures and surface permanent/authentication errors.

## Storage migration and mirrors

When changing providers:

1. inventory existing blobs;
2. define source-of-truth service;
3. copy historical data;
4. configure mirroring if appropriate;
5. monitor replication gaps/failures;
6. verify all files before cutover;
7. switch reads/writes deliberately;
8. retain rollback capability;
9. retire the old service only after reconciliation.

Rails documents mirrors as useful for temporary production migration and explicitly notes that mirroring is not atomic.

Do not describe a mirror as a transactional replica.

## CDN and proxy

If using a CDN, decide whether Active Storage redirect or proxy mode owns delivery.

Review:

- cache keys;
- URL expiry;
- authorization semantics;
- private/public classification;
- CDN host configuration;
- purge/cache invalidation;
- range requests;
- content-disposition behavior.

Do not cache tenant-private content at a shared CDN layer without proving cache-key and authorization isolation.

Compose with `rails-caching` when caching semantics become part of the file-access contract.
