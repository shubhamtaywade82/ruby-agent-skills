# Peer-Review Comment Examples

A useful review comment explains evidence, a triggering scenario, impact, and the smallest actionable correction. Keep the tone neutral and discuss code, not the author.

## Confirmed defect

**Weak:** “This is unsafe. Please fix authorization.”

**Strong:** “**[P1] The lookup is not scoped to the current tenant.** A caller who supplies another tenant's record ID can reach this query and read data they do not own. Scope the lookup using the server-derived tenant and add a request test that verifies cross-tenant access is rejected.”

## Test weakness

**Weak:** “More tests needed.”

**Strong:** “The expected value is computed using the same calculation as the implementation, so both can share the same defect and the test still passes. Assert against an independent worked example and add a boundary case.”

## Reliability defect

**Weak:** “This job could have race conditions.”

**Strong:** “If the provider accepts the request but the response times out, the retry can submit the same side effect again. Use a stable idempotency key or reconcile the provider result before retrying, and test the timeout-after-success case.”

## Maintainability suggestion

**Weak:** “This abstraction is bad.”

**Strong:** “This wrapper has one caller and only forwards the same arguments. Inlining it would preserve the contract and remove an additional navigation point; keep the abstraction only if a real second responsibility or variation is expected.”

## Finding versus suggestion

- Use a blocking severity only when a concrete defect or policy violation justifies it.
- Label maintainability preferences as suggestions or judgment calls.
- Do not report style preferences as defects.
- Do not duplicate a linter finding; report whether the tool ran and whether it passed.
- Avoid speculative statements such as “this might be a problem” unless the uncertainty is explicit and the evidence needed to resolve it is named.
