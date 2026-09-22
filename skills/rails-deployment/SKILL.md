---
name: rails-deployment
description: Use when preparing, reviewing, debugging, or validating Rails deployment, hosting, production configuration, migrations, builds, or release readiness.
---

# Rails Deployment

## Purpose

Make deployment behavior reproducible and evidence-based rather than assuming a local-working application is production-ready.

## Activate when

- deploying Rails
- preparing a release
- debugging a production boot/build failure
- changing environment configuration
- changing production migrations
- reviewing hosting readiness
- deploying with Kamal 2, registry-free Kamal flows, or Thruster

## Repository inspection

Identify the actual deployment model:

- hosting/platform
- Ruby/Rails versions
- Gemfile/Gemfile.lock
- buildpack/container/Dockerfile
- CI/CD workflows
- database
- asset pipeline
- environment variables
- storage
- background jobs
- external services
- health checks
- logging/error reporting

Do not assume a platform from the Rails version.

## Configuration

Separate code/configuration from secrets.

Verify required environment variables without printing their values.

Do not commit secrets.

## Database changes

For production migrations, inspect:

- lock duration
- table size
- index creation behavior
- default/backfill strategy
- nullable transition
- compatibility between old/new application versions
- rollback expectations

A migration that works locally may still be unsafe on a large production table.

## Release procedure

A robust release should make explicit:

1. build artifact
2. dependency installation
3. database migration strategy
4. asset/static preparation
5. process startup
6. health/readiness checks
7. logs/metrics
8. rollback/recovery

Follow repository-specific deploy tooling rather than inventing generic commands.

## Runtime verification

Check:

- application boots
- database connects
- routes respond
- critical background processes run
- external services authenticate
- assets/rendering function where applicable
- errors are visible in logs

## Failure discipline

Do not report "deployed successfully" without observing deployment/build/runtime evidence.

When deployment fails, capture:

- exact command
- exact error
- stage
- environment
- recent changes

then debug from evidence.

## Agent review checklist

- [ ] platform/process model identified
- [ ] secrets protected
- [ ] migrations reviewed for production safety
- [ ] build verified
- [ ] boot verified
- [ ] database verified
- [ ] health checks verified
- [ ] rollback path understood
- [ ] actual deployment evidence observed

## Verification

Use the repository's real CI/CD and staging/deployment checks. Never substitute a local test for a production deployment claim.

## Rails 8 current framework considerations

- Rails 8 applications are commonly provisioned with Kamal 2 and Thruster; Rails 8.1 also documents registry-free Kamal deployments for suitable setups.
- Treat Kamal configuration, proxy behavior, image provenance, secret injection, health checks, and rollback/roll-forward behavior as deployment contracts rather than copying defaults blindly.

## Source foundation

Grounded in the hosting/deployment activity from *The Ruby Workshop*. Production-readiness and evidence requirements are extended here for modern agent-assisted engineering.
