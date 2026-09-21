# Migration Gate

1. Classify destructive migrations as irreversible.
2. Verify the compatible application/schema state before readiness.
3. Deploy compatible application code.
4. Verify readiness.
5. Do not claim application rollback restores database state.
6. Perform destructive contract work only after old processes are gone.
