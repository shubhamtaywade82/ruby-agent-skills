# Routing Benchmark History and Model Matrix

Protocol version: 1

## History

`bin/routing-history` scans an immutable evidence archive and produces a descriptive index of completed public routing campaign archives.

It does not mutate archived evidence and does not score or rank runs.

## Multi-model report

`bin/routing-model-matrix-report` groups independently archived campaign evidence by provider/model/model version and reports observed campaign metrics as descriptive data.

It does not select a winner, generate a ranking, or infer results for models without executed archives.

Only campaigns with the same public campaign identity should be included in a single report.
