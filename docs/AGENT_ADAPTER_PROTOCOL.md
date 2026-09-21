# Agent Adapter Protocol

Phase 8 defines the protocol used by an external AI coding agent to participate in the benchmark campaign.

The benchmark runner remains provider-neutral. An adapter can wrap Codex, Claude, Copilot, Cursor, an internal agent, an Ollama-based harness, or another coding system.

## Required environment

The runner provides:

- `RUBY_AGENT_EVAL_ID`: evaluation identifier
- `RUBY_AGENT_EVAL_PROMPT`: task prompt file
- `RUBY_AGENT_EVAL_FILE`: complete evaluation YAML
- `RUBY_AGENT_EVAL_ROOT`: benchmark repository root
- `RUBY_AGENT_WORKSPACE`: disposable implementation workspace
- `RUBY_AGENT_SKILLS_ENABLED`: `true` or `false`
- `RUBY_AGENT_SKILLS_DIR`: selected skill files when enabled
- `RUBY_AGENT_PATTERNS_DIR`: selected pattern files when enabled
- `RUBY_AGENT_SKILL_MANIFEST`: skill-pack manifest
- `RUBY_AGENT_CONTEXT_FILE`: materialized task + enabled skill/pattern context
- `RUBY_AGENT_METADATA_FILE`: optional agent metadata destination

The adapter executes in the workspace and must make the requested code changes there.

## Skill isolation

A baseline run receives the task context but no selected skill files.

A skill-enabled run receives exactly the skills and patterns declared by the evaluation case.

The adapter must not silently load unrelated skills from a global installation during a controlled benchmark. Doing so breaks the experimental control.

## Context contract

The adapter should provide the agent with:

1. the task prompt
2. the fixture/workspace
3. the selected skill/pattern context when enabled
4. the repository/runtime constraints available through the evaluation

The canonical combined context is available at `RUBY_AGENT_CONTEXT_FILE`.

## Metadata contract

The adapter may write JSON to `RUBY_AGENT_METADATA_FILE`:

    {
      "provider": "example",
      "model": "example-model",
      "model_version": "example-version",
      "tool_mode": "example",
      "temperature": 0
    }

The benchmark runner records this metadata under the agent result.

## No hidden assistance

Do not provide the benchmark solution, private expected outputs, or hidden verifier logic to the agent.

The agent receives only the task, fixture and allowed skills/patterns.

## Fair comparison

For a baseline-versus-skill-enabled pair, keep constant:

- agent model/version
- adapter implementation
- prompt
- workspace fixture
- runtime
- available tools
- timeout
- network policy
- environment variables other than the skill-pack variables

The controlled difference is the selected skill/pattern context.

## Repetitions

Use repeated paired runs for stochastic agents. Phase 8 defaults the public campaign to three repetitions.

Do not aggregate away the individual result files. The campaign summary is only a compact view of the underlying evidence.

## Provider-specific adapters

Provider adapters should live outside this repository when they contain authentication, private endpoints or model-specific secrets.

This repository defines the protocol; it does not need to vendor an Ollama/Codex/Claude-specific runtime.

## Phase 9 concrete adapter

The repository now includes:

    adapters/command_agent.rb
    bin/agent-benchmark
    lib/ruby_agent_skills/agent_adapter.rb

The command adapter is provider-neutral. It runs a trusted external coding-agent command inside the disposable benchmark workspace and writes normalized metadata to RUBY_AGENT_METADATA_FILE.

Use bin/agent-benchmark when the same external command should be paired automatically with skills disabled and enabled:

    ruby bin/agent-benchmark \
      --command 'YOUR_AGENT_COMMAND' \
      --provider your-provider \
      --model your-model

Provider-specific authentication and model launch logic remain outside the repository.

The adapter does not supply hidden solutions. It exposes the task context and selected skill pack that the benchmark runner has already materialized.
