# Desktop, mobile, and local IPC

*Native apps, deep links, webview bridges, exported components, privileged helpers, local daemons, Unix sockets, XPC, Binder, D-Bus.*

- Custom-scheme and deep-link ambiguity; app and account handoff confusion.
- Navigation-origin to webview bridge confusion; over-broad native bridge capabilities; webview file and universal access.
- IPC peer authentication; claimed principal versus channel identity; a privileged helper as confused deputy.
- Exported service, activity, receiver, or provider overreach; IPC lifecycle and correlation confusion.
- Install, update, and repair path trust; local file ownership and TOCTOU.
- Credential-store and local-secret boundary mismatch; account switch, logout, and device restore leakage.

*Run with [ATTACK-CLASSES.md](ATTACK-CLASSES.md), never instead of it: transport, access control, injection, and file handling remain ordinary boundaries in every domain.*
