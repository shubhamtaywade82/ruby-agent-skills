# Skill Routing Quality

The repository contains enough Ruby/Rails skills that trigger-token matching alone is unsafe. Closely related tasks routinely cross authentication, authorization, persistence, security, performance, runtime, and framework-boundary skills.

## Contract

Routing is a two-stage decision:

1. **Primary skill** owns the dominant engineering boundary and should drive the first implementation/review context.
2. **Secondary skills** contribute constraints or dependent boundaries when the task crosses them.

A trigger is evidence, not a routing verdict. The agent must inspect the task and repository before selecting skills.

## Adversarial routing cases

The file router/ROUTING_CASES.yml contains deterministic cases for overlapping boundaries such as:

- authentication versus authorization;
- authorization versus persistence;
- delayed background authorization;
- realtime authorization;
- API versus security;
- validation versus database constraints;
- performance versus Active Record;
- loading versus runtime compatibility;
- routing versus controller behavior;
- initialization versus production runtime;
- caching versus authorization;
- engine versus host routing;
- credentials/encryption versus operations.

These cases are intended to become benchmark inputs for measuring actual agent skill-selection behavior. The repository does not claim benchmark performance merely from the existence of the cases.

## Selection rules

Use this precedence:

1. explicit task requirements;
2. repository architecture and conventions;
3. runtime/framework constraints;
4. primary focused skill;
5. secondary boundary skills;
6. pattern guidance;
7. generic style preference.

When two skills appear equally plausible, inspect the ownership language in router/ROUTING.md and the corresponding skill files rather than choosing by keyword frequency.

Do not invent a new skill merely because a task crosses two existing boundaries. Prefer composition of existing skills when ownership remains clear.

## Empirical evaluation

Iteration 54 adds a provider-neutral routing evaluation runner. An external agent command receives the routing case through environment variables and writes a JSON result containing the selected primary and secondary skills.

Run a single case:

    ruby bin/routing-eval --command 'YOUR_ROUTING_AGENT_COMMAND' --case tenant-scoped-resource-access --output /tmp/routing-result.json

Run the complete routing corpus:

    ruby bin/routing-eval --command 'YOUR_ROUTING_AGENT_COMMAND' --output /tmp/routing-campaign.json

The runner reports primary-skill accuracy, required-secondary-skill recall, unexpected secondary selections, and completion. It measures actual agent behavior; it does not claim routing quality merely because the contract exists.

See docs/ROUTING_EVAL_RESULT_SCHEMA.md for the result protocol.

## Validation

Run:

    ruby scripts/audit_skill_routing.rb
    ruby -Itest test/skill_routing_system_test.rb

The canonical bin/validate command executes the routing system test as part of the repository-wide verification path.
