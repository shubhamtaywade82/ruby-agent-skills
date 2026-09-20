---
name: rails-deployment
description: Use when preparing, reviewing or debugging Rails application deployment, hosting configuration or production readiness.
---

# Rails Deployment

## Purpose

Translate an application that works locally into a reproducible deployed environment.

## Inspect first

Identify:
- deployment platform
- Ruby version
- Rails version
- build/deploy commands
- database
- environment variables
- asset pipeline
- background processes
- storage/external services
- CI/CD configuration

Never assume a deployment platform from the task wording.

## Configuration

Separate code from environment-specific configuration.

Verify required environment variables exist and are not committed as secrets.

## Database

For schema changes:
- confirm migration order
- verify production-safe migration behavior
- consider existing data and table size
- confirm application and database versions are compatible

## Application behavior

Verify:
- boot
- routes
- database connection
- asset/static behavior as applicable
- external service configuration
- health checks where the project defines them
- logs and error reporting

## Verification

Use the project's actual build/deploy checks and, where possible, a staging environment before production.

Do not claim deployment success without observing the deployment result.

## Source foundation

The Ruby Workshop includes hosting a Rails application as part of its Rails progression. This skill operationalizes the deployment concept without prescribing one hosting provider.
