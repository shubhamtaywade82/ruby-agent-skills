# Routing Campaign Provenance Binding

Protocol version: 1

Preflight records the exact repository identity used for a routing campaign:

- Git SHA
- skill manifest SHA-256
- public campaign manifest SHA-256
- public routing cases SHA-256
- routing contract SHA-256

The final campaign import must verify those values against the repository used for evidence packaging. This prevents evidence from being silently attached to a later or modified routing contract.

The default mode requires an exact Git SHA match. `--allow-repository-drift` may be used for operational recovery only when the content hashes still match; content drift always fails.

Example:

```bash
ruby bin/routing-campaign-provenance-verify ./routing-campaign-output
ruby bin/routing-campaign-import ./routing-campaign-output --archive ./routing-archives
```
