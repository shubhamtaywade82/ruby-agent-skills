# Channels, subscription authorization, parameters, and client actions

Reference for the `rails-action-cable` skill. Load it on demand when a change adds or alters a channel, subscription authorization, channel parameters, or client actions. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Channel boundary

A channel is the logical unit of realtime authorization and message handling.

A channel should define:

- what resource/topic the subscription represents;
- which caller may subscribe;
- which parameters are accepted;
- which stream(s) are opened;
- what client actions are allowed;
- what messages are sent;
- what happens on unsubscribe/disconnect;
- whether the subscription is tenant-scoped.

Keep channel methods small and explicit.

Do not put arbitrary domain workflows inside channel callbacks. Reuse application/domain services for state changes.

Treat client-submitted channel parameters as untrusted.

## Subscription authorization

Every subscription must be authorized against the domain resource it represents.

Typical flow:

```text
authenticate connection
-> normalize subscription parameters
-> resolve tenant/resource
-> authorize caller against resource
-> subscribe only to the authorized stream
```

Never authorize a subscription because:

- the caller is authenticated;
- the resource ID exists;
- the client knows a stream name;
- the client supplied a signed-looking identifier without verifying ownership;
- another controller already performed authorization.

For multi-tenant systems, ensure tenant ownership is part of the server-side lookup/authorization path.

Never construct a broad stream such as `"tenant_notifications"` for private data unless all authorized subscribers are intentionally allowed to receive the entire tenant stream.

## Channel parameters

Treat `params` as untrusted input.

Define:

- accepted keys;
- types;
- normalization;
- resource lookup;
- authorization;
- invalid-parameter behavior.

Prefer stable identifiers over free-form stream names.

Reject unknown or unsafe parameters rather than silently widening the subscription.

Do not embed arbitrary client strings directly into stream names without a bounded naming contract.

## Client actions

If the channel accepts incoming actions from the client, treat them like an API boundary.

For each action verify:

- authentication;
- authorization;
- parameter validation;
- resource ownership;
- idempotency where duplicate action delivery is possible;
- rate limits/abuse controls;
- domain operation outcome;
- broadcast behavior after successful state change.

Do not trust a client callback that claims an action succeeded.

Do not mutate Active Record directly from channel code when an existing domain service owns the transition.
