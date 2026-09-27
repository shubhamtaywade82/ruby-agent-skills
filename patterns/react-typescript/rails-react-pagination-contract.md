---
name: rails-react-pagination-contract
description: "Paginate Rails collections for React with stable ordering and complete cache identity."
family: react-typescript
---

# Rails React Pagination Contract

## Problem
Paginated lists drift or repeat rows when the Rails query orders by a non-unique column, and show wrong pages when the client cache key omits a filter, sort, or cursor.

## Use when
A React list loads a Rails collection page by page (numbered pages, cursors, or infinite scroll).

## Do not use when
The collection is small and bounded enough to load in one request.

## Repository inspection
Inspect the Rails ordering (and its index), the pagination gem or hand-written cursor, the response envelope, and the client's query-key convention.

## Implementation procedure
1. Order by a unique, stable key on the server (for example `placed_at DESC, id DESC`).
2. Return an envelope with data and the next cursor or page metadata; keep cursors opaque to the client.
3. Include every filter, sort, page size, and cursor in the query key and URL.
4. Parse the envelope at the boundary.

## Example

```ts
// Cursor pagination over a Rails endpoint that orders by a unique, stable key:
//   GET /api/orders?status=paid&after=<cursor>&limit=25
//   => {"data":[...], "meta":{"next_cursor":"MjAyNi0wOS0yN3wxMjM=" | null}}
// The cursor is opaque to the client; only the server decodes it.
export type Page<T> = { data: T[]; nextCursor: string | null };
export type OrderFilters = { status?: "pending" | "paid"; limit: number };

// Every input that changes the result set is part of the cache identity.
export const ordersPageKey = (tenantId: string, filters: OrderFilters, cursor: string | null) =>
  ["tenant", tenantId, "orders", filters.status ?? "all", filters.limit, cursor ?? "first"] as const;

export function ordersPageUrl(filters: OrderFilters, cursor: string | null): string {
  const params = new URLSearchParams({ limit: String(filters.limit) });
  if (filters.status !== undefined) params.set("status", filters.status);
  if (cursor !== null) params.set("after", cursor);
  return `/api/orders?${params.toString()}`;
}

export function parsePage<T>(raw: unknown, parseItem: (item: unknown) => T): Page<T> {
  if (typeof raw !== "object" || raw === null) throw new Error("page is not an object");
  const { data, meta } = raw as { data?: unknown; meta?: { next_cursor?: unknown } };
  if (!Array.isArray(data)) throw new Error("page.data must be an array");
  const next = meta?.next_cursor;
  if (next !== null && typeof next !== "string") throw new Error("page.meta.next_cursor must be a string or null");
  return { data: data.map(parseItem), nextCursor: next };
}
```

## Failure modes
Offset pagination over a non-unique sort, a cache key missing a filter, the client decoding or constructing cursors, and an unbounded `limit` accepted from the client.

## Testing
Distinct keys for distinct pages and filters, envelope parsing, a Rails request test for stable ordering across pages, and a cap on page size.

## Review checklist
Does every input that changes the result appear in both the URL and the cache key?

## Related skills
rails-react-integration,react-data-fetching,rails-active-record
