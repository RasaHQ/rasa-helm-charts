# Studio Helm Chart — Container Image Simplification (Phase 2)

> **Superseded for implementation (2026-08-06):** Use the canonical task plan
> [`docs/superpowers/plans/2026-08-06-studio-helm-app-rename-implementation.md`](./2026-08-06-studio-helm-app-rename-implementation.md).
> This file retains grill-me / locked-decision history and early Phase 2 notes, but
> mixed older `eventIngestion.enabled` semantics and version-bump steps — do **not**
> execute its tasks as written.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `charts/studio` so the chart consumes the unified Studio `studio` image (API + SPA + optional co-located ingestion + migration Job), renames the former `backend` surface to `app` (values, K8s names, templates, helpers, docs, schema), collapses dual SPA/API ingress to one host, and keeps Keycloak as temporary/migration-only — without redesigning Better Auth / modelservice work already on the 3.0 RC line.

**Architecture:** Full-surface rename of the former `backend` component to `app`: values key `app:`, uniform K8s names `{release}-app`, `{release}-app-migration`, `{release}-app-ingestion`, templates under `templates/studio/app/`, helpers/labels/docs/schema updated accordingly. **No nginx web-client** — the unified app container serves the SPA. Point app + migration (+ optional separate ingestion) at image name `studio` with `STUDIO_ROLE` / `ENABLE_EVENT_INGESTION`. Remove the web-client Deployment/Service/Ingress; retain slim `webClient.environmentVariables` only for the SPA `config.js` ConfigMap mounted into the app pod. Default topology is co-located ingestion (`eventIngestion.mode: colocated`). Better Auth is served on the app under `/api/auth/*`; while Keycloak remains enabled, a **separate** Keycloak Ingress keeps `/auth`.

**Tech Stack:** Helm 3/4, Kubernetes Ingress `networking.k8s.io/v1`, helm-docs, chart `values.schema.json` (draft-07 `#/definitions`), Studio unified image entrypoint (`STUDIO_ROLE`, `ENABLE_EVENT_INGESTION`).

## Global Constraints

- Branch baseline: Better Auth / modelservice changes are **already done** on the 3.0 RC line; do not redo them. Chart version is already `3.0.0-rc.13` — bump further only if CI requires another increment for this PR.
- Keycloak stays (templates, values, image `studio-keycloak`) as **temporary / migration-only** until Studio Phase 4. Better Auth lives under `/api/auth/*` on the app; keep a **separate** Keycloak Ingress for `/auth` while Keycloak is enabled.
- Do **not** change `charts/rasa/` or `charts/op-kits/`.
- Do **not** introduce image digests; keep tag-based `repository` + `tag` + `image.name`.
- Env contract (Studio design §2): `STUDIO_ROLE=app|ingestion|migration`, `ENABLE_EVENT_INGESTION` boolean.
- No HTTP/exec probes for ingestion role / sibling (design: deferred).
- Never mutate `.Values` at render time (Helm 4). Prefer `deepCopy` / local dicts.
- `README.md` is auto-generated — edit `values.yaml` `# --` comments + `README.md.gotmpl`, then `pre-commit run helm-docs --all-files`.
- Schema: draft-07 with `#/definitions/...` refs only (not `$defs`).
- **Terminology:** Kubernetes Ingress path objects have a field named `backend:` (service + port). That is the **K8s API**, not the old values key — leave Ingress YAML `backend:` field names as-is; only change the **service name** to `{release}-app`.

## Cross-links

| Doc | Path |
| --- | --- |
| Studio design (canonical) | `/Users/amal/Rasa/studio/docs/superpowers/specs/2026-08-03-studio-container-image-simplification-design.md` |
| Studio Phase 1 plan | `/Users/amal/Rasa/studio/docs/superpowers/plans/2026-08-03-studio-container-image-simplification.md` (Phase 2 stub §) |
| Design Phase 2 checklist | Design §4 Phase 2 + Workstreams §2 (`helm-packaging`) |
| Helm `app` rename + auth (this repo) | `docs/superpowers/specs/2026-08-06-studio-helm-app-rename-design.md` |

**Merge / publish dependency:** Do not release this chart RC against clusters until Studio Phase 1 has published the unified `studio` image. Preview/e2e that still pull `studio-backend` / `studio-web-client` / etc. will `ImagePullBackOff`.

---

## Locked Decisions

Do not re-litigate these during implementation.

| # | Topic | Decision | Source / rationale |
| --- | --- | --- | --- |
| 1 | Values API: `app` / `webClient` | **Rename `backend` → `app`** across the full surface: values key `app:` (not `studioApp` / `studio-app`), templates `templates/studio/app/`, helpers `studio.app.*`, label **`app.kubernetes.io/component: studio-app`**, schema, NOTES, README. Rename `config.database.backendDatabaseName` → `databaseName` (or `appDatabaseName`). **Hard-break** — no `backend:` alias. Remove web-client Deployment/Service/Ingress/SA. **No nginx** — unified app serves SPA. **Retain slim `webClient.environmentVariables`** only (ConfigMap → `config.js`). Delete obsolete `webClient.image`, replicas, probes, service, ingress, scheduling. | Grill-me 2026-08-06; design `2026-08-06-studio-helm-app-rename-design.md`. |
| 1b | Uniform K8s names | Main Deployment/Service: **`{release}-app`**. Migration Job: **`{release}-app-migration`**. Separate ingestion Deployment: **`{release}-app-ingestion`** (was `*-event-ingestion`). | Grill-me: keep names under the `app-*` family. |
| 2 | Default topology | Prefer **`eventIngestion.mode: colocated \| separate \| disabled`** (default **`colocated`**) instead of inverting `enabled` boolean meaning. Map: `colocated` → app `ENABLE_EVENT_INGESTION=true`, no sibling Deployment; `separate` → deploy `{release}-app-ingestion`, app `ENABLE_EVENT_INGESTION=false`; `disabled` → neither. If retaining a boolean temporarily during implement, document the break explicitly — prefer mode. | Grill-me Q5; avoid silent semantic flip of `enabled: false`. |
| 3 | `config.js` mount path | Mount ConfigMap file at **`/usr/src/app/spa/config.js`** (`subPath: config.js`). | Studio `Dockerfile`: `SPA_STATIC_ROOT=/usr/src/app/spa`. Replaces old nginx path. |
| 4 | Co-located Kafka env | When colocated, **inject Kafka env** from `eventIngestion.environmentVariables` into the **app** container (plus `studio.app.env` DB vars). Separate `{release}-app-ingestion` keeps Kafka env + `STUDIO_ROLE=ingestion`. | Studio product env contract; single Kafka values source. |
| 5 | Chart ↔ image pairing | Chart **`3.0.0` / `3.0.0-rc.13+` requires the unified `studio` image**. Minimum Studio **≥ 1.17.0**. Default `tag` = published unified tag at implement time. | Design §5; chart already at `rc.13`. |
| 6 | Image names in values | Defaults: `app.image.name: "studio"`, `app.migration.image.name: "studio"`, `eventIngestion.image.name: "studio"`. Keycloak remains `studio-keycloak`. | Design §1; rename locked. |
| 7 | Roles on containers | App: `STUDIO_ROLE=app`. Migration Job: `STUDIO_ROLE=migration`. Separate ingestion: `STUDIO_ROLE=ingestion`. | Design §2. |
| 8 | Ingress | **One Ingress** on the app Service: `/api` + `/` (Prefix), same host. Delete `web-client/ingress.yaml`. Same-origin URLs via `app.ingress.hostName` else `config.ingressHost`. While Keycloak enabled, keep a **separate** Keycloak Ingress for `/auth` (do not merge). Better Auth at `/api/auth/*`. Leave Ingress YAML field `backend:` (K8s API) unchanged. | Grill-me Q6; design §5–6. |
| 9 | Double-consumer guard | **Hard `fail`** at render if both colocated and separate ingestion would run. Also document in NOTES. | Grill-me Q8; data-corrupting if both run. |
| 10 | Probes / Keycloak / digests / other charts | No new ingestion probes. Keycloak templates stay (temporary until Phase 4). No digests. rasa/op-kits untouched. Leave Keycloak client id string `rasa-studio-backend` unless product renames it. | Non-goals; grill-me. |
| 11 | Kafka values ownership | Keep Kafka defaults under **`eventIngestion.environmentVariables`**. When colocated, also render onto the app pod. | Least-breaking Kafka overrides. |
| 12 | Network policies / tests / upgrade orphans | Drop web-client NetworkPolicy; retarget `*-backend` → `*-app` (and ingestion → `*-app-ingestion`). Update test-connection. **Document** manual delete of orphaned `*-backend` / `*-web-client` / old `*-event-ingestion` after upgrade — no auto-delete hooks. | Grill-me Q10. |

---

## Goal / non-goals

### Goals

- Unified `studio` image for app, optional separate ingestion, and migration Job.
- Full-surface rename: former `backend` → `app` (values, K8s `{release}-app` / `-app-migration` / `-app-ingestion`, templates, helpers, docs, schema).
- Single public hostname for UI + API; SPA `config.js` ConfigMap on app pod (no nginx web-client).
- Default co-located ingestion; `eventIngestion.mode: separate | disabled` escape hatches; hard-fail double-consumer.
- Docs/schema/NOTES/README for roles, mutual exclusion, chart↔image pairing, and the `backend`→`app` breaking rename.
- Chart version already `3.0.0-rc.13` (bump further only if needed for CI).

### Non-goals

- Removing Keycloak (it stays temporary/migration-only until Phase 4) or redesigning Better Auth.
- Changes to `charts/rasa` or `charts/op-kits`.
- Image digests / alias tags for old image names.
- Ingestion readiness/liveness probes.
- Using values keys `studioApp` / `studio-app` (use `app:`).
- Re-doing Better Auth, modelservice, or other already-landed 3.0 work.
- Pulumi / studio-ci-app (Studio Phase 3).

---

## File structure map

| Path | Responsibility |
| --- | --- |
| `charts/studio/Chart.yaml` | Already `3.0.0-rc.13`; bump only if CI needs another increment |
| `charts/studio/values.yaml` | Rename `backend:` → `app:`; image names; `eventIngestion.mode` (default `colocated`); slim `webClient`; role/docs comments; default `tag` for unified image |
| `charts/studio/values.schema.json` | Rename `backend` → `app`; slim `webClient`; `eventIngestion.mode` enum; image name strings unconstrained beyond existing `imageConfig` |
| `charts/studio/templates/studio/app/deployment.yaml` | Renamed from `backend/`; `STUDIO_ROLE`, `ENABLE_EVENT_INGESTION`, Kafka env when colocated, `config.js` volumeMount, checksum annotation, same-origin URL env; resource name `{release}-app` |
| `charts/studio/templates/studio/app/ingress.yaml` | `/api` + `/` paths → app Service only (Keycloak Ingress stays separate) |
| `charts/studio/templates/studio/app/database-migration-job.yaml` | `STUDIO_ROLE=migration`; Job name `{release}-app-migration` |
| `charts/studio/templates/studio/event-ingestion/deployment.yaml` | Image `studio` + `STUDIO_ROLE=ingestion`; resource name `{release}-app-ingestion`; gated by `mode: separate` |
| `charts/studio/templates/studio/web-client/configmap.yaml` | Keep (or move under `app/`); same-origin `API_ENDPOINT` from app host only |
| **Delete** web-client `deployment.yaml`, `service.yaml`, `ingress.yaml`, `serviceaccount.yaml` | No separate SPA pod |
| **Rename** `templates/studio/backend/` → `templates/studio/app/` (all remaining files: service, SA, etc.) | Full template path rename |
| `charts/studio/templates/_helpers.tpl` | Rename `studio.backend.*` → `studio.app.*`; drop unused webClient workload helpers; `studio.webClientUrl` → single app host helper |
| `charts/studio/templates/studio/_env.tpl` (if present) | Rename `studio.backend.env` → `studio.app.env` and any `.Values.backend` refs → `.Values.app` |
| `charts/studio/templates/network-policy/ingress-egress-from-kubelet.yaml` | Remove web-client NetworkPolicy; retarget `*-backend` → `*-app`, ingestion → `*-app-ingestion` |
| `charts/studio/templates/tests/test-connection.yaml` | Point at app Service / same-origin |
| `charts/studio/NOTES.txt` | Single Studio URL; hard-fail docs; orphan cleanup; `backend`→`app` + name-family notes |
| `charts/studio/README.md.gotmpl` | Topology / pairing / breaking image names + `app` rename |
| `charts/studio/README.md` | Regenerated via helm-docs |

---

### Task 1: Chart version + `backend`→`app` rename + image/topology defaults

**Files:**

- Modify: `charts/studio/Chart.yaml`
- Modify: `charts/studio/values.yaml` (rename key, image names, `eventIngestion.enabled`, slim `webClient`, comments, `tag`)
- Modify: helpers / `_env.tpl` / any template still reading `.Values.backend` (can land in Task 1–2; must be complete before lint)

**Interfaces:**

- Consumes: Locked decisions 1–2, 5–6, 11
- Produces: Defaults + renamed values surface ready for templates in later tasks

- [ ] **Step 1: Bump chart version**

In `charts/studio/Chart.yaml`:

```yaml
version: 3.0.0-rc.12
```

- [ ] **Step 2: Rename values key `backend:` → `app:` and point images at `studio`**

In `values.yaml`, rename the top-level key and update all nested comments/`# --` docs:

```yaml
# tag: use first published unified studio tag (verify registry; Studio ≥ 1.17.0)
tag: "<PUBLISHED_STUDIO_TAG>"   # e.g. 1.17.0-latest — replace at implement time

app:
  image:
    name: "studio"
  migration:
    image:
      name: "studio"

eventIngestion:
  # Separate Deployment escape hatch. Default false = co-located ingestion on app pod.
  enabled: false
  image:
    name: "studio"
```

Add `# --` comments documenting: full-surface rename from `backend`; `ENABLE_EVENT_INGESTION` mutual exclusion; chart ↔ image pairing (3.0.0 requires unified `studio` ≥ Studio 1.17.0).

Grep and replace remaining `.Values.backend` / `backend.` references in templates and schema in later tasks (must be zero before final lint).

- [ ] **Step 3: Slim `webClient` values**

Remove from defaults (or comment as removed): `replicaCount`, `image`, `envFrom`, `additionalContainers`, `serviceAccount`, pod/security contexts, `service`, probes, `ingress`, resources, scheduling — everything that only existed for the nginx Deployment.

Keep:

```yaml
webClient:
  # -- SPA runtime config only (ConfigMap → /usr/src/app/spa/config.js). No separate Deployment.
  environmentVariables: {}
```

- [ ] **Step 4: Commit**

```bash
git add charts/studio/Chart.yaml charts/studio/values.yaml
git commit -m "chore(studio): bump to 3.0.0-rc.12, rename backend→app, default unified studio image"
```

---

### Task 2: Template/helper rename + App Deployment — roles, Kafka co-location, config.js mount

**Files:**

- Rename: `charts/studio/templates/studio/backend/` → `charts/studio/templates/studio/app/`
- Modify: `charts/studio/templates/studio/app/deployment.yaml` (and service/SA/etc. for `{release}-app` naming)
- Modify: `charts/studio/templates/studio/web-client/configmap.yaml` (same-origin endpoint)
- Modify: `charts/studio/templates/_helpers.tpl`, `charts/studio/templates/studio/_env.tpl` (`studio.backend.*` → `studio.app.*`, `.Values.backend` → `.Values.app`)
- Optionally move ConfigMap to `templates/studio/app/configmap.yaml` and update include paths / checksum (if moved, delete old path)

**Interfaces:**

- Consumes: `eventIngestion.enabled`, `eventIngestion.environmentVariables`, slim `webClient.environmentVariables`, `config.ingressHost` / `app.ingress.hostName`
- Produces: App pod named `{release}-app` with `STUDIO_ROLE=app`, correct `ENABLE_EVENT_INGESTION`, Kafka when co-located, SPA config mounted

- [ ] **Step 1: Rename directory + K8s resource names + helpers**

- Move all files under `templates/studio/backend/` to `templates/studio/app/`.
- Change resource names from `{{ $fullName }}-backend` (and equivalents) to `{{ $fullName }}-app`.
- Rename helpers: `studio.backend.*` → `studio.app.*`; update labels/selectors (`studio-backend` → `studio-app` or `app`).
- Update `_env.tpl` and any `include` names accordingly.

- [ ] **Step 2: Add role + ingestion flag + Kafka + volumeMounts**

On the app container `env`, after existing auth/URL env (and **after** fixing URLs to same-origin — see Step 3):

```yaml
- name: STUDIO_ROLE
  value: "app"
- name: ENABLE_EVENT_INGESTION
  value: {{ if .Values.eventIngestion.enabled }}"false"{{ else }}"true"{{ end }}
```

When `not .Values.eventIngestion.enabled`, also render Kafka env from `.Values.eventIngestion.environmentVariables` (same range/`value`/`secret` pattern as `event-ingestion/deployment.yaml`) plus `KAFKA_CLIENT_ID` (same default `"kafka-python-rasa"`).

Volume mounts + volumes (replace nginx paths):

```yaml
volumeMounts:
  - name: spa-config
    mountPath: /usr/src/app/spa/config.js
    subPath: config.js
    readOnly: true
volumes:
  - name: spa-config
    configMap:
      name: studio-web-client-configmap
      items:
        - key: windowVariables
          path: config.js
```

Add pod annotation `checksum/config` over the ConfigMap template (as web-client Deployment did) so config changes roll the app.

- [ ] **Step 3: Same-origin URL env + ConfigMap**

In Deployment, set (single host; prefer `app.ingress.hostName` else `config.ingressHost`):

```yaml
- name: WEB_CLIENT_URL
  value: "{{ .Values.config.connectionType }}://{{ .Values.app.ingress.hostName | default .Values.config.ingressHost }}"
- name: API_URL
  value: "{{ .Values.config.connectionType }}://{{ .Values.app.ingress.hostName | default .Values.config.ingressHost }}/api"
- name: BETTER_AUTH_BASE_URL
  value: "{{ .Values.config.connectionType }}://{{ .Values.app.ingress.hostName | default .Values.config.ingressHost }}"
```

In ConfigMap, stop preferring a separate web-client hostname:

```yaml
window.API_ENDPOINT = "{{ .Values.config.connectionType }}://{{ .Values.app.ingress.hostName | default .Values.config.ingressHost }}/api";
```

Keep feature-flag / `MS_API_URL` / `CURRENT_VERSION_NUMBER` logic reading `.Values.webClient.environmentVariables`.

- [ ] **Step 4: Render smoke (co-located)**

```bash
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg \
  --set config.database.name=studio \
  --set config.database.username=u \
  --set config.database.password=p \
  --set keycloak.enabled=false \
  --set rasa.enabled=false \
  | tee /tmp/studio-colocated.yaml
```

Expected: no `*-web-client` Deployment/Service/Ingress; app resources named `*-app` (not `*-backend`); app has `STUDIO_ROLE=app`, `ENABLE_EVENT_INGESTION=true`, mount `/usr/src/app/spa/config.js`; no `*-app-ingestion` Deployment when mode is colocated.

- [ ] **Step 5: Commit**

```bash
git add charts/studio/templates
git commit -m "feat(studio): rename backend→app and wire unified app role, Kafka co-locate, SPA config mount"
```

---

### Task 3: Collapse ingress; delete web-client runtime templates

**Files:**

- Modify: `charts/studio/templates/studio/app/ingress.yaml`
- Delete: `charts/studio/templates/studio/web-client/deployment.yaml`
- Delete: `charts/studio/templates/studio/web-client/service.yaml`
- Delete: `charts/studio/templates/studio/web-client/ingress.yaml`
- Delete: `charts/studio/templates/studio/web-client/serviceaccount.yaml`
- Modify: `charts/studio/templates/_helpers.tpl` (remove dead webClient Deployment/image/SA/scheduling helpers if unused; update `studio.webClientUrl` to single-host)
- Modify: `charts/studio/templates/network-policy/ingress-egress-from-kubelet.yaml`
- Modify: `charts/studio/templates/tests/test-connection.yaml` (if present references web-client or `*-backend`)

**Interfaces:**

- Consumes: app Service port (80 → targetPort 4000)
- Produces: Single Ingress for UI + API (+ `/auth` → Keycloak when enabled)

- [ ] **Step 1: App Ingress paths**

```yaml
paths:
  - path: /api
    pathType: Prefix
    backend:
      service:
        name: {{ $fullName }}-app
        port:
          number: {{ $svcPort }}
  - path: /
    pathType: Prefix
    backend:
      service:
        name: {{ $fullName }}-app
        port:
          number: {{ $svcPort }}
```

Notes:

- Keep `/api` before `/` for readability; both Prefix to same Service is fine.
- The YAML keys `backend:` above are the **Kubernetes Ingress API** field — do **not** rename those keys to `app:`.
- Better Auth (`/api/auth/*`) is covered by the `/api` path to the app Service.
- While Keycloak is enabled, retain an `/auth` path to the Keycloak Service (unchanged Keycloak templates).

- [ ] **Step 2: Delete web-client runtime manifests; clean helpers + network policy + tests**

Remove web-client NetworkPolicy block targeting `studio-web-client`. Retarget any `studio-backend` / `*-backend` policy selectors to `studio-app` / `*-app`. Grep for `web-client` / `webClient.image` / `studio.webClient.image` / `Values.backend` / `-backend` resource names and delete or rename dead code.

- [ ] **Step 3: Template + assert**

```bash
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.name=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  | rg -n 'kind: (Ingress|Deployment|Service)'
```

Expected: one Studio app Ingress with `/api` and `/` targeting `*-app`; no web-client Ingress/Deployment/Service; no `*-backend` Service/Deployment names.

- [ ] **Step 4: Commit**

```bash
git add -u charts/studio/templates
git commit -m "feat(studio): single-host ingress and remove web-client Deployment"
```

---

### Task 4: Migration Job + separate ingestion Deployment

**Files:**

- Modify: `charts/studio/templates/studio/app/database-migration-job.yaml`
- Modify: `charts/studio/templates/studio/event-ingestion/deployment.yaml`

**Interfaces:**

- Consumes: `app.migration.*`, `eventIngestion.enabled`
- Produces: `STUDIO_ROLE=migration` / `ingestion` on unified image

- [ ] **Step 1: Migration Job env**

Add:

```yaml
- name: STUDIO_ROLE
  value: "migration"
```

Do not set `command`/`args` unless the published image lacks the entrypoint CMD — unified image uses `dumb-init` + `entrypoint.sh`.

Keep existing `SKIP_KEYCLOAK` behavior when `keycloak.enabled=false`.

- [ ] **Step 2: Event-ingestion Deployment**

Add:

```yaml
- name: STUDIO_ROLE
  value: "ingestion"
```

Image helper already uses `eventIngestion.image.name` (now `studio`). **Do not** add liveness/readiness probes.

- [ ] **Step 3: Template separate-ingestion scenario**

```bash
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.name=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  --set eventIngestion.enabled=true \
  | tee /tmp/studio-separate-ingest.yaml
```

Expected: `{release}-app-ingestion` Deployment with `STUDIO_ROLE=ingestion`; app `ENABLE_EVENT_INGESTION=false`; app **without** duplicate Kafka consumer env if you gated Kafka to colocated-only (preferred).

- [ ] **Step 4: Commit**

```bash
git add charts/studio/templates/studio/app/database-migration-job.yaml \
  charts/studio/templates/studio/event-ingestion/deployment.yaml
git commit -m "feat(studio): set STUDIO_ROLE on migration Job and ingestion Deployment"
```

---

### Task 5: Schema, NOTES, README

**Files:**

- Modify: `charts/studio/values.schema.json`
- Modify: `charts/studio/NOTES.txt`
- Modify: `charts/studio/README.md.gotmpl`
- Regenerated: `charts/studio/README.md`

**Interfaces:**

- Consumes: Locked decisions 1–2, 5, 8–9
- Produces: Valid defaults under `helm lint --strict`; operator docs

- [ ] **Step 1: Schema**

Rename schema property `backend` → `app` (and nested refs). Slim `webClient` to optional object with `environmentVariables` (object); remove required-looking `replicaCount`/`image`/`service`/`ingress` if they would reject slim defaults. Ensure `eventIngestion.enabled` boolean still allowed `false`.

- [ ] **Step 2: NOTES.txt**

- Single access URL for Studio (UI + API), not separate web-client section.
- Warn: do not run co-located ingestion and a separate `eventIngestion` Deployment with consumers both active.
- Note breaking image rename to `studio`; values/resource rename `backend` → `app` / `{release}-app`.
- Note Keycloak is temporary/migration-only; Better Auth on app under `/api/auth/*`; `/auth` still Keycloak while enabled.

- [ ] **Step 3: README.gotmpl**

Add short sections: unified image, `backend`→`app` rename, default co-located topology, scaled ingestion (`eventIngestion.enabled: true`), chart `3.0.0` ↔ Studio `studio` image ≥ 1.17.0, SPA config via `webClient.environmentVariables`, Keycloak temporary + Better Auth path.

- [ ] **Step 4: Docs generation + lint**

```bash
pre-commit run helm-docs --all-files
helm lint --strict charts/studio
```

Expected: lint passes; README lists new defaults under `app`.

- [ ] **Step 5: Commit**

```bash
git add charts/studio/values.schema.json charts/studio/NOTES.txt \
  charts/studio/README.md.gotmpl charts/studio/README.md
git commit -m "docs(studio): schema and NOTES for unified image topology and app rename"
```

---

### Task 6: Verification matrix + final tidy

**Files:** any leftovers from `rg` cleanup

- [ ] **Step 1: Grep for retired image / nginx paths / old values key**

```bash
rg -n 'studio-backend|studio-web-client|studio-event-ingestion|studio-database-migration|/usr/share/nginx/html|\.Values\.backend|templates/studio/backend' \
  charts/studio --glob '!README.md' --glob '!docs/**'

# Values/resource rename leftovers (exclude K8s Ingress API field `backend:`)
rg -n 'backend' charts/studio --glob '!README.md' | rg -v '^\s*backend:|pathType|service:|port:|number:'
```

Expected: only intentional historical mentions in comments/release notes if any; **no** default `image.name` still on old names; **no** `.Values.backend` or `templates/studio/backend`; Ingress YAML may still contain the K8s field `backend:`. Keycloak `studio-keycloak` OK.

- [ ] **Step 2: Lint + both topology templates**

```bash
helm lint --strict charts/studio

# Co-located (defaults)
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.name=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false >/tmp/c.yaml

# Separate ingestion
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.name=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  --set eventIngestion.enabled=true >/tmp/s.yaml
```

Assert:

| Check | Co-located | Separate |
| --- | --- | --- |
| Image refs contain `/studio:` (not old names) | yes | yes |
| Resources named `*-app` (not `*-backend`) | yes | yes |
| `STUDIO_ROLE=app` on app Deployment | yes | yes |
| `ENABLE_EVENT_INGESTION` | `true` | `false` |
| event-ingestion Deployment | absent | present with `STUDIO_ROLE=ingestion` |
| web-client Deployment | absent | absent |
| Ingress `/` + `/api` → `*-app` | yes | yes |
| Migration Job `STUDIO_ROLE=migration` | yes | yes |
| `config.js` mount `/usr/src/app/spa/config.js` | yes | yes |

- [ ] **Step 3: Confirm Chart.yaml is `3.0.0-rc.12`**

- [ ] **Step 4: Final commit if tidy needed**

```bash
git add -u charts/studio
git commit -m "chore(studio): finalize unified-image chart verification cleanups"
```

---

## Dependencies on Studio Phase 1

| Dependency | Why |
| --- | --- |
| Published image name `studio` (no aliases) | Chart defaults pull it |
| Entrypoint honors `STUDIO_ROLE` + `ENABLE_EVENT_INGESTION` | Deployment/Job env contract |
| `SPA_STATIC_ROOT=/usr/src/app/spa` + Express SPA serving | Ingress `/` + config mount path |
| Migration path via `STUDIO_ROLE=migration` (+ Keycloak bootstrap until Phase 4) | Hook Job |
| Studio ≥ 1.17.0 (or first tag that actually publishes `studio`) | Chart↔image pairing |

If Phase 1 is not yet in the registry, implement/merge chart on the release branch but **do not** promote customer upgrades until the image exists.

---

## Self-review (spec coverage)

| Design / Phase 2 requirement | Task(s) |
| --- | --- |
| Full-surface rename `backend` → `app` / `{release}-app` | 1, 2, 3, 5, 6 |
| Single app Deployment, `studio` image, `STUDIO_ROLE=app` | 1, 2 |
| Optional ingestion Deployment | 1, 4 |
| Migration Job → `studio` + `STUDIO_ROLE=migration` | 1, 4 |
| Remove web-client Deployment; collapse ingress | 3 |
| Values / NOTES for `ENABLE_EVENT_INGESTION` mutual exclusion | 2, 5 |
| Keep Keycloak (temporary); Better Auth on `/api/auth/*` | Global constraint; Task 3, 5 |
| No ingestion probes | Explicit non-goal |
| Chart ↔ image compatibility notes | 1, 5 |
| ConfigMap SPA `config.js` same-origin via `app.ingress.hostName` | 2 |
| Better Auth / modelservice untouched (no redesign) | Global constraint |
| Ingress YAML `backend:` field left as K8s API | Task 3 note |

No open placeholders for implementable Helm steps; `<PUBLISHED_STUDIO_TAG>` is resolved at Task 1 against the registry (not a design TBD).
