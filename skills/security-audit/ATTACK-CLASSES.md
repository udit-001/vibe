# Attack classes

Work these one at a time against the surface you mapped. Not every class applies to every codebase; say which ones you ran.

## Obvious things

Thorough and literal beats creative here. Check every item before reporting any of it: a missing `HttpOnly` matters only if the cookie holds security-sensitive data, and an error field name matters only if it is ever populated with something sensitive. A flag is not a finding — trace the impact.

- Hardcoded passwords, API keys, tokens, `-----BEGIN` blocks; secrets in logs, error messages, or URLs.
- `.env`, `credentials.json`, `*.pem`, `*.key` committed; does `.gitignore` actually cover secrets and uploads?
- `TODO`/`FIXME`/`HACK` comments that name a missing security control (`TODO: add auth`).
- Debug or dev mode enabled by env var, query param, or header — reachable in production?
- Unprotected `/debug`, `/admin`, `/metrics`, `/env`, `/status` routes; test or seed credentials that work in production.
- `eval`, `exec`, `child_process`, `Function`, `vm.runInContext`, dynamic `import()` on untrusted input.
- CORS wildcard origin combined with `Access-Control-Allow-Credentials`.
- Cookies missing `HttpOnly`, `Secure`, or `SameSite`; HTTP-only endpoints; TLS not enforced.
- Open redirects via `redirect`, `return`, `next`, `url`, `goto`, `continue`.
- Production errors returning stack traces, internal paths, or SQL text.
- Unpinned or known-vulnerable dependencies in the lockfile.
- **Tests**: what are they not testing? Compare the edge cases the developer imagined against the ones they did not.

## Injection

Trace untrusted input from entry to dangerous sink. The sink depends on the application: SQL queries, HTML output, shell commands, template engines, file paths, redirects, deserialization, LDAP/XPATH, log injection, search indexes.

Do not stop at direct paths. Chase:

- **Second-order** — stored safely, retrieved and used in a dangerous context by different code. A field name becomes a JSON path, a slug a file path, escaped text a raw render, a stored string a URL, regex, or template expression.
- **Field names, keys, headers, metadata** — not only values.
- **Secondary systems** — logs, caches, search indexes, analytics, webhooks.
- **Native** — buffer operations, parsers, format strings, any library function processing caller-supplied data unvalidated.

## Access control

Verify the caller cannot exceed its authority, and that the check is the *right* check on the *right* resource through the *right* mechanism:

- A second path to the same state change that checks a different, weaker permission.
- A request-body field overriding what the permission system intended to restrict.
- Endpoints that authenticate but never authorize.
- The same resource with inconsistent checks across access paths.
- Bulk, batch, export, import, and GraphQL operations that skip per-item enforcement.
- Identity: account linking, recovery, impersonation, and role changes that do not re-bind authorization to the new principal.

## Resource and file handling

- Path traversal through symlinks, encoded sequences, and null bytes.
- SSRF through redirects, DNS rebinding, and URL-parser differentials.
- Unsafe deserialization, archive extraction (zip slip), temp-file races.
- Memory safety: buffer overflows, use-after-free, integer overflow, unchecked casts.
- TOCTOU between a check and the use it guards.

## Cryptography and secrets

- Weak randomness for tokens, keys, and nonces.
- Broken key derivation, missing MAC verification, nonce reuse, static IVs, ECB, unauthenticated encryption.
- Timing side channels on secret comparison.
- Failure paths: does the error path fall back to no crypto, or to a default key?

## Business logic

Scanners miss these and they yield the highest-impact findings. For each major workflow:

- **State machines** — skip a step, go backwards, replay a completed flow, or fail midway: is step 1 rolled back when step 2 of 3 fails?
- **Races with business impact** — double-spend, double-approve, lost updates; check-then-act that is not atomic.
- **Numeric manipulation** — negative, zero, overflow, precision loss, string/number coercion.
- **The wrong check for the rule** — an input to one operation bypassing a restriction enforced on a different operation for the same effect.
- **Implicit trust** — data assumed safe because it was "validated on the way in"; what if another path wrote it?
- **Time** — expiry, rate windows, clock skew, and what happens at the exact boundary instant.
- **Defaults and fallbacks** — posture when config is missing, a feature flag is off, a dependency is unavailable, or a migration is half-done.

## Feature abuse and data leakage

Legitimate features used for unintended purposes — design bugs, not just code bugs:

- **Export and backup as exfiltration** — a low-privilege user triggering a snapshot that includes data above their access level, deleted or draft content, unpruned revision history.
- **Import and restore as injection** — overwriting existing data, creating records that skip validation, ignoring the UI's permission model.
- **Search, filter, and sort as an oracle** — existence probes for content the user cannot read, hidden fields exposed through ordering.
- **Enumeration through side effects** — error messages, response times, sizes, or status codes that differ between "does not exist" and "no access"; password-reset and invite flows.
- **Preview, draft, and staging leakage** — preview tokens scoped to one item or broader; drafts discoverable via search, feeds, sitemaps, or listing endpoints; cache headers serving private content publicly.
- **Notification and webhook URLs as SSRF** — validated against internal networks, and after redirects too.

## Chained trust boundaries

Individually allowed behavior becomes a vulnerability when something downstream relies on a stronger guarantee:

- **Cross-component guarantee gaps** — A validates, B acts. Compare the exact guarantee A produces with what B assumes, including truncation, type coercion, normalization, tenant scope, and plugin access.
- **Second-order use** — as above, when a safe representation becomes a dangerous context.
- **Capability growth** — a token, key, plugin, OAuth scope, or MCP capability that broadens after delegation, refresh, caching, or role change. Name the operation the resulting principal should not have.
- **Timing and ordering windows** — setup, migration, soft-delete, revoke, cache expiry, check/use, validate/consume. Confirm stale state is actually accepted before reporting.
- **Rollback and recovery** — undelete, restore, and rollback must apply *current* ownership, validation, and authorization. Confirm which invalid state comes back.

## Wildcard

Read what looks boring and disconnected from security. Incomplete, experimental, compatibility, and fallback paths got the least review, so they are the weakest.

- What is the strangest code here, and what happens if it is abused?
- What happens when the API is used a way the frontend never would? The UI constrains users; the API does not.
- What undocumented endpoints, parameters, or headers exist in route registration, middleware, or config?
- What happens when features combine that were never designed to work together — preview + cache, import + plugins + webhooks, OAuth + impersonation + API keys?
- What does the history show? Reverted security fixes, commented-out auth checks, committed-then-removed secrets.
- Which valid-account actions affect other users, shared integrity, availability, or operator-owned cost?
- What environment assumptions does the code make — that the database is local, the clock is accurate, DNS is trustworthy, the filesystem is case-sensitive?
- If something is named `temp`, `hack`, or `legacy`, or carries a comment explaining why it is safe, read it until you can settle whether it is.
