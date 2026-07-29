# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A build workspace for `docker-faq` — a deliberately incomplete three-service FAQ demo app used in a live Docker Sandboxes stage demo. The full spec is in [`docker-faq-demo-initial-state-SPEC.md`](./docker-faq-demo-initial-state-SPEC.md). Read it before touching anything.

The demo depends on three GitHub issues remaining *unsolved* in the initial state. Agents fix them live on stage. **Do not implement the issues.**

## Target architecture

```
browser → frontend :3000 → backend :8000 → postgres :5432
```

- **`docker-faq/backend/`** — Flask ≥3.0, psycopg2-binary, port 8000, reads `DB_*` env vars, no ORM
- **`docker-faq/frontend/`** — Express, port 3000, server-side proxy to `BACKEND_URL`, static `public/`
- **`docker-faq/db/`** — schema only (`01_schema.sql`); no seed data
- **`docker-faq-demo-kit/`** — sibling directory (not inside the repo), sandbox kit with brand guide

## Hard constraints (the demo breaks if violated)

1. **No `docker-compose.yml` / `compose.yaml` anywhere in `docker-faq/`** — issue #1 creates it
2. **No seed data** — `db/` contains schema only; `SELECT count(*) FROM faqs` must return 0
3. **No brand assets in the repo** — no hex codes, no `docker-brand.md`, no Docker palette references in `docker-faq/`; the brand guide lives only in `docker-faq-demo-kit/files/home/docker-brand.md`
4. **Frontend must look intentionally plain** — black/white/gray, system font, ≤30 lines of CSS, 1996-era

## Running the services (from README)

```bash
# Database
docker run -d --name faq-db \
  -e POSTGRES_DB=faq -e POSTGRES_USER=faq -e POSTGRES_PASSWORD=faq \
  -p 5432:5432 \
  -v "$PWD/db":/docker-entrypoint-initdb.d \
  postgres:16

# Backend
cd backend && pip install -r requirements.txt && python app.py

# Frontend
cd frontend && npm install && node server.js   # → http://localhost:3000
```

## Acceptance criteria (run before declaring done)

```bash
# No compose file
grep -ri "compose" --include="*.y*ml" docker-faq/    # must return nothing

# No brand material in repo
grep -ri "1D63ED\|00084D\|docker-brand" docker-faq/  # must return nothing

# Both Dockerfiles build
docker build docker-faq/backend/
docker build docker-faq/frontend/

# Issue script exists and is executable
ls -l docker-faq/scripts/create-issues.sh
```

Full criteria (DB startup, 503 on DB down, empty-state render, single-row smoke test) are in spec section 6.

## Key files to produce

| Path | Notes |
|---|---|
| `docker-faq/backend/app.py` | `GET /api/faqs` (503 on DB down), `GET /api/healthz` (always 200) |
| `docker-faq/db/01_schema.sql` | Schema only — do not rename |
| `docker-faq/frontend/public/styles.css` | ≤30 lines, intentionally ugly |
| `docker-faq/ISSUES.md` + `scripts/create-issues.sh` | Three issues verbatim from spec §4 |
| `docker-faq/RUNBOOK.md` | Presenter steps from spec §7 |
| `docker-faq-demo-kit/spec.yaml` | Sandbox kit — remove the placeholder env var before finalizing |
| `docker-faq-demo-kit/files/home/docker-brand.md` | Brand guide — must be under `files/home/`, not `files/workspace/` |
