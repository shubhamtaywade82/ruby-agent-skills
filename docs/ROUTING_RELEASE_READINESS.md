# Routing Release Readiness

Protocol version: 1

The routing release gate separates static repository readiness from empirical benchmark readiness.

## Static gates

The repository must maintain the routing campaign contract, evidence integrity contract, and external-only hidden benchmark boundary. Synthetic or unverified results are prohibited, and benchmark output is descriptive rather than a quality ranking.

## Empirical gate

A completed public campaign evidence package is required.

The release contract currently expects:

- 14 public routing cases;
- 3 repetitions per case;
- 42 completed runs;
- verified evidence with intact raw artifacts;
- an immutable archive.

Run:

```bash
ruby bin/routing-release-check \
  --evidence ./routing-campaign-output/campaign-evidence.json \
  --archive ./routing-archives
```

Without `--evidence`, the command reports static readiness but exits with a pending empirical status.

No release gate may infer model results that have not been executed.
