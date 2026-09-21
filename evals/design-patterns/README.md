# Design Pattern Evaluation Corpus

This public benchmark measures whether a Ruby/Rails coding agent can select and implement an appropriate design boundary rather than applying patterns mechanically.

## Evaluation dimensions

- functional correctness
- test presence and execution
- public contract
- pattern selection
- scope control

## Pattern-selection verifier

Each fixture declares required structural evidence, forbidden competing abstractions, and required public contract evidence.

The verifier runs the fixture tests and evaluates design constraints independently.

Pattern restraint is explicit: a simple behavior must remain a direct method rather than triggering speculative service, factory, strategy, presenter, policy, or repository abstractions.

## Cases

- poro-extraction
- service-object-selection
- command-object
- strategy-selection
- adapter-boundary
- policy-object
- dependency-injection
- factory-selection
- builder-selection
- null-object
- decorator
- facade
- repository-boundary
- specification
- state-object
- composition-over-inheritance
- presenter
- pattern-restraint

## Public benchmark limitation

The corpus is intentionally public. Hidden evaluation should later vary naming, file layout, and equivalent implementations so agents cannot optimize for the public regexes.
