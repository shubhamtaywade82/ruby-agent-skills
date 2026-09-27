# Migration Gate

1. Run all pending migrations, including column removals.
2. Deploy application code.
3. Mark the release healthy once the web process starts.
4. If the release misbehaves, roll back to the previous application version.
