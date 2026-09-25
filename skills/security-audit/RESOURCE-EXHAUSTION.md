# Resource exhaustion and availability

*Untrusted work consuming shared CPU, memory, disk, connections, workers, queues, quotas, or operator spend.*

- Superlinear parsing, matching, or evaluation; decompression bombs and representation amplification.
- Query amplification; unbounded buffering and cardinality.
- File descriptor and handle leaks; detached work continuing after cancellation; pre-authentication work imbalance.
- Quota accounting scoped to the wrong key, or reset before the window ends; worker and pool starvation.
- Reachable fatal error or deadlock; retry storms and fail-open amplification.
- Poison records causing head-of-line blocking; unsafe recovery and capacity rollback.

Read the limits in the code and the limits a caller can bypass. Shared-resource exhaustion is a boundary violation when an untrusted principal can consume capacity the owner paid for; the same work inside the caller's own budget is not.

*Run with [ATTACK-CLASSES.md](ATTACK-CLASSES.md), never instead of it: transport, access control, injection, and file handling remain ordinary boundaries in every domain.*
