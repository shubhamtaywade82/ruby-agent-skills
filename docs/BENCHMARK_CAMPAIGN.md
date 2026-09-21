# Benchmark Campaign

Phase 7 turns the execution harness into a controlled baseline-versus-skill-enabled campaign.

## What is held constant

For a valid comparison, keep these identical between runs:

- evaluation YAML
- benchmark fixture
- verifier
- Ruby/runtime version
- timeout
- repository snapshot
- tool permissions and external resources

Only the agent configuration should change.

## Fixture contracts

The original assessment defines behavior, examples and algorithmic constraints, but it does not prescribe one class/method API for every question. Phase 7 therefore introduces explicit fixture contracts in:

`benchmarks/ruby-training/fixtures.yml`

These contracts create stable seams for deterministic verification. They are benchmark infrastructure and should not be treated as claims about the original source implementation.

## Deterministic checks

The public verifier checks what can be established reproducibly:

- functional behavior against all public cases
- contract behavior where an API seam is defined
- presence of required OOP class boundaries
- test/spec changes
- selected forbidden constructs
- selected algorithmic static heuristics

Some complexity/space properties are intentionally reported as `not_evaluated` when static evidence is insufficient. The benchmark must not manufacture certainty from weak heuristics.

## Running one comparison

Example:

    ruby bin/benchmark compare triplet-sum       --baseline-command 'BASELINE_AGENT_COMMAND'       --skills-command 'SKILL_ENABLED_AGENT_COMMAND'       --output benchmark-results/triplet-sum

This produces:

    baseline.json
    skills.json
    comparison.json

## Reporting

A comparison keeps baseline and skill-enabled dimensions side by side. It does not calculate a winner or hide the underlying evidence.

    ruby bin/benchmark report       benchmark-results/triplet-sum/baseline.json       benchmark-results/triplet-sum/skills.json

## Public versus hidden benchmarks

The nine current training cases are public and should remain reproducible.

A serious benchmark campaign should add a private hidden pack containing independently authored cases. The hidden pack must live outside this public repository and use the same evaluation/result contracts.

## Campaign hygiene

Do not commit generated benchmark results. Keep them in `benchmark-results/` or external artifact storage.

Do not compare runs performed with different prompts, fixtures, runtimes, or tool permissions and attribute the difference to skills.
