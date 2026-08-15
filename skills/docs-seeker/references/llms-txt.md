# llms.txt discovery

Reach for this only while constructing an llms.txt URL (Step 2). One rule governs the whole file: **construct before you search**.

## context7 — fast path

GitHub repo → `https://context7.com/{org}/{repo}/llms.txt`

Website → `https://context7.com/websites/{normalized}/llms.txt` — normalize by lower-casing and joining path segments with `_`.

Topic → append `?topic={query}` to either form.

```text
next.js                    → https://context7.com/vercel/next.js/llms.txt
shadcn/ui                  → https://context7.com/shadcn-ui/ui/llms.txt
shadcn date picker         → https://context7.com/shadcn-ui/ui/llms.txt?topic=date
ffmpeg doxygen (8.0)       → https://context7.com/websites/ffmpeg_doxygen_8_0/llms.txt
```

## Official fallback — when context7 404s

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

Only after direct construction fails everywhere, search `"{name} llms.txt"`. If that returns nothing, descend to the repository step.