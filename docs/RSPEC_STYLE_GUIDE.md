# RSpec Style Guide Integration

This repository incorporates the RSpec Style Guide at https://rspec.rubystyle.guide/ as the specification-layer guidance for RSpec tests.

The upstream guide states that it targets RSpec 3 or later and that `rubocop-rspec` provides a way to enforce its rules. citeturn198163view0

## Covered areas

The guide is organized around complete spec-file structure and covers:

- layout and empty-line rules around example groups, examples, subjects, lets, and hooks;
- example-group structure, subject/let/hook ordering, and context organization;
- example structure and expectation organization;
- subject naming and reuse;
- instance-variable avoidance;
- shared examples and controlled DRYing of specs;
- hook scope and state-leakage risks;
- readable example/context naming;
- `expect` syntax and matcher choices;
- predicate and built-in matchers;
- avoiding `allow_any_instance_of` / `expect_any_instance_of`;
- verifying doubles and partial-double verification;
- time and HTTP isolation in tests;
- constant leakage from examples;
- incidental test state;
- factories and test-data boundaries;
- appropriate test-data volume;
- integration-vs-unit test considerations.

The upstream guide is a living document and notes that RSpec practices evolve over time. citeturn198163view0

## Executable enforcement

`rubocop-rspec` is already loaded by the repository root `.rubocop.yml`. Its current configuration contains cops linked directly to RSpec Style Guide sections, including:

- `RSpec/AnyInstance`
- `RSpec/BeforeAfterAll`
- `RSpec/ContextWording`
- `RSpec/EmptyLineAfterExample`
- `RSpec/EmptyLineAfterExampleGroup`
- `RSpec/EmptyLineAfterFinalLet`
- `RSpec/EmptyLineAfterHook`
- `RSpec/EmptyLineAfterSubject`
- `RSpec/ExampleWording`
- `RSpec/HookArgument`
- `RSpec/ImplicitBlockExpectation`
- `RSpec/ImplicitExpect`
- `RSpec/InstanceVariable`
- `RSpec/LeadingSubject`
- `RSpec/LeakyConstantDeclaration`
- `RSpec/MultipleExpectations`
- `RSpec/MultipleMemoizedHelpers`
- `RSpec/NamedSubject`
- `RSpec/PredicateMatcher`
- and additional RSpec-specific cops.

Many of these are enabled by the extension's defaults and contain direct Style Guide references. The repository therefore treats the guide as the semantic source and `rubocop-rspec` as the executable enforcement layer.

## Agent rules

For RSpec changes, the agent should:

```text
inspect RSpec version
  -> inspect rubocop-rspec version
  -> inspect .rubocop.yml
  -> apply RSpec Style Guide guidance
  -> run focused rubocop-rspec cops
  -> test the affected examples
  -> review the diff for readability and test isolation
```

The guide does not mean that every repetition must be abstracted away. It explicitly cautions against premature DRYing in test suites and favors readability when duplication improves understanding. citeturn198163view0

## Compatibility

Repository policy should follow the RSpec version actually installed. The guide currently assumes RSpec 3 or later. citeturn198163view0