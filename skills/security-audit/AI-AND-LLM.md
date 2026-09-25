# AI, LLM, and agent targets

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

*Run with [ATTACK-CLASSES.md](ATTACK-CLASSES.md), never instead of it: transport, access control, injection, and file handling remain ordinary boundaries in every domain.*
