# Recovery objectives, disaster recovery, and reconciliation

Reference for the `rails-reliability-engineering` skill. Load it on demand when a change alters RTO/RPO, backups and restore, failover, or post-incident reconciliation. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Recovery objectives

Define:

- RTO: maximum acceptable recovery time;
- RPO: maximum acceptable data-loss window;
- recovery owner;
- recovery source of truth;
- dependencies required for restore;
- failover procedure;
- reconciliation procedure;
- validation after recovery.

Recovery is not complete when the process starts. It is complete when the critical invariant and user journey are restored and verified.

Use `patterns/rails/recovery-objectives.md`.

## Disaster recovery and reconciliation

Backups are only useful when restore is tested.

Verify:

- backup coverage;
- retention;
- encryption/access;
- restore procedure;
- restore time;
- data validation;
- application compatibility;
- downstream reconciliation;
- idempotent reprocessing.

For eventually consistent systems, define how missing/out-of-sync state is detected and repaired.

Do not claim disaster recovery readiness from backup existence alone.
