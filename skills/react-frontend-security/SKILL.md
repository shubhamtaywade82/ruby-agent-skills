---
name: react-frontend-security
description: Use when React/TypeScript code renders untrusted or server-provided HTML, handles auth tokens, uses postMessage/iframe/window.open, accesses browser storage, configures CSP/Trusted Types, or ships third-party scripts and production source maps.
---

# React Frontend Security Engineering

## Purpose

Establish an explicit client-side security boundary for React + TypeScript
applications: DOM XSS prevention, sanitization boundaries, Content Security
Policy, Trusted Types, token storage, cross-origin communication, build
artifact hygiene, and third-party script supply chain.

This skill is the frontend complement to `rails-security-engineering`. The
Rails skill owns server-side concerns (CSRF tokens issued, SSRF, authz). This
skill owns the client-side boundary that consumes those primitives.

Runtime type safety (`typescript-runtime-contracts`) is orthogonal: a
fully-typed XSS is still an XSS. Type correctness does not replace security
engineering.

## Activate when

- rendering user-generated or CMS-authored HTML (`dangerouslySetInnerHTML`, `v-html`);
- handling auth tokens, refresh tokens, JWTs, or API keys in client code;
- using `postMessage`, `MessageChannel`, or `BroadcastChannel`;
- using `<iframe>`, `window.open`, or `target="_blank"`;
- accessing `localStorage`, `sessionStorage`, `IndexedDB`, or `document.cookie`;
- configuring `Content-Security-Policy` headers or meta tags;
- configuring `next.config.js` / `vite.config.ts` security-relevant fields (`headers`, `csp`, `trustedTypes`);
- integrating third-party `<script>` tags, analytics, or snippet injection;
- emitting source maps or inlining environment variables in a production build;
- reviewing a PR that touches any of the above.

If any of these are present in the touched code and this skill is not invoked,
treat it as a routing failure. This is a hard rule, not a guideline.

## Repository inspection

Inspect:

1. existing HTML rendering sites (`dangerouslySetInnerHTML` usage) and any sanitization utilities;
2. the auth/token handling pattern (where tokens live, how they're attached to requests);
3. the CSP configuration (header from Rails, meta tag in `index.html`, Next.js `headers` config);
4. `postMessage` and iframe usage across the codebase;
5. browser storage usage and what is stored;
6. the build config's source map and env-var inlining policy;
7. third-party script tags in `index.html` or analytics injection points;
8. the dependency manifest for security-relevant packages (`dompurify`, `trusted-types`, `partytown`, etc.);
9. existing security tests and the test runner configuration;
10. the Rails-side security skill output for the matching server primitives.

Never assume a control exists because the framework supports it. Verify where
the repository actually applies it.

## Decision rules

### DOM XSS and HTML rendering

- Treat any server-provided HTML as untrusted at the client boundary,
  regardless of upstream trust claims. "Trusted CMS" is a server-side claim;
  the client treats the bytes as hostile.
- Render untrusted HTML only after sanitization through an explicit allowlist
  of tags and attributes. Denylists are forbidden.
- `dangerouslySetInnerHTML` is allowed at exactly one site: the single
  sanitization module. It is forbidden everywhere else.
- Forbidden: `eval`, `new Function`, `setTimeout(string)`, `setInterval(string)`.
- Forbidden: `<a href={userInput}>` without validation — `javascript:` URLs are
  XSS vectors.

### Sanitization boundary

- Sanitization happens once, at the trust boundary, never at render time.
- Sanitized output is typed as a branded `SafeHTML` type, not `string`, so
  downstream render sites are auditable.
- The sanitization function is the only place that produces `SafeHTML` and the
  only place that calls `dangerouslySetInnerHTML`.

### Content Security Policy

- A baseline CSP is required for all production builds:
  `default-src 'self'`, `script-src 'self'`, `object-src 'none'`,
  `base-uri 'self'`, `frame-ancestors 'self'`.
- `unsafe-inline` and `unsafe-eval` are forbidden in production. Use nonces,
  hashes, or Trusted Types instead.
- The CSP is set by the server (Rails `content_security_policy` block or
  Next.js `headers` config), not by a meta tag, when possible. Meta tags are
  a fallback for static hosts.
- Cross-reference `rails-security-engineering` for the server-side CSP block.

### Trusted Types

- Required for any app that accepts user content or runs third-party scripts.
- Allowlist exactly one HTML policy in the CSP: DOMPurify's own policy
  (`trusted-types dompurify`), or one module-private policy passed to DOMPurify
  through its `TRUSTED_TYPES_POLICY` option. No other code creates HTML policies.
- The sanitization module returns `TrustedHTML` (DOMPurify
  `RETURN_TRUSTED_TYPE: true`). Under enforcement, assigning a plain string to
  `innerHTML` — including through `dangerouslySetInnerHTML` — throws a
  `TypeError`.
- `require-trusted-types-for 'script'` is the production default.

### Token storage and credential boundaries

- Forbidden: storing access tokens, refresh tokens, or session secrets in
  `localStorage` or `sessionStorage`. Any JS on the origin can read them.
- Allowed: HttpOnly, Secure, SameSite=Lax cookies set by the server; in-memory
  storage for short-lived access tokens with refresh-via-cookie.
- When cookies carry auth, CSRF protection is required on every state-changing
  request. Cross-reference `rails-security` for the CSRF token contract.

### Cross-origin communication

- `postMessage` must specify a target origin (never `*`) and validate
  `event.origin` on receipt.
- `iframe` sources must be pinned to a known origin; `sandbox` attributes must
  be set explicitly.
- `window.open` return values must be validated; cross-window references must
  assume the opener can be spoofed.
- Open-redirect defense: any client-side redirect target derived from query
  params must be validated against an allowlist of paths.

### Build artifact hygiene

- Source maps must not ship to production CDN origins accessible to anonymous
  clients. If needed, they live on a restricted origin or behind auth.
- Env vars inlined by the build (`import.meta.env.VITE_*`,
  `process.env.NEXT_PUBLIC_*`) are public — no secrets inlined.
- Production build output must not contain `.map` files on the public origin.

### Third-party scripts and supply chain

- Third-party scripts must be SRI-hashed (`integrity` attribute) and pinned to
  a specific version.
- Analytics/snippet injection must go through a CSP nonce, not `unsafe-inline`.
- `npm install` of any package from a new publisher requires a review note.

## Implementation procedure

1. **Identify the trust boundary.** Where does untrusted data enter the client?
   (API response, postMessage, URL param, browser storage, third-party script.)
2. **Place the sanitization site.** One function, one branded return type, one
   render site. No scattered `dangerouslySetInnerHTML` calls.
3. **Configure CSP.** Server-set if possible; meta tag fallback for static
   hosts. No `unsafe-inline` or `unsafe-eval` in production.
4. **Audit token storage.** Move any token in `localStorage`/`sessionStorage`
   to HttpOnly cookie or in-memory. Verify the refresh flow.
5. **Audit cross-origin code.** Every `postMessage` has a target origin; every
   receiver validates `event.origin`; every `iframe` has a `sandbox`.
6. **Audit build artifacts.** Production build has no public `.map` files; no
   secrets in `NEXT_PUBLIC_*` / `VITE_*` vars.
7. **Audit third-party scripts.** SRI hashes present; versions pinned; CSP
   nonce in place.
8. **Add security tests.** Assert that script tags in input are stripped from
   rendered output. Assert that `postMessage` receivers reject wrong origins.
9. **Verify statically.** Grep for `dangerouslySetInnerHTML` outside the
   sanitization module, `localStorage.setItem` with token keys, `postMessage(..., '*')`,
   `eval(`, `new Function(`.
10. **Report residual risk.** Anything that deviates from the rules above is
    documented with a reason and a revisit trigger.

## Anti-patterns / failure modes

- `dangerouslySetInnerHTML={{ __html: someString }}` outside the single
  sanitization site → XSS risk.
- `localStorage.setItem('token', ...)` → token leakage to any JS on the origin.
- `postMessage(data, '*')` → cross-origin data leak.
- `<a href={userInput}>` without validation → `javascript:` URL XSS.
- `target="_blank"` without `rel="noopener noreferrer"` → reverse tabnabbing.
- `eval` / `new Function` / `setTimeout(string)` → arbitrary code execution.
- `unsafe-inline` or `unsafe-eval` in production CSP → defeats CSP.
- Source maps on a public production origin → source code recovery.
- `NEXT_PUBLIC_*` / `VITE_*` env var whose value is a server secret → secret
  leakage to every client.
- Third-party `<script>` without `integrity` or with a mutable version →
  supply-chain compromise.
- Hand-rolled sanitizer instead of `dompurify` → bypassable.
- Treating "trusted CMS" as a license to skip client-side sanitization →
  ignores the editorially-open trust model.

## Reference example

Type-checked with `tsc --strict`. Sanitization is the single site that
produces `SafeHTML` and the single site that calls `dangerouslySetInnerHTML`.

```ts
// src/lib/safe-html.ts
import DOMPurify from "dompurify";

// Branded type: only this module can produce SafeHTML. Where the browser
// supports Trusted Types it is a TrustedHTML from DOMPurify's "dompurify"
// policy (allowlist it with `trusted-types dompurify`); elsewhere it is a
// sanitized string.
export type SafeHTML = (string | TrustedHTML) & { readonly __safeHTML: unique symbol };

const ALLOWED_TAGS = ["p", "h1", "h2", "h3", "ul", "ol", "li", "a", "img", "strong", "em", "br"];
const ALLOWED_ATTR = ["href", "src", "alt", "title"];

export function sanitizeHTML(input: string): SafeHTML {
  const clean = DOMPurify.sanitize(input, {
    ALLOWED_TAGS,
    ALLOWED_ATTR,
    ALLOW_DATA_ATTR: false,
    FORBID_TAGS: ["script", "style", "iframe", "object", "embed"],
    FORBID_ATTR: ["onerror", "onload", "onclick"],
    RETURN_TRUSTED_TYPE: true,
  });
  return clean as unknown as SafeHTML;
}
```

```tsx
// src/components/SafeHtml.tsx
import { sanitizeHTML, type SafeHTML } from "../lib/safe-html";

// The ONLY component in the codebase that calls dangerouslySetInnerHTML.
// Every other site that renders HTML must route through this component.
export function SafeHtml({ html }: { html: string | null }) {
  if (!html) return null;
  const safe: SafeHTML = sanitizeHTML(html);
  return <div dangerouslySetInnerHTML={{ __html: safe }} />;
}
```

```tsx
// src/pages/ArticlePage.tsx — the single sanctioned render site.
import { useArticle } from "../hooks/useArticle";
import { SafeHtml } from "../components/SafeHtml";

export function ArticlePage({ articleId }: { articleId: string }) {
  const { article } = useArticle(articleId);
  if (!article) return null;
  return (
    <article>
      <h1>{article.title}</h1>
      <p>{article.summary}</p>
      <SafeHtml html={article.body_html} />
    </article>
  );
}
```

## Agent review checklist

- Is every `dangerouslySetInnerHTML` call inside the single sanitization module?
- Is sanitized output typed as `SafeHTML`, not `string`?
- Is the sanitization allowlist explicit and restrictive (not a denylist)?
- Are auth tokens in HttpOnly cookies or in-memory, never in `localStorage`?
- Does every `postMessage` specify a target origin and validate `event.origin`?
- Does every `target="_blank"` have `rel="noopener noreferrer"`?
- Does the production CSP forbid `unsafe-inline` and `unsafe-eval`?
- Are source maps excluded from the public production origin?
- Are third-party scripts SRI-hashed and version-pinned?
- Are there tests asserting that script tags in input are stripped from output?

## Verification

Static checks the agent runs before claiming completion:

```sh
# No dangerouslySetInnerHTML outside the sanitization module.
grep -rn "dangerouslySetInnerHTML" src/ | grep -v "SafeHtml.tsx" && echo "FAIL" || echo "OK"

# No localStorage token storage.
grep -rnE "localStorage\.(setItem|getItem).*([Tt]oken|[Ss]ecret|[Aa]uth)" src/ && echo "FAIL" || echo "OK"

# No postMessage with wildcard target.
grep -rn "postMessage(.*'\*'" src/ && echo "FAIL" || echo "OK"

# No eval / new Function / setTimeout(string).
grep -rnE "eval\(|new Function\(|setTimeout\(['\"]" src/ && echo "FAIL" || echo "OK"
```

CSP verification:

```sh
# The production response must carry a CSP header (preferred) or the HTML
# must contain a CSP meta tag.
curl -sI https://app.example.com | grep -i "content-security-policy"
```

Build artifact check:

```sh
# Production build output must not contain .map files on the public origin.
# For Vite:
ls dist/assets/*.map 2>/dev/null && echo "FAIL: source maps in production build" || echo "OK"
```

If the agent cannot run a check, it must say so explicitly rather than claim
compliance.

## Source foundation

- DOMPurify: https://github.com/cure53/DOMPurify
- MDN Content Security Policy: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
- MDN Trusted Types: https://developer.mozilla.org/en-US/docs/Web/API/Trusted_Types_API
- OWASP Cross-Site Scripting: https://owasp.org/www-community/attacks/xss/
- OWASP Reverse Tabnabbing: https://owasp.org/www-community/attacks/Reverse_Tabnabbing
- React DOM XSS guidance: https://react.dev/reference/react-dom/components/common#dangerously-setting-the-inner-html
