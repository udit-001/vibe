# Native, binary, and kernel

*C/C++, Rust `unsafe`, kernel modules, parsers and decoders, FFI, concurrent runtimes, binary loaders, JIT, firmware.*

- Out-of-bounds read/write; integer overflow, truncation, signedness.
- Use-after-free, stale views, double free; uninitialized or partially initialized data.
- Type confusion and invalid downcasts; unit or pointer-depth confusion.
- Reference-count and ownership races; shared-state races and TOCTOU; lock-order deadlock and starvation.
- Pointer-length contract mismatches; layout, alignment, and enum disagreement between components.
- Library, plugin, and executable search-order trust; missing artifact identity or signature binding.
- Malformed binary metadata and relocation handling; JIT and generated-code consistency; unload and teardown safety.
- Under-authorized powerful interfaces; privileged object lifecycle and dispatch inconsistency.

*Run with [ATTACK-CLASSES.md](ATTACK-CLASSES.md), never instead of it: transport, access control, injection, and file handling remain ordinary boundaries in every domain.*
