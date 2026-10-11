---
name: the-rails-way
description: "Audit a Rails change against the Rails Way philosophy: convention over configuration, DRY, MVC boundaries, prefer-built-ins, deliberate deviation, and the 5-step decision hierarchy for AI coding assistants."
family: rails
---

# The Rails Way

## Problem
"The Rails Way" is a philosophy, not a single rule. It is convention-over-configuration, DRY, MVC, and "use Rails before reinventing it" — expressed as a decision hierarchy for AI coding assistants. The philosophy is widely cited but rarely mapped to executable enforcement. An agent reviewing a Rails change needs a single cross-reference: for each Rails Way principle, which skill, which pattern, which eval, and which `rubocop-rails` cop already enforces it, and which rules are out of scope for this pack.

## Use when
- A review or PR touches Rails application structure, controller responsibilities, model boundaries, or background-job placement.
- An agent is choosing between "use Rails' built-in mechanism" and "introduce a custom abstraction" — repository, service object, form object, presenter, policy, query object.
- A team references "the Rails Way" or "convention over configuration" as the architectural bar and needs to translate that prose into executable checks.
- Onboarding a Rails engineer or agent to the pack's conventions.

## Do not use when
- The repository is a non-Rails Ruby project (Sinatra, Hanami, Roda, plain Ruby). Use `ruby-clean-code`, `ruby-oop`, and `ruby-domain-modeling` directly.
- The repository is a Rails API-only app with explicit architectural divergence already documented (e.g. dry-validation, Hanami::Model, rom-rb). The audit can still run, but every deviation must already be documented; an undocumented deviation is not "the Rails Way", it is technical debt.
- The change is a single-object refactor with no boundary implication. Use the focused skill (`rails-active-record`, `rails-action-controller`, etc.) directly.
- The team has a documented in-repo style that overrides a Rails Way default. Repository conventions take precedence over external guidelines; record the override in `AGENTS.md` or `docs/`.

## Repository inspection
Before applying this audit:

1. Resolve the Rails version: `bundle exec rails -v` or read `Gemfile.lock`. Rails 7.2+ and 8.x differ on defaults (`bins`, `brakeman`, `solid_queue`, `solid_cache`, `solid_cable`, `kaminal`, built-in `authentication`).
2. Inspect `config/application.rb`, `config/environments/*.rb`, and `config/initializers/` for divergences from Rails defaults (e.g. `config.action_controller.api_only`, `config.active_record.default_column_serializer`, `config.autoloaders`).
3. Inspect `app/models/` for `ApplicationRecord` inheritance, concern usage, and existing PORO/service boundaries.
4. Inspect `app/controllers/` for `ApplicationController` shared filters, `before_action` chains, and rescue-from patterns.
5. Inspect `config/routes.rb` for resource shape, namespaces, concerns, and `direct`/`resolve` usage.
6. Inspect `db/migrate/` and `db/schema.rb` (or `structure.sql`) for constraint coverage vs. validation-only invariants.
7. Inspect `app/jobs/` for queue selection, retry policy, idempotency, and transactional-enqueue discipline.
8. Inspect `app/policies/` or `app/authorization/` for the authorization mechanism (Pundit, Cancan, Action Policy, hand-rolled).
9. Inspect `spec/` or `test/` for boundary coverage (request specs, system specs, job specs).
10. Inspect `AGENTS.md` for any documented in-repo override of Rails defaults.

## Upstream coverage

This pack already covers most of the Rails Way's principles through dedicated skills and patterns. This audit pattern is the cross-reference layer; it does not duplicate guidance from the owning skills.

- **MVC boundaries** — `skills/rails-architecture/SKILL.md` (cross-layer ownership) + `patterns/rails/request-flow.md` (request lifecycle).
- **Controller responsibilities** — `skills/rails-action-controller/SKILL.md` + `patterns/rails/action-controller-callback-contract.md`.
- **Active Record conventions** — `skills/rails-active-record/SKILL.md` + `patterns/rails/active-record-callback-contract.md` + `patterns/rails/active-record-deletion-contract.md`.
- **Associations, validations, migrations** — `skills/rails-associations/`, `skills/rails-validations/`, `skills/rails-database-engineering/`.
- **Authorization at execution boundary** — `skills/rails-authorization/` + `skills/rails-cross-boundary-authorization-security/` + `patterns/rails/controller-service-authorization-composition.md` + `patterns/rails/policy-object-boundary.md`.
- **Background jobs** — `skills/rails-active-job/` + `patterns/rails/concurrency-controlled-job.md` + `patterns/rails/job-retry-policy.md`.
- **Minimality / no-premature-abstraction** — `skills/stack-minimality/` + `skills/ruby-poro/` + `patterns/ruby-design/service-object.md` ("Do not use when" section).

## Implementation procedure (the 5-step decision hierarchy)

When the audit is applied to a Rails change, run this hierarchy in order. Stop at the first step that resolves the decision; only descend to the next step when the previous one cannot answer the question.

1. **Follow the convention.** Use Rails naming, directory structure, RESTful routes, Active Record associations, migrations, and framework-supported facilities. If the conventional path satisfies the requirement, take it and stop. (Cross-reference: `rails-application-bootstrap`, `rails-generators`, `rails-routing`, `rails-active-record`, `rails-associations`, `rails-validations`.)
2. **Assign responsibilities correctly.** Keep controllers focused on request coordination. Place behavior in the domain layer (model or PORO). Extract an additional object only when the responsibilities are genuinely distinct and the complexity warrants it. (Cross-reference: `rails-architecture`, `ruby-service-objects`, `ruby-poro`, `stack-minimality`, `patterns/rails/request-flow.md`, `patterns/rails/dependency-direction-contract.md`.)
3. **Protect correctness and security.** Use authorization, strong parameters, validations, database constraints, transactions, and safe query construction as required by the operation. Authorization is enforced at the execution boundary, not only in the controller. (Cross-reference: `rails-authorization`, `rails-cross-boundary-authorization-security`, `rails-action-controller`, `rails-validations`, `rails-database-engineering`, `patterns/rails/policy-object-boundary.md`, `patterns/rails/controller-service-authorization-composition.md`.)
4. **Verify behavior.** Add tests at the appropriate level (request specs for HTTP contracts, system specs for user journeys, model specs for domain rules), run the relevant test suite, and inspect edge cases before considering the implementation complete. (Cross-reference: `rails-test-engineering`, `patterns/testing/rspec-request-spec.md`, `patterns/testing/rspec-shared-examples-contract.md`, `patterns/testing/rspec-betterspecs-audit.md`.)
5. **Deviate deliberately.** When choosing a nonstandard abstraction or structure, identify the problem it solves and why the conventional alternative is insufficient. Document the deviation in `AGENTS.md` or a decision record. (Cross-reference: `stack-minimality-debt`, `ruby-domain-modeling` references on context-and-adrs.)

## Where code belongs (the Rails Way placement table)

The Rails Way says: each concern has a default home. The pack's skill router encodes this; this table is the cross-reference for an agent deciding where to place a new piece of behavior.

| Concern | Rails-default home | Practical rule | Owning skill / pattern |
|---|---|---|---|
| HTTP request handling | Controller | Keep actions small and explicit; one responsibility per action. | `rails-action-controller` · `patterns/rails/action-controller-callback-contract.md` |
| Database persistence | Active Record model | Use associations, scopes, and query interfaces; do not wrap Active Record in a custom repository without justification. | `rails-active-record` · `rails-associations` |
| Domain rules | Model or domain object (PORO) | Keep rules close to the concepts they govern; extract a PORO when the rule spans models or belongs to no model. | `ruby-domain-modeling` · `ruby-poro` · `ruby-service-objects` |
| Request and response presentation | View, serializer, or presenter | Do not mix presentation with domain behavior. | `rails-action-view` · `rails-serialization-globalid-engineering` |
| Database structure changes | Migration | Change the schema through version-controlled migrations; pair constraints with validations for invariants that must hold under bypass writes. | `rails-database-engineering` |
| Asynchronous work | Active Job and job classes | Move slow or deferred work out of the request cycle; declare queue, retry policy, and idempotency. | `rails-active-job` · `patterns/rails/concurrency-controlled-job.md` · `patterns/rails/job-retry-policy.md` |
| Shared authorization | Policies or established authorization mechanism | Enforce permissions on the server, not only in the UI; re-authorize at the execution boundary. | `rails-authorization` · `rails-cross-boundary-authorization-security` · `patterns/rails/policy-object-boundary.md` · `patterns/rails/controller-service-authorization-composition.md` |
| Complex multi-step workflows | Plain Ruby object or another justified abstraction | Introduce one only when it clarifies ownership and orchestration. Not for every CRUD action. | `ruby-service-objects` · `stack-minimality` · `patterns/rails/request-flow.md` |

## Anti-patterns (what is NOT the Rails Way)

The Rails Way explicitly forbids these defaults. The "Better default" column shows the conventional path; the "Owning pattern / skill" column shows where this pack already catches the violation.

| Approach | Better default | Owning pattern / skill |
|---|---|---|
| Building a custom repository layer around every Active Record model | Use Active Record directly unless an actual architectural need justifies the extra layer. | `rails-active-record` · `stack-minimality-review` |
| Using generic service classes for all business logic | Put simple behavior in its natural home; extract complex workflows when needed. | `ruby-service-objects` (Do-not-use-when section) · `patterns/ruby-design/service-object.md` · `stack-minimality` |
| Writing SQL strings for ordinary CRUD | Use Active Record's query interface and associations. Parameterized queries when raw SQL is justified. | `rails-active-record` · `patterns/rails/active-record-model-boundary.md` · `skills/rails-security` |
| Putting every rule in controllers | Enforce domain rules in domain objects and models; enforce request-specific concerns in controllers. | `rails-action-controller` · `rails-architecture` · `ruby-domain-modeling` |
| Using callbacks to orchestrate the entire business process | Make important workflows explicit; use `after_commit` only for intrinsic lifecycle behavior. | `rails-active-record` (critical invariant: "Do not use callbacks to hide multi-record workflows…") · `patterns/rails/active-record-callback-contract.md` |
| Relying exclusively on Rails validations for data integrity | Add suitable database constraints and indexes. Validations are advisory; constraints are authoritative. | `rails-database-engineering` · `rails-validations` · `skills/rails-data-modeling` |
| Building large abstractions before understanding the requirements | Start with conventional Rails code and refactor based on demonstrated complexity. | `stack-minimality` · `stack-minimality-debt` |
| Ignoring query performance because Active Record generates SQL | Inspect queries, prevent N+1, and use eager loading where appropriate. | `rails-performance` · `rails-active-record` · `patterns/rails/active-record-strict-loading.md` |

These are defaults, not absolute prohibitions. Rails explicitly allows developers to override conventions when necessary; the deviation must be deliberate and documented.

## Example: creating an order (the Rails Way)

The structural example from the Rails Way document, annotated with the owning skill / pattern that each line honors:

```ruby
# config/routes.rb — Convention: RESTful resource declaration.
# Owning skill: rails-routing. Owning pattern: rest-resource.
resources :orders, only: %i[index show create]

# app/controllers/orders_controller.rb — Convention: thin controller,
# strong parameters, render with explicit status, no domain logic.
# Owning skill: rails-action-controller. Critical invariant: strong
# parameters enforced at the controller boundary.
class OrdersController < ApplicationController
  def create
    @order = current_user.orders.build(order_params)  # association-aware build

    if @order.save                                    # model owns the save
      render json: @order, status: :created           # explicit status
    else
      render json: { errors: @order.errors },
             status: :unprocessable_entity           # 422 with Rails error shape
    end
  end

  private

  def order_params
    params.require(:order).permit(:product_id, :quantity)  # strong params
  end
end

# app/models/order.rb — Convention: associations + validations in the model.
# Owning skills: rails-associations, rails-validations. The numericality
# validation is model-level feedback; pair it with a CHECK constraint in
# the migration so bulk writes cannot bypass it.
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :quantity,
            numericality: { only_integer: true, greater_than: 0 }
end
```

Important: this is a structural example, not a complete production checkout. A real implementation also needs:

- **Authorization** — `current_user.orders` scopes by the authenticated user, but a queued job or admin action must re-authorize. Use `patterns/rails/controller-service-authorization-composition.md`.
- **Stock and price validation** — extract to a domain object (`Checkout`, `OrderPricing`) when the rule spans `Product`, `Inventory`, and `Order`. Use `ruby-service-objects` + `stack-minimality` to decide whether the abstraction is justified.
- **Database constraints** — `add_foreign_key :orders, :users, on_delete: :restrict` and a CHECK constraint mirroring the numericality validation. Use `rails-database-engineering` + `rails-validations`.
- **Transaction handling** — wrap order creation + stock decrement + payment capture in `ActiveRecord::Base.transaction`. Use `rails-database-engineering`.
- **Background work** — `OrderMailer.with(order: @order).confirmation.deliver_later` enqueued after `after_commit` (or explicitly from the service object if the workflow is multi-step). Use `rails-active-job` + `patterns/rails/concurrency-controlled-job.md`.

## Failure modes

- Reading "convention over configuration" as "never deviate". Rails explicitly permits overrides; the audit's step 5 (Deviate deliberately) exists for that reason.
- Applying the audit to a non-Rails Ruby project. The principles partially transfer (DRY, MVC, use-the-framework-first) but the placement table does not — `Sinatra`, `Hanami`, `Roda`, and plain Ruby have different conventions.
- Treating "thin controllers" as "controllers with one line each". A controller action with 5–10 lines of explicit coordination is healthy; a 100-line action is not. The rule is responsibility focus, not line count.
- Adding a service object for every CRUD action because the team has a service-object pattern in the catalog. The catalog's existence is not authorization; the abstraction must earn its complexity (see `patterns/ruby-design/service-object.md` "Do not use when" section).
- Skipping step 4 (Verify behavior) because the change "looks conventional". Conventional changes still need request specs to prove the contract holds.
- Treating step 5 (Deviate deliberately) as a get-out-of-jail-free card. A deviation without a documented problem it solves is technical debt, not deviation. Use `stack-minimality-debt` to mark it.

## Testing

The audit pattern itself is exercised by the existing system-test suite:

- `test/rails_active_record_system_test.rb` enforces the Active Record callback invariant ("Do not use callbacks to hide multi-record workflows") referenced in the anti-patterns table.
- `test/rails_action_controller_system_test.rb` enforces the strong-parameters and explicit-status conventions referenced in the example.
- `test/rails_routing_system_test.rb` enforces the RESTful resource declaration referenced in the example.
- `test/test_engineering_system_test.rb` enforces the request-spec coverage required by step 4 (Verify behavior).
- `test/rails_cross_boundary_authorization_security_system_test.rb` enforces the re-authorization-at-execution-boundary rule referenced in the example's "Authorization" extension.

To audit a change against this pattern in a downstream Rails project, run:

```bash
ruby bin/verify-change /path/to/app --base origin/main --strict --out verify-change.json
```

The verifier runs the project's RuboCop (including `rubocop-rails` if installed), tests, Brakeman, bundler-audit, and `zeitwerk:check`, and emits an evidence report with per-check status. The verifier also lists owning skills whose change contract applies to each changed path — a routing hint, not a verification of adherence.

## Review checklist

- [ ] Rails version resolved from `Gemfile.lock`, not from memory.
- [ ] `config/application.rb` and `config/environments/` inspected for documented divergences.
- [ ] Change follows the conventional request lifecycle (route → controller → model → response) or has a documented reason not to.
- [ ] Controller action is thin and explicit; no domain logic, no multi-step orchestration.
- [ ] Model owns its associations, validations, and intrinsic lifecycle callbacks.
- [ ] No callback hides a multi-record workflow, authorization decision, or external integration.
- [ ] Validations paired with database constraints for invariants that must hold under bypass writes.
- [ ] Authorization enforced at the controller AND at the execution boundary (job, service, channel).
- [ ] Background work moved to Active Job; queue, retry, and idempotency declared.
- [ ] Service object / PORO extracted only when complexity warrants it; documented if introduced.
- [ ] Request specs cover the success and rejection paths at the HTTP boundary.
- [ ] No N+1 introduced; `strict_loading` considered for new eager-loaded associations.
- [ ] Deviations from Rails defaults documented in `AGENTS.md` or a decision record.

## Related skills

rails-architecture, rails-action-controller, rails-active-record, rails-associations, rails-validations, rails-routing, rails-database-engineering, rails-authorization, rails-cross-boundary-authorization-security, rails-active-job, rails-test-engineering, ruby-service-objects, ruby-poro, ruby-domain-modeling, stack-minimality, stack-minimality-review, stack-minimality-debt
