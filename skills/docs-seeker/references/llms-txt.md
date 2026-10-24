# llms.txt discovery

Reach for this during Step 2: constructing an id, resolving one, reading indexing state. One rule governs the file: **construct before you search** — and a constructed id that 404s gets resolved, not re-slugged.

## context7 — id shapes

Every library is served at `https://context7.com{id}/llms.txt`:

| Source | id | Example |
| --- | --- | --- |
| Git repo | `/{org}/{repo}` | `/vercel/next.js` |
| Website | `/websites/{slug}` | `/websites/humanlayer` |
| Site's own llms.txt | `/llmstxt/{slug}_llms_txt` · `_llms-full_txt` | `/llmstxt/react_dev_llms_txt` |
| DeepWiki mirror | `/websites/deepwiki_{org}_{repo}` | `/websites/deepwiki_humanlayer_humanlayer` |

A versioned docs set carries a suffix: `/websites/python_3_10`, `/websites/nextjs_15`.

Append `?topic={query}` to rank snippets toward the question, and `?tokens={n}` to cap the response (uncapped by default; the UI links `?tokens=10000`).

## Slugs

A slug is the docs URL with the scheme gone: host, then path segments, lowercased, every non-`[a-z0-9-]` run collapsed to `_`, minus `www`, `docs`, `documentation`, `com`, `org`, `net`, `html`, `htm`, `latest`, `index`.

```text
docs.humanlayer.com                       → /websites/humanlayer
code.claude.com/docs                      → /websites/code_claude
developers.cloudflare.com/api             → /websites/developers_cloudflare_api
developers.google.com/maps/documentation/javascript/reference
                                          → /websites/developers_google_maps_javascript_reference
react.dev/llms.txt                        → /llmstxt/react_dev_llms_txt
trigger.dev/docs/llms-full.txt            → /llmstxt/trigger_dev_llms-full_txt
```

Reverse-engineered from 252 live `/websites` entries; reproduces 99% of them. The drop-set is undocumented and drifts, so a miss is a resolution trigger.

## Resolve an id

Start here for any target you can name but can't place.

`https://context7.com/api/v2/libs/search?libraryName={name or domain}&query={topic}` — no key, `query` optional. Returns every indexed form of the library, ranked, each with its `id`. `libraryName` takes a bare name (`hono`), a domain (`docs.humanlayer.com`), or a path. Take the top result, or the shape matching the ask: repo for code-level, website or llmstxt for prose.

`https://context7.com/api/v1/search?query={name}` is the flatter fallback (`id`, `totalSnippets`, `branch`) when v2 comes back empty.

`https://context7.com/api/v3/search?query={question}` skips ids and returns reranked snippets — reach for it when the ask is a question, not a doc set.

## Indexing state

`No content available` on a 200 means the entry is still parsing, not missing.

- `https://context7.com/api/libraries/latest?limit=20` — newest finished entries, each with `settings.project` (the id) and `settings.docsSiteUrl`. Caps at 10, no pagination.
- `https://context7.com/tasklist?tab=recent` — the same feed as a page; `?tab=website` and `?tab=repo` show the live queue.
- `https://context7.com/api/locks` — in-flight parses with progress and `task.projectName`.

The first is documented surface; the other two are internals, a snapshot of what is indexed *yet*.

## Official fallback — when context7 has nothing

Try in order:

1. `https://docs.{domain}/llms.txt`
2. `https://{domain}/llms.txt`, then `{name}.dev`, `{name}.io`, `{name}.org`

Known URLs:

```text
Astro    https://docs.astro.build/llms.txt
Next.js  https://nextjs.org/llms.txt
React    https://react.dev/llms.txt
```

## Then search

Only after construction and id resolution both fail, search `"{name} llms.txt"`. If that returns nothing, descend to the repository step.
