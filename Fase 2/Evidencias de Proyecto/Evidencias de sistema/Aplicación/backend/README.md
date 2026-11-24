# AI Assessment — Backend API

FastAPI backend for the AI Assessment platform. Production runs on **Render**, with **Supabase** for Auth, PostgreSQL and Storage, and the web app on **Vercel**.
Async SQLAlchemy 2.0 · Pydantic v2 · Supabase Auth · Stripe.

## Stack & layout

```
app/
  main.py            # FastAPI app, middleware, router registration, /health
  core/              # config, errors (unified envelope), security (JWT), logging, email rules, pagination
  db/                # async engine/session, declarative base
  models.py          # all ORM models (single source of truth)
  api/deps.py        # get_db, get_current_user, require_roles, require_pro (plan gating)
  api/routes/        # 15 domain routers (auth, leads, organizations, questionnaires,
                     #   assessments, areas, documents, team, delegations, estimator,
                     #   payments, results, reviews, consultant, metadata)
  schemas/           # Pydantic request/response models
  services/          # business logic per domain
  integrations/      # email (ACS), storage (Blob), payments (Stripe) — all with dev fallbacks
  seed.py            # idempotent seed: maturity questions (ES/EN) + demo distributor code
migrations/          # Alembic
Dockerfile, docker-compose.yml
```

All endpoints are served under `/api/v1`. Interactive docs at `/docs`, schema at `/openapi.json`, liveness at `/health`.

## Supabase Auth and PostgreSQL

Production (`APP_ENV=prod`, the value set in `render.yaml`) accepts only Supabase
access tokens. `POST /auth/magic-link`, `/auth/verify` and `/auth/refresh` return
404 outside local development. Supabase JWT validation uses the project JWKS when
`SUPABASE_JWT_SECRET` is empty. `POST /api/v1/auth/supabase/session` links the
authenticated Supabase user to `public.users`.

Local development (`APP_ENV=dev`) can still issue its own magic-link JWTs when the
web app has no Supabase env vars.

Run Alembic against Supabase:

```bash
alembic upgrade head
python -m app.seed
```

Apply `supabase/migrations/20261120_enable_rls_and_private_storage.sql` after the
schema migration. It enables RLS on all public application tables and creates a
private `evidence` Storage bucket. Do not expose the database password or Supabase
service-role key in the repository.

## Error format

Every error returns:

```json
{ "error": { "code": "LEAD_EMAIL_FREE_PROVIDER", "message": "…", "field": "company_email", "request_id": "…" } }
```

`code` is stable and localizable; `message` respects `Accept-Language` where applicable.

## Run locally (Docker)

```bash
cp .env.example .env          # adjust if needed
docker compose up --build     # API on http://localhost:8000, Postgres on 5432
```

Then seed demo data (in another shell):

```bash
docker compose exec api python -m app.seed
```

## Run locally (without Docker)

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # point DATABASE_URL at your local Postgres
python -m app.seed            # creates tables (dev) + seeds
uvicorn app.main:app --reload
```

In `dev`, tables are auto-created on startup. For staging/prod use Alembic:

```bash
alembic revision --autogenerate -m "init"
alembic upgrade head
```

## Configuration (env vars)

See `.env.example`. Key ones: `DATABASE_URL` (async, `postgresql+asyncpg://…`), `JWT_SECRET`,
`FREE_MATURITY_LIMIT`, `STRIPE_SECRET_KEY` / `STRIPE_WEBHOOK_SECRET`,
`SUPABASE_SERVICE_ROLE_KEY` (Supabase Storage), `SMTP_HOST` and friends.
Leave Stripe/SMTP values empty in dev to use the built-in fallbacks
(console email, local filesystem storage, mock Stripe checkout).

## Deploy to Render

The image listens on `$PORT` (Render sets it) and exposes `/health`. Connect the repo to Render using the root `render.yaml` (Docker build of `backend/`). Set the secret env vars there:

- `DATABASE_URL` — Supabase Postgres URL with the `postgresql+asyncpg` driver
- `SUPABASE_SERVICE_ROLE_KEY` — Supabase Storage for the `evidence` bucket
- `SUPABASE_JWT_SECRET` — optional; leave empty to validate tokens with JWKS
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_FROM_ADDRESS`
  for transactional email (invitations, delegations); without them mail is only logged
- `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` when payments are live

`APP_ENV`, `SUPABASE_URL`, `CORS_ORIGINS` and `WEB_APP_URL` are already declared in `render.yaml`. Point the Stripe webhook at `https://<render-host>/api/v1/webhooks/stripe`.

The web app is deployed separately on Vercel from `web/`.

### CI

`.github/workflows/deploy.yml` runs a compile and import check. It does not deploy. Render and Vercel deploy from the connected repository.

## Verified

`python -m compileall app` passes; the app boots and registers **43 endpoints across 15 routers**;
the unified error envelope, auth/plan guards and public endpoints were smoke-tested with FastAPI's
TestClient. Full DB-backed flows require a running PostgreSQL (see Run locally).
