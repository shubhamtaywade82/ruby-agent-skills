# Normalization and keys

Reference for the `rails-data-modeling` skill. Load it on demand when identifying facts and dependencies, checking normal forms, or choosing keys. The decision rules and invariants stay in the skill's `SKILL.md`.

## Facts and functional dependencies

A functional dependency `A -> B` means that knowing `A` determines `B`. Store each fact once, in the table whose key is its determinant.

Ask of every column: **what determines this value?**

| Column | Determined by | Belongs in |
|---|---|---|
| `product_name` | `product_id` | `products` |
| `quantity` on an order line | `(order_id, product_id)` | `order_items` |
| `department_name` | `department_id` | `departments` |
| `unit_price_cents` at purchase time | the order line (a snapshot) | `order_items` |

The last row is not a violation: the price at purchase time is a different fact from the product's current price. See the history reference.

## Normal forms, applied

**1NF: one value per column, no repeating groups.**

```text
users.phone_numbers = "111,222,333"   # three facts in one column
users.roles         = "admin,editor"  # filtered and joined in practice
```

Use rows instead: `user_phone_numbers`, or `memberships` with a role. An array or JSON column is acceptable only when its elements are never joined, filtered by, or constrained individually.

**2NF: no attribute depends on part of a composite key.**

```text
order_items(order_id, product_id, product_name, quantity)
# product_name depends only on product_id
```

Keep `product_name` in `products`, unless the line deliberately records the name at purchase time.

**3NF: no attribute depends on another non-key attribute.**

```text
employees(id, department_id, department_name)
# department_name depends on department_id, not on the employee
```

Move `department_name` to `departments`.

**BCNF**: every determinant is a candidate key. It matters when a table has overlapping candidate keys, as in scheduling tables where `(room, slot)` and `(teacher, slot)` are both unique. Check it when a table has more than one natural unique combination.

## Anomalies to look for

- **Update anomaly**: one fact stored in many rows can be updated in some and not others (a department renamed in half the employee rows).
- **Insert anomaly**: a fact cannot be recorded without an unrelated fact (a department with no employees cannot exist).
- **Delete anomaly**: deleting one fact removes another (deleting the last employee loses the department).

Any of these in a proposed schema is a normalization defect unless it is a recorded snapshot or denormalization.

## Keys

Distinguish four things that are often conflated:

| Concept | Purpose | Rails representation |
|---|---|---|
| Primary key | persistence identity, referenced by foreign keys | `id` by default |
| Candidate or natural key | a business combination that is unique | unique index, often composite |
| Business identifier | a value users and systems quote, such as an invoice number | column with unique index |
| Public identifier | an unguessable id for URLs and APIs | UUID or token column with unique index |

Uniqueness is a business constraint; primary key choice is a persistence decision. A mutable value (email, slug, SKU) makes a poor primary key, because changing it cascades through every foreign key.

## Primary key strategies

Check the application's Rails version and database before choosing:

- **`bigint` `id`** (the default for new tables on PostgreSQL and MySQL): simple, compact, ordered. Prefer it unless a reason below applies.
- **UUID** (`create_table :orders, id: :uuid`, with `t.references ..., type: :uuid` on children): for ids generated outside the database, merged across databases, or exposed publicly without enumeration. On PostgreSQL the default uses `gen_random_uuid()`. Costs: larger indexes and random insert order.
- **Composite primary key** (`create_table ..., primary_key: [:store_id, :sku]`, native since Rails 7.1): when the composite is the real identity, often in legacy or sharded schemas. Rails supports it in queries and associations, but it adds complexity across the stack. Prefer a surrogate `id` plus a composite unique index when the composite is only a business rule.
- **Custom single-column key** (`self.primary_key = "account_code"`): mainly for legacy schemas.

Decision:

```text
Is a single stable surrogate id enough?                      -> bigint id (default)
Must ids be generated off-database or be unguessable?        -> UUID id
Is the composite genuinely the row's identity (legacy, shard)? -> composite primary key
Is the composite only a uniqueness rule?                     -> surrogate id + composite unique index
```
