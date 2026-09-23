# Routing Model Matrix Execution Contract

Protocol version: 2

The model matrix is an explicit execution plan for running the same public routing campaign against one or more named runtimes.

## Model entries

A model may be supplied on the command line with `--model NAME`, or in `router/ROUTING_MODEL_MATRIX.yml`:

```yaml
models:
  - provider: ollama
    name: example-model
```

The repository does not infer model names from installed runtimes. Empty `models` is valid and means that execution requires explicit CLI model arguments.

## Execution invariants

Every model execution must use the same:

- public routing corpus;
- repetition count;
- per-run timeout;
- provider/runtime endpoint;
- routing contract;
- result protocol.

Every model gets its own campaign output and immutable evidence archive. A failed model does not authorize comparison with another model and does not invalidate already archived evidence from other completed models.

The runner is descriptive infrastructure, not a ranking system. It never declares a best model and never creates synthetic results.

## Modes

Plan-only is the default and performs no model execution.

`--execute` runs the campaign for each explicit model, imports/verifies the campaign evidence, and archives each model independently.

Example:

```bash
ruby bin/routing-model-matrix-campaign \
  --model model-a \
  --model model-b \
  --execute \
  --archive ./routing-matrix-archives
```

Execution requires the target Ollama runtime to be reachable and the named model to be installed.
