# Upload authorization and tenant isolation

Reference for the `rails-active-storage` skill. Load it on demand when a change decides who may upload, attach, or read a blob, or crosses tenants. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Upload authorization

Before accepting an attachment, verify:

- authenticated actor;
- resource ownership;
- tenant membership;
- action authorization;
- upload purpose;
- allowed attachment slot;
- size/count limits;
- content policy.

For direct uploads, the browser may send bytes directly to storage before the final domain record is persisted. Therefore authorization and attachment ownership must still be enforced when the signed blob is attached to the domain record.

Never interpret possession of a signed blob ID as proof that the caller owns the target resource.

## Tenant isolation

For multi-tenant applications, make resource ownership the authoritative access boundary.

Review:

- attachment lookup by resource;
- blob access through resource routes;
- direct blob IDs accepted from clients;
- background jobs processing attachment IDs;
- administrative access;
- downloads/exports;
- previews and variants;
- purge operations.

Do not expose a generic `ActiveStorage::Blob.find(params[:id])` endpoint for tenant-private files without an explicit authorization boundary.

A blob can outlive the controller/request that created it, so authorization must be applied at every access boundary.

Use `rails-security` and `rails-security-engineering` for threat modeling and tenant-isolation review.
