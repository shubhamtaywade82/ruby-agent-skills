# Serving files and downloads

Reference for the `rails-active-storage` skill. Load it on demand when a change serves private or public files, adds file controllers, or downloads blobs into memory. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Serving private files

Default private storage should remain private unless a public access contract is explicit.

Decide between:

- redirect to service URL;
- application proxy;
- authenticated controller;
- CDN-backed proxy.

For tenant/private files, define authorization before issuing a file URL.

Be especially careful with signed URLs: possession of a usable URL can itself be the access capability.

Rails documents that default Active Storage controllers are publicly accessible and that signed blob URLs can remain usable by anyone who knows the URL; higher-protection applications should use authenticated controllers and can disable the generated routes.

Do not rely on a global `before_action` alone to protect Active Storage's default controllers.

## Public files

Public access is a data-classification decision.

Before enabling public storage, verify:

- file contents are intentionally public;
- bucket/container policy is correct;
- existing objects are consistent with the new policy;
- cache/CDN behavior is understood;
- deletion/retention is compatible;
- tenant-private resources cannot accidentally attach public storage.

Never switch private storage to public as a debugging shortcut.

## Authenticated file controllers

When stronger protection is required:

1. expose a domain-owned resource route;
2. authenticate the caller;
3. authorize the resource;
4. resolve the attachment through the authorized owner;
5. generate the file response/redirect;
6. disable conflicting public Active Storage routes when appropriate.

Keep authorization tied to the domain resource rather than an arbitrary blob ID.

## Download and memory usage

Downloading a file into process memory can create large memory spikes.

Choose streaming/proxy/tempfile approaches according to the workload.

For external processors, prefer opening/downloading to a temporary file rather than loading large files into Ruby memory when the library supports it.

Inspect:

- maximum object size;
- Puma/job concurrency;
- worker memory;
- transformation concurrency;
- external process limits.

A file endpoint can become a memory-amplification path even when the database query is trivial.

Use `rails-performance`, `ruby-performance`, and `rails-production-runtime` for capacity analysis.
