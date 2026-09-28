# Glossary and decision records

Reference for the `ruby-domain-modeling` skill. Load it on demand when reading, creating, or updating a domain glossary or decision record. When to write each one stays in the skill's `SKILL.md`.

Always prefer the repository's existing files and locations. The layout below is the default when the repository has none and the user agrees to add one.

## Layout

One context, the common case:

```text
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-invoices-are-immutable-after-issue.md
│       └── 0002-postgres-exclusion-constraint-for-bookings.md
└── app/
```

Several contexts, for example Rails engines or a packwerk-style modular monolith: a `CONTEXT-MAP.md` at the root points to each context's own glossary and decision records.

```text
/
├── CONTEXT-MAP.md
├── docs/adr/                         # system-wide decisions
├── engines/billing/
│   ├── CONTEXT.md
│   └── docs/adr/                     # billing decisions
└── engines/fulfillment/
    ├── CONTEXT.md
    └── docs/adr/
```

Resolve which applies: a `CONTEXT-MAP.md` means several contexts; a root `CONTEXT.md` alone means one; neither means none yet. When several contexts exist and the topic's context is unclear, ask.

Create files only when there is something to write: the glossary when the first term is settled, the decision directory when the first record is needed.

## Glossary format

```markdown
# Billing

Issues invoices for delivered orders and records payments against them.

## Language

**Invoice**:
A request for payment issued to a customer after delivery. Immutable once issued.
_Avoid_: Bill, statement

**Credit note**:
A document that reduces the amount owed on an issued invoice.
_Avoid_: Refund, negative invoice
```

Rules:

- pick one term per concept and list the rejected synonyms under `_Avoid_`;
- one or two sentences per definition: what the term is, not how the code implements it;
- only terms specific to this domain; general programming ideas (timeouts, retries, service objects) stay out;
- group terms under subheadings when natural clusters appear.

A context map lists each context with a one-line purpose and a link to its glossary, then how the contexts relate:

```markdown
## Relationships

- **Ordering → Fulfillment**: Ordering publishes `OrderPlaced`; Fulfillment consumes it to start picking.
- **Fulfillment → Billing**: Fulfillment publishes `ShipmentDispatched`; Billing issues the invoice.
```

## Decision record format

Number records sequentially (`0001-slug.md`, `0002-slug.md`) after the highest existing number. A record can be one paragraph:

```markdown
# Invoices are immutable after issue

Issued invoices are never updated; corrections are credit notes. Auditors
reconcile against the issued PDF, and in-place edits broke that trail twice.
```

Add sections only when they carry information: a status (`proposed`, `accepted`, `deprecated`, `superseded by 0007`) when decisions get revisited, rejected options when the rejection is not obvious, and consequences when a downstream effect is easy to miss.

## What qualifies as a decision record

All three must hold:

1. **hard to reverse**: changing course later costs real time or data migration;
2. **surprising without context**: a future reader would wonder why the code is this way;
3. **a real trade-off**: there were genuine alternatives, and one was chosen for stated reasons.

Typical qualifying decisions in a Rails codebase:

- architectural shape: a modular monolith with engines, or event-sourced orders with projected read models;
- integration between contexts: events rather than synchronous calls between engines;
- choices with lock-in: the database, queue backend, authentication provider, or hosting target;
- ownership and scope: "Billing owns customer payment data; other contexts reference it by id";
- deliberate deviations from Rails defaults: raw SQL instead of Active Record for a path, no callbacks for a model family;
- constraints invisible in the code: a compliance rule, a partner latency contract;
- a non-obvious rejected alternative, so it is not proposed again.

Skip the record when the choice is easy to reverse, unsurprising, or had no real alternative.
