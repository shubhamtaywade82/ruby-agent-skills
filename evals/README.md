# Evaluations

The evaluation layer measures whether an AI coding agent can apply the skills, not whether it can repeat Ruby/Rails terminology.

## Evaluation dimensions

Each case defines:
- task prompt
- expected behavior
- relevant skill IDs
- optional implementation patterns
- constraints
- deterministic behavioral cases
- quality expectations
- verification dimensions

Signals remain separate so regressions are diagnosable.

## Evaluation families

### Ruby training

The public corpus contains nine cases derived from the uploaded Allerin Ruby assessment:
- selection sort
- recursive selection sort
- smallest missing number
- shopping cart
- triplet sum
- majority element
- distinct elements
- power-of-two detection
- Chocolate Feast

The assessment explicitly requires OOP concepts across the programs, so OOP/design is evaluated separately from functional output.

### Ruby workshop / Rails book integration v2

The second public family is derived from practical material in The Ruby Workshop and the uploaded Learn Rails 6 book. It covers:
- Enumerable transformation
- public Ruby API contract
- object-oriented voting application
- service object workflow
- external API client isolation
- Ruby gem boundary
- Rails REST resource
- Rails authentication boundary

These are benchmark tasks, not copied book exercises. The cases preserve the engineering concepts and add deterministic executable contracts.

## Runner

The provider-neutral runner executes an evaluation in a disposable workspace, captures the agent process, captures patch evidence, optionally invokes the declared verifier, and records dimension-level results.

For repeated baseline-versus-skills campaigns:

    ruby bin/benchmark campaign \
      --manifest benchmarks/ruby-training/campaign.yml \
      --agent-command 'AGENT_COMMAND'

Book Integration v2:

    ruby bin/benchmark campaign \
      --manifest benchmarks/ruby-workshop/campaign.yml \
      --agent-command 'AGENT_COMMAND'

For the concrete provider-neutral adapter wrapper:

    ruby bin/agent-benchmark \
      --command 'AGENT_COMMAND' \
      --provider your-provider \
      --model your-model

## Public versus hidden cases

The YAML cases in this repository are public benchmark definitions. Truly hidden cases must remain outside the repository and be injected by a private benchmark harness using the same schema.

## Validation

bin/validate validates skills, implementation patterns and evaluation definitions. CI also runs benchmark and agent-adapter smoke tests.

## Experimental discipline

Keep baseline and skills-enabled runs matched on agent/model/adapter/runtime/tools/prompt/fixture/timeout. The controlled difference is the selected skill/pattern context.