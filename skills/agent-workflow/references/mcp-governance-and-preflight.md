# MCP Permission Profiles and Preflight

This reference defines the MCP governance workflow used by `bin/mcp-preflight`. Read it with [Ruby and Rails MCP Developer Tools](ruby-rails-mcp-tools.md) when selecting or configuring a server.

## Separate four decisions

Do not collapse configuration, availability, tool-level permission, and human approval into one boolean.

```text
MCP client configuration
  -> exact tool classification in mcp/permissions.yml
  -> profile and environment decision
  -> explicit preflight consent (--probe)
  -> transport + MCP protocol discovery
  -> live tools/list membership
  -> preflight report
  -> host-side user approval, where required
  -> actual tools/call (outside this preflight)
```

| State | Evidence | What it proves |
|---|---|---|
| Configured | Exact server key exists in the MCP client's `mcpServers` map | The client has a registration; it may still be broken |
| Healthy | Discovery and `tools/list` complete successfully | The process/endpoint responds and publishes a tool inventory now |
| Tool available | Exact requested name appears in live `tools/list` | The server currently advertises that tool |
| Profile allowed | Exact server key + tool name maps to an allowed capability | The local policy permits the capability under the selected profile |
| Approval required | The capability is listed under `require_approval` | The agent must obtain specific user consent before the host invokes it |

A successful discovery check does **not** prove a Rails app, database, debugger, shell, or external dependency is healthy. It does not invoke the requested tool or test side effects. The report always includes `tool_invoked: false`.

## Run the preflight

```bash
ruby bin/mcp-preflight \
  --config .mcp.json \
  --policy mcp/permissions.yml \
  --server ask-rails-harness \
  --tool query_database \
  --profile inspect \
  --environment development \
  --probe
```

| Option | Meaning |
|---|---|
| `--config PATH` | JSON config containing `mcpServers`; defaults to `.mcp.json` |
| `--policy PATH` | Permission policy YAML; defaults to this pack's `mcp/permissions.yml` |
| `--server NAME` | Exact key under `mcpServers` |
| `--tool NAME` | Exact name returned by the live `tools/list` response |
| `--profile NAME` | `inspect`, `test`, `debug`, `console`, or `maintenance` |
| `--environment NAME` | `development`, `test`, `staging`, or `production` |
| `--cwd PATH` | Override the STDIO server's working directory |
| `--timeout SECONDS` | Per-request timeout, default 5 seconds, maximum 30 |
| `--isolated` | Operator attestation that the target is disposable and isolated |
| `--probe` | Explicitly allow starting the registered STDIO command or contacting its HTTP URL |

**Review the registration before using `--probe`.** Starting a STDIO MCP server executes its configured command and startup code. The preflight avoids shell interpolation and never calls `tools/call`, but process startup is still code execution. An HTTP probe makes an outbound network request. Do not run it automatically for untrusted or newly-added server registrations.

The command prints a JSON report. Exit codes are `0` allowed, `2` approval required, `3` denied, `4` unavailable, and `64` invalid configuration or usage. A non-zero result is a gate outcome, not an invitation to retry with weaker permissions.

## Default permission profiles

The default policy is `mcp/permissions.yml`. Copy it into the consuming project or a private configuration location before changing its tool map. The server key must match the MCP client's `mcpServers` key exactly.

| Profile | Allowed capabilities | Approval required |
|---|---|---|
| `inspect` | Metadata, source, and schema reads | Application-data reads |
| `test` | Metadata/source/schema reads and test execution | Application-data reads, database writes, filesystem writes |
| `debug` | Metadata/source/schema reads | Debugger control and arbitrary code evaluation |
| `console` | Metadata/source/schema reads | Arbitrary code evaluation, application-data reads, database writes, external network |
| `maintenance` | Metadata/source/schema reads | Application-data reads, test execution, shell, dependency/filesystem/database writes, external network |

Test execution, debugger control, arbitrary code evaluation, shell execution, dependency writes, filesystem writes, database writes, and external network capabilities also require `--isolated`. For the test profile, use `--environment test` and attest isolation only when the test database and process are actually disposable.

`production` is denied by the evaluator before a server process starts or an HTTP request is made. `production_access` and `credential_export` are unconditional denies even if mistakenly added to a profile's allow list. Capabilities absent from a profile are denied.

## Tool classification is explicit

A tool is classified by the local policy, not by text supplied by the MCP server. Server names, tool descriptions, annotations, and tool results are untrusted inputs. Never infer that a tool is read-only because its name contains `list`, `get`, `read`, or `inspect`.

The shipped policy contains a starter map for the Rails harness:

```yaml
servers:
  ask-rails-harness:
    tools:
      schema_graph: schema_read
      route_inspector: metadata_read
      read_model: schema_read
      query_database: application_data_read
      read_log: application_data_read
      run_tests: test_execution
      run_command: shell_execution
```

`ask-rails-harness` is an example MCP client key. If your `.mcp.json` uses `rails-harness`, rename the policy key to match. A different or newly-added tool remains **unclassified and denied** until a maintainer reviews the live tool list and implementation, then adds an explicit mapping.

Do not trust MCP tool annotations as a substitute for this classification. They are advisory metadata, not a security boundary.

## Capability vocabulary

- `metadata_read`, `source_read`, `schema_read`: structural and source context.
- `application_data_read`: logs, records, and query results that may contain sensitive data.
- `test_execution`: test code can execute application code and mutate test fixtures/databases.
- `debugger_control`, `arbitrary_code_execution`: process inspection, evaluation, and persistent console execution.
- `shell_execution`: command execution in the configured working directory.
- `dependency_write`, `filesystem_write`, `database_write`, `external_network`: mutation or external side effects.
- `production_access`, `credential_export`: unconditional deny capabilities.

## Availability checks and protocol eras

### STDIO

The STDIO probe:

1. Starts the registered command without a shell.
2. Sends the modern `server/discover` request with protocol `2026-07-28`.
3. Falls back to the legacy `initialize` / `notifications/initialized` exchange when the server responds with JSON-RPC method-not-found.
4. Calls `tools/list` in the selected protocol era and reports exact tool names.
5. Terminates the child process group after the probe.

STDIO responses must be newline-delimited JSON-RPC on STDOUT. Logs belong on STDERR; non-JSON STDOUT is treated as a protocol failure. The child inherits a small environment allowlist (PATH, HOME, temporary-directory and Ruby toolchain variables) plus explicitly configured `env` and named `inherit_env` values. Values are never written to the report.

### Streamable HTTP

The HTTP probe implements modern `2026-07-28` discovery and `tools/list`. It sends the per-request protocol metadata and `Mcp-Method` routing header, verifies TLS certificates, allows plain HTTP only for loopback hosts, rejects credentials embedded in URLs, and does not follow redirects.

The current preflight does not run OAuth or consume custom `headers` from the client config. Authenticate with the MCP host first; HTTP 401/403 is reported as `authorization_required`. Legacy handshake-era HTTP and legacy HTTP+SSE are not supported by this preflight and fail closed. An ordinary HTTP health URL is not proof that MCP discovery or `tools/list` works.

### Report states

- `healthy`: discovery and `tools/list` succeeded.
- `not_checked`: the policy denied the request before a process was started or URL contacted.
- `authorization_required`: remote MCP requires authentication unavailable to this preflight.
- `unavailable`: command startup, transport, timeout, protocol, or tool-list check failed.
- Decision `unavailable`: the server is not healthy or the requested tool is absent from its live inventory.

Health is a point-in-time observation. It is not cached and cannot guarantee that a later tool invocation will succeed.

## Security contract and limitations

1. **No implicit trust:** unclassified servers and tools are denied. Add exact mappings only after reviewing the server implementation or trusted documentation.
2. **Policy before process start:** denied capabilities, production, and unknown environments are rejected before the process starts or HTTP request is made.
3. **No tool execution:** preflight performs discovery and tool listing only; it never invokes `tools/call`.
4. **Approval is separate:** `approval_required` is not an allow decision. Obtain specific user consent, and require the MCP host to enforce it at the actual call boundary.
5. **Isolation is an attestation:** `--isolated` is supplied by the operator. The script does not inspect containers, DB grants, mounts, egress policy, or OS privileges. Do not use it without independently verifying those controls.
6. **Production fails closed:** the shipped policy denies the `production` environment. Do not bypass this by renaming the environment.
7. **Secret hygiene:** reports include server/tool names, health metadata, and decisions only. Do not put tokens in command-line arguments. Explicit `env` values may still contain secrets and are passed to the child process.
8. **A name is not a safety property:** a listed query tool may still mutate data; a schema tool may depend on a running database; a healthy process may still fail every test.

The preflight is a guardrail for agent reasoning, **not a reference monitor**. It does not enforce permissions on later calls. For high-impact operations, enforce the same policy inside the MCP host/client and at application/database boundaries.

## Skill composition

| Task | Load |
|---|---|
| Select a Ruby/Rails MCP server | [ruby-rails-mcp-tools.md](ruby-rails-mcp-tools.md) |
| Configure profiles, tool mappings, or health checks | This reference + `agent-workflow` |
| Test execution and test isolation | `rails-test-engineering` + owning implementation skill |
| Shell/console/debugger and credentials | `ruby-debugging`, `rails-security`, `rails-security-engineering` |
| Application-owned MCP tools and authorization | `rails-api-integration`, `rails-security`, `rails-authorization` |
| LLM tool calls made by application code | `ruby-llm-integration` |

## Source foundation

- MCP specification and 2026-07-28 release: https://modelcontextprotocol.io/specification/2026-07-28
- 2026-07-28 protocol changes: https://blog.modelcontextprotocol.io/posts/2026-07-28/
- MCP Ruby SDK protocol versions: https://ruby.sdk.modelcontextprotocol.io/protocol-versions/
- MCP TypeScript SDK 2026-07-28 migration notes: https://ts.sdk.modelcontextprotocol.io/v2/migration/support-2026-07-28
