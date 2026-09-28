# Rendering boundary, template lookup, partials, strict locals, and layouts

Reference for the `rails-action-view` skill. Load it on demand when a change alters what a view renders, template lookup, partial contracts, strict locals, or layouts. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

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
