---
name: hotwire-progressive-enhancement
description: Treat Hotwire as enhancement over a valid server-rendered HTML contract.
family: rails
---
# Hotwire Progressive Enhancement

## Problem
The application only works when Turbo or Stimulus executes successfully.

## Structure
Preserve meaningful HTML forms, links, statuses, errors, and server authorization independently of client enhancements.

## Testing
Verify direct HTTP/HTML behavior for critical workflows in addition to enhanced behavior.
## Do not use when
A feature is explicitly non-functional without JavaScript and that limitation is intentional.

## Repository inspection
Inspect server-rendered HTML, forms, links, fallback responses, and accessibility expectations.

## Implementation procedure
Build the server HTML contract first, then add Turbo and Stimulus enhancement without moving authorization into the client.

## Failure modes
JavaScript-only workflows, broken direct requests, inaccessible fallbacks, and hidden server assumptions.

## Testing
Verify direct HTTP and HTML behavior for critical workflows.

## Review checklist
Critical workflows remain meaningful without enhancement where required.

## Related skills
rails-hotwire, rails-action-controller, rails-action-view, rails-security
