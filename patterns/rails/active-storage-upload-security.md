---
name: active-storage-upload-security
description: Enforce safe Active Storage upload boundaries for type, size, authorization, tenant isolation, and untrusted file content.
family: rails
---

# Active Storage Upload Security

## Problem

Browser-provided files and metadata are untrusted and can become a cross-tenant access, resource-exhaustion, or content-processing risk.

## Use when

- accepting user uploads;
- adding direct uploads;
- allowing sensitive document/media types.

## Do not use when

- no untrusted upload boundary exists.

## Repository inspection

Inspect auth, resource ownership, tenant scope, permitted params, file-size/type rules, direct-upload configuration, storage CORS, analyzers, and malware/content scanning.

## Implementation procedure

1. Authorize the target resource.
2. Define size/count limits.
3. Define allowed business file types.
4. Treat declared MIME type and filename as untrusted.
5. Define deeper inspection where risk warrants it.
6. Restrict direct-upload origins.
7. Test invalid and cross-tenant cases.

## Failure modes

- trusting MIME type;
- arbitrary blob attachment by signed ID;
- unrestricted file sizes;
- wildcard direct-upload CORS;
- uploaded executable content treated as safe.

## Testing

Test invalid type/size, unauthorized resource, cross-tenant attachment, and unsafe direct-upload cases.

## Review checklist

- [ ] authorization
- [ ] tenant scope
- [ ] size limit
- [ ] type/content policy
- [ ] CORS
- [ ] negative security tests

## Related skills

rails-active-storage, rails-security, rails-security-engineering, rails-authentication
