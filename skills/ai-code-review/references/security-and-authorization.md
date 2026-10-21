# Security and Authorization Review

Use this reference when a change touches authentication, authorization, tenant scope, untrusted input, file/network boundaries, credentials, or sensitive data. Compose with the owning Rails security, authentication, authorization, and security-engineering skills; those skills remain authoritative for the framework and application contracts.

## Core distinctions

Authentication establishes who the actor is. Authorization decides whether that actor can perform an action on a resource in the current context. A login check alone does not prove resource authorization.

For important access rules, identify the actor, resource, action, tenant/account scope, authoritative identity source, policy owner, audit requirement, and alternate execution paths.

## Object-level authorization

Inspect lookups that use request-controlled identifiers. Determine whether the query scope is derived from trusted server context or an explicit policy authorizes the loaded resource. Do not flag an unscoped lookup mechanically if a real, enforced authorization boundary follows it; trace the complete path.

```ruby
# Potential defect: no visible scope or policy boundary in this path.
def show
  order = Order.find(params[:id])
  render json: order
end

# Typical scoped lookup; adapt to the actual identity model.
def show
  order = current_user.orders.find(params[:id])
  render json: order
end
```

Check API endpoints, admin paths, exports/downloads, jobs, webhooks, callable services, and cached decisions—not only browser actions.

## Tenant isolation

Tenant context should normally come from a trusted server-side identity/session or authenticated service context, not from an arbitrary request parameter when the server can determine tenant identity independently. Review database constraints, jobs/messages, exports/reports, and cache keys for cross-tenant access.

```ruby
# Risk: the caller chooses the tenant whose data is queried.
tenant = Tenant.find(params[:tenant_id])
tenant.orders.find(params[:id])
```

This is a candidate finding until the actual identity model and authorization path are inspected. Confirm impact and severity from the real data boundary.

## Input and output boundaries

Trace untrusted data to its destination:

- SQL: use parameterized conditions or safe query APIs; inspect dynamic identifiers separately from values.
- HTML: verify contextual escaping and safe rendering; do not trust user-controlled strings because they are marked safe.
- Shell/process: avoid constructing shell commands from input; use safe argument arrays and explicit allowlists.
- Redirects/network: validate schemes and destinations; account for redirects and private/link-local destinations when SSRF is relevant; apply timeouts and response-size limits.
- Uploads/imports: enforce size and format limits based on content, storage isolation, and authorization before exposing results.
- Webhooks: verify signatures, replay protection, event identity, and idempotent side effects.
- Secrets/logging: avoid credentials and sensitive payloads in source, URLs, exceptions, logs, fixtures, and telemetry.

## Sessions and credentials

Check session rotation/revocation, CSRF controls, token expiry, password-recovery replay rules, cookie flags/scope, provider credentials, rotation, and secret redaction where the change reaches these boundaries. Do not recommend disabling controls to make a request work.

## Evidence and testing

For a confirmed finding, show the concrete request/job/event and resource that crosses the boundary, cite the actual code path, and test the security property at the owning boundary. Useful tests prove unauthorized access is denied, tenant A cannot access tenant B, forged/replayed events are rejected, dangerous input cannot reach a sink, and secrets do not appear in logs.

A clean scanner is not proof that security is correct. Treat scanner output as evidence to investigate, not an automatic severity verdict.
