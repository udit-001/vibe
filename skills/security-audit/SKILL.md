---
name: security-audit
description: "Find real vulnerabilities in a codebase and hand owners the source trace, priority, and smallest fix. Use when the user asks for a security audit, review, or pen test of code, asks where the vulnerabilities are, or wants a specific weakness investigated (auth, injection, secrets, access control, supply chain, agent/LLM targets). Scope: defensive review of the repository. Not for live exploitation, incident response, or general code review."
---

# Security audit

Find vulnerabilities that cross a real **trust boundary**, then give the owner the trace, the priority, and the smallest effective fix. A candidate without a named lower-trust principal, a concrete path, and an observable result is not a finding.

The scarce resource is the owner's attention: a report padded with hardening advice trains them to skim the real ones. Volume is not the goal — a **short list of confirmed boundary failures** is.

## The bar

Every candidate names six things. A candidate missing one is a note, not a finding:

1. **Lower-trust principal** — who can reach it (anonymous, any account, tenant B, an LLM reading a poisoned doc).
2. **Entry** — the untrusted input or action that starts the path.
3. **Intended control** — the check the code means to enforce.
4. **Broken path** — the source trace from entry to sink, with the control that fails to hold.
5. **Affected principal or resource** — whose data, authority, or availability actually suffers.
6. **Result** — what the observer can see happen, not what could plausibly follow.

**Severity is impact, not unease.** An unproven chain is not a critical.

**Defense-in-depth gaps are hardening notes.** If Layer A stops the attack, the absence of Layer B is worth a sentence at the bottom of the report, not a finding. Same for missing headers, absent rate limits, a missing best practice, and a generic parser crash.

**Deployment controls are real.** Proxy config, provider settings, identity policy, browser behavior, and topology count as controls. When a control that is required is absent from the repository, the honest verdict is *needs validation* — assume neither presence nor absence.

## Verdicts

Three verdicts, and they are not interchangeable.

- **confirmed** — the trace and the result both hold in source and bounded local evidence. Carries a severity.
- **needs validation** — a source-grounded boundary hypothesis blocked by one exact unresolved fact (a proxy header, a branch-protection setting, an IdP behavior). Carries no severity. The fact must be nameable in one sentence, and you must supply the safe check that resolves it. A vague blocker means the candidate is not ready.
- **rejected** — disproved by source or a visible control. Note it when it explains a disagreement you expect someone to have, otherwise drop it.

Assign the verdict after the trace, never before. A hypothesis you have already fallen in love with is the one most likely to need demoting.

## Severity anchors

- **critical** — unauthenticated code execution, full data-store access, or takeover of arbitrary accounts.
- **high** — an actor fully defeats an explicit security control with real consequences: auth bypass, cross-tenant read/write, stored script execution against other users, authenticated code execution, or unauthenticated stop of a shared service.
- **medium** — a real boundary violation with limited blast radius, uncommon preconditions, or a narrow resource set.
- **low** — disclosure of non-secret internals, or sustained effort for minimal gain.
- **informational** — a confirmed observation that matters mainly as a prerequisite inside a larger finding.

The high/medium test: does the result **fully defeat** an explicit control for an action with real consequences, or only **weaken** it? If you cannot state the concrete damage, it is not high. Overall severity never exceeds the demonstrated impact.

## Execution boundary

Source inspection is read-only and is the default. Establish a result the cheapest way that cannot reach anyone else: a local fixture, a unit test, a dummy principal, a rendered config, a function harness. Stop at the minimum effect that proves the defect — a wrong return value, an unauthorized dummy record, a rejected assertion.

Reach for a live system only when the user owns it and asks you to. Never target deployed endpoints, shared infrastructure, production identities, other users' data, or third-party services; never install dependencies or spend paid quota on the target's behalf. If the decisive fact only exists outside source and a local fixture, the verdict is *needs validation* — say so and stop.

## Steps

### 1. Map the surface

Read the entry points, the auth/session layer, the data stores, and the privileged operations. Note the target type, then open only the checklists that fit it:

| Target | Checklist |
|---|---|
| Web app, API, proxy, CDN, sessions, JWT, OAuth/OIDC, SAML, MFA, passkeys, API keys, mTLS | [WEB-AND-IDENTITY.md](WEB-AND-IDENTITY.md) |
| SPA, browser extension, webview, service worker, DOM, cross-window messaging | [CLIENT-SIDE.md](CLIENT-SIDE.md) |
| Chatbot, RAG, agent memory, tool-calling agent, MCP server or client | [AI-AND-LLM.md](AI-AND-LLM.md) |
| C/C++, Rust `unsafe`, kernel module, parser, decoder, FFI, binary loader, JIT | [NATIVE-AND-BINARY.md](NATIVE-AND-BINARY.md) |
| Dependency resolution, codegen, CI, release signing, updater, plugins | [SUPPLY-CHAIN-AND-RELEASE.md](SUPPLY-CHAIN-AND-RELEASE.md) |
| IAM, infrastructure as code, containers, service mesh, serverless/edge, ingress | [CLOUD-AND-DEPLOYMENT.md](CLOUD-AND-DEPLOYMENT.md) |
| gRPC, GraphQL, Protobuf, Thrift, custom protocol, queue, broker, pub/sub, webhook | [PROTOCOLS-AND-MESSAGING.md](PROTOCOLS-AND-MESSAGING.md) |
| Multi-tenant store, search, cache, export, backup, migration, deletion, restore | [DATA-ISOLATION-AND-LIFECYCLE.md](DATA-ISOLATION-AND-LIFECYCLE.md) |
| Native app, deep link, webview bridge, privileged helper, local daemon, IPC | [DESKTOP-MOBILE-AND-IPC.md](DESKTOP-MOBILE-AND-IPC.md) |
| Untrusted work consuming shared CPU, memory, disk, connections, quota, or spend | [RESOURCE-EXHAUSTION.md](RESOURCE-EXHAUSTION.md) |

Library and CLI targets usually need only [ATTACK-CLASSES.md](ATTACK-CLASSES.md) itself.

Also run the **obvious things** pass in [ATTACK-CLASSES.md](ATTACK-CLASSES.md): hardcoded secrets, ungated debug endpoints, checked-in `.env`/key files, `eval`/`exec` on dynamic input, permissive CORS, cookies missing `HttpOnly`/`Secure`/`SameSite`, open redirects, stack traces in production errors. Cheap, and it catches what everyone assumes someone else checked.

**Done when** you can name the trust boundaries and the untrusted inputs, and every class below is either applied or explicitly out of scope for this target.

### 2. Hunt by class

Work the core classes in [ATTACK-CLASSES.md](ATTACK-CLASSES.md) — injection, access control, resource and file handling, crypto and secrets, business logic, feature abuse, chained trust — plus every checklist the table above selected.

For each class, trace forward from a real untrusted entry to a sink, and chase the awkward cases: data validated on the way in and used dangerously on the way out; field names and headers as well as values; the same resource reachable by two paths with different checks; a permission check that exists but guards the wrong permission; bulk and export operations that skip per-item checks.

Keep a running list of the classes you applied. One pass is never complete coverage, and the report says which classes ran.

**Done when** every applicable class has been applied to a named entry point, and each surviving candidate carries the six parts of the bar.

### 3. Try to kill each candidate

Assume you are wrong. Re-read the cited lines and reconstruct the strongest control on the path: validation, authorization, normalization, framework behavior, containment. A guardrail prompt, a comment, or a naming convention is not a control — find the code that enforces it. Then reproduce the minimum result locally where you can.

Candidates die here, and that is the point. The ones that survive are the report.

**Done when** every candidate carries a verdict, and each confirmed or needs-validation one names the exact fact a skeptic would still have to check.

### 4. Report

Report in the conversation by default. Write files only when the user asks for them.

Order: a posture sentence, a confirmed-findings table (severity, title, boundary, one-line result), then one block per confirmed finding with location, principal, bounded reproduction, conditions, actual result, impact, and the smallest source fix. Then a **needs validation** section with the exact blocker and the safe check that resolves it. Then hardening notes. Close with the classes you ran and what you did not cover.

Name the invariant the code must enforce and the narrowest change that enforces it at the last trusted decision point — a specific file and a regression test beats a paragraph of advice. You describe fixes; you do not modify the target.

Keep the report proportional to the evidence. A clean audit is a real result; say so and state the limits rather than inventing low findings.
