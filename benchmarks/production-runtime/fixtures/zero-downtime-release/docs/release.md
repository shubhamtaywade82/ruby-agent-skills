# Release

1. Expand schema with customer.display_name.
2. Deploy code compatible with old and new schema.
3. Verify readiness.
4. Restart web processes.
5. Update background workers after queued-job compatibility is verified.
6. Backfill display_name.
7. Contract the old schema in a later release.
