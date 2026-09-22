# Agent Adapter Examples

Phase 9 adds a concrete provider-neutral command adapter.

## Contract

The benchmark launches:

    ruby adapters/command_agent.rb

The adapter reads:

- RUBY_AGENT_COMMAND
- RUBY_AGENT_WORKSPACE
- RUBY_AGENT_CONTEXT_FILE
- RUBY_AGENT_METADATA_FILE
- RUBY_AGENT_SKILLS_ENABLED
- RUBY_AGENT_SKILLS_DIR
- RUBY_AGENT_PATTERNS_DIR

The command in RUBY_AGENT_COMMAND must edit the disposable workspace and exit non-zero on failure.

## Metadata

Optional process metadata can be supplied with:

- RUBY_AGENT_PROVIDER
- RUBY_AGENT_MODEL
- RUBY_AGENT_MODEL_VERSION
- RUBY_AGENT_TOOL_MODE
- RUBY_AGENT_TEMPERATURE

The adapter writes normalized metadata to RUBY_AGENT_METADATA_FILE.

## Generic usage

Run a real coding-agent CLI that already knows how to operate on the current directory:

    ruby bin/agent-benchmark \
      --command 'YOUR_AGENT_COMMAND' \
      --provider your-provider \
      --model your-model \
      --model-version your-version \
      --tool-mode filesystem

For the controlled comparison, the same command and model metadata are used for the baseline and skills-enabled sides. Only the materialized skill pack changes.

## Provider-specific harnesses

A provider-specific harness may translate the repository protocol to a provider CLI or API. Keep credentials, private endpoints, and model-specific secrets outside this repository.

Examples of acceptable adapter responsibilities:

1. read RUBY_AGENT_CONTEXT_FILE
2. open RUBY_AGENT_WORKSPACE as the working directory
3. provide the task to the coding agent
4. allow the agent to edit files and run permitted tools
5. return the agent process status
6. write metadata to RUBY_AGENT_METADATA_FILE

Do not provide benchmark answers, hidden cases, private verifier logic, or unrelated global skills.

## Trusted commands

The command adapter executes RUBY_AGENT_COMMAND with the disposable workspace as its working directory. Treat that environment variable as a trusted local benchmark configuration, not as untrusted input.
