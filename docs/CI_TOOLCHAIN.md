# CI Toolchain Maintenance

## Purpose

Iteration 52 keeps the repository's GitHub Actions toolchain aligned with current action runtimes and turns CI maintenance into an executable contract.

## Current contract

- `actions/checkout@v7` is the repository standard for checkout.
- The workflow must not fall back to the Node 20-based checkout line.
- CI toolchain changes must preserve the existing Ruby validation and provider-neutral smoke-test workflow.

The current `actions/checkout` documentation identifies v7 as the current release line and documents the Node 24 runtime. The repository therefore treats v7+ as the minimum compatible checkout major for CI maintenance.

## Verification

Run:

    ruby scripts/audit_ci_toolchain.rb

It is also part of:

    bin/validate

For CI action changes, inspect GitHub's current action documentation before upgrading or downgrading versions.
