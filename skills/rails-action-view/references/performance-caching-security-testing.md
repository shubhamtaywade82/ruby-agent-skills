# Rendering performance, caching, security, and testing

Reference for the `rails-action-view` skill. Load it on demand when a change has rendering-performance, fragment-caching, security/privacy, or view-test impact. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Rendering performance

Rendering performance is a workload problem.

Measure before optimizing:

- template lookup;
- database queries triggered by views;
- partial count;
- collection rendering;
- helper allocations;
- HTML output size;
- fragment-cache hit rate;
- view compilation/runtime.

Prefer preparing data outside templates, collection/object rendering where appropriate, cache only with correctness identity, appropriate preload/query shaping in the owning data layer, and bounded partial depth.

Rails supports collection fragment caching and can fetch cached collection fragments efficiently.

Do not solve an N+1 by globally caching private or authorization-sensitive output.

Do not add presenters solely to disguise an unmeasured performance issue.

## Caching interaction

Coordinate with rails-caching.

For cached view fragments define cache key identity, template dependencies, record/version identity, locale, tenant/user/permission dimensions when applicable, invalidation behavior, and public/private scope.

Rails fragment caches can incorporate template tree digests and record versions, while collection caching can use explicit cache keys.

Never cache a private fragment under a key shared across tenants or authorization scopes.

## Security and privacy

Review Action View as an output boundary.

Threats include XSS, unsafe URLs, HTML injection, sensitive data in shared fragments, authorization checks hidden in rendering, secrets in debug output, unsafe helper output, user-controlled translation interpolation, and cache leakage.

Keep authorization decisions outside templates but preserve authorization context in data/cache identity when rendered output depends on it.

Do not expose secrets merely because the view is rendered only to authenticated users.

## Testing

Test at the smallest owning boundary:

- template lookup;
- strict local failures/defaults;
- partial rendering with explicit locals;
- layout selection;
- helper output;
- HTML escaping;
- sanitizer behavior;
- unsafe URL handling;
- localized template selection;
- authorization-sensitive output;
- cache-key isolation when view caching exists;
- collection rendering;
- view-triggered query behavior where performance matters.

Security regressions should include representative malicious markup or unsafe protocols.

Prefer deterministic view/request/system tests over brittle full-page snapshots when only a small contract matters.

Do not make ordinary rendering tests depend on external network services.
