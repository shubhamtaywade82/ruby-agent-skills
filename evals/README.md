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

### Ruby and Rails platform foundations

The platform-foundation evaluations cover the developer lifecycle before and around application code:
- Ruby toolchain selection and executable provenance;
- RubyGems and Bundler dependency installation and native-extension diagnosis;
- Rails application bootstrap with `rails new`, API-only versus standard application shape, database/frontend choices, and version-aware generator options;
- reusable Ruby gem development with `bundle gem`, gemspec/load-path contracts, package verification, isolated installation, and release authorization.

The Rails bootstrap evaluation has a disposable fixture/reference in the controlled Rails campaign. Toolchain and gem-development evaluations remain `coverage: static-only` until their own benchmark fixture families exist.

### Design-pattern system

The design-pattern family evaluates whether an agent can choose an appropriate abstraction and avoid unjustified patterns. It includes PORO extraction, service/application objects, commands, strategies, adapters, policies, dependency injection, factories, builders, null objects, decorators, facades, repositories, specifications, state objects, composition over inheritance, presenters, and an explicit pattern-restraint case.

The `pattern_selection` dimension is verified independently using deterministic fixture contracts. Hidden follow-up cases should vary naming and implementation shape so agents cannot overfit the public structural rules.

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