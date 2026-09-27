---
name: react-frameworks
description: Use when working in Next.js App Router (or comparable React frameworks with RSC) — server/client boundaries, "use client"/"use server" directives, server actions, SSR/streaming, route segment config, fetch caching/revalidation, and next.config security-relevant fields.
---

# React Frameworks Engineering (Next.js App Router)

## Purpose

Define the engineering contract for React frameworks whose server/client
boundary is load-bearing: Next.js App Router, React Server Components, Server
Actions, SSR/streaming, route-level data loading, and framework-level caching.

The existing React core skills (`react-component-engineering`,
`react-state-effects`, `react-data-fetching`) are deliberately library-neutral
and framework-neutral. That neutrality is correct for the core layer. But when
an agent hits a Next.js App Router codebase, the core skills give the mental
model and not the contract: what `"use client"` does, when a server action is
the right move, why a `useEffect` in a server component is a type error, how
`fetch` caching interacts with route segment config.

This skill is **opinionated**: Next.js App Router is the primary variant. An
agent working in Remix or TanStack Start should know this skill's rules are
Next-flavored and adapt accordingly. The bar for adding a second
framework-specific skill is evidence from EARP
(`docs/AGENT_ROUTING_EVAL_PROTOCOL.md`) that agents using this skill produce
materially worse outcomes on the other framework.

## Activate when

Hard triggers (the agent must invoke this skill if any of these appear in the
touched code or task):

- a file under `app/` (Next.js App Router convention);
- `"use client"` or `"use server"` directives;
- a `next.config.js` / `next.config.ts` / `next.config.mjs` file;
- `import from "next/..."` (`next/navigation`, `next/headers`, `next/cache`, etc.);
- a function named `generateMetadata`, `generateStaticParams`, or a route
  segment config object (`export const dynamic`, `export const revalidate`, etc.);
- a server action (an `"use server"` function or a function passed to `action=`);
- `revalidateTag`, `revalidatePath`, or `unstable_cache`;
- `cookies()`, `headers()`, or `draftMode()` from `next/headers`.

Soft triggers (the agent should consider invoking):

- a routing task that mentions SSR, SEO, streaming, or server-side rendering;
- a data-fetching task where the codebase already uses server components;
- a performance task that mentions Core Web Vitals, TTFB, or RSC payload size.

## Repository inspection

Inspect:

1. the `app/` directory structure (layouts, pages, loading, error, not-found);
2. existing `"use client"` placement patterns and the boundary the repo has chosen;
3. the data-loading pattern (server component `await` vs. client `use` vs. `useEffect`);
4. the `fetch` caching convention — are caching flags set explicitly or left at default?
5. the cache invalidation map — is there a tag/path owner per cache key?
6. the server action pattern — are mutations progressive-enhancement-friendly?
7. `next.config.js` fields: `experimental.serverActions`, `headers` (CSP),
   `images.remotePatterns`, `reactStrictMode`, `productionBrowserSourceMaps`;
8. the metadata generation pattern (`generateMetadata` vs. static metadata export);
9. the Suspense boundary placement pattern;
10. the test setup for server components and server actions.

Never assume a Next.js convention is in effect because the framework supports
it. Verify the repo actually uses it.

## Decision rules

### Version resolution

Resolve the installed `next` and `react` versions from `package.json` and the
lockfile before applying any rule below. Several defaults changed between
releases:

- **Next.js 15:** `params`, `searchParams`, `cookies()`, and `headers()` are
  async and must be awaited; `fetch` requests, `GET` route handlers, and the
  client router cache are no longer cached by default.
- **Next.js 16:** `revalidateTag(tag, profile)` requires a `cacheLife` profile
  (for example `"max"`); `updateTag(tag)` gives read-your-own-writes and may
  only be called from a server action; `refresh()` refreshes the client
  router from a server action.
- **React 19:** server-function arguments and return values may be primitives,
  plain objects, arrays, `Date`, `Map`, `Set`, typed arrays, `FormData`,
  promises, and other server functions. Class instances and ordinary
  functions cannot cross.

When the repository pins an older version, follow that version's behavior and
say so in the change.

### The server/client boundary

- The default: a module is a server component unless it opts out with
  `"use client"`.
- What can cross the boundary: serializable props only. Functions cannot be
  passed from a server component to a client component (except server actions,
  which are a special case).
- What cannot cross: non-serializable values (DOM nodes, class instances, file
  handles), and any value whose serialization would leak server secrets.
- Place the boundary as far down the tree as possible. A page that needs one
  interactive widget should not become a client component; extract the widget
  into a client component and import it.
- Forbidden: a `"use client"` module that imports a module with server-only
  side effects (e.g., a module that reads `process.env.DATABASE_URL` at import
  time). Use the `server-only` package to enforce this.

### Server Components

- A server component may: read from the database, call internal services, read
  `cookies()`/`headers()`, await async data, render client components.
- A server component may not: use `useState`, `useEffect`, event handlers,
  browser APIs, or any hook that depends on client runtime.
- The async component pattern: a server component may be `async` and `await`
  data directly. Extract the await into a child when a Suspense boundary is
  needed around the slow region.
- Forbidden: passing a Promise from a server component to a client component
  without using React's `use()` hook or a Suspense boundary.

### Server Actions

- When a server action is the right tool: a mutation triggered from a client
  component, where the action closes over server-only context (db, headers,
  cookies).
- When it is the wrong tool: anything that needs to be called from outside the
  React tree (an API route, a webhook, a cron). Those are route handlers.
- Signature rules: `"use server"` at the top of a module or function; args and
  return values must be serializable; the function must not close over
  non-serializable values.
- The invalidation rule: a server action that mutates data must invalidate
  every cache key the mutation affects — `updateTag` (Next.js 16, server
  actions), `revalidateTag` (with a profile on Next.js 16), or
  `revalidatePath`. No orphan invalidations; no missing invalidations.
- A server action is a public POST endpoint. Authenticate, authorize, and
  validate its arguments inside the action; never rely on the component that
  renders the form to have checked permission.
- Forbidden: a server action that returns a class instance or an ordinary
  function (neither can be serialized).
- Forbidden: a server action that does not invalidate after a mutation.
- Progressive enhancement: a server action should be invocable via a plain
  `<form action={...}>` so it works without JS. Deviate only when the action
  requires client-only context that cannot be expressed in a form post.

### Data loading and caching

- The hierarchy: server component `await` > `fetch` with caching flags >
  client-side `use` (Suspense) > client-side `useEffect` (last resort).
- The `fetch` caching model: `force-cache`, `no-store`, `revalidate: N`, and
  the interaction with route segment config. The default is version-dependent:
  cached through Next.js 14, uncached from Next.js 15.
- Decision table for cache strategy:
  - Static content, no per-request data → `force-cache` + `generateStaticParams`.
  - Per-request data, real-time → `no-store` + `dynamic = 'force-dynamic'`.
  - Cached for N seconds → `revalidate: N` at the `fetch` call.
  - On-demand invalidation → `revalidateTag` with a named tag per cache key.
- The invalidation contract: every cache key has a named owner (a tag or path)
  and every mutation knows which keys it invalidates. No orphan caches.
- Forbidden: a `fetch` in a server component that omits caching flags without a
  comment explaining why. The default changed between versions; silence hides
  which behavior the author intended.

### Streaming and Suspense

- A server component that awaits slow data must be wrapped in a `<Suspense>`
  boundary with a meaningful fallback. The fallback is a design decision, not
  a placeholder.
- Suspense boundaries go where the page can meaningfully show partial content.
  Wrapping the whole page in one Suspense boundary defeats the purpose.
- The page's initial HTML must include the static shell; slow regions stream
  in. Verify this with the network panel or by curling the route with JS
  disabled.
- Forbidden: `<Suspense fallback={null}>` in a customer-facing page. The user
  sees a flash of nothing; use a skeleton.

### Routing and layouts

- File conventions: `layout.tsx` wraps children and persists across
  navigations; `page.tsx` is the leaf; `loading.tsx` is the Suspense fallback
  for the segment; `error.tsx` is the error boundary.
- The layout-persistence rule: state in a layout is preserved across child
  navigations. Do not put page-specific state in a layout; do not put
  navigation-persistent state in a page.
- Parallel routes and intercepting routes: use for modals and conditional
  layouts. Prefer a simple route unless the pattern is load-bearing — they add
  cognitive load.
- Forbidden: a `layout.tsx` that fetches data the child page doesn't need.
  Layouts fetch layout data; pages fetch page data.

### Configuration and the build

- `next.config.js` fields this skill owns: `experimental.serverActions`,
  `headers` (CSP — cross-references `react-frontend-security`),
  `images.domains`/`remotePatterns`, `reactStrictMode`,
  `productionBrowserSourceMaps`.
- The source-map rule: `productionBrowserSourceMaps: true` is forbidden in
  production unless source maps are served from a restricted origin.
  Cross-references `react-frontend-security` build artifact hygiene.
- The image-optimization rule: `next/image` with `remotePatterns` is required
  for any remote image; raw `<img>` with a remote src is a performance and
  security defect.
- The env-var rule: only `NEXT_PUBLIC_*` vars are inlined to the client.
  Verify no server secret is in a `NEXT_PUBLIC_*` var with:

  ```sh
  grep -rnE "NEXT_PUBLIC_[A-Z_]+" .env* | grep -iE "(secret|key|password|token)"
  ```

## Implementation procedure

1. **Identify the boundary.** Which modules must be server components (data,
   secrets, cookies) and which must be client components (interactivity,
   state, browser APIs)? Push `"use client"` as far down as possible.
2. **Place the data loading.** Server component `await` first; `fetch` with
   explicit caching flags; client `use` with Suspense; client `useEffect`
   only as a last resort.
3. **Place the mutations.** Server action if triggered from the React tree;
   route handler if triggered from outside. Every mutation revalidates the
   cache keys it owns.
4. **Place the Suspense boundaries.** Where can the page meaningfully show
   partial content? Each boundary has a real fallback, not `null`.
5. **Configure metadata.** `generateMetadata` for dynamic; static export for
   fixed. OpenGraph fields set.
6. **Configure the build.** CSP in `headers`, source maps gated,
   `images.remotePatterns` for any remote image, no secret in `NEXT_PUBLIC_*`.
7. **Verify the boundary.** `next build` succeeds with no server/client
   boundary warnings. Treat any warning as a hard error.
8. **Verify streaming.** Curl the route with JS disabled; the static shell is
   present.
9. **Add tests.** Server actions tested for serializable return values and
   correct revalidation. Server components tested for the data they own.

## Anti-patterns / failure modes

- `"use client"` at the top of a page that doesn't need client interactivity —
  the whole page becomes a client component, defeating RSC.
- `useState` / `useEffect` in a server component — a build error in App
  Router, but agents sometimes work around it by adding `"use client"` too high.
- A server action that returns a class instance or an ordinary function —
  non-serializable.
- A server action that mutates without `updateTag` / `revalidateTag` /
  `revalidatePath`.
- A server action that trusts its caller: no authorization or argument
  validation inside the action.
- Reading `params.id` synchronously on Next.js 15+ (`params` is a Promise).
- A `fetch` in a server component with no caching flags and no comment.
- `<Suspense fallback={null}>` in a customer-facing route.
- Raw `<img>` with a remote src instead of `next/image`.
- A `NEXT_PUBLIC_` env var whose value is a server secret.
- `productionBrowserSourceMaps: true` without a restricted-origin source-map
  serving strategy.
- A layout that fetches data only its child page needs.
- A page that puts navigation-persistent state in the page instead of the
  layout — state resets on navigation.
- Treating Remix or TanStack Start as if they were Next.js — the conventions
  differ; this skill's rules are Next-flavored.

## Reference example

Type-checked with `tsc --strict` (plus `noUncheckedIndexedAccess` and
`exactOptionalPropertyTypes`) against `next@16.3` and `react@19` types. The
page is a server component; the interactive child is a client component with
an optimistic update; the mutation is a server action with explicit
invalidation.

```tsx
// app/articles/[id]/page.tsx — server component, owns data loading.
import { notFound } from "next/navigation";
import { LikeButton } from "./LikeButton";
import { getArticle } from "./data";

// Next.js 15+: route params arrive as a Promise.
export default async function ArticlePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const article = await getArticle(id);
  if (!article) notFound();

  return (
    <article>
      <h1>{article.title}</h1>
      <p>{article.summary}</p>
      <LikeButton articleId={article.id} initialLikes={article.likeCount} />
    </article>
  );
}
```

```tsx
// app/articles/[id]/LikeButton.tsx — client component, owns interactivity.
"use client";

import { useOptimistic } from "react";
import { useFormStatus } from "react-dom";
import { likeArticle } from "./actions";

type Props = { articleId: string; initialLikes: number };

export function LikeButton({ articleId, initialLikes }: Props) {
  const [likes, addOptimisticLikes] = useOptimistic(initialLikes, (current: number, delta: number) => current + delta);

  // A form action already runs inside a transition: the optimistic value is
  // shown until likeArticle settles, then replaced by the re-rendered server value.
  return (
    <form
      action={async () => {
        addOptimisticLikes(1);
        await likeArticle(articleId);
      }}
    >
      <SubmitButton likes={likes} />
    </form>
  );
}

// useFormStatus reads the pending state of the enclosing <form>.
function SubmitButton({ likes }: { likes: number }) {
  const { pending } = useFormStatus();
  return (
    <button type="submit" disabled={pending}>
      {likes} likes
    </button>
  );
}
```

```ts
// app/articles/[id]/actions.ts — server action, owns mutation + invalidation.
"use server";

import { updateTag } from "next/cache";
import { db } from "@/lib/db";

// A server action is a public POST endpoint: validate its arguments and
// authorize the caller here, not only in the component that renders the form.
export async function likeArticle(articleId: string): Promise<void> {
  if (typeof articleId !== "string" || articleId.length === 0) throw new Error("invalid article id");

  await db.article.update({
    where: { id: articleId },
    data: { likeCount: { increment: 1 } },
  });
  // Next.js 16: updateTag expires the tag with read-your-own-writes for this caller.
  // Next.js 15: revalidateTag(`article:${articleId}`) (single argument).
  updateTag(`article:${articleId}`);
}
```

## Agent review checklist

- Is `"use client"` placed as far down the tree as possible?
- Does every server component avoid `useState` / `useEffect` / event handlers?
- Were the installed `next` and `react` versions resolved before applying version-dependent rules?
- Does every server action return a serializable value (no class instances)?
- Does every server action that mutates call `updateTag`, `revalidateTag`, or `revalidatePath`?
- Does every server action authorize its caller and validate its arguments?
- Does every `fetch` in a server component have explicit caching flags or a
  comment justifying the default?
- Does every customer-facing Suspense boundary have a real fallback?
- Is every remote image rendered through `next/image` with `remotePatterns`?
- Is the production build free of source maps on the public origin?
- Are no server secrets in `NEXT_PUBLIC_*` env vars?
- Does `next build` pass with no server/client boundary warnings?

## Verification

Static checks the agent runs before claiming completion:

```sh
# No "use client" in a file that doesn't use client-only APIs.
# (AST check; the agent should justify any "use client" that doesn't
#  use useState/useEffect/event handlers/browser APIs.)

# Files that use client-only hooks or event handlers without "use client".
grep -rlE "\b(useState|useEffect|useOptimistic)\(|on(Click|Change|Submit)=" app/ | while read f; do
  grep -q '^"use client"' "$f" || echo "REVIEW: $f uses client-only APIs without \"use client\""
done

# No class-instance return from a "use server" function.
# (Manual review; the agent must justify each return type.)

# Every "use server" module that performs a write invalidates a cache key.
grep -rln '"use server"' app/ | while read f; do
  grep -qE "updateTag|revalidateTag|revalidatePath|refresh\(" "$f" || echo "REVIEW: $f has use server without invalidation"
done
```

Build verification:

```sh
# next build must succeed with no server/client boundary warnings.
next build 2>&1 | grep -i "warning" && echo "REVIEW" || echo "OK"
```

Streaming verification:

```sh
# The production route's initial HTML must include the static shell.
# (Disable JS in the browser, or curl the route and inspect the HTML.)
curl -s https://app.example.com/articles/123 | grep -q "<h1>" && echo "OK" || echo "FAIL: no static shell"
```

## Source foundation

- Next.js App Router: https://nextjs.org/docs/app
- React Server Components: https://react.dev/reference/rsc/server-components
- React `use()` hook: https://react.dev/reference/react/use
- Next.js Server Actions: https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations
- Next.js Caching: https://nextjs.org/docs/app/building-your-application/caching
- `server-only` package: https://www.npmjs.com/package/server-only
- MDN Streaming HTML: https://developer.mozilla.org/en-US/docs/Web/API/Streams_API
