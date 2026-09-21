# Ruby Training Benchmark Fixtures

These fixtures provide a minimal, deterministic Ruby workspace for the public
evaluation corpus.

The source assessment specifies behavior, examples and explicit constraints,
but it does not prescribe a single object-oriented class/method API for every
problem. The fixture contract therefore defines a stable test seam for the
benchmark runner.

The agent still has to inspect the workspace and implement the task. The
fixture README names the expected public seam; it is benchmark infrastructure,
not a claim that the original assessment used these class names.

Each fixture contains:

- `lib/solution.rb`: the implementation seam
- `README.md`: task-local contract
- no pre-written solution tests, so test creation remains part of evaluation

The verifier lives in `scripts/verify_training_eval.rb` and runs outside the
fixture workspace.
