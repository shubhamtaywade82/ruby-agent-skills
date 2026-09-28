# belongs_to, has_one, has_many, through, polymorphic, and inverse associations

Reference for the `rails-associations` skill. Load it on demand when a change declares or alters an association's type, options, through path, polymorphism, or inverse. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## belongs_to contract

A belongs_to association expresses that the declaring row references another record.

Review:

- required versus optional relationship
- foreign key name/type
- primary key when nonstandard
- database foreign key
- validation semantics
- inverse association
- authorization of referenced records.

Do not assume belongs_to validation replaces a database foreign key. Application validation and database referential integrity protect different failure paths.

When optional: true is required, explicitly reason about what NULL means and what happens when a non-NULL foreign key points to a missing row.

## has_one and uniqueness

A has_one declaration describes expected cardinality, but it does not by itself guarantee database uniqueness.

When exactly one child is required:

1. define the association
2. inspect/create the corresponding foreign key
3. enforce uniqueness where the database contract requires it
4. test duplicate creation under concurrent or independent writes.

Do not rely on a model association to prevent two rows from referencing the same owner.

## has_many collection semantics

A has_many association exposes a collection API with add, remove, clear, build, create, and assignment behavior.

Before changing collection mutation, establish:

- whether add saves immediately
- whether build leaves records unsaved
- what happens to removed members
- which callbacks/validations execute
- how dependent behavior interacts with collection methods
- whether the collection is loaded or query-backed.

Do not infer collection mutation semantics from ordinary Array behavior.

Test add, remove, replace/assignment, clear, unsaved parent, and persisted parent scenarios when they are contractual.

## Through associations

Use has_many :through when the intermediate relationship is meaningful or already exists.

Inspect the join model's:

- belongs_to associations
- validations
- uniqueness constraints
- additional attributes
- callbacks
- authorization/tenant ownership
- lifecycle.

For writable through associations, explicitly determine what Rails creates or removes in the join table when assigning or mutating the association.

Remember that deleting/replacing through join records is not necessarily equivalent to destroying the target records. The current Rails guide notes that automatic deletion of join models can be direct and does not invoke destroy callbacks.

Avoid HABTM when the join itself carries domain attributes or behavior. Prefer a join model so those semantics have an explicit owner.

## Polymorphic associations

Polymorphism stores both an identifier and a type discriminator.

Before adding or changing polymorphism define:

- allowed target classes
- tenant/security ownership
- type naming/stability
- foreign-key/index strategy
- deletion behavior
- serialization/API exposure
- migration strategy if class names change.

Do not accept arbitrary client-provided polymorphic type names for constantization or lookup.

Treat the type column as untrusted data at external boundaries and use an explicit allowlist in application code where it crosses a trust boundary.

## Inverse associations

Bidirectional recognition can affect:

- duplicate queries
- object identity in memory
- autosave
- validation of associated records
- building child records through parent associations.

Use inverse_of explicitly when automatic inference is not reliable, especially when using custom class_name, foreign_key, through relationships, or scopes.

Audit both sides whenever an association name, foreign key, or scope changes.

Do not add inverse_of blindly to every association. Verify that the relationship is genuinely bidirectional and that the local Rails version supports the declaration.
