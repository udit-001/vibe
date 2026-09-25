# Web, HTTP, and identity

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

*Run with [ATTACK-CLASSES.md](ATTACK-CLASSES.md), never instead of it: transport, access control, injection, and file handling remain ordinary boundaries in every domain.*
