# Benchmark Fixture Schema

Fixture metadata is separate from the source evaluation schema.

Example:

    version: 1
    source: allerin-ruby-set-2
    fixtures:
      triplet-sum:
        implementation_file: lib/solution.rb
        classes:
          - TripletSum
        api:
          find: TripletSum#find(values, target)

## Fields

- `root`: fixture workspace directory; overrides the conventional `<campaign fixture_root>/<evaluation_id>`
- `implementation_file` / `implementation_files`: implementation seam loaded by the verifier
- `classes`: class boundaries required for the OOP check
- `api`: stable callable names exposed to deterministic checks
- `noop_expected`: `fail` (default) or `pass`; `pass` is allowed only for review/preserve tasks where leaving the fixture unchanged is a correct outcome
- `noop_rationale`: required when `noop_expected: pass`

`bin/benchmark campaign` and `scripts/audit_benchmark_quality.rb` both resolve fixtures through `RubyAgentSkills::FixtureRegistry`, so the audit checks the same workspace paths the runner executes. A campaign aborts before any agent run if an evaluation does not resolve.

## Starting state and controls

The fixture directory is copied verbatim into every agent workspace, so it must hold the task's *starting state*, never its answer:

- implementation tasks ship a skeleton whose method bodies raise `NotImplementedError`;
- refactor tasks ship the pre-refactor code the prompt describes;
- review/preserve tasks may ship code that is already correct and declare `noop_expected: pass`.

Known-good implementations live outside the workspace, at `benchmarks/<evaluation_set>/references/<evaluation_id>/`, and contain only implementation-seam files.

`test/benchmark_fixture_controls_system_test.rb` enforces both controls through `EvalRunner` and the campaign verifier:

- **negative control:** a no-op agent must produce `overall: failed` on every fixture unless `noop_expected: pass` is declared;
- **positive control:** copying a reference into the workspace must produce `overall: passed`;
- **tamper control:** for verifiers that grade with the registry `test_file` (Rails and design-patterns), rewriting the workspace test file to pass trivially must not change the grade. `functional` runs the fixture's original test file against the agent's code (`RubyAgentSkills::FixtureTestRun`); the agent's edited tests only count toward the separate `tests` check.

Every `*_regex` entry must compile and must not contain an escaped backslash. In single-quoted YAML write `'all_records\.map'`, not `'all_records\\.map'`: the doubled form requires a literal backslash and never matches Ruby source.

## Accepted residual risk

Public fixtures, tests, and references are readable by anyone with the repository, including an agent that locates it by other means. The runner withholds the repository root from the agent process, but that is exposure reduction, not isolation. Public campaign results measure harness behaviour on public tasks; claims about model capability require the external hidden cases (`controls.hidden_cases: external-only`). Review this if public campaigns are ever used as the sole evidence for a capability claim.

The fixture contract is benchmark infrastructure. It exists because the source assessment examples use free-function-style names while also requiring OOP; the benchmark needs a concrete seam to execute the behavior repeatedly.

The contract must remain minimal. It should not force unrelated architecture, framework choices, or naming conventions beyond what is needed for deterministic execution.
