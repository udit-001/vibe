# Domain checklists

Per-target-type classes, to run alongside [ATTACK-CLASSES.md](ATTACK-CLASSES.md) — never instead of it. Transport, access control, injection, and file handling remain ordinary boundaries in every domain. Read only the sections that fit the target.

## Web, HTTP, and identity

*Web apps, APIs, proxies, CDNs, gateways, custom HTTP parsers, sessions, JWT, OAuth/OIDC, SAML, MFA, passkeys, recovery, API keys, mTLS.*

- **Request framing** — front end and back end disagree on request length or header normalization: multiple `Content-Length`, `Transfer-Encoding`, H2/H3 downgrade, CRLF conversion, forbidden connection headers. Name both parses and the bytes each assigns.
- **Cache poisoning** — a request value changes cached content or security headers but is absent from the cache key (forwarded host/scheme, selected cookies, language, device, auth state).
- **Cache deception** — cache routing treats a private dynamic path as a public static asset, or caches a response whose identity inputs are missing from policy.
- **Host and forwarded-header trust** — untrusted host or `X-Forwarded-*` determines absolute URLs, tenant routing, callbacks, reset links, cache keys, or the client address authorization uses. Check that trusted ingress strips client copies.
- **Response-header injection** — untrusted data reaches `Location`, `Set-Cookie`, CSP with unsafe characters.
- **CSRF** — a browser sends ambient credentials to a state-changing endpoint with no effective anti-CSRF token, same-site binding, or strict Origin/Referer check. Inventory every cookie-authenticated mutation including form, multipart, and method-override routes. Routes needing a non-ambient bearer token do not qualify.
- **Session lifecycle** — identifiers not rotated on login, account switch, MFA completion, or impersonation, or still valid after logout, password change, revocation, disablement. Also check signed cookies, refresh tokens, websocket state, cached copies.
- **Cookie scope** — over-broad `Domain`/`Path`, insecure transport. Bare missing flags stay hardening notes unless a less-trusted origin or network position can gain the credential.
- **JWT verification and claim binding** — signature check, server-pinned algorithm and key source, `exp`/`nbf`/`aud`/`iss`, and `kid`/`jku`/`x5u` as untrusted key selectors. A valid token for another service is invalid here.
- **OAuth/OIDC callback binding** — exact `redirect_uri`, session-bound `state`, PKCE, ID-token issuer/audience/nonce, selected-IdP binding. Compare the initial callback with retry, mobile deep-link, and account-link routes.
- **SAML** — the element whose signature is validated is the element used as identity; unsigned fallback paths, parser config, canonicalization, freshness and audience fields.
- **MFA and step-up** — enrollment, replacement, disablement, recovery codes, and trusted devices require the intended prior assurance. A challenge must bind principal, current session, assurance target, action, expiry, one-time use. Compare UI, API, batch, and resumed paths.
- **WebAuthn/passkeys** — at registration bind challenge, RP ID, origin, credential, userHandle, and required user verification to the initiating session; at authentication verify challenge, origin, signature, and presence.
- **Account linking and recovery** — adding or unlinking an identity requires a current session, verified ownership of the new identity, step-up, and callback state bound to the initiating account. Recovery tokens are the weakest path: check randomness, user/action binding, expiry, one-time state, rate limits, delivery URL trust, and revocation of prior sessions.
- **API keys and mTLS** — server-side scope vs what the key actually authenticates to; parameters overriding the binding; publishable/secret type confusion; revocation caches; keys in bundles, URLs, logs, or responses. For mTLS: cert identity headers from any peer, subject text mapped to the wrong account, and a fail-open fallback when certs expire or renew.

Walk **issue → store → transmit → consume → refresh → revoke** for every credential. The effective policy is the weakest parallel path, not the most polished UI.

## Client-side and browser

*SPAs, extensions, webviews, service workers, browser storage, cross-window messaging, WebSockets, DOM rendering.*

- DOM XSS, DOM clobbering, and prototype pollution with a real gadget chain.
- `postMessage` origin and source checks; cross-site WebSocket use with ambient cookies.
- Credentialed CORS trust; wildcard origin plus credentials.
- Service-worker registration and scope takeover; cache and identity confusion between users.
- Browser-storage disclosure and stale authorization; cross-context storage and broadcast confusion.
- XS-Leaks: cross-origin state oracles through timing, frame count, or error events.
- Window/opener state disclosure; clickjacking; client-side navigation confusion with a trusted origin.

## AI, LLM, and agent targets

*Chatbots, RAG, persistent memory, tool-calling agents, MCP servers and clients, prompt assembly, model-controlled actions.*

The data flow to break is **untrusted content → model or memory → capability**. A guardrail prompt is not a boundary: count only deterministic checks, resource-scoped authorization, isolation, binding, and constrained credentials.

- **Indirect injection** — an attacker writes a RAG document, indexed page, file, or tool response that enters another principal's model context. Trace who writes each source, how retrieval scopes it, whose session consumes it, and what capability is enabled there.
- **Context bleed** — history, embeddings, retrieval results, or prompt caches keyed too broadly. Verify the tenant and ACL filter in the query itself and in every cache key; a tenant field stored on an object is not enforcement if another path omits it.
- **Memory poisoning** — attacker content or model summaries written into memory that later shapes another task, user, or privileged session. Who may create, update, and merge memory; is its provenance and tenant scope preserved; do low-trust observations become durable instructions?
- **Provenance confusion** — untrusted text impersonating a system message, tool result, or memory record. Forged provenance must change a deterministic trust decision or reach a real capability.
- **Tool-argument injection** — model-produced arguments reach SQL, shell, file, URL-fetch, or privileged APIs without handler-side validation. Structured output narrows shape; it establishes no authorization.
- **Excessive agency / confused deputy** — the agent uses a service identity or broad credential while the handler does not re-check the requesting principal's permission on the named resource. A shared credential with enforced per-user query scope is not a defect.
- **Action binding** — a user approves one described action, but execution uses changed arguments, a different resource, or a later turn. Also a defect when attacker content causes a side effect under a victim's valid authority that the victim never requested. Bind intent to the normalized tool name, full argument object, requester, target, amount, expiry, and batch membership. Retries must not duplicate a side effect.
- **Tool-schema and dispatcher disagreement** — the schema accepts aliases, extra fields, coercions, or nested free-form objects the handler interprets differently. Compare validation, canonicalization, generated bindings, and handler defaults.
- **Unbounded action loops** — a bounded request enqueues repeated spend, send, or mutation with no per-request budget, cancellation, or idempotency. Bound the test to code-level accounting; never exhaust a real service.
- **MCP trust inheritance and identity** — a delegated task receives the full session and credentials rather than the least authority; calls routed by model-selected tool or server names rather than the authenticated connection; tool descriptions and metadata trusted as policy.

Draw four maps: every execution identity, every capability, every writable memory source, every output destination. Start at side-effecting tools and work backward.

## Native, binary, and kernel

*C/C++, Rust `unsafe`, kernel modules, parsers and decoders, FFI, concurrent runtimes, binary loaders, JIT, firmware.*

- Out-of-bounds read/write; integer overflow, truncation, signedness.
- Use-after-free, stale views, double free; uninitialized or partially initialized data.
- Type confusion and invalid downcasts; unit or pointer-depth confusion.
- Reference-count and ownership races; shared-state races and TOCTOU; lock-order deadlock and starvation.
- Pointer-length contract mismatches; layout, alignment, and enum disagreement between components.
- Library, plugin, and executable search-order trust; missing artifact identity or signature binding.
- Malformed binary metadata and relocation handling; JIT and generated-code consistency; unload and teardown safety.
- Under-authorized powerful interfaces; privileged object lifecycle and dispatch inconsistency.

## Supply chain and release

*Dependency resolution, generated inputs, CI, release/signing/promotion, updates, plugins, extensions.*

- **Namespace and source confusion** — resolver configuration selecting an unintended namespace, fallback registry, mirror, or source URL; lockfile and checksum use; first-install vs update behavior.
- **Mutable build inputs** — branches, tags, unverified submodules, downloaded tools, floating CI actions, container tags consumed by a trusted build.
- **Generated-source provenance** — schemas, vendored archives, generated clients, and localization that ship executable content without the same review gate.
- **Build-context inclusion** — secrets, local config, or developer artifacts entering a package because the build context exceeds intended release inputs.
- **Untrusted code in a privileged workflow** — a PR, issue comment, fork, or dependency update running contributor code with protected secrets or write tokens. Compare trigger type, checkout ref, approval gate, environment protection, permission narrowing.
- **Workflow expression injection** — branch names, commit messages, issue fields, artifact names, or matrix values reaching shell commands or privileged inputs.
- **Cache and artifact trust mixing** — a lower-trust job populating a cache or artifact a higher-trust job later restores and executes or releases.
- **Build-to-promotion substitution** — tests, review, signature, and publication referring to mutable tags or filenames rather than one immutable digest.
- **Release authorization** — a release or signature accepted from the wrong workflow, branch, environment, or key role; whether the consumer validates the attestation's identity claims, not just the signature; rotation and revocation failing closed.
- **Update and plugin trust** — an updater authenticating payload bytes but not version, platform, channel, path, or rollback state; extensions gaining host authority beyond declared scope, or install hooks running before authenticity checks.

Walk backward from a released digest to every source, generated input, credential, worker, cache, and authorization decision. A mutable or known-vulnerable dependency is not a finding until you show who influences resolution and what boundary follows.

## Cloud, infrastructure, and deployment

*IAM, infrastructure as code, containers/Kubernetes, service mesh, serverless/edge, ingress, provider events, runtime config.*

- Workload identity overreach; cross-account or cross-tenant role confusion.
- Application authorization delegated to cloud metadata; metadata and internal-service reachability from user input.
- Trusted-proxy and mesh identity bypass; unexpected management-plane reachability.
- Host or control-plane capability exposure; admission and policy path inconsistency; namespace and label trust confusion.
- Security-control precedence drift; secret exposure across workload boundaries.
- Credential renewal and outage fallback; object-storage and signed-URL policy confusion.
- Event-source identity confusion; edge/runtime boundary mismatch.

## RPC, protocols, and messaging

*gRPC, GraphQL, Protobuf/Cap'n Proto/Thrift, custom protocols, queues, brokers, pub/sub, webhooks, streaming.*

- Message boundary and canonicalization disagreement between producers and consumers.
- Union, enum, and default-value confusion; envelope/payload identity mismatch.
- Interceptor and method-path inconsistency; peer identity confused with application principal.
- Per-item and streaming authorization gaps — the first message authorized, the rest trusted.
- Callback and reply-correlation confusion; topic, routing-key, and subscription scope gaps.
- Untrusted producers treated as a control plane; duplicate delivery and idempotency gaps; out-of-order and stale message acceptance; ack/commit ordering defects; dead-letter, retry, and diagnostic disclosure.

## Data isolation and lifecycle

*Multi-tenant stores, caches and search, object links, analytics, export/backup, migration, deletion, retention, restore.*

- Missing tenant or owner enforcement; composite-key and namespace collision; policy and query disagreement.
- Search, cache, and index ACL drift — the filter lives in code but not in the cached artifact.
- Analytics, logs, traces, and diagnostics as alternate readers of data the main path protects.
- Enumeration and aggregate oracles; export and backup scope expansion; import and restore authority expansion.
- Migration default and ownership confusion; backup and replication boundary drift.
- Soft-delete and tombstone bypass; stale authorization in derived copies.
- Restore reintroducing invalid state — undelete and rollback must apply *current* ownership and authorization.

## Desktop, mobile, and local IPC

*Native apps, deep links, webview bridges, exported components, privileged helpers, local daemons, Unix sockets, XPC, Binder, D-Bus.*

- Custom-scheme and deep-link ambiguity; app and account handoff confusion.
- Navigation-origin to webview bridge confusion; over-broad native bridge capabilities; webview file and universal access.
- IPC peer authentication; claimed principal versus channel identity; a privileged helper as confused deputy.
- Exported service, activity, receiver, or provider overreach; IPC lifecycle and correlation confusion.
- Install, update, and repair path trust; local file ownership and TOCTOU.
- Credential-store and local-secret boundary mismatch; account switch, logout, and device restore leakage.

## Resource exhaustion and availability

*Untrusted work consuming shared CPU, memory, disk, connections, workers, queues, quotas, or operator spend.*

- Superlinear parsing, matching, or evaluation; decompression bombs and representation amplification.
- Query amplification; unbounded buffering and cardinality.
- File descriptor and handle leaks; detached work continuing after cancellation; pre-authentication work imbalance.
- Quota accounting scoped to the wrong key, or reset before the window ends; worker and pool starvation.
- Reachable fatal error or deadlock; retry storms and fail-open amplification.
- Poison records causing head-of-line blocking; unsafe recovery and capacity rollback.

Read the limits in the code and the limits a caller can bypass. Shared-resource exhaustion is a boundary violation when an untrusted principal can consume capacity the owner paid for; the same work inside the caller's own budget is not.
