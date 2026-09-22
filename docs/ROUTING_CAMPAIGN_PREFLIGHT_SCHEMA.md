# Routing Campaign Preflight Schema

Protocol version: 1

`bin/routing-campaign-preflight` is the runtime gate executed before any routing model calls.

## Required information

- public campaign id and version;
- routing case count;
- repetition count and expected total runs;
- Ollama endpoint and reported runtime version;
- exact installed model name, digest, size, and modification timestamp;
- planned per-run timeout and workspace controls;
- repository Git SHA;
- SHA-256 identities for the skill manifest, campaign manifest, and routing case corpus.

## Boundary

Preflight records what runtime will be used. It does not execute a routing case and does not measure model quality.

A successful preflight is required before the campaign runner invokes `bin/routing-eval`.