# Source Coverage Map

This document records how the uploaded learning material is converted into operational agent skills.

The repository intentionally synthesizes concepts rather than reproducing source text.

## The Ruby Workshop

| Source area | Agent coverage |
|---|---|
| Writing and running Ruby programs | `ruby-core`, future `ruby-runtime` |
| Ruby data types and operations | `ruby-core`, `ruby-collections`, future `ruby-data-types` |
| Program flow | future `ruby-control-flow` |
| Ruby methods | `ruby-method-design` |
| Object-oriented programming | `ruby-oop`, `ruby-tdd-refactoring` |
| Modules and mixins | `ruby-modules-mixins` |
| RubyGems, files, CSV and service classes | `ruby-gems-io-services` |
| Debugging | `ruby-debugging` |
| Metaprogramming/reflection | `ruby-metaprogramming` |
| HTTP/client integration | `ruby-gems-io-services`, future dedicated HTTP skill if justified |
| Rails MVC/application anatomy | `rails-architecture` |
| Rails routes/controllers/views/forms | current architecture coverage; split into dedicated skills |
| Models, migrations, Active Record and console | `rails-activerecord` |
| Authentication | future `rails-authentication` |
| Associations | `rails-activerecord`, future dedicated `rails-associations` |
| Validations | `rails-activerecord`, future dedicated `rails-validations` |
| Scaffolding | future `rails-generators` |
| Hosting/deployment activity | future `rails-deployment` |

The source book also contains practical activities and exercises. These belong in evaluations and examples, not as copied source chapters.

## Clean Ruby

| Source area | Agent coverage |
|---|---|
| Qualities of clean code | `ruby-clean-code` |
| Naming | `ruby-clean-code` |
| Quality methods | `ruby-method-design`, `ruby-clean-code` |
| Boolean logic | `ruby-clean-code`; future dedicated skill if routing value justifies it |
| Classes | `ruby-oop`, `ruby-clean-code` |
| Refactoring | `ruby-clean-code`, `ruby-tdd-refactoring` |
| Test-driven development | `ruby-tdd-refactoring` |

## Allerin training / assessment material

The assessment should be treated as an evaluation corpus.

Observed task families include:
- selection sort and recursive selection sort
- smallest missing number in a sorted array
- shopping cart domain behavior
- triplet sum with the stated `O(n^2)` / `O(1)` target
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

- **covered** — a skill already provides actionable guidance.
- **partial** — the topic is mentioned but deserves dedicated routing or deeper procedure.
- **planned** — the topic has no dedicated skill yet.
- **eval-only** — the material is primarily a benchmark or exercise.

The goal is not to maximize skill count. The goal is to make routing precise while keeping each skill focused.
