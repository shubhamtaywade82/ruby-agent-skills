# Rails Security Integration

This repository includes a dedicated security-engineering layer for AI coding assistants.

## Sources

- Rails Security Guide: https://guides.rubyonrails.org/security.html
- Brakeman: https://github.com/presidentbeef/brakeman
- bundler-audit: https://github.com/rubysec/bundler-audit

The Rails guide covers authentication, sessions, CSRF, redirection/files, user management, injection, unsafe query generation, HTTP security headers, admin security, credentials, and dependency security.

## Architecture

```text
untrusted input
      ↓
trust boundary
      ↓
authentication
      ↓
authorization
      ↓
validation / parameterization
      ↓
dangerous sink
      ↓
abuse-case test
      ↓
security scanners
```

## Tooling

| Tool | Role |
|---|---|
| Brakeman | Rails static security analysis |
| bundler-audit | Gem dependency advisory checking |

Brakeman supports multiple machine-readable formats and configurable checks/ignores. It returns a non-zero status by default when security warnings or scan errors are present.

bundler-audit checks Bundler dependencies against the Ruby Advisory Database; its compatibility is version-sensitive, so the installed version and repository lockfile govern invocation details.

## Agent command

```bash
ruby bin/security-audit /path/to/rails-app
```

The command runs installed Brakeman and bundler-audit tooling where available and emits structured JSON. Missing tools are reported as `skipped`, not as a false security pass.

## Security policy

Scanner findings are evidence. Agents must trace data flow and verify whether attacker-controlled input can reach the reported sink and whether an existing control blocks exploitation.

Do not:

- suppress findings merely to make CI green;
- disable CSRF globally;
- treat authentication as authorization;
- trust resource IDs without authorization;
- interpolate untrusted values into SQL or shell commands;
- mark untrusted HTML safe;
- trust arbitrary outbound URLs;
- accept webhook side effects before authenticating the event;
- store secrets in source control or logs.

Security regression tests should prove the protected boundary, not merely inspect implementation details.