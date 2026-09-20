---
name: rails-generators
description: Use when using Rails generators or scaffolding to create models, controllers, views, migrations or related application structure.
---

# Rails Generators and Scaffolding

## Purpose

Use generators to accelerate conventional Rails development while still inspecting and reviewing the generated code.

## Inspect first

Check existing project generator conventions, Rails version, naming patterns and test framework.

## Decision rules

- Use generators when the generated structure matches the intended architecture.
- Treat generated code as a starting point, not automatically correct final code.
- Review generated migrations, associations, validations, routes, views, controllers and tests.
- Remove generated code that is not part of the actual requirement.

## Scaffolding

Scaffolding is appropriate for quickly creating conventional CRUD structure around a resource when the project wants the generated structure.

Do not scaffold merely to avoid understanding the resource boundaries.

## Verification

After generation:
1. inspect the diff
2. inspect routes
3. inspect the migration/schema change
4. inspect model/controller/view/test code
5. run the generated/relevant tests
6. remove unnecessary artifacts

## Source foundation

Derived from the Rails scaffolding material in The Ruby Workshop.
