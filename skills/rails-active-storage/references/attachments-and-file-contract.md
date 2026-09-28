# Attachment boundary, schema ownership, and file contract

Reference for the `rails-active-storage` skill. Load it on demand when a change declares or alters attachments, cardinality, Active Storage tables, or the accepted file contract. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Attachment boundary

Treat the attachment association as a relationship, not the file contents themselves.

The logical model is:

```text
domain record
   |
attachment relationship
   |
ActiveStorage::Blob metadata
   |
object-storage service
   |
actual file bytes
```

Define explicitly:

- owner/resource;
- cardinality;
- replacement versus additive semantics;
- allowed file types;
- maximum size;
- retention;
- access policy;
- transformation policy;
- deletion/purge behavior.

The database relationship is not the authorization policy for the underlying blob.

A valid attachment must still belong to an authorized resource and tenant.

## Active Storage schema ownership

Active Storage uses its own tables for blobs, attachment relationships, and optionally variant records.

Treat these tables as framework-owned persistence infrastructure.

Inspect:

- foreign keys/indexes;
- polymorphic record type behavior;
- primary-key type compatibility;
- variant tracking configuration;
- migration/deployment compatibility.

When domain model class names change, inspect the stored polymorphic type in attachment rows.

Do not hand-edit Active Storage tables as a shortcut for domain changes.

## File contract

A production upload should have an explicit contract:

```text
who can upload
what resource receives it
which file sizes are allowed
which media types are allowed
whether file content needs inspection
whether filenames are user-visible
where it is stored
who can read it
how it is transformed
how long it is retained
how it is deleted
```

Do not treat filename extension or browser-provided content type as sufficient trust.

The storage provider is not the application authorization layer.
