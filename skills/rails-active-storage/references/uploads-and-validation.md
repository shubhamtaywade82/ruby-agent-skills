# Direct uploads, CORS, and file validation

Reference for the `rails-active-storage` skill. Load it on demand when a change adds or alters direct uploads, CORS, file validation, filenames, or metadata. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Direct uploads

Direct uploads move file bytes from the browser to storage instead of through the application server.

Before enabling them, verify:

- upload endpoint/authentication;
- allowed storage service;
- CORS policy;
- maximum request/file size;
- content policy;
- signed blob creation;
- final attachment ownership;
- cleanup of blobs uploaded but never attached;
- client-side progress/error behavior.

The application server still owns domain authorization.

Do not assume direct upload makes an upload trusted because the browser successfully received a signed ID.

Direct upload is primarily a network/capacity architecture change, not a security bypass.

## Direct-upload lifecycle

Model the lifecycle explicitly:

```text
select file
-> obtain upload token/instructions
-> upload bytes
-> create/persist blob
-> receive signed blob identifier
-> attach to authorized record
-> analyze/process
```

A failure between "blob uploaded" and "record attached" can leave an unattached object.

Plan cleanup for unattached uploads.

If the application requires transactionally coupled business state and attachment, design the attachment commit boundary explicitly rather than assuming the object-store write participates in the database transaction.

## CORS

For browser-to-object-storage direct uploads, CORS is part of the security contract.

Review:

- allowed origins;
- allowed methods;
- request headers;
- credential behavior;
- exposed headers;
- preflight behavior;
- environment-specific origins.

Keep the allowlist narrow.

Never use a wildcard CORS policy for private production uploads unless the actual threat model explicitly permits it.

## File validation

Validate files at the application boundary.

Review:

- maximum byte size;
- attachment count;
- declared content type;
- extension;
- filename;
- business-purpose allowlist;
- archive/container policy;
- image/video/PDF processing requirements.

Treat uploaded bytes as untrusted even when the filename and declared MIME type look correct.

For high-risk file types or untrusted documents, consider content inspection or malware scanning before making the file broadly accessible.

Never execute uploaded files as code.

## Filenames and metadata

Treat filenames and metadata as untrusted input.

Normalize or safely encode filenames at display boundaries.

Do not construct filesystem paths from raw user filenames.

Avoid logging sensitive filenames or metadata unnecessarily.

Do not use filenames as stable identifiers.

The Active Storage blob key, not the original filename, should be treated as the storage identity.
