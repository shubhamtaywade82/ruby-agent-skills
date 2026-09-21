---
name: production-index
description: Add or change a database index with explicit lock, build, and rollback considerations.
family: rails
---

# Production Index

## Problem
Adding an index to a large production table can consume CPU/I/O or block writes.

## Use when
Creating an index on a live table or changing a high-traffic query's indexing strategy.

## Do not use when
The table is disposable or small enough that normal locking is explicitly acceptable.

## Procedure
1. Identify the target query shape.
2. Inspect existing indexes and cardinality.
3. Estimate table size and write traffic.
4. Determine whether concurrent build is required.
5. If PostgreSQL concurrent index creation is used, handle migration transaction settings explicitly.
6. Deploy and verify index validity/use.
7. Define failure cleanup for invalid indexes.

## Failure modes
- adding redundant indexes
- concurrent creation inside an implicit migration transaction
- ignoring failed invalid-index cleanup
- optimizing without query-plan evidence

## Testing
Verify migration behavior and query execution plan in a representative environment.

## Review checklist
- query evidence exists
- lock/build cost considered
- adapter support verified
- recovery documented
