# RuboCop Plugin Catalog

This repository incorporates the current plugin taxonomy published by RuboCop.

Source:
https://docs.rubocop.org/rubocop/latest/plugins.html

The current documentation page is for RuboCop 1.89 and lists 11 official plugins and 7 third-party plugins.

## Loading model

RuboCop 1.72 introduced the plugin system based on lint_roller. RuboCop recommends the plugin API for extensions that support it. Older extensions may still use the legacy require mechanism.

Preferred:

```yaml
plugins:
  - rubocop-performance
  - rubocop-rails
```

Legacy compatibility:

```yaml
require:
  - rubocop-extension
```

The AI agent must inspect the installed extension version before changing require to plugins.

## Core

| Gem | Role |
|---|---|
| rubocop | Ruby language style, linting, metrics, and static analysis |

## Official plugins

| Plugin | Scope | Activate when |
|---|---|---|
| rubocop-performance | Performance optimization | performance-sensitive Ruby or optimization review |
| rubocop-rails | Rails-specific analysis | Rails application |
| rubocop-rspec | RSpec-specific analysis | RSpec |
| rubocop-minitest | Minitest-specific analysis | Minitest/Test::Unit |
| rubocop-rake | Rake-specific analysis | Rake tasks/Rakefiles |
| rubocop-sequel | Sequel-specific analysis | Sequel |
| rubocop-thread_safety | Thread-safety analysis | threaded/concurrent Ruby |
| rubocop-capybara | Capybara-specific analysis | Capybara |
| rubocop-factory_bot | factory_bot-specific analysis | factory_bot |
| rubocop-rspec_rails | RSpec Rails-specific analysis | Rails + RSpec |
| rubocop-i18n | i18n wrapper-function analysis | i18n/gettext/rails-i18n usage |

## Third-party plugins

| Plugin | Scope | Activate when |
|---|---|---|
| rubocop-require_tools | Missing require dynamic analysis | require/load/autoload boundary review |
| cookstyle | Chef Infra Cookbook cops/config | Chef Infra cookbooks |
| rubocop-packaging | Packaging/downstream compatibility | distributable packages/downstream compatibility |
| rubocop-sorbet | Sorbet-specific analysis | Sorbet/typed Ruby |
| rubocop-graphql | GraphQL-specific analysis | GraphQL |
| rubocop-changed | Changed-files-only analysis | CI optimization for diffs |
| rubocop-sketchup | SketchUp Ruby API analysis | SketchUp extension code |

## Selection rules

The plugin catalog is not an installation list.

The agent should:
1. inspect Gemfile, Gemfile.lock, source files, and existing RuboCop configuration;
2. identify frameworks/libraries actually present;
3. select only applicable plugins;
4. verify plugin/version compatibility;
5. load compatible extensions using the modern plugin API;
6. use legacy require only where necessary;
7. run focused checks before broad linting;
8. interpret findings against repository conventions and runtime contracts.

### Common stacks

```text
Ruby                         -> rubocop + rubocop-performance
Rails                        -> + rubocop-rails
Rails + RSpec                -> + rubocop-rspec + rubocop-rspec_rails
Rails + Minitest             -> + rubocop-minitest
Rails + factory_bot          -> + rubocop-factory_bot
Rails + Capybara             -> + rubocop-capybara
Rake-heavy project           -> + rubocop-rake
Sequel project               -> + rubocop-sequel
Concurrent/threaded project  -> + rubocop-thread_safety
GraphQL project              -> + rubocop-graphql
Sorbet project               -> + rubocop-sorbet
Chef cookbook                -> cookstyle
```

Do not enable all plugins simply because they are catalogued.

## Important distinction

RuboCop plugins extend static analysis; they do not replace the repository's architecture skills.

```text
RuboCop finding
      ↓
inspect code + contract
      ↓
select domain/Rails skill
      ↓
apply smallest fix
      ↓
test
      ↓
rerun RuboCop
```

A cop finding is therefore an input to reasoning, not an automatic architecture decision.