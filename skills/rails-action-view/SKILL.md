---
name: rails-action-view
description: "Use when designing, implementing, reviewing, testing, or optimizing Rails Action View rendering, templates, partials, layouts, helpers, strict locals, output safety, localized views, and rendering performance."
---

# Rails Action View Engineering

## Purpose

Treat Action View as a response-rendering subsystem with explicit contracts for data boundaries, HTML safety, template composition, localization, caching interaction, and rendering performance.

This skill deepens the foundational rails-views skill. It owns Action View-specific runtime behavior rather than replacing basic Rails view guidance.

Compose with:

- rails-views for presentation responsibility and basic template/form conventions;
- rails-controllers for controller/render/redirect response semantics;
- rails-i18n for locale resolution and localization context;
- rails-action-text for persisted rich text;
- rails-caching for fragment/cache correctness;
- rails-performance and ruby-performance for evidence-driven rendering optimization;
- rails-security and rails-security-engineering for XSS, content safety, authorization, and privacy;
- rails-test-engineering and rails-testing for deterministic rendered-output verification.

Current Rails documents Action View as the response-rendering layer used with Action Controller, covering templates, partials, layouts, helpers, and localized views. Modern Rails also supports strict local signatures for partials and template-specific rendering contracts. Sources are listed below.

Core flow:

    controller/domain-prepared data
    -> template lookup
    -> layout/partial composition
    -> helper execution
    -> escaping/sanitization/output safety
    -> optional fragment caching
    -> rendered response

## Activate when

- changing ERB or other Action View templates;
- designing partial/layout boundaries;
- introducing strict local signatures;
- adding or refactoring view helpers;
- diagnosing escaped HTML, XSS, or html_safe behavior;
- changing localized views;
- optimizing repeated partial rendering or collection rendering;
- debugging template lookup or rendering failures;
- changing fragment/collection caching from a view;
- reviewing presentation code for hidden queries or side effects.

Do not replace rails-views with this skill for simple view edits that do not involve an Action View runtime concern.

## Repository inspection

Inspect before implementing:

1. Rails and Action View versions;
2. template engines and extensions in use;
3. app/views structure and naming;
4. layouts, partial, collection, and object-rendering conventions;
5. helper modules and whether logic is shared globally or by controller namespace;
6. existing presenters/view models/decorators;
7. sanitizer/output-safety conventions;
8. localized view conventions and rails-i18n usage;
9. fragment/cache conventions and cache key policy;
10. request/system/view tests and snapshot/golden-output conventions.

Search for an existing local solution before introducing a new helper, presenter, rendering abstraction, or partial hierarchy.

## Rendering boundary

The template should render already-authorized and already-prepared information.

Prefer:

    controller/application service
    -> authorization/domain logic
    -> query/data preparation
    -> Action View rendering

Avoid making templates responsible for business state transitions, authorization decisions, database writes, network calls, unbounded queries, or complex cross-resource policy.

A helper may format presentation data, but it should not become an application service hidden inside the view layer.

## Template and lookup contract

Action View resolves templates using Rails naming and lookup conventions. Treat template paths, formats, variants, locales, and handlers as part of the rendering contract.

Review:

- controller/action naming;
- .html.erb, .json.jbuilder, builder, and other installed handlers;
- locale variants such as .de.html.erb;
- device/request variants where used;
- fallback behavior;
- missing-template errors;
- custom view_paths.

Do not add arbitrary view-path manipulation merely to bypass a naming problem.

Keep view-path mutation scoped and intentional when engines or modular applications require it.

## Partial contract

Partials are reusable rendering units. Define their inputs explicitly.

Prefer meaningful locals, explicit locals:, object rendering when the repository convention supports it, strict local signatures for stable interfaces, and small coherent responsibilities.

Avoid hidden dependency on unrelated controller instance variables, query execution inside the partial, helper chains that reach deep into infrastructure, and partials whose behavior changes based on many undocumented locals.

A partial contract should be explainable as:

    inputs
    -> presentation transformation
    -> rendered fragment

For collection rendering, define empty collection behavior and per-item local naming.

## Strict locals

Modern Rails supports strict local signatures for templates and partials using a locals signature comment. This constrains accepted locals and can avoid compiling multiple local combinations.

Use strict locals when:

- a partial has a stable interface;
- accidental local omissions are expensive to diagnose;
- a partial is widely reused;
- compilation variants are measurable or clearly unnecessary.

Do not add strict locals blindly to every one-off partial.

Treat changes to required, default, optional locals as API changes for the template's callers.

## Layout boundary

Layouts wrap action responses and provide shared presentation structure.

Keep layouts concerned with document structure, navigation/presentation chrome, shared metadata, content slots, and globally expected helper output.

Do not put business workflows into layouts.

When introducing multiple layouts, define selection criteria explicitly rather than allowing controller actions to infer layout names dynamically from user input.

Review layout changes for authentication-sensitive navigation, tenant identity, locale, CSP/security metadata, asset/script inclusion, and content-for contracts.

## Helper boundary

Helpers should be presentation-focused and composable.

Good helper responsibilities include formatting, HTML tag generation, link/button construction, view-specific predicates, and small representation decisions.

Avoid helpers that load collections, write to the database, call external providers, decide business authorization, mutate global/application state, or become unbounded orchestration layers.

When helper logic becomes domain logic, move it to an owning domain object/service/policy and leave a thin presentation adapter in the view layer.

## Output safety and sanitization

Rails escapes dynamic template output by default. raw bypasses escaping, and sanitize removes unsafe HTML using configured sanitizer rules.

Treat HTML safety as a security contract.

Review user-controlled strings, translated/interpolated content, raw, html_safe, safe_join, sanitize, custom allowlists, URLs and protocols, Action Text output, and helpers returning SafeBuffer.

Never mark user input HTML-safe merely because it is expected to contain markup.

Do not weaken the sanitizer allowlist to fix a presentation defect without a security review.

Use sanitize or escaping at the owning rendering boundary when untrusted HTML is intentionally allowed.

## Forms and tag helpers

Action View form and tag helpers produce HTML and commonly encode security behavior such as CSRF tokens for non-GET forms.

Compose with rails-controllers for parameter/response contracts, rails-validations for validation errors, and rails-authentication or rails-security for authorization and CSRF boundaries.

Do not treat hidden inputs, disabled fields, DOM attributes, or generated HTML as authorization.

Verify successful and failed render paths, including validation error state and accessibility-critical labels when the repository tests them.

## Localization

Action View can resolve locale-specific templates before falling back to the non-localized template.

Use rails-i18n for locale context and policy.

Define locale source, supported locale contract, fallback, template naming, translation interpolation, and locale-sensitive fragment cache identity.

Do not use locale-specific templates as an authorization mechanism.

Do not duplicate business logic across localized templates. Prefer shared structure plus localized presentation data.

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

## Agent review checklist

- [ ] Rails/Action View version resolved
- [ ] existing rails-views conventions inspected
- [ ] template lookup/format/variant contract explicit
- [ ] partial inputs explicit
- [ ] strict locals used where justified
- [ ] layout responsibility remains presentation-only
- [ ] helper responsibility remains presentation-focused
- [ ] no hidden database/network side effects in templates
- [ ] output escaping/sanitization reviewed
- [ ] raw/html_safe usage justified
- [ ] form security semantics preserved
- [ ] locale/fallback behavior explicit when applicable
- [ ] view cache identity includes correctness/security dimensions
- [ ] rendering performance measured before optimization
- [ ] deterministic rendering tests exist
- [ ] security regression coverage exists for untrusted HTML/URLs

## Anti-patterns / failure modes

- query loops inside templates;
- authorization logic embedded only in ERB;
- raw or html_safe used on user input;
- global sanitizer allowlist expansion for one template;
- helpers performing domain workflows;
- layouts performing data mutations;
- partials depending on undocumented instance variables;
- excessive partial nesting;
- strict locals added without stable callers;
- localized templates duplicating business logic;
- fragment caches missing locale/tenant/permission identity;
- full-page snapshots replacing focused rendering contracts;
- optimizing view code without query/render evidence.

## Verification

For an Action View change:

    version/runtime evidence
    -> template lookup
    -> data/input contract
    -> partial/layout/helper boundary
    -> output safety
    -> locale
    -> cache identity
    -> rendering performance
    -> focused tests
    -> security regression
    -> regression suite

For a rendering bug distinguish:

    controller data
    -> lookup
    -> layout
    -> partials
    -> helpers
    -> escaping/sanitization
    -> cache
    -> final response

Never claim a view is safe because it comes from ERB or a helper is safe because it returns a string. Verify escaping, sanitization, authorization boundaries, and cache isolation where applicable.

## Source foundation

Primary Rails sources:

- https://guides.rubyonrails.org/action_view_overview.html
- https://guides.rubyonrails.org/action_view_helpers.html
- https://guides.rubyonrails.org/form_helpers.html
- https://guides.rubyonrails.org/caching_with_rails.html
- https://api.rubyonrails.org/v8.1.3/classes/ActionView/Helpers/SanitizeHelper.html
- https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html

These sources document Action View rendering, partials, strict locals, layouts, helpers, localized views, sanitization, output safety, form helpers, and fragment/collection caching.

Composed repository skills:

- skills/rails-views/SKILL.md
- skills/rails-controllers/SKILL.md
- skills/rails-i18n/SKILL.md
- skills/rails-caching/SKILL.md
- skills/rails-performance/SKILL.md
- skills/ruby-performance/SKILL.md
- skills/rails-security/SKILL.md
- skills/rails-security-engineering/SKILL.md
- skills/rails-action-text/SKILL.md
- skills/rails-test-engineering/SKILL.md
- skills/rails-testing/SKILL.md
