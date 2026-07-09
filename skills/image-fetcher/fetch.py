#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "requests",
# ]
# ///
"""image-fetcher — search & download free-licensed images from keyless public APIs.

No API keys. Run with `uv run fetch.py ...` — uv installs requests automatically.

Sources:
  openverse   Aggregates CC0/public-domain images (Flickr, Wikimedia, ...).
  nasa        NASA Image Library — all public domain.
  wikimedia   Wikimedia Commons — per-item CC / public-domain license.

License:
  -l cc0,pd   Only no-attribution-required images (default).
  -l any      Include CC-BY etc.; credit recorded in attribution.json.

Downloads go to a scratch dir (/tmp/opencode/image-fetcher/) by default;
copy the winner into your project. Use -o <project path> to place directly.
"""
from __future__ import annotations

import argparse
import base64
import html
import json
import os
import re
import sys
import time
import urllib.parse
import requests
from pathlib import Path

UA = "image-fetcher/1.0 (https://github.com/agent/image-fetcher; opencode skill)"
TIMEOUT = 30
DEFAULT_SCRATCH = "/tmp/opencode/image-fetcher"
MAX_RETRIES = 3
RETRY_DELAYS = [2, 5, 10]
CONFIG_FILE = Path.home() / ".config" / "image-fetcher" / ".env"
TOKEN_CACHE = Path.home() / ".config" / "image-fetcher" / "token_cache.json"


def _load_config():
    """Load credentials from ~/.config/image-fetcher/.env, then env vars."""
    cfg = dict(os.environ)
    if CONFIG_FILE.exists():
        for line in CONFIG_FILE.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                cfg.setdefault(k.strip(), v.strip())
    return cfg


CONFIG = _load_config()


def _get_openverse_token():
    """Get a valid Openverse Bearer token, refreshing from cached credentials."""
    cached = {}
    if TOKEN_CACHE.exists():
        try:
            cached = json.loads(TOKEN_CACHE.read_text())
        except Exception:
            pass
    if cached.get("expires_at", 0) > time.time() + 60:
        return cached["access_token"]

    cid = CONFIG.get("OPENVERSE_CLIENT_ID")
    csec = CONFIG.get("OPENVERSE_CLIENT_SECRET")
    if not cid or not csec:
        return None

    try:
        r = requests.post(
            "https://api.openverse.org/v1/auth_tokens/token/",
            data={"client_id": cid, "client_secret": csec, "grant_type": "client_credentials"},
            headers={"User-Agent": UA}, timeout=TIMEOUT,
        )
        r.raise_for_status()
        d = r.json()
        token = d["access_token"]
        expires = time.time() + d.get("expires_in", 36000)
        TOKEN_CACHE.parent.mkdir(parents=True, exist_ok=True)
        TOKEN_CACHE.write_text(json.dumps({"access_token": token, "expires_at": expires}))
        return token
    except Exception as e:
        print(f"  ! openverse token refresh failed: {e}", file=sys.stderr)
        return None


def _auth_headers(source):
    """Return auth headers for a given source, or {} if unauthenticated."""
    if source == "openverse":
        token = _get_openverse_token()
        if token:
            return {"Authorization": f"Bearer {token}"}
    return {}


def _get(url, headers=None):
    return _request(url, headers).content


def _get_json(url, headers=None):
    return _request(url, headers).json()


def _request(url, headers=None):
    h = {"User-Agent": UA, **(headers or {})}
    for attempt in range(MAX_RETRIES):
        r = requests.get(url, headers=h, timeout=TIMEOUT)
        if r.status_code == 429:
            delay = RETRY_DELAYS[min(attempt, len(RETRY_DELAYS) - 1)]
            print(f"  ! rate limited (429) — backing off {delay}s (attempt {attempt+1}/{MAX_RETRIES})", file=sys.stderr)
            time.sleep(delay)
            continue
        r.raise_for_status()
        return r
    r.raise_for_status()


def _strip_html(s):
    if not s:
        return ""
    return html.unescape(re.sub(r"<[^>]+>", "", s)).strip()


def _b64(s):
    return base64.b64encode(s.encode()).decode()


def _ext_for(url, content_type=None):
    if content_type:
        ct = content_type.split(";")[0].lower()
        m = {"image/jpeg": "jpg", "image/png": "png", "image/gif": "gif",
             "image/webp": "webp", "image/svg+xml": "svg", "image/tiff": "tif"}
        if ct in m:
            return m[ct]
    path = urllib.parse.urlparse(url).path
    for ext in (".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg", ".tif", ".tiff"):
        if path.lower().endswith(ext):
            return ext[1:].replace("jpeg", "jpg").replace("tiff", "tif")
    return "jpg"


def _slugify(s, n=40):
    s = _strip_html(s) or "image"
    s = re.sub(r"\.(jpe?g|png|gif|webp|svg|tiff?)$", "", s, flags=re.I)
    s = re.sub(r"[^\w\s-]", "", s).strip().lower()
    s = re.sub(r"[\s_-]+", "-", s)[:n].strip("-")
    return s or "image"


def _needs_credit(license_str):
    low = (license_str or "").upper()
    no_attrib = ("CC0" in low or "PDM" in low or "PUBLIC DOMAIN" in low or low == "PD")
    return not no_attrib


# ---- Openverse ----
def search_openverse(query, count, license_tier):
    params = {"q": query, "page_size": str(count), "filter_dead": "true"}
    if license_tier == "cc0,pd":
        params["license"] = "cc0,pdm"
    url = "https://api.openverse.org/v1/images/?" + urllib.parse.urlencode(params)
    data = _get_json(url, _auth_headers("openverse"))
    out = []
    for r in data.get("results", []):
        lic = (r.get("license") or "").upper()
        ver = r.get("license_version") or ""
        out.append({
            "source": "openverse",
            "title": r.get("title") or "",
            "creator": r.get("creator") or "",
            "creator_url": r.get("creator_url") or "",
            "license": f"{lic} {ver}".strip(),
            "license_url": r.get("license_url") or "",
            "attribution": r.get("attribution") or "",
            "image_url": r.get("url") or "",
            "landing_url": r.get("foreign_landing_url") or "",
            "width": r.get("width"),
            "height": r.get("height"),
        })
    return out


# ---- NASA ----
def search_nasa(query, count):
    url = "https://images-api.nasa.gov/search?" + urllib.parse.urlencode(
        {"q": query, "media_type": "image"})
    data = _get_json(url)
    out = []
    for item in data.get("collection", {}).get("items", [])[:count]:
        d = (item.get("data") or [{}])[0]
        canonical = preview = None
        cw = ch = None
        for link in item.get("links", []):
            if link.get("rel") == "canonical" and link.get("render") == "image":
                canonical = link.get("href")
                cw = link.get("width")
                ch = link.get("height")
            elif link.get("rel") == "preview":
                preview = link.get("href")
        title = d.get("title") or ""
        creator = d.get("secondary_creator") or "NASA"
        out.append({
            "source": "nasa",
            "title": title,
            "creator": creator,
            "creator_url": "",
            "license": "Public domain (NASA)",
            "license_url": "https://www.nasa.gov/about/about_nasa.html",
            "attribution": f'"{title}" by NASA is in the public domain.',
            "image_url": canonical or preview or "",
            "landing_url": item.get("href") or "",
            "width": cw,
            "height": ch,
        })
    return out


# ---- Wikimedia Commons ----
def search_wikimedia(query, count, license_tier, want_full, width):
    iiwidth = str(width or 1280)
    params = {
        "action": "query", "generator": "search", "gsrnamespace": "6",
        "gsrsearch": query, "gsrlimit": str(count * 3),
        "prop": "imageinfo", "iiprop": "url|extmetadata|size|mime",
        "iiurlwidth": iiwidth, "format": "json", "origin": "*", "maxlag": "5",
    }
    url = "https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode(params)
    headers = {}
    wm_user = CONFIG.get("WIKIMEDIA_BOT_USER")
    wm_pass = CONFIG.get("WIKIMEDIA_BOT_PASS")
    if wm_user and wm_pass:
        headers = {"Authorization": "Basic " + _b64(f"{wm_user}:{wm_pass}")}
    data = _get_json(url, headers)
    out = []
    pages = (data.get("query") or {}).get("pages") or {}
    for page in sorted(pages.values(), key=lambda p: p.get("index", 999)):
        ii = (page.get("imageinfo") or [{}])[0]
        meta = ii.get("extmetadata") or {}
        lic_name = _strip_html((meta.get("LicenseShortName") or {}).get("value"))
        lic_url = _strip_html((meta.get("LicenseUrl") or {}).get("value"))
        artist = _strip_html((meta.get("Artist") or {}).get("value"))
        title = page.get("title", "").replace("File:", "")
        if license_tier == "cc0,pd":
            low = lic_name.lower()
            if not ("public domain" in low or "cc0" in low or low in ("pd", "pdm")):
                continue
        full_url = ii.get("url") or ""
        thumb = ii.get("thumburl") or ""
        img_url = full_url if want_full else (thumb or full_url)
        out.append({
            "source": "wikimedia",
            "title": title,
            "creator": artist,
            "creator_url": "",
            "license": lic_name or "See item",
            "license_url": lic_url,
            "attribution": f'"{title}" by {artist or "unknown"} — {lic_name or "see item"}' + (f" ({lic_url})" if lic_url else ""),
            "image_url": img_url,
            "landing_url": ii.get("descriptionurl") or "",
            "width": ii.get("thumbwidth") or ii.get("width"),
            "height": ii.get("thumbheight") or ii.get("height"),
        })
        if len(out) >= count:
            break
    return out


def search(query, source, count, license_tier, want_full, width):
    results, errors = [], []

    def maybe(fn, name):
        try:
            results.extend(fn())
        except Exception as e:
            errors.append(f"{name}: {e}")

    if source in ("openverse", "all"):
        maybe(lambda: search_openverse(query, count, license_tier), "openverse")
    if source in ("nasa", "all"):
        maybe(lambda: search_nasa(query, count), "nasa")
    if source in ("wikimedia", "all"):
        maybe(lambda: search_wikimedia(query, count, license_tier, want_full, width), "wikimedia")
    for e in errors:
        print(f"  ! source error — {e}", file=sys.stderr)
    seen, dedup = set(), []
    for r in results:
        u = r["image_url"]
        if u and u not in seen:
            seen.add(u)
            dedup.append(r)
    return dedup


def download(results, out_dir):
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    manifest = []
    for i, r in enumerate(results, 1):
        url = r["image_url"]
        if not url:
            continue
        try:
            resp = _request(url)
            data = resp.content
            ct = resp.headers.get("Content-Type")
        except Exception as e:
            print(f"  ! download failed {url}: {e}", file=sys.stderr)
            continue
        ext = _ext_for(url, ct)
        fname = f"{i:02d}_{_slugify(r['title'])}.{ext}"
        (out / fname).write_bytes(data)
        entry = {**r, "filename": fname, "bytes": len(data)}
        manifest.append(entry)
        lic = r.get("license", "")
        print(f"  + {fname}  ({len(data)//1024} KB)  [{lic}]")
        if _needs_credit(lic):
            print(f"    attribution required — see attribution.json")
    mpath = out / "attribution.json"
    with open(mpath, "w") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    print(f"\nSCRATCH: {out}")
    print(f"attribution: {mpath}")
    return manifest


def print_list(results, as_json):
    if as_json:
        print(json.dumps(results, indent=2, ensure_ascii=False))
        return
    if not results:
        print("No results.")
        return
    for i, r in enumerate(results, 1):
        print(f"\n[{i}] {r['title']}")
        print(f"    source:    {r['source']}")
        print(f"    creator:   {r['creator'] or 'unknown'}")
        print(f"    license:   {r['license']}")
        if r["license_url"]:
            print(f"    lic url:   {r['license_url']}")
        print(f"    image url: {r['image_url']}")


def main():
    ap = argparse.ArgumentParser(description="Search & download free-licensed images (no API key).")
    ap.add_argument("query", help="search query")
    ap.add_argument("-n", "--count", type=int, default=5)
    ap.add_argument("-s", "--source", choices=["openverse", "nasa", "wikimedia", "all"], default="openverse")
    ap.add_argument("-l", "--license", choices=["cc0,pd", "any"], default="cc0,pd",
                    help="cc0,pd = no attribution (default); any = include CC-BY etc.")
    ap.add_argument("-w", "--width", type=int, default=None, help="max width px (wikimedia thumbnail)")
    ap.add_argument("--full", action="store_true", help="full-res (wikimedia original)")
    ap.add_argument("-d", "--download", action="store_true", help="download to scratch")
    ap.add_argument("-o", "--out", default=DEFAULT_SCRATCH, help=f"output dir (default {DEFAULT_SCRATCH})")
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    args = ap.parse_args()

    results = search(args.query, args.source, args.count, args.license, args.full, args.width)

    if args.download:
        if not results:
            print("No results to download.", file=sys.stderr)
            sys.exit(1)
        print(f"Downloading {len(results)} image(s) to {args.out}/")
        download(results, args.out)
    else:
        print_list(results, args.json)
        if not results:
            sys.exit(1)


if __name__ == "__main__":
    main()
