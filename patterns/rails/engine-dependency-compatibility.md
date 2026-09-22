---
name: engine-dependency-compatibility
description: Engine Dependency Compatibility Contract
family: rails
---
# Engine Dependency Compatibility Contract

## Problem
An engine gem can break hosts when its Ruby/Rails/dependency constraints do not match actual supported behavior.

## Use when
Changing engine dependencies, gemspec constraints, or supported Rails versions.

## Do not use when
No dependency or compatibility effect.

## Repository inspection
Inspect gemspec, Gemfile.lock, runtime requirements, engine dependencies, and support matrix.

## Implementation procedure
Declare accurate runtime constraints and test the supported matrix where required.

## Failure modes
Dependency resolution failures, incompatible Rails APIs, and transitive conflicts.

## Testing
Run dependency resolution and compatibility tests for supported versions.

## Review checklist
[ ] Ruby constraint [ ] Rails constraint [ ] runtime deps [ ] matrix evidence

## Related skills
rails-engines-railties-engineering, ruby-runtime-compatibility