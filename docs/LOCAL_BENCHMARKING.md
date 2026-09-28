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

# Routing campaign (all 23 cases x 3 repetitions):
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
# Sanity check the CLI is reachable and authenticated:
claude --print --output-format json --tools "" "reply with: OK"

# Routing campaign (all 23 cases x 3 repetitions):
ruby bin/routing-eval \
  --command "ruby $(pwd)/bin/routing-agent-claude" \
  --provider anthropic --model claude-sonnet-5 \
  --router router/ROUTING.md \
  --output benchmark-results/routing-claude

# Rails campaign (27 evaluations x 3 repetitions x 2, paired):
ruby bin/agent-benchmark \
  --command "ruby $(pwd)/bin/coding-agent-claude" \
  --manifest benchmarks/rails/campaign.yml \
  --provider anthropic --model claude-sonnet-5 \
  --timeout 300 --continue-on-failure \
  --output benchmark-results/rails-claude
```

Both adapters accept `CLAUDE_BIN` (defaults to `claude` on `PATH`) and
`CLAUDE_MODEL` (defaults to `claude-sonnet-5`) as overrides, so a specific
binary or model alias never needs a code change.

`bin/coding-agent-claude` runs the CLI with `--restricted` and
`--setting-sources ""`: no local `CLAUDE.md`, skills, or MCP servers leak
into the benchmark run, so a skill-enabled pair's advantage can only come
from the skill/pattern context the runner itself materialized.

## Smoke-test before a full run

Both campaigns are large (69 and up to 162 real calls). Prove the adapter
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
