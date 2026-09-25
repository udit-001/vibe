# Cloud, infrastructure, and deployment

*IAM, infrastructure as code, containers/Kubernetes, service mesh, serverless/edge, ingress, provider events, runtime config.*

- Workload identity overreach; cross-account or cross-tenant role confusion.
- Application authorization delegated to cloud metadata; metadata and internal-service reachability from user input.
- Trusted-proxy and mesh identity bypass; unexpected management-plane reachability.
- Host or control-plane capability exposure; admission and policy path inconsistency; namespace and label trust confusion.
- Security-control precedence drift; secret exposure across workload boundaries.
- Credential renewal and outage fallback; object-storage and signed-URL policy confusion.
- Event-source identity confusion; edge/runtime boundary mismatch.

*Run with [ATTACK-CLASSES.md](ATTACK-CLASSES.md), never instead of it: transport, access control, injection, and file handling remain ordinary boundaries in every domain.*
