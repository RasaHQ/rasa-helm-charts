# Studio Helm Chart — `backend` → `app` Rename + Auth Clarifications

**Date:** 2026-08-06  
**Status:** Locked for Phase 2 plan (post grill-me)  
**Scope:** `charts/studio` only (docs/plan alignment; chart implementation follows the Phase 2 plan)  
**Related plan:** `docs/superpowers/plans/2026-08-05-studio-helm-container-image-simplification.md`

## Context

Phase 2 unifies the Studio container image and collapses dual SPA/API ingress. Separately, the values/resource surface formerly called `backend` is renamed to `app` to match the unified Studio process (API + SPA serving + optional co-located event ingestion via roles). There is **no nginx web-client** — the unified `app` container serves the UI.

This doc locks rename + auth + grill-me decisions so the implementation plan does not re-litigate them.

## Decisions

### 1. Full-surface rename: `backend` → `app`

Rename across the chart surface:

| Surface | From | To |
| --- | --- | --- |
| Values key | `backend:` | `app:` |
| K8s resource names (main) | `{release}-backend` | `{release}-app` (e.g. `my-release-app`) |
| Migration Job | `{release}-database-migration` (today) | `{release}-app-migration` |
| Separate ingestion Deployment | `{release}-event-ingestion` (today) | `{release}-app-ingestion` |
| Template directory | `templates/studio/backend/` | `templates/studio/app/` |
| Helpers | `studio.backend.*` | `studio.app.*` |
| Component label | `studio-backend` | `studio-app` (exact: `app.kubernetes.io/component: studio-app`) |
| DB name field | `config.database.backendDatabaseName` | `config.database.databaseName` (or `appDatabaseName`) |
| Schema, NOTES, README, `# --` comments | `backend` | `app` |

Do **not** use `studioApp` / `studio-app` as the values key — the key is `app:`.

**Upgrade:** Hard-break — no Helm alias from `backend:` → `app:`. Document values translation + manual cleanup of orphaned `*-backend` / `*-web-client` resources in NOTES/README (no auto-delete hooks).

The component was formerly the API-only `backend` Deployment; it is now the **unified Studio app** (API + serves frontend + optional event ingestion via `STUDIO_ROLE` / `ENABLE_EVENT_INGESTION`).

### 2. SPA / no nginx web-client

- No web-client Deployment, Service, Ingress, or ServiceAccount.
- Unified `app` container serves the SPA; ConfigMap mounts `config.js` at `/usr/src/app/spa/config.js`.
- Keep slim `webClient.environmentVariables` as the SPA override bag (feature flags, `MS_API_URL`) feeding that ConfigMap only.

### 3. Single-host URL resolution

Prefer `app.ingress.hostName`, else `config.ingressHost`, for same-origin URL env and SPA ConfigMap patterns:

- `WEB_CLIENT_URL`
- `BETTER_AUTH_BASE_URL`
- `API_URL` (typically `…/api`)
- `window.API_ENDPOINT` in `config.js`
- `CORS_ORIGINS` / `studio.webClientUrl` (derive from app host, not removed web-client ingress)

### 4. Event ingestion topology

Prefer an explicit mode over inverting the meaning of `eventIngestion.enabled`:

| Mode | Behavior |
| --- | --- |
| `colocated` (default) | No separate Deployment; app sets `ENABLE_EVENT_INGESTION=true` |
| `separate` | Deploy `{release}-app-ingestion` with `STUDIO_ROLE=ingestion`; app sets `ENABLE_EVENT_INGESTION=false` |
| `disabled` | No consumers (neither co-located nor separate) |

**Double-consumer guard:** Hard `fail` at template render if both co-located and separate would run.

### 5. Auth / Keycloak (migration-only)

- **Better Auth** lives under `/api/auth/*` on the **app** Service (same host as UI + API).
- **Keycloak** remains in the chart for temporary / migration use until Studio Phase 4.
- While Keycloak is enabled, keep a **separate** Keycloak Ingress for `/auth` (do not merge into the app Ingress in Phase 2).
- Do not redesign Better Auth or remove Keycloak in this Phase 2 work.
- Leave `config.keycloak.clientId: rasa-studio-backend` as the Keycloak realm client string unless product renames it (out of chart rename scope).

### 6. Terminology: Ingress `backend:` vs values `app:`

Kubernetes Ingress path objects use a field named `backend:` (service name + port). That is the **Kubernetes API**, not the old values key. Leave Ingress YAML `backend:` service references as-is; only the **service name** changes (`…-backend` → `…-app`).

## Non-goals

- Implementing the rename in this doc (plan + implement separately).
- Removing Keycloak or finishing Better Auth migration (Phase 4).
- Renaming to `studioApp` / `studio-app` values keys.
- Changing `charts/rasa` or `charts/op-kits`.
- Auto-deleting orphaned old Deployments on upgrade.

## Intentional remaining “backend” mentions

| Kind | Why it stays |
| --- | --- |
| Ingress path field `backend:` | Kubernetes Ingress API |
| Historical notes (“formerly `backend`”) | Migration / breaking-change docs |
| Old image names in grep (`studio-backend`) | Verification that defaults no longer use them |
| Studio product paths (`backend/config.ts`) | Upstream Studio repo, not Helm values |
| Keycloak client id `rasa-studio-backend` | Realm/client identifier in Keycloak, not Helm resource name |

## Success criteria

- Phase 2 plan locks rename to `app` / `{release}-app` / `{release}-app-migration` / `{release}-app-ingestion`.
- Implementers treat values/helpers/templates/docs/schema as one rename surface.
- Auth notes distinguish Better Auth (`/api/auth/*`) from temporary Keycloak (`/auth`).
- Ingestion has an explicit disable path and hard-fail double-consumer guard.
