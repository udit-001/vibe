# Recovery

The **fallback chain** is the primary recovery path — a failed step means descend. These are the recurring failure shapes and their fixes.

## Not found (404 / empty llms.txt)

Descend: context7 → official llms.txt → search → repository → research. Record the method actually used in the report's Source section.

## Repo too big or binary-heavy

Scope Repomix to `docs/`, or read key files directly via **fan out** (see [repo.md](repo.md)).

## Rate-limited (429 / slowing)

Stop hitting that endpoint immediately; switch source (GitHub → official docs → registry). Add a short delay only when a source must be reused.

## Conflicting sources

Prefer official → package registry → repo README → recent community. Identify each source's version and date, present the conflict, and recommend the official/latest.

## Incomplete or stubbed docs

Mark the holes in the report's Gaps; backfill from repo examples or tests and label inferred content as inferred.

## Auth-walled, or video/image-only docs

Unretrievable — say so in Gaps and name the public alternative you used instead.