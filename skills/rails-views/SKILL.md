---
name: rails-views
description: Use when implementing or reviewing Rails views, ERB templates, partials, helpers, forms, presentation logic, or rendered response behavior.
---

# Rails Views

## Purpose

Keep presentation expressive without allowing business rules and data-access concerns to leak into templates.

## Activate when

- editing ERB/templates
- adding forms or partials
- changing helper behavior
- fixing rendering bugs
- moving logic out of an overgrown template

For Action View engineering beyond template edits (strict locals, helper API design, html_safe/XSS boundaries, collection rendering performance, or template lookup), activate `rails-action-view` and treat this skill as supporting context.

## Repository inspection

Inspect:

- neighboring views
- partial conventions
- layout
- helpers/presenters if present
- form builder conventions
- request/system tests
- response formats

## Decision rules

### Views

A view should answer:

> How is the already-prepared information presented?

Avoid:

- database queries
- substantial business rules
- destructive side effects
- complicated data transformations

### Partials

Extract a partial when a repeated, coherent presentation fragment exists or the template's intent becomes obscured.

Do not fragment tiny one-use pieces solely to reduce line count.

### Helpers/presenters

Use existing helper/presenter conventions when presentation logic becomes complex.

Keep helpers presentation-specific.

### Forms

Verify:

- parameter names/nesting
- field defaults
- validation errors
- CSRF conventions
- submit behavior
- failed/successful render paths

Do not assume a form field is an authorization mechanism.

## ERB readability

Prefer:

- clear locals
- meaningful partial names
- modest conditional logic
- explicit iteration

over deeply nested or compressed Ruby expressions.

## Accessibility/user behavior

When the repository tests user-facing behavior, preserve important labels, form semantics, links/buttons, and validation messaging.

## Anti-patterns

- SQL/database access in templates
- hidden business rules
- massive helpers that become service objects
- conditionals repeated across many views
- relying on client-side state for server authorization

## Agent review checklist

- [ ] template is presentation-focused
- [ ] partial boundaries are coherent
- [ ] helpers remain presentation-specific
- [ ] form contract matches controller
- [ ] errors render correctly
- [ ] response behavior is covered by appropriate tests

## Verification

Use request/system/view tests according to the repository. Verify rendered content and important interactions, especially form submission and error states.

## Source foundation

Derived from the Action View, ERB, helpers, forms, and UI material in *The Ruby Workshop*, constrained by the readability and responsibility principles of *Clean Ruby*.
