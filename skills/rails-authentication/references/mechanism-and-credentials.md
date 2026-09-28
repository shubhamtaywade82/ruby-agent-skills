# Authentication mechanism, identity, credential storage, and state machine

Reference for the `rails-authentication` skill. Load it on demand when a change alters the authentication mechanism, identity model, credential storage, or authentication states. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Authentication mechanism boundary

Classify the repository mechanism before editing.

### Rails 8+ generated authentication

Rails 8 introduced a built-in authentication generator. The current Rails Security Guide documents a baseline flow containing User, Session, Current, SessionsController, PasswordsController, an Authentication concern, password reset views/mailers, routes, and migrations.

The generator uses has_secure_password/bcrypt for password hashing and creates a database-backed Session model in its baseline implementation.

Do not treat generated authentication as a black box. Inspect the generated concern, session model, routes, password reset flow, and migrations before modifying it.

### Authentication gem

For Devise or another gem, map:

~~~text
gem module
-> model concerns
-> controllers/routes
-> session/token storage
-> callbacks/hooks
-> configuration
-> upgrade/version semantics
~~~

Do not duplicate framework behavior with a second home-grown authentication concern.

### Custom authentication

For custom systems identify:

- password hashing API;
- credential comparison;
- session/token issuance;
- storage;
- revocation;
- expiry;
- recovery;
- request identity loading;
- audit/observability;
- failure semantics.

Custom authentication needs explicit security regression coverage because framework guarantees may not exist.

## Identity versus authorization

Authentication should establish a stable principal such as current_user, current_account, a service identity, or an API client identity.

Do not infer authorization from identity alone.

A protected request should normally compose:

~~~text
authenticate
-> resolve principal
-> resolve authoritative tenant/resource
-> authorize action
-> execute
~~~

Avoid trusting a client-supplied resource or tenant identifier as authoritative identity context.

Use the repository's authorization policy and tenant-isolation skills for resource access decisions.

## Credential storage

Passwords must never be stored in plaintext.

Inspect hashing algorithm/library, digest columns, credential normalization, password-change timestamp, password history requirements, compromised-password checks, logging filters, and migration compatibility.

For Rails has_secure_password, inspect the actual Rails version's supported behavior rather than assuming every version has identical validation or token APIs.

Password policy is separate from password hashing.

Never log plaintext passwords, password confirmations, reset tokens, bearer credentials, session cookies, or Authorization headers.

## Authentication state machine

Model authentication as explicit state transitions.

~~~text
anonymous
-> credential submitted
-> credential accepted/rejected
-> authenticated session created
-> authenticated request context
-> logout/revocation/expiry
-> anonymous
~~~

Recovery adds:

~~~text
authenticated
-> credential-change request
-> recovery verification
-> credential updated
-> previous authentication state reviewed/revoked
~~~

Compromise remediation may require:

~~~text
active sessions
-> revoke all
-> rotate/reissue credentials
-> re-authenticate
~~~

Define these transitions before adding callbacks or scattered controller logic.

Treat authentication as explicit states and transitions rather than a boolean current-user check:

anonymous
  -> credential_verified
  -> authenticated
  -> renewed
  -> expired
  -> revoked

Also model security-triggered transitions:

authenticated
  -> logout
  -> credential_change
  -> global_revoke
  -> compromise_response

For each transition identify the authoritative state store, the credential involved, the evidence required, and what subsequent requests must observe.

A valid session is not necessarily a fresh authentication. Sensitive operations may require recent credential proof or explicit reauthentication.
