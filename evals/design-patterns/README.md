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


## Negative pattern-selection cases

The corpus now includes explicit negative-selection cases where a named pattern is tempting but not warranted by the contract. These cases pair `stack-minimality` with the Ruby design skills and require the verifier to reject speculative abstractions.

Additional cases:

- service-object-not-needed
- strategy-not-needed
- factory-not-needed
- repository-not-needed
- value-object-not-needed
- presenter-not-needed

The benchmark therefore tests both sides of pattern selection: when a pattern solves a real responsibility problem, and when the correct design decision is to use no pattern.

## Public benchmark limitation

The corpus is intentionally public. Hidden evaluation should later vary naming, file layout, and equivalent implementations so agents cannot optimize for the public regexes.
