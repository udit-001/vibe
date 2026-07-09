# Sources — what to reach for when

Reference for picking a source by subject. The default is `openverse` (broadest); the others win on specific subjects.

## openverse  (`-s openverse`)

Aggregates openly-licensed images from Flickr, Wikimedia, and more via `api.openverse.org/v1/images/`.

- **Strong at** — general photos: people, objects, places, nature, tech, everyday subjects. The safe default when you're unsure.
- **License** — per item; `-l cc0,pd` filters to CC0 / Public Domain Mark (no attribution). `-l any` adds CC-BY etc.
- **Quirks** — Flickr-heavy, so quality varies shot to shot. The `url` field is the direct image (often a ~1024px Flickr `_b`); there's no server-side resize, so `-w`/`--full` don't apply here. Use `-l any` if CC0 results look thin.

## nasa  (`-s nasa`)

NASA Image Library via `images-api.nasa.gov/search`.

- **Strong at** — space, astronomy, science, aeronautics, historical NASA, earth-from-orbit. Unbeatable for those subjects.
- **License** — all public domain. No attribution legally required.
- **Quirks** — Useless for everyday/everyman subjects (it returns nothing or off-topic). The `canonical` link is the full-resolution original; no resize. Great for hero shots of planets, rockets, galaxies.

## wikimedia  (`-s wikimedia`)

Wikimedia Commons via `commons.wikimedia.org/w/api.php`.

- **Strong at** — landmarks, historical photos, diagrams, SVG illustrations, maps, coats of arms, technical drawings. The only source here with good SVG/diagram content.
- **License** — per item (Public Domain / CC0 / CC-BY / CC-BY-SA); `-l cc0,pd` filters to the no-attribution subset, which cuts a lot — use `-l any` for breadth and surface the credit.
- **Quirks** — Full originals can be huge (5-15 MB). The script grabs a ~1280px thumbnail by default; pass `--full` for the original or `-w N` for a specific width. Noisy for generic stock-photo queries — prefer `openverse` there.

## all  (`-s all`)

Queries every source, merges, and dedups. Use when you want maximum breadth or are unsure which source fits. Fault-tolerant: if one source errors, the others still return and the failure is noted on stderr.
