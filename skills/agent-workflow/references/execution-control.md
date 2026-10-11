# Execution-control contract

Load this when an agent run can change files outside the repository's own working tree, run commands with side effects, use credentials or the network, or spend a bounded budget.

Each section states the contract, the mechanism that enforces it, and the evidence a run must leave. Where this repository does not enforce a contract, the mechanism says so, and that gap is recorded in TODO.md rather than assumed away.

## 1. Destructive commands and approval boundaries

Contract: commands that delete data, rewrite history, overwrite uncommitted work, run destructive migrations, or change a remote require explicit approval from the person who owns the outcome. Approval given for one action does not extend to another.

Mechanism: the harness permission mode decides which tool calls prompt. Repository adapters add their own gates. For example, `bin/coding-agent-*` refuses to start without `RUBY_AGENT_UNSANDBOXED_CODING=1` (see `docs/LOCAL_BENCHMARKING.md`).

Evidence: the approval appears in the transcript before the command runs, and the command's exit status is recorded.

## 2. Credential and network access

Contract: an agent run receives only the credentials its task needs, and only in the environment that needs them. Automated coding runs do not execute on a host that holds long-lived credentials or sensitive mounts.

Mechanism: the disposable container or VM requirement in `docs/LOCAL_BENCHMARKING.md`. The repository cannot verify the host it runs on; the operator attests to it by setting the opt-in. Network egress is not restricted by this repository.

Evidence: the run's environment description (container or VM, mounts, network policy) is recorded with the run.

## 3. Checkpointing and recovery

Contract: before a multi-step change begins, the working tree's state is recorded so the run can resume from its last verified step after a crash or timeout. A resumed run re-verifies before continuing.

Mechanism: version control. A commit or stash marks each verified step. The repository does not implement a checkpoint store.

Evidence: a commit or recorded revision exists for each verified step, and the resumed run names the revision it started from.

## 4. Verified undo of failed multi-file changes

Contract: when a change fails verification, every file it touched returns to the last verified revision, and the undo itself is verified by re-running the failing check's pre-change baseline.

Mechanism: revert to the recorded revision (section 3). Partial undo is not allowed: a failed change is reverted as a unit, not file by file.

Evidence: the revert's diff is empty against the recorded revision, and the baseline check passes after the revert.

## 5. Budgets: tokens, tool calls, runtime, and context

Contract: each run declares limits for model tokens, tool calls, wall-clock runtime, and context size before it starts. Reaching a limit stops the run in a state that can be resumed or reported; it does not silently continue.

Mechanism: the agent adapter's `--timeout` bounds runtime in the benchmark runner (`bin/agent-benchmark`). Token and tool-call budgets are not enforced by this repository; the provider CLI or harness must enforce them.

Evidence: the declared limits and the observed usage are recorded in the run's metadata. A run that hit a limit is reported as stopped, not as failed or passed.

## 6. Reproducibility and decision provenance

Contract: a run's result can be reproduced from its recorded inputs. Each routing or design decision names the evidence it relied on, and the exact model, provider, skill manifest, and routing contract hashes in effect.

Mechanism: adapter metadata records the provider and model (`metadata` in routing results, `RUBY_AGENT_METADATA_FILE` for the command adapter). Campaign manifests pin fixture and verifier identity. Hashes of the skill manifest and routing contract are not yet recorded per run.

Evidence: the result file names provider, model, and case id; the campaign manifest identifies the fixtures and verifier; decisions cite the observed facts from the fact manifest (`fact-gate.md`).
