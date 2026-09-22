# Contributing

## Scope

This repository is an executable skill system for Ruby and Ruby on Rails coding agents. Contributions should improve routing precision, implementation guidance, deterministic evaluation, or verification.

## Development workflow

1. Inspect the existing skill, pattern, manifest, router, evaluation, and test contracts before changing them.
2. Reuse an existing skill or pattern when it already owns the responsibility.
3. Add behavior changes with deterministic tests and update the evaluation corpus when the agent contract changes.
4. Register every new skill, pattern, evaluation, and system test in the canonical manifest/validation paths.
5. Run `bin/validate`.
6. Review the Git diff for accidental generated artifacts, secrets, unrelated changes, or stale inventory/documentation.
7. Wait for repository CI to pass before treating the change as complete.

## Source and version discipline

Framework-sensitive guidance must identify the relevant Ruby/Rails version and prefer official sources or repository evidence over memory.

Book- or assessment-derived material should be synthesized into operational guidance rather than copied verbatim.

## Benchmark changes

Benchmark fixtures and evaluation cases must remain deterministic. Keep public evaluation definitions separate from hidden benchmark cases, preserve paired baseline/skills controls, and never weaken a verifier merely to make an agent pass.

## Documentation

When repository architecture, inventory, release status, or public behavior changes, update the relevant README/docs and keep counts consistent with `bin/validate`.
