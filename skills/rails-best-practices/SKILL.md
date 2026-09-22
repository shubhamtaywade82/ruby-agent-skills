---
name: rails-best-practices
description: Use when reviewing or implementing Rails code for maintainability, REST/resource design, model/controller/view responsibilities, database indexing, query access, route discipline, callbacks, migrations, and common Rails code-quality risks.
---

# Rails Best Practices

## Purpose
Apply evidence-based Rails quality checks as a review layer without turning historical linter rules into unconditional laws.

This skill is derived from the checks documented by flyerhzm/rails_best_practices, including model responsibility, associations, database indexes, RESTful routes, controller/view/helper boundaries, migrations, exception handling, and unused code. The source describes the project as a Rails code-metric tool rather than a universal style specification.

## Activate when
- reviewing a Rails application
- adding or changing Rails models, controllers, views, routes, migrations, or helpers
- reviewing query/persistence design
- investigating Rails maintainability issues
- preparing a Rails code-quality pass
- deciding whether a RailsBestPractices-style warning represents a real defect or an intentional trade-off

## Repository inspection
Inspect:
- Rails/Ruby versions
- config/routes.rb
- controllers, models, views/helpers
- migrations/schema
- associations/scopes
- tests
- services/jobs where relevant
- config/rails_best_practices.yml if used
- repository conventions

Do not apply a check mechanically without understanding the application's contract.

## Review domains
### Model and persistence
Review missing database indexes, risky default_scope, misplaced finder/query logic, duplicated relationship traversal, query attributes, duplicated model logic, unnecessary model methods, and input-protection concerns appropriate to the Rails version.

### RESTful routes
Review excessive custom actions, needless deep nesting, default/catch-all routes, and unrestricted auto-generated routes. Prefer conventional resources when they accurately represent the operation.

### Controllers
Review business logic leakage, repetitive setup, render complexity, and unused actions. Do not move business logic merely to satisfy a metric.

### Views and helpers
Review business/data-access logic in templates, presentation logic that belongs in helpers/presenters, unnecessary instance-variable exposure, complex rendering, and empty/unused helpers.

### Migrations and seed data
Review indexes, seed/application data separation, migration safety, and production impact. Historical rules must be adapted to the current Rails/database environment.

### Error handling
Do not rescue Exception broadly. Catch the narrowest recoverable exception at the appropriate boundary.

### Mailers
Review multipart representation when the application's mail contract requires multiple content alternatives.

### Dead code
Treat unused methods as review signals. Search callers, reflection, routes, callbacks, jobs, and external consumers before removal.

## Pattern-selection guidance
Treat analyzer findings as signals:
detect -> inspect context -> identify risk -> choose smallest justified fix -> test -> verify

Do not turn historical rules into absolute laws. In particular, do not interpret 'move to model' as permission for fat models, 'use before filter' as permission for business workflows in callbacks, or 'use association/scope/factory' as a mandate to introduce those abstractions everywhere.

## Modern Rails compatibility
Some original checks reflect older Rails conventions such as before_filter, legacy mass-assignment APIs, and Turbo Sprockets-era asset behavior. Translate the underlying intent to the application's actual Rails version. Never introduce deprecated APIs to satisfy a historical rule.

## Agent review checklist
- [ ] Rails/Ruby version resolved
- [ ] relevant checks considered
- [ ] findings interpreted in repository context
- [ ] indexes/constraints considered
- [ ] REST route surface reviewed
- [ ] controller/model/view/helper ownership checked
- [ ] callbacks justified
- [ ] migrations reviewed for production safety
- [ ] exception handling is narrow
- [ ] unused-code claims verified
- [ ] historical rules translated to modern Rails
- [ ] no pattern introduced solely to satisfy a metric

## Verification
Run the repository's configured RailsBestPractices command when installed and compatible. Also run focused tests and relevant CI checks. Treat analyzer output as review input: resolve, suppress with documented justification, or intentionally accept findings according to repository policy. Never claim a clean run unless it was actually executed.

## Source foundation
Based on the documented checks and workflow of flyerhzm/rails_best_practices: model/controller/view/helper responsibility, RESTful routing, database indexes, migrations, exception handling, unused code, and related Rails quality checks. citeturn0search0 The repository's agent system adds modern-Rails compatibility and contract-first interpretation.