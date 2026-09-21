---
name: hotwire-testing
description: Test Turbo and Stimulus behavior at deterministic request, system, and JavaScript boundaries.
family: testing
---
# Hotwire Testing

## Problem
Tests validate only rendered HTML or only the browser, leaving protocol and lifecycle defects undetected.

## Use when
Changing frames, streams, forms, navigation lifecycle, or Stimulus controllers.

## Required cases
Frame response contract, stream actions, status/redirect behavior, authorization, CSRF, controller lifecycle cleanup, and stable target identity.

## Review checklist
Use the smallest deterministic boundary that proves the behavior and add a browser/system test when DOM lifecycle is essential.
