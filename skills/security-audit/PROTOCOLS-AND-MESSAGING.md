# RPC, protocols, and messaging

*gRPC, GraphQL, Protobuf/Cap'n Proto/Thrift, custom protocols, queues, brokers, pub/sub, webhooks, streaming.*

- Message boundary and canonicalization disagreement between producers and consumers.
- Union, enum, and default-value confusion; envelope/payload identity mismatch.
- Interceptor and method-path inconsistency; peer identity confused with application principal.
- Per-item and streaming authorization gaps — the first message authorized, the rest trusted.
- Callback and reply-correlation confusion; topic, routing-key, and subscription scope gaps.
- Untrusted producers treated as a control plane; duplicate delivery and idempotency gaps; out-of-order and stale message acceptance; ack/commit ordering defects; dead-letter, retry, and diagnostic disclosure.

*Run with [ATTACK-CLASSES.md](ATTACK-CLASSES.md), never instead of it: transport, access control, injection, and file handling remain ordinary boundaries in every domain.*
