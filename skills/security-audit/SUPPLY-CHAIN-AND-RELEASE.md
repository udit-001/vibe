# Supply chain and release

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

*Run with [ATTACK-CLASSES.md](ATTACK-CLASSES.md), never instead of it: transport, access control, injection, and file handling remain ordinary boundaries in every domain.*
