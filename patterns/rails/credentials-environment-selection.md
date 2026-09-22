---
name: credentials-environment-selection
description: Credentials Environment Selection Contract
family: rails
---
# Credentials Environment Selection Contract

## Problem
Ambiguous environment-specific credential selection can make the wrong secret available to the wrong runtime.

## Use when
An application uses per-environment credentials or custom credential paths.

## Do not use when
There is one deliberately shared credential store with a documented policy.

## Repository inspection
Inspect config.credentials.content_path, config.credentials.key_path, environment files, and deployment commands.

## Implementation procedure
Make environment selection explicit and test the expected credential/key pair in each supported environment.

## Failure modes
Production reads development credentials, missing keys, or accidental fallback to shared credentials.

## Testing
Exercise credential loading under each supported Rails environment.

## Review checklist
[ ] path explicit [ ] key explicit [ ] environment test [ ] fallback understood

## Related skills
rails-encryption-credentials-engineering, rails-initialization-configuration-engineering