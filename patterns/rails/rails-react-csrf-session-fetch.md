---
name: rails-react-csrf-session-fetch
description: "Send the Rails session cookie and CSRF token from React fetch calls without weakening forgery protection."
family: rails
---

# Rails React CSRF Session Fetch

## Problem
Same-origin React code calling Rails with `fetch` fails with `InvalidAuthenticityToken` unless it sends the CSRF token, and the tempting fixes (disabling forgery protection or storing tokens in `localStorage`) remove a security control.

## Use when
React runs on the same origin as a Rails app that authenticates with the session cookie.

## Do not use when
The client is cross-origin or third-party; use the token path from the `browser-api-auth-boundary` pattern instead.

## Repository inspection
Inspect `protect_from_forgery` settings, `csrf_meta_tags` in the layout, controller base classes, and the client's HTTP wrapper.

## Implementation procedure
1. Confirm the layout renders `csrf_meta_tags`.
2. In one HTTP wrapper, send `X-CSRF-Token` on non-GET requests and `credentials: "same-origin"` on all requests.
3. Fail loudly when the meta tag is missing.
4. Distinguish 401 (re-authenticate) from other failures and keep error bodies for 422 handling.

## Example

```ts
// Same-origin React inside a Rails app authenticated by the Rails session cookie.
// The cookie is HttpOnly and sent by the browser; the client never stores a
// session token in localStorage. State-changing requests carry the CSRF token
// that Rails renders with <%= csrf_meta_tags %>.
export class UnauthenticatedError extends Error {}
export class HttpError extends Error {
  constructor(readonly status: number, readonly body: unknown) {
    super(`HTTP ${status}`);
  }
}

function csrfToken(): string {
  const meta = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]');
  if (!meta?.content) throw new Error("csrf-token meta tag missing: render csrf_meta_tags in the layout");
  return meta.content;
}

const SAFE_METHODS = new Set(["GET", "HEAD", "OPTIONS"]);

export async function railsFetch(path: string, init: RequestInit = {}): Promise<unknown> {
  const method = (init.method ?? "GET").toUpperCase();
  const headers = new Headers(init.headers);
  headers.set("Accept", "application/json");
  if (!SAFE_METHODS.has(method)) headers.set("X-CSRF-Token", csrfToken());
  if (init.body !== undefined && !headers.has("Content-Type")) headers.set("Content-Type", "application/json");

  const response = await fetch(path, { ...init, method, headers, credentials: "same-origin" });
  if (response.status === 401) throw new UnauthenticatedError("session expired");
  const body: unknown = response.status === 204 ? null : await response.json().catch(() => null);
  if (!response.ok) throw new HttpError(response.status, body);
  return body;
}
```

## Failure modes
`skip_forgery_protection` or `with: :null_session` added to silence errors, tokens in `localStorage`, CSRF added in some call sites but not others, and 401 treated like a generic error.

## Testing
CSRF header present on POST/PATCH/DELETE and absent on GET, missing meta tag fails, 401 and 422 handled distinctly, and a Rails request test proving a mutation without the token is rejected.

## Review checklist
Is there exactly one place that adds CSRF and credentials, and is forgery protection still on?

## Related skills
rails-react-integration,rails-authentication,rails-security
