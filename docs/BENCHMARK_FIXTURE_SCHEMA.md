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

- `implementation_file`: implementation seam loaded by the verifier
- `classes`: class boundaries required for the OOP check
- `api`: stable callable names exposed to deterministic checks

The fixture contract is benchmark infrastructure. It exists because the source assessment examples use free-function-style names while also requiring OOP; the benchmark needs a concrete seam to execute the behavior repeatedly.

The contract must remain minimal. It should not force unrelated architecture, framework choices, or naming conventions beyond what is needed for deterministic execution.
