# Observability and testing

Reference for the `rails-active-storage` skill. Load it on demand when adding storage instrumentation or choosing and writing Active Storage tests. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Observability

Track the file lifecycle rather than only application exceptions.

Useful bounded dimensions include:

- attachment/model type;
- operation (upload, attach, download, purge, analyze, variant);
- storage service;
- outcome class;
- latency;
- retry count;
- file-size bucket;
- processing type.

Avoid logging:

- signed IDs;
- private blob URLs;
- access tokens;
- credentials;
- full filenames when sensitive;
- raw file contents.

Correlate asynchronous analysis/variant jobs with the initiating request or business operation where safe.

Use `rails-observability` for instrumentation and `rails-incident-engineering` for operational diagnosis.

## Testing

Test at the smallest boundary that proves the file contract.

Include:

- attachment association behavior;
- validation of size/content policy;
- replacement versus additive semantics;
- authorization and tenant isolation;
- direct-upload completion/ownership;
- authenticated download;
- private/public access contract;
- variant/preview behavior;
- purge behavior;
- unattached cleanup;
- provider failure handling;
- Active Job analysis/processing behavior;
- test storage isolation.

Use the Active Storage test service and local fixtures rather than live cloud providers in ordinary CI tests.

Do not make the test suite depend on networked object storage unless that is an intentional integration environment.
