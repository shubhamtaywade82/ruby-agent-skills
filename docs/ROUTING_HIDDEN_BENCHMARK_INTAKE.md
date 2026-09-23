# Hidden Benchmark External Intake

Protocol version: 1

Hidden routing cases, gold labels, raw results, and hidden case counts remain outside the public repository.

The repository may receive an **evidence receipt**, but it must not copy the hidden evidence payload into repository storage.

## Intake

Use:

```bash
ruby bin/routing-hidden-benchmark-intake \
  ./external-hidden-evidence.json \
  --expected-runs 100 \
  --provider ollama \
  --model example-model \
  --output ./hidden-benchmark-receipt.json
```

`--expected-runs` is supplied by the private benchmark operator. The verifier never derives hidden cardinality from the public 14-case corpus.

The external evidence JSON must contain benchmark identity, case/repetition/run counts, provider/model metadata, and a SHA-256-valid external evidence artifact reference. It must not contain repository copies of `cases`, `gold_labels`, or hidden prompts.

The generated receipt contains only provenance and verification facts. It does not contain hidden case content or gold labels.
