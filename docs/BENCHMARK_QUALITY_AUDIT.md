# Benchmark Quality Audit

## Purpose

Iteration 47 hardens the executable benchmark layer so public campaign results remain reproducible, structurally valid, and explicit about what has and has not been measured.

## Enforced contracts

Every public benchmark campaign must:

- identify its evaluation set, source, verifier, fixture root, and schema version;
- use at least three repetitions;
- run paired baseline/skills comparisons;
- create a fresh workspace per run;
- use the same fixture for the paired baseline and skills runs;
- use the same agent command when a single agent command is supplied;
- disclose that hidden cases are external-only;
- map campaign evaluation IDs exactly to fixture registry IDs;
- resolve every fixture root and implementation seam;
- resolve optional fixture test files when declared;
- match each public fixture to an evaluation YAML with the campaign source;
- preserve campaign execution controls/provenance in generated campaign.json.

## Benchmark coverage policy

A public evaluation family without a campaign is not considered benchmark-measured. The quality audit reports those families as warnings instead of silently treating the evaluation corpus as measured evidence.

This distinction matters because the repository contains a larger evaluation corpus than the currently provisioned public fixture/campaign set.

## Runner provenance

Campaign results retain:

- protocol version;
- campaign ID and version;
- evaluation set and source corpus;
- repository-relative fixture root and verifier;
- execution policy;
- benchmark controls;
- per-evaluation baseline and skills-enabled result artifacts.

The raw agent command remains in individual run evidence rather than the campaign summary so campaign artifacts do not accidentally duplicate secrets or provider launch details.

## Verification

Run:

    ruby scripts/audit_benchmark_quality.rb

The audit is also part of:

    bin/validate

The CI workflow separately runs provider-neutral benchmark smoke tests. A smoke test validates harness behavior; it is not evidence that an external coding model improved on the benchmark corpus.
