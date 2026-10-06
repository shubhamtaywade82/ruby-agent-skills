# GraphQL APIs with graphql-ruby

Reference for the `rails-api-integration` skill. Load it on demand when a change adds or alters a `graphql-ruby` schema, type, field, mutation, resolver, or data source. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

Resolve the installed `graphql` gem version from `Gemfile.lock` before using any API below; the method names here follow the current graphql-ruby guides.

## The schema is the public contract

- Treat type and field names, nullability, and argument shapes as a published contract, exactly like a versioned REST endpoint.
- Add fields and arguments compatibly. Deprecate with `deprecation_reason:` before removing anything, and make a field non-null only when every resolver path can honour it.
- Return business failures as a typed result: a payload with an `errors` field on mutations. Reserve top-level GraphQL errors for transport, authorization, and unexpected failures.

## Authorization belongs to every object and field

A GraphQL query can reach the same record through many paths, so check permissions where the data leaves the schema, not only at the entry field. Delegate the decision itself to the application's policy layer (`rails-authorization`); graphql-ruby only enforces it.

- **Object level:** `def self.authorized?(object, context)` on the type, calling `super` first. When it returns false, the field receives `nil` and `Schema.unauthorized_object` decides the outcome.
- **Field level:** `def authorized?(object, args, context)` on the field class, for sensitive fields on otherwise visible objects. A failure goes to `Schema.unauthorized_field`.
- **Mutations and resolvers:** `def self.authorized?(object, context)`, plus an instance `authorized?` that receives the loaded arguments as keywords (for example `def authorized?(employee:)`), so loaded records are checked too. Returning `false`, or `[false, { errors: [...] }]`, halts the mutation; raising `GraphQL::ExecutionError` halts it with a top-level error.
- **Lists:** `def self.scope_items(items, context)` filters list and connection fields, which are scoped by default. Use `scope: false` only on fields that are already scoped another way, and say so in the change.
- Decide deliberately between returning `nil` and raising `GraphQL::ExecutionError` in the unauthorized hooks. Raising reveals that the object exists; returning `nil` keeps lookups enumeration-safe.

Test denial explicitly: for every protected type and field, a query from an actor without permission must get the chosen denial outcome, including when it reaches the object through a nested path.

## Batch loading prevents N+1 queries

Resolvers run per object, so a naive association lookup in a field is an N+1 query.

- Enable batching with `use GraphQL::Dataloader` in the schema.
- Define a source with `class Sources::RecordById < GraphQL::Dataloader::Source` and `def fetch(keys)`, returning results in the same order as `keys`, with `nil` for missing keys.
- Load from fields with `dataloader.with(Sources::RecordById, Model).load(id)` or `.load_all(ids)`.
- Pin the batching with a query-count test, following the query-count regression gate in `rails-performance`: a list of N parents must not cost N+1 queries.

## Bound query cost

A single GraphQL request can ask for an unbounded tree, so the schema must refuse expensive queries.

- Set `max_depth` and `max_complexity` in the schema, both of which count introspection fields by default. Override them per query only from trusted server code.
- Paginate list fields with connections and a maximum page size rather than returning unbounded arrays.
- Decide whether production exposes introspection. If not, use `disable_introspection_entry_points` (or the `__schema`- and `__type`-specific variants) in that environment.

## Transport and authentication

- The `/graphql` endpoint is an ordinary controller. Authentication, CSRF for cookie sessions, rate limits, and request logging follow the rest of this skill and `rails-authentication`.
- Build `context` from the authenticated request only (current actor, tenant, request id). Never trust a client-supplied actor or tenant in variables.
- Log the operation name and a query fingerprint, not full variables, which can carry personal data.

## Verification

- Schema tests: dump the schema (`MySchema.to_definition`) and compare it against a committed snapshot, so contract changes are reviewed.
- Request tests through the controller for success, validation-error payloads, authentication failure, and authorization denial.
- A query-count test on at least one list path with nested associations.
- Rejection tests for queries exceeding `max_depth` and `max_complexity`.
