# Ownership, content contract, editing authorization, and the editor boundary

Reference for the `rails-action-text` skill. Load it on demand when a change alters rich-text ownership, the stored content contract, who may edit, or the Trix/editor boundary. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Ownership boundary

Action Text attaches rich content to an owning Active Record model.

Define:

- owner/resource;
- rich-text attribute;
- who may create/update/delete it;
- tenant/account scope;
- retention/deletion semantics;
- whether embeds may reference external/domain objects;
- whether content can be public or private.

`ActionText::RichText` existence is not equivalent to authorization.

Do not expose or mutate arbitrary RichText rows through a generic ID endpoint without authorizing the owning record.

Prefer editing through the domain resource that owns the rich-text field.

## Content contract

Define what the rich text is for.

Examples:

- article body;
- comment;
- support note;
- product description;
- internal documentation;
- user profile biography.

The contract should state:

- allowed formatting;
- links;
- tables/lists if supported;
- embeds/attachments;
- maximum content size;
- permitted HTML elements/attributes;
- URL policy;
- whether content is public/private;
- whether historical versions are retained.

Do not allow arbitrary HTML simply because Action Text stores HTML-like content.

Treat rich text as structured untrusted user input at the write boundary even though Action Text sanitizes content for rendering.

## Editing authorization

Authorization happens before the content is persisted.

For update flows verify:

- authenticated actor;
- resource ownership/tenant;
- edit permission;
- content purpose;
- allowed attachment/embed policy.

The controller/form may permit the rich-text attribute, but authorization must still be evaluated against the owning resource.

Do not authorize arbitrary `ActionText::RichText.find(params[:id])` updates.

Do not infer authorization from a Signed Global ID.

Compose with `rails-security` and `rails-security-engineering`.

## Trix/editor boundary

Trix is the browser editing interface, not the application's authorization layer.

Review:

- imported Trix/@rails/actiontext assets;
- editor toolbar/custom actions;
- direct-upload events for attachments;
- pasted HTML/content behavior;
- client-side limits;
- server-side validation/sanitization;
- browser compatibility.

Client-side restrictions are usability controls.

Never rely on editor JavaScript to enforce a security or tenant boundary.
