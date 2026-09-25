# Data isolation and lifecycle

*Multi-tenant stores, caches and search, object links, analytics, export/backup, migration, deletion, retention, restore.*

- Missing tenant or owner enforcement; composite-key and namespace collision; policy and query disagreement.
- Search, cache, and index ACL drift — the filter lives in code but not in the cached artifact.
- Analytics, logs, traces, and diagnostics as alternate readers of data the main path protects.
- Enumeration and aggregate oracles; export and backup scope expansion; import and restore authority expansion.
- Migration default and ownership confusion; backup and replication boundary drift.
- Soft-delete and tombstone bypass; stale authorization in derived copies.
- Restore reintroducing invalid state — undelete and rollback must apply *current* ownership and authorization.

*Run with [ATTACK-CLASSES.md](ATTACK-CLASSES.md), never instead of it: transport, access control, injection, and file handling remain ordinary boundaries in every domain.*
