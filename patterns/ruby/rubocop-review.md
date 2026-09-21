# RuboCop Review

## Problem

A Ruby/Rails change needs static-analysis review, or a RuboCop finding needs interpretation and remediation.

## Use when

- configuring RuboCop
- selecting RuboCop plugins
- fixing RuboCop findings
- adding RuboCop to CI
- reviewing a RuboCop autocorrect diff

## Do not use when

- the task has no Ruby code or Ruby static-analysis boundary
- a non-Ruby linter is the only relevant tool

## Procedure

1. Inspect Ruby/Rails versions and Gemfile.lock.
2. Inspect existing .rubocop.yml and CI commands.
3. Determine which RuboCop plugins are actually applicable.
4. Prefer the modern plugin API for compatible extensions.
5. Run focused RuboCop checks.
6. Interpret each finding against repository conventions and behavior.
7. Apply the smallest justified fix.
8. Run tests for behavior changes.
9. Run broader RuboCop/CI-equivalent checks.
10. Review the final diff for accidental autocorrect churn.

## Plugin selection

Use data/rubocop/plugins.yml as the repository catalog. Never treat its existence as a mandate to install all plugins.

## Failure modes

- enabling every plugin
- using a plugin that does not match the repository technology
- introducing incompatible plugin versions
- using deprecated loading instructions without checking compatibility
- applying broad unsafe autocorrection
- disabling many cops instead of addressing the actual cause
- changing behavior just to satisfy a style preference
- treating a performance/style cop as an unconditional architecture rule

## Verification

- focused RuboCop run
- relevant tests
- full RuboCop run when appropriate
- final diff inspection
