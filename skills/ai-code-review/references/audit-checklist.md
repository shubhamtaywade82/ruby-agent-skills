# Whole-Repository Audit Checklist

## Scope and inventory
- [ ] Repository root, default branch, runtime/framework versions, and local instructions identified.
- [ ] Inventory generated; excluded paths, generated code, vendored code, and external systems recorded.
- [ ] Audit risk zones prioritized by impact and exploitability.

## Identity and security
- [ ] Public, authenticated, privileged, and tenant-scoped entry points enumerated.
- [ ] Every sensitive resource access has an authoritative authorization check.
- [ ] Input-to-sink flows examined at SQL, HTML, filesystem, network, command, and deserialization boundaries.
- [ ] Secrets and sensitive data excluded from logs, URLs, fixtures, and error output.

## Persistence and reliability
- [ ] Critical data invariants enforced at the authoritative database boundary where applicable.
- [ ] Concurrent writers, transactions, locks, callback bypasses, and migration sequencing considered.
- [ ] Jobs and event consumers are safe under retries, duplicates, timeouts, and partial side effects.
- [ ] Recovery, observability, and replay mechanisms have bounded behavior.

## Tests and quality
- [ ] Tests for critical behavior are meaningful, deterministic, and exercise the owning boundary.
- [ ] Security and integrity findings have adversarial regression coverage or documented limits.
- [ ] Dead-code candidates checked against dynamic dispatch, callbacks, routes, reflection, external APIs, and autoloading.
- [ ] Complexity and dependency findings cite concrete cost or unnecessary behavior rather than personal preference.

## Evidence and report
- [ ] Each confirmed finding has a location, triggering scenario, impact, violated contract, evidence, and recommended action.
- [ ] Systemic findings are backed by independent instances; one-offs are not generalized.
- [ ] Severity matches impact, exploitability, scope, and recoverability.
- [ ] Commands and tools reported only when actually run.
- [ ] Coverage limits and residual uncertainty are explicit.
