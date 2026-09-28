# Ingress boundary and mailbox routing

Reference for the `rails-action-mailbox` skill. Load it on demand when a change configures ingress, ingress authentication, or ApplicationMailbox routing. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Ingress boundary

Classify the ingress before processing any message.

~~~
external provider / MTA
-> transport authentication
-> request normalization
-> raw message capture
-> InboundEmail persistence
-> asynchronous routing
~~~

Ingress authentication proves only that the request was accepted by the configured ingress mechanism. It does not prove:

- the sender is a registered user;
- the recipient belongs to a tenant;
- the message is business-authorized;
- the content is safe;
- the From header is trustworthy as identity.

For each ingress define:

- endpoint/path;
- provider/MTA authentication mechanism;
- credential owner and rotation;
- raw message requirement;
- request/body size limits;
- timeout and proxy limits;
- replay behavior;
- logging/filtering;
- failure response semantics.

Keep provider credentials out of mailbox/domain code.

## Mailbox routing

Action Mailbox routes incoming email to mailbox classes using configured routes. Routing matches recipient-related fields and invokes the selected mailbox asynchronously.

Design routing as an explicit contract:

~~~
normalized recipient
-> specific route
-> mailbox
-> domain owner
~~~

Rules:

- order routes from specific to general;
- keep patterns narrow and readable;
- normalize address expectations before matching when custom normalization exists;
- define a deliberate catch-all/backstop strategy;
- do not route authorization decisions solely from a string match;
- do not place tenant identity in an unauthenticated mailbox name and treat it as authorization;
- test collisions between routes;
- test unmatched recipients and explicit bounce behavior.
