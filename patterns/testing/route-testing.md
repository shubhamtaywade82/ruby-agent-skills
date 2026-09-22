---
name: route-testing
description: Use when proving Rails route recognition, URL generation, precedence, constraints, helpers, or dispatch contracts.
family: rails
---

# Route Testing

## Problem

A route declaration can look correct while the effective route set, generated helpers, constraints, or dispatch behavior differ from the intended contract.

## Use when

- adding or changing routes;
- debugging route precedence;
- changing helper names or constraints;
- reviewing route reorganizations.

## Do not use when

- route behavior is unchanged.

## Repository inspection

Inspect routes.rb, effective route output, existing routing/request tests, helper callers, and Rails version.

## Implementation procedure

1. Choose the narrowest assertion that proves the routing contract.
2. Use route assertions for recognition/generation when available.
3. Use request/integration tests when middleware or authorization behavior matters.
4. Add negative cases for constraints, wrong verbs, shadowing, and fallbacks where relevant.
5. Run bin/rails routes for structural verification.

## Failure modes

- testing only source text;
- testing controllers while helper contracts are broken;
- asserting incidental implementation ordering without behavioral proof;
- omitting negative route cases.

## Testing

Use assert_generates, assert_recognizes, or assert_routing as appropriate, then request/system tests for cross-layer behavior.

## Review checklist

- [ ] recognition tested
- [ ] generation tested
- [ ] negative cases covered
- [ ] route table inspected
- [ ] higher-layer behavior tested where required

## Related skills

rails-routing, rails-action-controller, rails-test-engineering, rails-testing
