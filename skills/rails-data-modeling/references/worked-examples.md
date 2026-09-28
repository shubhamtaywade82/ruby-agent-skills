# Worked examples

Reference for the `rails-data-modeling` skill. Load it on demand when one of these situations is closer to the task than the rules. Each example states the facts, the decisions, and the Rails 8.1 code. Check the application's Rails version before copying any API.

## 1. Commerce: normalized model with historical snapshots

Facts: a customer places orders; an order has lines; a line is a quantity of a product at the price charged when the order was placed. Products change price and name over time.

```text
customers(id, email)                                    email unique
products(id, sku, name, price_cents)                    current price; sku unique
orders(id, customer_id, status, placed_at)              status domain checked
order_items(id, order_id, product_id, quantity,
            unit_price_cents, product_name)             snapshot of price and name
```

`products.price_cents` is the current price. `order_items.unit_price_cents` is what this order charged. They are two facts, so storing both is correct, not duplication: re-pricing a product must never change a placed order.

```ruby
class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: { on_delete: :cascade }
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :unit_price_cents, null: false
      t.string :product_name, null: false
      t.timestamps
    end

    add_index :order_items, [:order_id, :product_id], unique: true
    add_check_constraint :order_items, "quantity > 0", name: "order_items_quantity_positive"
    add_check_constraint :order_items, "unit_price_cents >= 0", name: "order_items_price_nonnegative"
  end
end

class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy

  # The aggregate root copies the snapshot; callers never set it.
  def add_item(product, quantity:)
    order_items.build(product: product, quantity: quantity,
                      unit_price_cents: product.price_cents, product_name: product.name)
  end
end
```

## 2. SaaS multi-tenancy

Facts: an account is the tenant; a user can belong to several accounts with a role in each; projects belong to one account, and a project slug is unique within its account.

```text
accounts(id, name)
users(id, email)                                        global identity; email unique
memberships(id, account_id, user_id, role)              unique (account_id, user_id)
projects(id, account_id, slug, name)                    unique (account_id, slug)
```

```ruby
class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :account, null: false, foreign_key: true
      t.string :slug, null: false
      t.string :name, null: false
      t.timestamps
    end

    add_index :projects, [:account_id, :slug], unique: true
  end
end

class Project < ApplicationRecord
  belongs_to :account

  validates :slug, presence: true, uniqueness: { scope: :account_id } # message only
end
```

Tenant reasoning:

- `users` is global because one person can join several accounts; the tenant relationship lives in `memberships`.
- `projects.account_id` is stored directly so every query can scope by tenant without a join.
- The slug is unique per account, not globally, so the index is composite. A global unique index would leak one tenant's names into another's namespace.
- Modeling tenancy does not enforce it: every read and write must still scope by the current account, owned by `rails-authorization`.

## 3. JSON versus relational columns

Facts: an account connects external integrations. Each has a provider, a status, the provider's id, a last-sync time, provider-specific settings, and the last raw webhook payload.

| Field | Decision | Why |
|---|---|---|
| `account_id` | relational, foreign key | joined, scoped, and constrained |
| `provider` | relational string + check constraint | filtered on, part of a unique key |
| `status` | relational string + enum + check constraint | filtered and sorted on constantly |
| `external_id` | relational, unique with `provider` | looked up by webhook handlers |
| `last_synced_at` | relational, indexed | sorted and filtered for stale integrations |
| `settings` | JSONB | per-provider shape, read and written as a whole |
| `last_payload` | JSONB | audit and replay only; never queried by field |

```ruby
class CreateIntegrations < ActiveRecord::Migration[8.1]
  def change
    create_table :integrations do |t|
      t.references :account, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :status, null: false, default: "pending"
      t.string :external_id, null: false
      t.datetime :last_synced_at
      t.jsonb :settings, null: false, default: {}
      t.jsonb :last_payload
      t.timestamps
    end

    add_index :integrations, [:provider, :external_id], unique: true
    add_index :integrations, :last_synced_at
    add_check_constraint :integrations, "status IN ('pending', 'active', 'failed')",
                         name: "integrations_status_valid"
  end
end

class Integration < ApplicationRecord
  belongs_to :account

  enum :status, { pending: "pending", active: "active", failed: "failed" }, validate: true
  store_accessor :settings, :webhook_secret_ref, :sync_interval_minutes
end
```

If a JSON field starts appearing in `where`, `order`, joins, or uniqueness rules, promote it to a column.

## 4. UUID versus bigint primary keys

Neither is universally better. Decide per table:

| Need | Prefer |
|---|---|
| internal rows, joined heavily, ids never shown | `bigint` (compact, ordered, cheap indexes) |
| ids generated outside the database (offline clients, other services) | UUID primary key |
| ids exposed in URLs or APIs without revealing volume or allowing enumeration | a public UUID column beside a `bigint` key, or a UUID key |
| rows merged across databases or regions | UUID primary key |

```ruby
class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    # Devices register offline and create their own ids.
    create_table :devices, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
  end
end

class AddPublicIdToInvoices < ActiveRecord::Migration[8.1]
  def change
    # Internal bigint key stays; the public id goes in URLs and APIs.
    add_column :invoices, :public_id, :uuid, null: false, default: -> { "gen_random_uuid()" }
    add_index :invoices, :public_id, unique: true
  end
end
```

UUID keys cost larger indexes and random insert order, and children need `t.references ..., type: :uuid`. On PostgreSQL, `id: :uuid` defaults to `gen_random_uuid()`.

## 5. Composite primary key versus surrogate key

Natural composite identity: a store-level catalog where `(store_id, sku)` is how every system, including an external point-of-sale, identifies a row. Rails 7.1+ supports it natively.

```ruby
class CreateStoreProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :store_products, primary_key: [:store_id, :sku] do |t|
      t.bigint :store_id, null: false
      t.string :sku, null: false
      t.integer :price_cents, null: false
      t.timestamps
    end
  end
end

class StoreProduct < ApplicationRecord
  has_many :price_changes, foreign_key: [:store_id, :sku]
end

class PriceChange < ApplicationRecord
  belongs_to :store_product, foreign_key: [:store_id, :sku]
end
```

Surrogate key plus a unique constraint: a course enrollment where `(course_id, student_id)` is a business rule, not how other tables or systems refer to the row.

```ruby
class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :course, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.timestamps
    end

    add_index :enrollments, [:course_id, :student_id], unique: true
  end
end
```

Choose the composite key only when it is the row's real identity everywhere. Composite keys add complexity to every association, URL, and form, and the Rails guide warns they can be slower; a surrogate id with a composite unique index keeps the rule without that cost.

## 6. Controlled denormalization: a reconciled order total

Facts: an order's total is the sum of its lines. Lists and reports filter and sort by total, so it is stored. Once an order is placed, its total is also a snapshot that must not change.

The four answers:

1. **Source**: `order_items.quantity * order_items.unit_price_cents`.
2. **Update path**: the `Order` aggregate recalculates inside a row lock whenever its lines change; lines are never edited around the root.
3. **Repair**: a scheduled reconciliation finds drift and reports or repairs it.
4. **Failure**: a stale total is visible until reconciliation; placed orders are reported, never silently rewritten.

```ruby
class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  def recalculate_total!
    with_lock do
      update!(total_cents: order_items.sum(Arel.sql("quantity * unit_price_cents")))
    end
  end

  # Orders whose stored total no longer matches their lines.
  def self.with_drifted_total
    joins(:order_items)
      .group(:id)
      .having(Arel.sql("orders.total_cents <> SUM(order_items.quantity * order_items.unit_price_cents)"))
  end
end

class ReconcileOrderTotalsJob < ApplicationJob
  def perform
    Order.with_drifted_total.find_each do |order|
      Rails.logger.warn("order_total_drift order_id=#{order.id}")
      order.recalculate_total! unless order.placed_at
    end
  end
end
```

A counter cache follows the same rules: `belongs_to :order, counter_cache: :items_count` is maintained by Active Record callbacks, so `update_all`, `delete_all`, and raw SQL skip it, and `Order.reset_counters(order.id, :order_items)` repairs it.
