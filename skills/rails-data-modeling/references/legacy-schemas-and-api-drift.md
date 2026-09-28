# Legacy schemas and Rails API drift

Reference for the `rails-data-modeling` skill. Load it on demand when mapping a schema that does not follow Rails conventions, or when modernizing guidance or code written for older Rails versions (for example, examples from 2007-era Active Record books). Resolve the application's Rails version from `Gemfile.lock` before applying anything here.

## Mapping a legacy schema

Map the existing schema; do not rename production tables just to match conventions unless that migration is itself the task.

```ruby
class Account < ApplicationRecord
  self.table_name = "tbl_accounts"
  self.primary_key = "account_code"
  self.inheritance_column = :_type_disabled # a legacy "type" column that is not STI
  self.ignored_columns += ["legacy_flags"]

  alias_attribute :name, :acct_name

  belongs_to :region, foreign_key: "rgn_code", primary_key: "code"
  has_many :invoices, foreign_key: "account_code", inverse_of: :account
end
```

- Declare `foreign_key:` and `primary_key:` on associations whenever names differ from conventions.
- Use `ignored_columns` for columns the application must not read or write, including before dropping them.
- Add missing foreign keys and unique indexes to the legacy schema when data allows; they are the integrity the old application relied on implicitly.
- Record deliberate deviations from Rails conventions as decision records.

## Removed or replaced APIs

Never generate the left-hand column in new code. When editing legacy code that uses it, change it only as part of an upgrade the task covers.

| Older API | Status | Use instead |
|---|---|---|
| `Model.find(:all, conditions: ..., order: ..., include: ...)` and other finder option hashes | removed | relation methods: `where`, `order`, `includes`, `joins`, `limit` |
| `find_all_by_*`, `find_or_create_by_<attr>` dynamic finders | removed | `where(...)`, `find_or_create_by(attr: ...)` |
| `find_by_<attr>` dynamic finders | still work; legacy style | `find_by(attr: value)`, `find_by!(...)` |
| `update_attributes`, `update_attributes!` | removed in Rails 6.1 | `update`, `update!` |
| `set_table_name`, `set_primary_key`, `set_inheritance_column` | removed | `self.table_name =`, `self.primary_key =`, `self.inheritance_column =` |
| `ActiveRecord::Observer` | removed from Rails in 4.0 (moved to the `rails-observers` gem) | callbacks for record-local lifecycle; `after_commit` plus a job or event for side effects; explicit domain services for workflows |
| `enum status: { ... }` keyword form | removed in Rails 8.0 | `enum :status, { ... }` |
| plugin-based composite primary keys | superseded | native composite primary keys (Rails 7.1+) |
| UUID generation gems for primary keys | superseded | `id: :uuid` with database generation |
| `created_on` / `updated_on` timestamps | legacy naming | `t.timestamps` (`created_at`, `updated_at`) |

## Version-gated features

Confirm the application's version before using:

| Feature | Available from |
|---|---|
| check constraints (`add_check_constraint`), `delegated_type`, `dependent: :destroy_async` | Rails 6.1 |
| PostgreSQL enum types (`create_enum`, `t.enum`) | Rails 7.0 |
| native composite primary keys, `add_unique_constraint` and `add_exclusion_constraint` (PostgreSQL), `enum ... validate: true` | Rails 7.1 |
| removal of the keyword `enum` form | Rails 8.0 |

When a feature is unavailable in the application's version, use the older mechanism the repository already uses, or raise the upgrade as a separate decision.
