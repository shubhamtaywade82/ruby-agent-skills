# Routing External Campaign and Hidden Benchmark Contracts

Protocol version: 1

## External campaign handoff

`bin/routing-campaign-handoff` creates a machine-readable handoff for a runtime that is outside the repository execution environment.

The handoff records:

- public campaign id/version;
- case count;
- repetition count and expected run count;
- target model and Ollama endpoint;
- per-run timeout;
- repository Git SHA;
- SHA-256 hashes of the skill manifest, campaign manifest, routing corpus, and result schema.

It also emits an executable `run-campaign.sh`.

The handoff does not run a model. The target runtime must execute the normal campaign runner, which performs runtime preflight before model calls.

## Hidden benchmark

`router/ROUTING_HIDDEN_BENCHMARK.yml` defines the private evaluation boundary.

Hidden cases and gold labels remain external-only. They must never be committed to the public repository or exposed to the routing agent. The public corpus and public campaign remain independent of the hidden set.

The hidden benchmark uses the same normalized routing result contract so public and private evaluations remain protocol-compatible without exposing private labels.
