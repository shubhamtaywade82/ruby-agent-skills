---
name: rails-routing
description: Use when designing, changing, debugging, reviewing, or testing Rails routes, resource hierarchies, route helpers, scopes, constraints, routing concerns, direct routes, mounted endpoints, or URL generation.
---

# Rails Routing

## Purpose

Treat the Rails router as an explicit public dispatch and URL-generation contract. Design routes so path, HTTP verb, controller/action, parameters, helper names, constraints, resource relationships, and generation behavior are intentional, inspectable, secure, and stable.

## Activate when

- adding, removing, changing, or debugging a route;
- changing resource hierarchies, nested or shallow URLs, namespaces, scopes, or API versions;
- changing route constraints, host/subdomain/format behavior, route concerns, direct routes, resolve mappings, redirects, wildcards, or mounted endpoints;
- changing polymorphic URL/path generation;
- restructuring a large routes file;
- changing localized or host-aware URLs;
- reviewing route exposure, route-table complexity, URL stability, or routing tests.

## Repository inspection

Inspect before editing:

- config/routes.rb and route files loaded from it;
- bin/rails routes output and filtered route searches;
- controller namespaces/actions and routing concerns;
- resources/resource, scope, namespace, constraints, concern, direct, resolve, root, mount, and redirect declarations;
- URL/path helper call sites in controllers, views, mailers, jobs, serializers, and policies;
- to_param, model naming, polymorphic routing, and custom route proxy usage;
- authentication/authorization and tenant/host constraints;
- localized routing and locale propagation;
- route, request, integration, and system tests;
- resolved Ruby/Rails versions before using version-sensitive APIs.

Use the effective route table, not only routes.rb source, when route resolution is uncertain.

## Routing mental model

The router performs two related jobs:

1. Recognition: match the first applicable incoming request by HTTP verb, path, format, and constraints to a dispatch target.
2. Generation: produce stable path/URL helpers and object-aware routes from the declared route set.

Treat both directions as contracts. A route can recognize correctly while generating an unintended helper, and a helper can generate a syntactically valid URL whose dispatch or authorization semantics are wrong.

## Resource routing

Prefer resourceful routing when the domain naturally maps to resources.

Use resources for collections and identified members. Use singular resource only when the domain truly has one addressable instance per scope.

Restrict generated actions with only/except when the public surface does not need all CRUD routes. Do not create routes merely because a controller contains an action.

Use member/collection routes only for coherent resource operations. Prefer an explicit resource or command-style endpoint when a custom operation has a distinct domain identity.

## Route precedence and shadowing

Rails matches routes in declaration order; the first matching route wins. A generic dynamic route such as /photos/:id can therefore capture a literal path such as /photos/poll when the literal route appears later.

When adding a route:

1. inspect neighboring routes;
2. identify generic routes capable of recognizing the new path;
3. place specific routes before broader routes when both intentionally coexist;
4. verify actual recognition with bin/rails routes and a focused request/routing test.

Do not add arbitrary constraints merely to hide a route-order defect.

## Nested and shallow resources

Use nesting to encode a real parent-child addressing contract, not merely a database association.

Keep nested routes shallow enough that URLs and helpers remain comprehensible. Rails explicitly recommends limiting deep nesting and supports shallow routing when only collection actions need parent context while member routes are uniquely identifiable by the child.

Before nesting, answer:

- Which parent identity is required to address the child?
- Is the child globally addressable?
- Must the parent constrain authorization or tenancy?
- Will member paths remain stable if the parent relationship changes?
- Are helper signatures becoming unnecessarily complex?

Never infer authorization from URL nesting.

## Namespaces and scopes

Treat path, controller module, and helper name as independent dimensions.

- namespace conventionally changes path, helper namespace, and controller module;
- scope module changes controller resolution without changing the public path;
- scope path changes the public path without changing the controller module;
- scope as changes helper names;
- parametric scopes add explicit route context such as account identifiers.

Choose the form that matches the desired contract. Do not introduce a namespace solely because a controller directory exists.

## Constraints

Use constraints to make route matching narrower and deterministic when the request itself carries a meaningful routing discriminator.

Typical constraints include segment formats, host/subdomain, request properties, formats, and bounded objects responding to matches?.

Keep constraints cheap, deterministic, and side-effect free. Do not perform database writes, network calls, authorization workflows, or business transactions inside constraints.

Constraints shape dispatch; they are not authorization, validation, or domain invariants. Rails notes that request constraint values should match the corresponding Request method value type.

## Route helpers and URL generation

Treat generated helper names as public interfaces when callers depend on them.

Prefer route helpers over hard-coded paths. Use path helpers for relative URLs and URL helpers when an absolute URL is required.

When changing as, param, path, nesting, namespace, or scope, verify helper names and signatures.

For object-based URL generation:

- inspect to_param and persisted state;
- use polymorphic helpers when they express an existing repository convention;
- use resolve for deliberate singular/custom mappings;
- test persisted and relevant new-record behavior.

Do not allow identifiers, slugs, or object conversion semantics to drift accidentally when URLs are public contracts.

## Routing concerns

Use routing concerns to reuse a genuinely stable group of routes across compatible resources.

Inspect concern expansion with bin/rails routes. A concern should describe a route capability, not hide business workflow or create an implicit authorization mechanism.

Avoid concerns that create unexpected route names, ambiguous nesting, or broad route surfaces across unrelated resources.

## Non-resourceful routes

Use explicit routes for genuinely non-CRUD contracts such as legacy URLs, webhooks, health endpoints, callbacks, and bounded application operations.

For every custom route, define and test:

- HTTP verb;
- exact path;
- dispatch target;
- parameters;
- helper name when generated;
- authentication/authorization ownership;
- redirect/deprecation behavior when relevant.

Avoid match-all-verb routing unless the contract genuinely needs multiple verbs.

## Direct routes and resolve

Use direct routes when callers need a stable URL-generation abstraction whose internal composition is more complex than a conventional helper.

Use resolve when object-based routing needs an explicit mapping that ordinary polymorphic routing cannot infer.

Keep both deterministic and free of side effects. Do not hide authorization or database lookups in route-generation blocks.

## Wildcards, redirects, and catch-alls

Wildcard routes are deliberately broad. Place them after narrower routes and test intended matches plus important negative cases.

For redirects, verify status, target normalization, host/scheme behavior, and loop prevention. Treat user-controlled redirect targets as a security boundary.

A catch-all route needs an explicit purpose and owner. Do not use it as a generic substitute for correct routing.

## Rack mounts and engines

Rails routing can forward requests to Rack endpoints, and engines contribute additional route sets. Treat a mount as a separate dispatch and security boundary.

When mounting:

- identify owner and trust boundary;
- choose and test the mount path;
- verify helper/proxy behavior;
- preserve authentication and authorization boundaries;
- inspect route precedence around the mount;
- test failure behavior when the mounted endpoint is unavailable.

Deep engine/Railtie implementation belongs to the dedicated engine skill when that skill is selected.

## API and format routing

Keep API/version routing explicit and compatible with the current application contract.

Use namespaces/scopes or constraints only when they represent an actual version or format boundary. Do not encode arbitrary client behavior into URLs just to avoid controller/service decisions.

When format participates in routing, test explicit and implicit format behavior separately. Content negotiation after dispatch remains an Action Controller concern.

## Localization and host-aware routing

When locale, host, or subdomain participates in URL identity:

- compose rails-i18n for locale resolution/propagation;
- define whether locale is path state or request context;
- ensure helpers receive the required dimensions;
- test host/subdomain constraints with realistic requests;
- prevent wrong-tenant, wrong-host, or wrong-locale URL generation.

Locale is presentation/request context, not authorization.

## Route-file organization

Keep routes readable and locally navigable. For large applications, use the repository's established route-loading/splitting convention rather than inventing a parallel router abstraction.

Every extracted file participates in the same effective route set. Verify the aggregate route table and not only individual source fragments.

## Security boundary

Routing answers which endpoint receives a request, not whether the actor may perform the operation.

Compose routing with authentication, authorization, tenant isolation, input validation, and relevant request security controls.

Do not infer authorization from:

- a namespace such as admin;
- a private-looking path;
- a route constraint;
- an opaque or signed-looking identifier;
- an HTTP verb.

Review route exposure as part of the public attack surface.

## Performance and operability

Routing is generally cheap, but complexity becomes an engineering concern with many overlapping dynamic routes, expensive custom constraints, duplicated declarations, broad wildcards before specific routes, or very large route sets.

Measure before optimizing. Prefer simplification and deterministic constraints over clever dispatch logic.

## Testing and verification

Use the smallest boundary that proves the route contract:

- route-table inspection for declaration correctness;
- assert_generates for URL/path generation;
- assert_recognizes for request recognition;
- assert_routing when generation and recognition form one contract;
- request/integration tests for dispatch plus controller behavior;
- system tests when browser navigation or redirects matter.

Rails documents these route-specific assertions for generation and recognition.

Always include negative cases when relevant: wrong verb, mismatched constraint, shadowed route, unsupported format, wrong host/subdomain, unauthorized namespace access, and catch-all behavior.

## Agent review checklist

- [ ] Ruby/Rails version resolved
- [ ] effective route table inspected
- [ ] route precedence checked
- [ ] resource hierarchy intentional
- [ ] nested depth justified or shallow routing used
- [ ] namespace/scope dimensions explicit
- [ ] constraints cheap, deterministic, and non-authorizing
- [ ] helper names/signatures stable or intentionally migrated
- [ ] custom routes have explicit contracts
- [ ] direct/resolve/polymorphic routing tested when used
- [ ] wildcard/redirect/catch-all behavior bounded
- [ ] mounted endpoints have clear ownership and authorization
- [ ] locale/host/tenant dimensions tested when relevant
- [ ] authorization remains outside routing
- [ ] focused routing tests exist
- [ ] route-table verification performed

## Verification

Run, as applicable:

    bin/rails routes
    bin/rails routes -g users
    bin/rails test test/routing_test.rb

Then run request/integration/system tests that own the affected endpoint. Review generated helpers and actual dispatch behavior. For version-sensitive routing APIs, verify against the resolved Rails version and official guide/API documentation.

## Source foundation

Derived from the Rails Routing Guide's resource routing, helper generation, controller namespaces/scopes, nested resources, routing concerns, constraints, direct routes, resolve, Rack mounting, route inspection, and routing-test contracts; supplemented by the repository's existing routing/REST/testing/security material.
