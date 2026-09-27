---
name: rails-react-typed-api-contract
description: "Type Rails JSON on the React side and validate it at runtime at the boundary."
family: react-typescript
---

# Rails React Typed API Contract

## Problem
A TypeScript type on `response.json()` is erased at runtime. When a Rails serializer renames, removes, or nulls an attribute, the client silently renders `undefined`.

## Use when
A React client consumes JSON rendered by a Rails controller or serializer.

## Do not use when
The repository already generates validated client types from the Rails contract (for example from an OpenAPI document); extend that instead of hand-writing parsers.

## Repository inspection
Inspect the Rails serializer (`as_json`, Jbuilder, serializer class), the request test that pins its keys, and the client's existing validation approach.

## Implementation procedure
1. Read the exact JSON the Rails endpoint renders.
2. Declare the client type and a parser that checks presence, types, enums, and nullability.
3. Convert snake_case and ISO-8601 dates once, inside the parser.
4. Pin the same keys in a Rails request test so both sides fail when the contract changes.

## Example

```ts
// The Rails serializer is the source of truth for the wire shape. The client
// declares the type it expects AND checks it at runtime, because a TypeScript
// type is erased and cannot detect a server-side rename or a null.
export type OrderId = string & { readonly __brand: "OrderId" };
export type OrderStatus = "pending" | "paid" | "cancelled";
export type Order = { id: OrderId; status: OrderStatus; totalCents: number; placedAt: Date };

const STATUSES: readonly OrderStatus[] = ["pending", "paid", "cancelled"];

export class ContractError extends Error {}

function field(record: Record<string, unknown>, key: string): unknown {
  if (!(key in record)) throw new ContractError(`order.${key} missing`);
  return record[key];
}

// Rails renders snake_case JSON (`total_cents`, ISO-8601 `placed_at`);
// the mapping to client naming happens here, once.
export function parseOrder(raw: unknown): Order {
  if (typeof raw !== "object" || raw === null) throw new ContractError("order is not an object");
  const record = raw as Record<string, unknown>;
  const id = field(record, "id");
  const status = field(record, "status");
  const totalCents = field(record, "total_cents");
  const placedAt = field(record, "placed_at");
  if (typeof id !== "string") throw new ContractError("order.id must be a string");
  if (typeof status !== "string" || !STATUSES.includes(status as OrderStatus)) {
    throw new ContractError(`order.status ${String(status)} is not a known status`);
  }
  if (typeof totalCents !== "number" || !Number.isInteger(totalCents)) {
    throw new ContractError("order.total_cents must be an integer");
  }
  if (typeof placedAt !== "string" || Number.isNaN(Date.parse(placedAt))) {
    throw new ContractError("order.placed_at must be an ISO-8601 string");
  }
  return { id: id as OrderId, status: status as OrderStatus, totalCents, placedAt: new Date(placedAt) };
}
```

## Failure modes
Casting with `as` instead of parsing, converting casing inside components, treating an unknown enum value as valid, and a parser that passes while the Rails request test is missing.

## Testing
Parser accepts the real Rails payload and rejects a missing key, a wrong type, and an unknown enum value; a Rails request test asserts the same keys.

## Review checklist
Would a renamed Rails attribute fail a test on both sides?

## Related skills
rails-react-integration,typescript-runtime-contracts,rails-api-integration
