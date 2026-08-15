# Fan out & tool selection

Reading one URL differs from reading many. Choose the tool by count; when there are several, **fan out** — launch every subagent in a single batch, never one-then-wait.

## By count

| URLs | Action |
|------|--------|
| 1 | fetch directly |
| 2 | one subagent, or two fetches |
| 3+ | fan out across subagents |

## Distribution

- Balance by estimated size, not by raw URL count.
- Group related URLs under one agent.
- Cap each batch at ~7 agents.
- Past ~15 URLs, run two phases (critical first, then the rest); reassess coverage after phase one before launching the second.

## Tool map

| Need | Tool |
|------|------|
| Construct and fetch an llms.txt URL | fetch |
| Find a repo or an unknown docs domain | search |
| Read several doc pages at once | fan out across subagents |
| Pack and analyze a repo | shell (repomix) |

## Timeouts

search ~30s · fetch ~60s · clone ~5 min · repomix ~10 min. On timeout, descend the chain rather than retrying the same endpoint.