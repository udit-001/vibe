# Client-side and browser

*SPAs, extensions, webviews, service workers, browser storage, cross-window messaging, WebSockets, DOM rendering.*

- DOM XSS, DOM clobbering, and prototype pollution with a real gadget chain.
- `postMessage` origin and source checks; cross-site WebSocket use with ambient cookies.
- Credentialed CORS trust; wildcard origin plus credentials.
- Service-worker registration and scope takeover; cache and identity confusion between users.
- Browser-storage disclosure and stale authorization; cross-context storage and broadcast confusion.
- XS-Leaks: cross-origin state oracles through timing, frame count, or error events.
- Window/opener state disclosure; clickjacking; client-side navigation confusion with a trusted origin.

*Run with [ATTACK-CLASSES.md](ATTACK-CLASSES.md), never instead of it: transport, access control, injection, and file handling remain ordinary boundaries in every domain.*
