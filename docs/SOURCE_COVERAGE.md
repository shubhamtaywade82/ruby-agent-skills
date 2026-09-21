# Source Coverage Map

This document records how the uploaded learning material is converted into operational agent skills.

The repository intentionally synthesizes concepts rather than reproducing source text.

## The Ruby Workshop

| Source area | Agent coverage |
|---|---|
| Writing and running Ruby programs | ruby-core |
| Ruby data types and operations | ruby-core, ruby-data-types, ruby-collections |
| Program flow | ruby-control-flow, ruby-boolean-logic |
| Ruby methods | ruby-method-design, ruby-api-design |
| Object-oriented programming | ruby-oop, ruby-tdd-refactoring |
| Modules and mixins | ruby-modules-mixins |
| RubyGems, files, CSV and service classes | ruby-gems-io-services, ruby-gem, service-object |
| Debugging | ruby-debugging |
| Metaprogramming/reflection | ruby-metaprogramming, metaprogramming-boundary |
| Blocks/Procs/lambdas | ruby-blocks-procs-lambdas |
| Enumerable and collection design | ruby-enumerables, ruby-collections |
| HTTP/client integration | ruby-gems-io-services, external-api-client |
| Rails MVC/application anatomy | rails-architecture |
| Rails routes/controllers/views/forms | rails-routing, rails-controllers, rails-views |
| Models, migrations, Active Record and console | rails-activerecord |
| Authentication | rails-authentication |
| Associations | rails-associations |
| Validations | rails-validations |
| Scaffolding | rails-generators, scaffold-lifecycle |
| Hosting/deployment activity | rails-deployment |

Practical activities are represented as evaluations rather than copied source chapters.

## Clean Ruby

| Source area | Agent coverage |
|---|---|
| Qualities of clean code | ruby-clean-code |
| Naming | ruby-clean-code |
| Quality methods | ruby-method-design, ruby-clean-code, ruby-api-design |
| Boolean logic | ruby-boolean-logic, ruby-clean-code |
| Classes | ruby-oop, ruby-clean-code |
| Refactoring | ruby-clean-code, ruby-tdd-refactoring |
| Test-driven development | ruby-tdd-refactoring |

## Learn Rails 6

The uploaded Learn Rails 6 book adds practical Rails workflow and Ruby language material. The repository uses it to deepen existing skills and add focused gaps rather than cloning chapters.

| Source area | Agent coverage |
|---|---|
| Rails application anatomy and MVC lifecycle | rails-architecture, request-flow |
| RESTful resources and CRUD | rails-routing, rails-controllers, rest-resource |
| Strong parameters and controller boundary | rails-controllers, request-flow |
| before_action filters | rails-controllers, rails-authentication |
| Service objects | ruby-gems-io-services, ruby-api-design, service-object |
| Request-level testing | rails-testing, ruby-tdd-refactoring |
| Blocks, Proc and lambda semantics | ruby-blocks-procs-lambdas |
| Enumerable and collection choices | ruby-enumerables, ruby-collections |
| Public method/API contracts | ruby-api-design, ruby-method-design |
| Boolean/truthiness decisions | ruby-boolean-logic, ruby-control-flow |
| External HTTP client boundary | ruby-gems-io-services, external-api-client, adapter |
| Ruby gem boundary | ruby-gems-io-services, ruby-gem |
| Metaprogramming safety | ruby-metaprogramming, metaprogramming-boundary |
| Scaffold cleanup | rails-generators, scaffold-lifecycle |

The book-derived benchmark family is evals/ruby-workshop and benchmarks/ruby-workshop.

## Allerin training / assessment material

The assessment should be treated as an evaluation corpus.

Observed task families include:
- selection sort and recursive selection sort
- smallest missing number in a sorted array
- shopping cart domain behavior
- triplet sum with the stated O(n^2) / O(1) target
- majority element
- distinct elements from duplicates
- power-of-two detection with bitwise logic
- Chocolate Feast
- object-oriented design expectations across the programs

Do not turn these prompts into source-text skills. Turn them into testable evaluation cases that measure:
- functional correctness
- edge-case handling
- complexity adherence
- object-oriented design
- readability
- test quality

## Coverage states

- covered — a skill already provides actionable guidance.
- partial — the topic is mentioned but deserves dedicated routing or deeper procedure.
- planned — the topic has no dedicated skill yet.
- eval-only — the material is primarily a benchmark or exercise.

The goal is not to maximize skill count. The goal is to make routing precise while keeping each skill focused.