# Running benchmarks locally

The routing and Rails campaigns are real agentic workloads: dozens to hundreds
of model calls, some with real tool use. Running them from a shared cloud
sandbox session shares that session's usage allowance with everything else in
it, so a long campaign can silently starve mid-run (every remaining call
fails instantly with a `session limit` error, which is easy to mistake for
the model failing the task instead of the harness being throttled). Running
locally, against your own machine's Ollama server or your own authenticated
`claude` CLI, avoids that: nothing else on your machine competes for the same
call budget while the campaign runs.

This doc covers both local paths. Neither requires changes to the runner or
verifiers — only the adapter script you point `--command` at differs.

## Prerequisites

```bash
git clone <this repository> && cd ruby-agent-skills
bundle install
ruby bin/validate   # confirms the checkout is sound before spending model calls on it
```

## Path A: Ollama

Already fully supported; `bin/routing-agent-ollama` is the routing adapter,
and any locally installed coding CLI (your own agent, `nexum`, or similar)
works as the `--command` for `bin/agent-benchmark`/`bin/benchmark`.

```bash
export OLLAMA_URL=http://127.0.0.1:11434   # default; omit if unchanged
export OLLAMA_MODEL=your-model:tag

# Routing campaign (all 31 cases x 3 repetitions):
ruby bin/routing-campaign --model "$OLLAMA_MODEL" --output benchmark-results/routing-ollama

# Rails campaign, using your own coding-agent CLI as the adapter:
ruby bin/agent-benchmark \
  --command "your-agent-cli run --model $OLLAMA_MODEL" \
  --manifest benchmarks/rails/campaign.yml \
  --provider ollama --model "$OLLAMA_MODEL" \
  --output benchmark-results/rails-ollama
```

Your own coding-agent CLI must satisfy the [Agent Adapter Protocol](AGENT_ADAPTER_PROTOCOL.md):
read `RUBY_AGENT_CONTEXT_FILE`, make the change inside `RUBY_AGENT_WORKSPACE`,
and never read the benchmark repository root (`RUBY_AGENT_EVAL_ROOT` is
deliberately unset for the agent process).

## Path B: local `claude` CLI

`bin/routing-agent-claude` and `bin/coding-agent-claude` drive the `claude`
CLI directly. Authenticate it once (`claude auth login` or
`claude setup-token`), then point the campaign runners at them exactly as
you would any other adapter:

```bash
# Choose the exact model; both adapters refuse to run without it:
export CLAUDE_MODEL=<full model name>   # an alias such as "sonnet" also works, but moves when new models ship

# Sanity check the CLI is reachable and authenticated:
claude --print --output-format json --tools "" --model "$CLAUDE_MODEL" "reply with: OK"

# Routing campaign (all 31 cases x 3 repetitions):
ruby bin/routing-eval \
  --command "ruby $(pwd)/bin/routing-agent-claude" \
  --provider anthropic --model "$CLAUDE_MODEL" \
  --router router/ROUTING.md \
  --output benchmark-results/routing-claude

# Rails campaign (28 evaluations x 3 repetitions x 2, paired):
ruby bin/agent-benchmark \
  --command "ruby $(pwd)/bin/coding-agent-claude" \
  --manifest benchmarks/rails/campaign.yml \
  --provider anthropic --model "$CLAUDE_MODEL" \
  --timeout 300 --continue-on-failure \
  --output benchmark-results/rails-claude
```

Both adapters accept `CLAUDE_BIN` (defaults to `claude` on `PATH`) and
require `CLAUDE_MODEL` (a `claude` CLI alias such as `sonnet`, or a full
model name). There is no model default, so the evidence records the model the
operator chose. Prefer a full model name for paired evidence, because an alias
resolves to whatever model is latest on the day of the run. Pass the same value to `--model` so the campaign label
matches the model that actually ran.

`bin/coding-agent-claude` runs the CLI with `--restricted` and
`--setting-sources ""`: no local `CLAUDE.md`, skills, or MCP servers leak
into the benchmark run, so a skill-enabled pair's advantage can only come
from the skill/pattern context the runner itself materialized.

## Smoke-test before a full run

Routing uses 93 model invocations (31 cases × 3). The Rails campaign uses 168 model invocations (28 evaluations × 3 paired repetitions × 2 configurations). Each Ruby platform foundation campaign uses 6 model invocations (1 evaluation × 3 paired repetitions × 2 configurations). Prove the adapter
works on one case before spending the full budget:

```bash
# One routing case:
ruby bin/routing-eval --command "ruby $(pwd)/bin/routing-agent-claude" \
  --case password-recovery-not-authorization --runs 1 \
  --router router/ROUTING.md --output /tmp/routing-smoke

# One paired Rails evaluation:
ruby bin/agent-benchmark --command "ruby $(pwd)/bin/coding-agent-claude" \
  --manifest benchmarks/rails/campaign.yml --evaluation action-cable-contract \
  --runs 1 --timeout 300 --output /tmp/rails-smoke
```

Check the written JSON for `"exit_code": 0` on the agent and a sensible
`checks` block before committing to the full campaign.

## Reading results

```bash
# Routing: confusion pairs, primary accuracy, repetition stability.
ruby bin/routing-analyze benchmark-results/routing-claude/campaign.json

# Rails: paired baseline-vs-skills-enabled comparison per dimension.
ruby bin/benchmark report benchmark-results/rails-claude/<eval>/baseline-1.json \
  benchmark-results/rails-claude/<eval>/skills-1.json
```

Individual run JSON files are the evidence; the analysis/report commands are
compact views over them, not a replacement for reading a surprising result
directly.

## Gotchas

- **Usage limits are shared per account, not per session.** If you run a
  campaign while also using `claude` interactively (or from another
  session), they draw from the same allowance.
- **Timeouts**: the Rails campaign's real coding tasks can take longer than
  the 120s a quick sandbox test uses; `--timeout 300` (or higher) avoids
  false timeouts on slower evaluations.
- **Non-UTF-8 locale**: if your shell has no `LANG`/`LC_ALL` set, Ruby
  defaults process-output encoding to US-ASCII; a diff or CLI response
  containing a non-ASCII byte (an em dash, a curly quote) used to crash
  `EvalRunner`'s JSON writer before this was fixed (`lib/ruby_agent_skills/eval_runner.rb`'s
  `utf8` helper) — make sure your checkout includes that fix before running
  a long campaign unattended.


## Ruby platform foundation campaigns

The two newly benchmark-backed foundation families can be run through the same local coding-agent adapter:

```bash
# Ruby toolchain: 1 evaluation × 3 paired repetitions × 2 configurations.
ruby bin/agent-benchmark \
  --command "ruby $(pwd)/bin/coding-agent-claude" \
  --manifest benchmarks/ruby-toolchain/campaign.yml \
  --provider anthropic --model "$CLAUDE_MODEL" \
  --timeout 300 --output benchmark-results/ruby-toolchain-claude

# Ruby gem development: 1 evaluation × 3 paired repetitions × 2 configurations.
ruby bin/agent-benchmark \
  --command "ruby $(pwd)/bin/coding-agent-claude" \
  --manifest benchmarks/ruby-gem-development/campaign.yml \
  --provider anthropic --model "$CLAUDE_MODEL" \
  --timeout 300 --output benchmark-results/ruby-gem-development-claude
```

These campaigns are intentionally small enough to use as adapter smoke tests while still preserving the repository's paired three-repetition protocol. They produce empirical evidence only when a real coding agent actually edits the disposable fixture and the declared verifier evaluates the result.
