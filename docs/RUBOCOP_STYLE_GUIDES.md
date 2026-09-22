# RuboCop Style Guide Configuration

This repository now ships a root `.rubocop.yml` intended to make the Ruby and Rails style-guide stack executable by AI coding assistants.

## Source guides

- Ruby Style Guide: https://rubystyle.guide/
- Rails Style Guide: https://rails.rubystyle.guide/

The Ruby guide explicitly states that RuboCop is a static analyzer and formatter based on the guide. The Rails guide states that `rubocop-rails` is based on the Rails style guide. citeturn561168view0turn274870search0

## Configuration policy

### Ruby

The configuration enables the core RuboCop rules with `AllCops/NewCops: enable`, targets Ruby 3.3, uses two-space indentation, and adopts a 100-character line limit. The Ruby Style Guide recommends two spaces and an 80-character limit, while allowing teams to raise the limit to 100 or 120 by agreement. citeturn672989view0

The guide also permits either single-quoted or double-quoted string styles when applied consistently; this repository selects single quotes, matching the guide's examples. citeturn672989view2

### Rails

`rubocop-rails` is loaded through the modern plugin API. Its Rails cops cover Rails-specific best practices, while the actual Rails version should come from the consuming application's lockfile or an explicit `AllCops/TargetRailsVersion`. citeturn123169search2turn274870search6

The Rails style guide covers controller boundaries, model design, validations/scopes, persistence, migrations, and Active Support conventions. Examples include minimizing controller-to-view instance variables, keeping controller actions focused, and using database-enforced defaults where appropriate. citeturn305861view0turn305861view1turn305861view2turn305861view3

## Complete plugin loading

The root config loads all plugins currently documented on RuboCop's Plugins page: 11 official plugins and 7 third-party plugins. RuboCop recommends the plugin system for compatible extensions starting with 1.72; older extensions may still require legacy loading. citeturn123169search1

### Official

- rubocop-performance
- rubocop-rails
- rubocop-rspec
- rubocop-minitest
- rubocop-rake
- rubocop-sequel
- rubocop-thread_safety
- rubocop-capybara
- rubocop-factory_bot
- rubocop-rspec_rails
- rubocop-i18n

### Third-party

- rubocop-require_tools
- cookstyle
- rubocop-packaging
- rubocop-sorbet
- rubocop-graphql
- rubocop-changed
- rubocop-sketchup

## Agent usage

Agents should not treat loading every plugin as evidence that every plugin is applicable. The configuration makes the whole ecosystem available; repository dependency inspection determines which findings matter.

Recommended sequence:

```text
inspect Gemfile/Gemfile.lock
        ↓
inspect .rubocop.yml
        ↓
identify applicable plugin/framework cops
        ↓
bundle exec rubocop --show-cops
        ↓
run focused lint on changed files
        ↓
fix smallest justified issues
        ↓
run tests
        ↓
run full RuboCop
        ↓
review autocorrect diff
```

## Rails version

For Rails projects, set `AllCops/TargetRailsVersion` only when the version cannot be reliably inferred from the application's lockfile, or when the repository intentionally targets a specific Rails version. `rubocop-rails` documents this behavior and the accepted version format. citeturn274870search6

## Important boundary

Style-guide compliance is not an architecture mandate. A cop finding must still be interpreted against the task contract, repository conventions, runtime version, and existing architecture. The Ruby Style Guide itself emphasizes project consistency and says guidelines can be ignored when they would reduce readability or break compatibility. citeturn561168view0