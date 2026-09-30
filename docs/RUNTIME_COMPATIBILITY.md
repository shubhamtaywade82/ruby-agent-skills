# Runtime Compatibility Contract

The runtime compatibility layer turns the repository's `ruby-runtime-compatibility` guidance into an executable boundary.

## Runtime evidence

`lib/ruby_agent_skills/runtime_profile.rb` resolves repository evidence for Ruby, Rails, Bundler, and CI version declarations. A conflict is preserved instead of choosing a winner.

## Constraint format

Version-bound skills in `skill-manifest.yml` and patterns can declare a `compatibility` mapping:

    compatibility:
      ruby: ">= 3.2, < 3.4"
      rails: ">= 8.1"

Requirements use RubyGems version/requirement semantics. Invalid requirements fail repository validation.

## Enforcement

`RubyAgentSkills::SkillPack#compatibility_report` evaluates selected skills and patterns against a target runtime profile.

`SkillPack#materialize` blocks known `unsupported` or `conflict` material. Unknown runtime evidence remains observable and is allowed by default; `strict_compatibility: true` fails closed on unknown evidence.

The evaluation runner captures the target workspace runtime profile and passes it into skills-enabled materialization.

## CLI

Use the installed or checkout-provided checker:

    ruby bin/skill-pack-compatibility /path/to/project \
      --pattern patterns/rails/active-job-continuation-contract

Use `--json` for machine-readable evidence and `--strict` when unresolved runtime evidence must block activation.

## Version-bound patterns

The current pack includes explicit Rails 8.1 contracts for:

- `active-job-continuation-contract`
- `structured-event-reporting`
- `credentials-fetch-contract`

These patterns are intentionally version-bound because their contract depends on framework behavior identified in the repository's Rails 8.1 framework review.

## Non-goals

The gate does not infer compatibility from a pattern's prose, from current online documentation, or from a successful installation alone. It only enforces explicit machine-readable constraints against observed runtime evidence.

Unknown compatibility is not silently converted into supported compatibility.

## Evaluation evidence

Evaluation results retain the resolved target runtime profile and compatibility report so compatibility decisions can be replayed without re-resolving the source repository.
