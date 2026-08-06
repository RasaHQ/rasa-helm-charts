# Studio Helm Chart — `backend` → `app` Rename + Unified Image Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `charts/studio` so the former `backend` surface becomes `app` (values, K8s names, templates, helpers, schema, docs), the chart consumes the unified `studio` image (API + SPA + optional co-located ingestion + migration), and dual SPA/API ingress collapses to one host — without redesigning Better Auth / Keycloak Phase 4 work.

**Architecture:** Full-surface hard-break rename (`backend` → `app`). Uniform K8s names `{release}-app`, `{release}-app-migration`, `{release}-app-ingestion`. No nginx web-client Deployment; slim `webClient.environmentVariables` feed a SPA `config.js` ConfigMap mounted into the app pod. Explicit `eventIngestion.mode: colocated|separate|disabled` (default `colocated`) with a hard `fail` if both co-located and separate consumers would run. Keycloak keeps a separate Ingress for `/auth`; app Ingress serves `/` and `/api`.

**Tech Stack:** Helm 3/4, Kubernetes Ingress `networking.k8s.io/v1`, helm-docs, `values.schema.json` (draft-07 `#/definitions`), Studio unified image (`STUDIO_ROLE`, `ENABLE_EVENT_INGESTION`).

## Global Constraints

- Chart version is already **`3.0.0-rc.13`** in the working tree — **do not re-bump** unless CI later requires another increment for this PR.
- Better Auth / modelservice work on the 3.0 RC line is **already done** — do not redesign it.
- Keycloak stays (templates, values, image `studio-keycloak`) as **temporary / migration-only** until Studio Phase 4. Better Auth is under `/api/auth/*` on the app Service. Keep a **separate** Keycloak Ingress for `/auth` while Keycloak is enabled.
- Do **not** change `charts/rasa/` or `charts/op-kits/`.
- Do **not** introduce image digests; keep tag-based `repository` + `tag` + `image.name`.
- Env contract: `STUDIO_ROLE=app|ingestion|migration`, `ENABLE_EVENT_INGESTION` boolean.
- No HTTP/exec probes for the ingestion role / sibling Deployment.
- **Never mutate `.Values`** at render time (Helm 4). Prefer `deepCopy` / local dicts / `mergeOverwrite` on copies.
- `README.md` is auto-generated — edit `values.yaml` `# --` comments + `README.md.gotmpl`, then `pre-commit run helm-docs --all-files`. Never hand-edit README content except what helm-docs regenerates.
- Schema: draft-07 with `#/definitions/...` refs only (**not** `$defs`).
- Kubernetes Ingress path objects use a YAML field named `backend:` (service + port). That is the **K8s API** — leave those field names as-is; only change the **service name** to `{release}-app`.
- Leave Keycloak client id string `rasa-studio-backend` unchanged (out of chart rename scope).
- Hard-break: **no** Helm alias from `backend:` → `app:`. Document values translation + **manual** orphan cleanup (no auto-delete hooks).
- Locked DB field rename: `config.database.backendDatabaseName` → **`config.database.databaseName`**.
- Locked component label for the main app: `app.kubernetes.io/component: studio-app`.
- Locked ingestion Deployment component label: `app.kubernetes.io/component: studio-app-ingestion`.

## Cross-links

| Doc | Path |
| --- | --- |
| Locked rename + auth design (this repo) | `docs/superpowers/specs/2026-08-06-studio-helm-app-rename-design.md` |
| Older mixed Phase 2 plan (superseded for implement) | `docs/superpowers/plans/2026-08-05-studio-helm-container-image-simplification.md` |
| Studio product design (canonical image/roles) | `/Users/amal/Rasa/studio/docs/superpowers/specs/2026-08-03-studio-container-image-simplification-design.md` |

**Why a new plan file:** The 2026-08-05 plan mixed older `eventIngestion.enabled` semantics, wrong version bumps (`rc.12`), and partial rename notes. This file is the **canonical implementation plan**. The older plan keeps historical grill-me / locked-decision tables and should point here.

---

## Starting state (do not continue half-done work)

As of plan authorship (2026-08-06):

| Area | State |
| --- | --- |
| `charts/studio/Chart.yaml` | **Uncommitted** bump `3.0.0-rc.11` → **`3.0.0-rc.13`**. Keep this version; do not bump again for this work. |
| `charts/studio/README.md` | **Uncommitted** badge/version string updates reflecting `rc.13` only. |
| `charts/studio/values.yaml` | **Clean / pre-rename**: top-level `backend:`, images `studio-backend` / `studio-web-client` / `studio-event-ingestion`, `eventIngestion.enabled: true`, `config.database.backendDatabaseName`. |
| Templates | **Unchanged**: `templates/studio/backend/` still exists; **no** `templates/studio/app/`. Web-client Deployment/Service/Ingress/SA still present. Helpers still `studio.backend.*` and `.Values.backend`. |
| Schema / NOTES / gotmpl | Still describe `backend` / dual web-client access. |
| Prior implement attempt | An agent may have briefly edited `values.yaml` toward `app:` / `mode: colocated` / `databaseName`; those edits were **reverted**. **Ignore any partial implementation.** Implement from this plan + the locked design, starting from the table above. |

**Baseline smoke (before any task):** chart should still lint against current defaults, but defaults are the *old* surface. Do not “finish” a half-renamed tree — start Task 1 cleanly.

```bash
helm lint --strict charts/studio
```

Expected: PASS on current (pre-rename) tree.

---

## Locked decisions (do not re-litigate)

| # | Decision |
| --- | --- |
| 1 | Full-surface rename `backend` → `app` (values key `app:`, not `studioApp` / `studio-app`). Hard-break, no aliases. |
| 2 | K8s names: `{release}-app`, `{release}-app-migration`, `{release}-app-ingestion`. |
| 3 | Label: `app.kubernetes.io/component: studio-app` (ingestion: `studio-app-ingestion`). |
| 4 | No nginx web-client Deployment/Service/Ingress/SA. Unified app serves UI. |
| 5 | Keep slim `webClient.environmentVariables` for SPA ConfigMap → `/usr/src/app/spa/config.js`. |
| 6 | `eventIngestion.mode`: `colocated` \| `separate` \| `disabled` (default **`colocated`**). Remove semantic use of `eventIngestion.enabled`. |
| 7 | Hard `fail` at render if colocated + separate would both run; also fail on unknown mode / leftover `enabled` key. |
| 8 | `config.database.backendDatabaseName` → `config.database.databaseName`. |
| 9 | Single app Ingress: `/api` + `/` → app Service. Keycloak Ingress stays separate for `/auth`. |
| 10 | Chart version `3.0.0-rc.13` — no re-bump unless CI forces it. |
| 11 | Document manual orphan cleanup for `*-backend`, `*-web-client`, old `*-event-ingestion`, old `*-database-migration`. |
| 12 | Same-origin URLs: prefer `app.ingress.hostName`, else `config.ingressHost`. |
| 13 | Image defaults: `app.image.name`, `app.migration.image.name`, `eventIngestion.image.name` → `"studio"`. Keycloak stays `studio-keycloak`. |
| 14 | Roles: app=`STUDIO_ROLE=app`; migration=`migration`; separate ingestion=`ingestion`. |
| 15 | **Default image tag:** placeholder **`2.0.0-latest`** (unified Studio image ≥2.0.0). Replace with the first published unified tag before customer promotion if needed. Comments/docs that said ≥1.17.0 should say ≥2.0.0 for this chart line. |
| 16 | **SPA ConfigMap resource name:** keep **`studio-web-client-configmap`** (file lives under `templates/studio/app/`; name unchanged to reduce upgrade churn). |

**Execution (2026-08-06):** User confirmed decisions 15–16 and chose **subagent-driven development**. **Do not git-commit** unless the user explicitly asks — implementers skip plan commit steps; controller tracks progress via working-tree diffs + `.superpowers/sdd/progress.md`.

---

## File structure map

| Path | Responsibility |
| --- | --- |
| `charts/studio/Chart.yaml` | Already `3.0.0-rc.13` — leave unless CI requires another bump |
| `charts/studio/values.yaml` | Rename `backend:` → `app:`; `databaseName`; image names; `eventIngestion.mode`; slim `webClient`; `# --` docs; default `tag` for unified image |
| `charts/studio/values.schema.json` | Rename `backend` → `app`; slim `webClient`; `eventIngestion.mode` enum; `databaseName`; `#/definitions/...` only |
| `charts/studio/templates/studio/app/*` | Renamed from `backend/`; Deployment/Service/Ingress/HPA/SA/migration |
| `charts/studio/templates/studio/app/configmap.yaml` | SPA `config.js` ConfigMap (moved from `web-client/configmap.yaml`) |
| **Delete** `web-client/deployment.yaml`, `service.yaml`, `ingress.yaml`, `serviceaccount.yaml` | No SPA pod |
| `charts/studio/templates/studio/event-ingestion/*` | Gate on `mode: separate`; name `{release}-app-ingestion`; `STUDIO_ROLE=ingestion` |
| `charts/studio/templates/_helpers.tpl` | `studio.app.*`; validation helper; `studio.webClientUrl` → app host; drop dead web-client workload helpers |
| `charts/studio/templates/studio/_env.tpl` | `studio.app.env` / `studio.app.keycloak`; `.databaseName` |
| `charts/studio/templates/network-policy/ingress-egress-from-kubelet.yaml` | Drop web-client NP; retarget `studio-backend` → `studio-app`; add/retarget ingestion → `studio-app-ingestion` |
| `charts/studio/templates/tests/test-connection.yaml` | Point at app Service port |
| `charts/studio/templates/shared-env-configmap.yaml` | Continues to use `studio.webClientUrl` (updated helper) |
| `charts/studio/NOTES.txt` | Single Studio URL; mode docs; hard-fail; orphan cleanup; rename notes |
| `charts/studio/README.md.gotmpl` | Topology / pairing / breaking rename |
| `charts/studio/README.md` | Regenerated via helm-docs only |

---

### Shared render / assert helpers (use in every verification step)

**Minimal required values** (repeat in commands):

```bash
RENDER_BASE=(
  --kube-version 1.29.0
  --set config.ingressHost=studio.example.com
  --set config.database.host=pg
  --set config.database.username=u
  --set config.database.password=p
  --set keycloak.enabled=false
  --set rasa.enabled=false
)
# After Task 1, DB field is databaseName (defaults already "studio").
# Before Task 1 completes, schemas/templates may still expect backendDatabaseName.
```

**Assert script pattern** (inline; do not invent a permanent test harness unless useful):

```bash
assert_render() {
  local file="$1"; shift
  local pattern="$1"; shift
  local expect="$1" # present|absent
  if rg -q "$pattern" "$file"; then
    [[ "$expect" == present ]] || { echo "FAIL: unexpected $pattern"; return 1; }
  else
    [[ "$expect" == absent ]] || { echo "FAIL: missing $pattern"; return 1; }
  fi
}
```

---

### Task 1: Values surface — `backend`→`app`, images, `mode`, slim `webClient`, `databaseName`

**Files:**
- Keep: `charts/studio/Chart.yaml` at `version: 3.0.0-rc.13` (already uncommitted)
- Modify: `charts/studio/values.yaml`
- Test: `helm lint --strict` will fail until helpers/templates catch up — **do not expect full lint green until Task 2–3**. Prefer structural `rg` checks after this task.

**Interfaces:**
- Consumes: Locked decisions 1, 5–8, 12–13
- Produces: Values API that later tasks read: `.Values.app`, `.Values.eventIngestion.mode`, `.Values.config.database.databaseName`, slim `.Values.webClient.environmentVariables`

- [ ] **Step 1: Confirm Chart.yaml stays at rc.13**

```bash
grep '^version:' charts/studio/Chart.yaml
```

Expected: `version: 3.0.0-rc.13`

Do **not** change the version in this task.

- [ ] **Step 2: Write failing grep for the new values surface**

```bash
rg -n '^app:' charts/studio/values.yaml
rg -n 'mode: colocated' charts/studio/values.yaml
rg -n 'databaseName: "studio"' charts/studio/values.yaml
```

Expected: FAIL / no matches (current tree still has `backend:`, `backendDatabaseName`, `eventIngestion.enabled`).

- [ ] **Step 3: Rename top-level `backend:` → `app:` and point images at `studio`**

In `charts/studio/values.yaml`:

1. Rename the section header comment from “Studio Backend…” to “Studio App…”.
2. Rename key `backend:` → `app:`.
3. Globally within that section, update `# -- backend.` doc prefixes to `# -- app.`.
4. Set:

```yaml
app:
  image:
    # -- app.image.name is the unified Studio container image (API + SPA + optional co-located ingestion).
    # Chart 3.0.0 requires this image (Studio ≥ 2.0.0). Formerly studio-backend.
    name: "studio"
  migration:
    image:
      # -- app.migration.image.name uses the same unified studio image with STUDIO_ROLE=migration.
      name: "studio"
```

5. Rename `config.database.backendDatabaseName` → `config.database.databaseName` (comments + key + examples).

6. Replace `eventIngestion.enabled` with mode (default colocated) and unified image:

```yaml
eventIngestion:
  # -- eventIngestion.mode controls event-ingestion topology.
  # colocated (default): ENABLE_EVENT_INGESTION=true on the app pod; no sibling Deployment.
  # separate: deploy {release}-app-ingestion with STUDIO_ROLE=ingestion; app sets ENABLE_EVENT_INGESTION=false.
  # disabled: neither co-located nor separate consumers.
  # Breaking: replaces eventIngestion.enabled. Do not set both semantics.
  mode: colocated
  image:
    # -- eventIngestion.image.name is the unified studio image for the separate ingestion Deployment.
    name: "studio"
```

Remove the old `enabled: true` default under `eventIngestion` (schema + templates will stop accepting it in later tasks).

7. Update top-level `tag` comment to require the published unified image tag. Set the concrete tag only when known:

```yaml
# -- tag specifies image tag for Studio (unified studio image; Studio ≥ 2.0.0).
# Placeholder until the first published unified tag is confirmed for promotion.
tag: "2.0.0-latest"
```

Locked (decision 15): use `2.0.0-latest` as the clear ≥2.0.0 placeholder.

- [ ] **Step 4: Slim `webClient` to SPA config bag only**

Replace the entire `webClient:` block with:

```yaml
# Studio SPA runtime config (no separate Deployment — unified app serves the UI).
webClient:
  # -- webClient.environmentVariables feeds the SPA config.js ConfigMap mounted at
  # /usr/src/app/spa/config.js on the app pod. Values are not secrets (ConfigMap only).
  # Used for feature flags (FEATURE_FLAG_*), MS_API_URL, CURRENT_VERSION_NUMBER, etc.
  # Breaking: web-client Deployment/Service/Ingress/image removed in chart 3.0.0.
  environmentVariables: {}
```

Delete from defaults: `replicaCount`, `image`, `envFrom`, `additionalContainers`, `serviceAccount`, pod/security contexts, `service`, probes, `ingress`, resources, scheduling, annotations that only existed for the nginx Deployment.

- [ ] **Step 5: Verify values structure (not full lint yet)**

```bash
rg -n '^backend:' charts/studio/values.yaml   # expect no match
rg -n '^app:' charts/studio/values.yaml       # expect match
rg -n 'backendDatabaseName' charts/studio/values.yaml  # expect no match
rg -n 'databaseName: "studio"' charts/studio/values.yaml
rg -n 'mode: colocated' charts/studio/values.yaml
rg -n 'studio-backend|studio-web-client|studio-event-ingestion|studio-database-migration' charts/studio/values.yaml
# expect: no default image.name on those strings (comments mentioning "formerly" OK)
```

Expected: values key surface matches locked rename; image defaults are `studio` / `studio-keycloak` only.

- [ ] **Step 6: Commit**

**Skip unless the user asks.** Leave Chart.yaml at `3.0.0-rc.13` and values changes uncommitted; controller tracks via SDD progress ledger + working-tree review packages.

---

### Task 2: Helpers + `_env.tpl` rename + ingestion mode validation

**Files:**
- Modify: `charts/studio/templates/_helpers.tpl`
- Modify: `charts/studio/templates/studio/_env.tpl`
- Test: `helm template` with a tiny throwaway values override once templates still reference old helpers — full green after Task 3. After this task, `rg` must show zero `studio.backend` defines.

**Interfaces:**
- Consumes: `.Values.app`, `.Values.eventIngestion.mode`, `.Values.config.database.databaseName`
- Produces:
  - `studio.app.serviceAccountName`, `studio.app.migration.serviceAccountName` (default name `{fullname}-app-migration`)
  - `studio.app.image`, `studio.migration.image` (unchanged define name OK if already generic), `studio.app.scheduling`, `studio.app.migration.scheduling`
  - `app.deployment.annotations`, `app.ingress.annotations` (renamed from `backend.*`)
  - `studio.app.env`, `studio.app.keycloak`
  - `studio.eventIngestion.validate` (fail helper)
  - `studio.eventIngestion.isColocated` / `isSeparate` / `isDisabled` (optional but recommended)
  - `studio.webClientUrl` → prefer `app.ingress.hostName` else `config.ingressHost`
  - `studio.appHost` (optional shared host helper used by Deployment + ConfigMap)

- [ ] **Step 1: Write failing check for new helper names**

```bash
rg -n 'define "studio.app.serviceAccountName"' charts/studio/templates/_helpers.tpl
rg -n 'define "studio.eventIngestion.validate"' charts/studio/templates/_helpers.tpl
rg -n 'define "studio.app.env"' charts/studio/templates/studio/_env.tpl
```

Expected: FAIL (still `studio.backend.*`).

- [ ] **Step 2: Add mode validation + topology helpers**

Add near other studio helpers in `_helpers.tpl` (exact names later tasks must use):

```yaml
{{/*
Validate eventIngestion.mode and refuse dual-consumer / legacy enabled.
*/}}
{{- define "studio.eventIngestion.validate" -}}
{{- if hasKey .Values.eventIngestion "enabled" -}}
{{- fail "eventIngestion.enabled was removed; use eventIngestion.mode: colocated|separate|disabled" -}}
{{- end -}}
{{- $mode := .Values.eventIngestion.mode | default "colocated" -}}
{{- if not (has $mode (list "colocated" "separate" "disabled")) -}}
{{- fail (printf "eventIngestion.mode must be one of colocated|separate|disabled, got %q" $mode) -}}
{{- end -}}
{{- /* Defensive: colocated and separate must never both activate consumers */ -}}
{{- $colocated := eq $mode "colocated" -}}
{{- $separate := eq $mode "separate" -}}
{{- if and $colocated $separate -}}
{{- fail "invalid eventIngestion.mode: colocated and separate cannot both be active" -}}
{{- end -}}
{{- end -}}

{{- define "studio.eventIngestion.mode" -}}
{{- .Values.eventIngestion.mode | default "colocated" -}}
{{- end -}}

{{- define "studio.appHost" -}}
{{- if .Values.app.ingress.hostName -}}
{{- .Values.app.ingress.hostName -}}
{{- else -}}
{{- .Values.config.ingressHost -}}
{{- end -}}
{{- end -}}

{{- define "studio.webClientUrl" -}}
{{- printf "%s://%s" .Values.config.connectionType (include "studio.appHost" .) -}}
{{- end -}}
```

Notes:
- Never `set` on `.Values`.
- Call `include "studio.eventIngestion.validate" .` at the top of app Deployment and event-ingestion Deployment (Task 4 / Task 6).

- [ ] **Step 3: Rename backend helpers to app**

In `_helpers.tpl`, rename defines and body refs:

| From | To |
| --- | --- |
| `studio.backend.serviceAccountName` | `studio.app.serviceAccountName` — default `printf "%s-app"` |
| `studio.backend.migration.serviceAccountName` | `studio.app.migration.serviceAccountName` — default `printf "%s-app-migration"` (replace old `%s-db-migration`) |
| `studio.backend.image` | `studio.app.image` — `.Values.app.image.name` |
| `studio.backend.scheduling` | `studio.app.scheduling` |
| `studio.backend.migration.scheduling` | `studio.app.migration.scheduling` |
| `backend.deployment.annotations` | `app.deployment.annotations` — `.Values.app.annotations` |
| `backend.ingress.annotations` | `app.ingress.annotations` — `.Values.app.ingress.additionalAnnotations` |

Update `studio.migration.image` to read `.Values.app.migration.image.name`.

Delete (or leave unused only until Task 5 deletes callers — prefer delete once callers gone): `studio.webClient.serviceAccountName`, `studio.webClient.image`, `studio.webClient.scheduling`, `webclient.deployment.annotations`, `webclient.ingress.annotations`, `nginx.selectorLabels` if only web-client used them.

Update `studio.eventIngestion.serviceAccountName` default to `printf "%s-app-ingestion"`.

- [ ] **Step 4: Rename `_env.tpl`**

```yaml
{{- define "studio.app.keycloak" -}}
# same body as studio.backend.keycloak; update any .Values.backend refs if present
{{- end -}}

{{- define "studio.app.env" -}}
{{- with .Values.config.database }}
# ... same as studio.backend.env but:
- name: DB_NAME
  {{- if kindIs "map" .databaseName }}
  valueFrom:
    secretKeyRef:
      name: {{ .databaseName.secretName | quote }}
      key: {{ .databaseName.secretKey | quote }}
  {{- else }}
  value: {{ .databaseName | quote }}
  {{- end }}
{{- end }}
{{- end -}}
```

Delete old `studio.backend.env` / `studio.backend.keycloak` defines after renaming.

- [ ] **Step 5: Verify helper defines exist; old defines gone**

```bash
rg -n 'define "studio\.backend' charts/studio/templates && echo 'FAIL: backend helpers remain' || echo 'OK: no studio.backend defines'
rg -n 'define "studio.app.env"|define "studio.eventIngestion.validate"|define "studio.appHost"' charts/studio/templates
```

Expected: no `studio.backend` defines; new defines present.

- [ ] **Step 6: Commit**

```bash
git add charts/studio/templates/_helpers.tpl charts/studio/templates/studio/_env.tpl
git commit -m "$(cat <<'EOF'
refactor(studio): rename helpers backend→app and add ingestion mode validation

EOF
)"
```

---

### Task 3: Rename template directory + K8s resource names + labels

**Files:**
- Rename dir: `charts/studio/templates/studio/backend/` → `charts/studio/templates/studio/app/`
- Modify every file under the new `app/` dir for names/labels/`.Values.app` / helper includes
- Move: `charts/studio/templates/studio/web-client/configmap.yaml` → `charts/studio/templates/studio/app/configmap.yaml` (update host refs; keep ConfigMap resource name `studio-web-client-configmap` for now to reduce churn — document in comments)

**Interfaces:**
- Consumes: helpers from Task 2
- Produces: Manifests named `{release}-app` / `{release}-app-migration` with label `studio-app` (content wiring of roles/mounts still Task 4)

- [ ] **Step 1: Write failing check for `templates/studio/app`**

```bash
test -d charts/studio/templates/studio/app && echo present || echo absent
```

Expected: `absent`

- [ ] **Step 2: Move directory and ConfigMap**

```bash
git mv charts/studio/templates/studio/backend charts/studio/templates/studio/app
git mv charts/studio/templates/studio/web-client/configmap.yaml charts/studio/templates/studio/app/configmap.yaml
```

- [ ] **Step 3: Bulk-update names, labels, values refs in `templates/studio/app/`**

Apply consistently:

| Pattern | Replacement |
| --- | --- |
| `.Values.backend` | `.Values.app` |
| `include "studio.backend.` | `include "studio.app.` |
| `include "backend.` | `include "app.` |
| `-backend` resource suffix | `-app` |
| `-database-migration` Job name | `-app-migration` |
| `studio-backend` component | `studio-app` |
| `include "studio.backend.env"` | `include "studio.app.env"` |

Job metadata name example:

```yaml
metadata:
  name: {{ include "studio.fullname" . }}-app-migration
```

Service / Deployment / Ingress / HPA: `...-app` / `...-app-hpa`.

ConfigMap `window.API_ENDPOINT` must use app host:

```yaml
window.API_ENDPOINT = "{{ .Values.config.connectionType }}://{{ include "studio.appHost" . }}/api";
```

Keep reading `.Values.webClient.environmentVariables` for flags / `MS_API_URL` / `CURRENT_VERSION_NUMBER`.

- [ ] **Step 4: Smoke — expect render errors until Roles/mode wired; still verify paths exist**

```bash
ls charts/studio/templates/studio/app/
test ! -d charts/studio/templates/studio/backend
rg -n '\.Values\.backend|studio-backend|-backend' charts/studio/templates/studio/app
```

Expected: app dir lists deployment/service/ingress/migration/configmap/etc.; no backend dir; no leftover `.Values.backend` in app templates.

- [ ] **Step 5: Commit**

```bash
git add -A charts/studio/templates/studio/app charts/studio/templates/studio/web-client
git commit -m "$(cat <<'EOF'
refactor(studio): move templates backend→app and rename K8s resources

EOF
)"
```

---

### Task 4: App Deployment — roles, ENABLE_EVENT_INGESTION, Kafka co-locate, SPA mount, same-origin URLs

**Files:**
- Modify: `charts/studio/templates/studio/app/deployment.yaml`
- Modify: `charts/studio/templates/studio/app/configmap.yaml` (if any leftover host prefs)

**Interfaces:**
- Consumes: `studio.eventIngestion.validate`, `studio.eventIngestion.mode`, `studio.appHost`, `eventIngestion.environmentVariables`, slim `webClient.environmentVariables`
- Produces: App pod with `STUDIO_ROLE=app`, correct ingestion flag, Kafka env when colocated, `config.js` mount, checksum annotation

- [ ] **Step 1: Write failing render assertions (colocated default)**

```bash
helm template studio ./charts/studio "${RENDER_BASE[@]}" \
  --set config.database.databaseName=studio \
  >/tmp/studio-t4-fail.yaml 2>/tmp/studio-t4-fail.err || true
rg -n 'STUDIO_ROLE|ENABLE_EVENT_INGESTION|/usr/src/app/spa/config.js' /tmp/studio-t4-fail.yaml /tmp/studio-t4-fail.err
```

Expected: FAIL — role/flag/mount not present yet (or render fails on remaining `.Values.backend` elsewhere — fix those includes if they block).

- [ ] **Step 2: Wire validation + role + ingestion flag + Kafka + mount**

At the top of `deployment.yaml`:

```yaml
{{- include "studio.eventIngestion.validate" . -}}
{{- $mode := include "studio.eventIngestion.mode" . -}}
```

On the app container `env` (after DB/auth includes; **replace** old WEB_CLIENT_URL / API_URL / BETTER_AUTH_BASE_URL that preferred `webClient.ingress.hostName`):

```yaml
- name: WEB_CLIENT_URL
  value: "{{ .Values.config.connectionType }}://{{ include "studio.appHost" . }}"
- name: API_URL
  value: "{{ .Values.config.connectionType }}://{{ include "studio.appHost" . }}/api"
- name: BETTER_AUTH_BASE_URL
  value: "{{ .Values.config.connectionType }}://{{ include "studio.appHost" . }}"
- name: STUDIO_ROLE
  value: "app"
- name: ENABLE_EVENT_INGESTION
  value: {{ if eq $mode "colocated" }}"true"{{ else }}"false"{{ end }}
```

When `eq $mode "colocated"`, also render Kafka-related env from `.Values.eventIngestion.environmentVariables` using the **same** `value` / `secret` range pattern as `event-ingestion/deployment.yaml`, plus default `KAFKA_CLIENT_ID` (`"kafka-python-rasa"`) if that default exists on the separate Deployment today — copy it for parity.

Volume mounts (replace any nginx paths; app Deployment previously had none for SPA):

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

Add pod annotation checksum (mirror old web-client Deployment):

```yaml
checksum/config: {{ include (print $.Template.BasePath "/studio/app/configmap.yaml") . | sha256sum }}
```

Use `mergeOverwrite` on **local** dicts only (already the pattern for `environmentVariables`) — never `set` on `.Values`.

- [ ] **Step 3: Render colocated and assert**

```bash
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg \
  --set config.database.databaseName=studio \
  --set config.database.username=u \
  --set config.database.password=p \
  --set keycloak.enabled=false \
  --set rasa.enabled=false \
  | tee /tmp/studio-colocated.yaml

assert_render /tmp/studio-colocated.yaml 'STUDIO_ROLE.\n[[:space:]]*value: "app"|STUDIO_ROLE"\n' present
# Practical asserts:
rg -n 'kind: Deployment' -A20 /tmp/studio-colocated.yaml | rg 'name: .*app$'
rg -q 'value: "app"' /tmp/studio-colocated.yaml
rg -q 'ENABLE_EVENT_INGESTION' /tmp/studio-colocated.yaml
rg -q 'value: "true"' /tmp/studio-colocated.yaml   # ingestion true in colocated — pair with nearby context manually
rg -q '/usr/src/app/spa/config.js' /tmp/studio-colocated.yaml
rg -q 'kind: Deployment' /tmp/studio-colocated.yaml && ! rg -q 'web-client' /tmp/studio-colocated.yaml || true
# web-client Deployment may still render until Task 5 — note that; this task does not require web-client gone yet
```

Expected: app Deployment has role `app`, `ENABLE_EVENT_INGESTION=true` for default mode, SPA mount present.

- [ ] **Step 4: Commit**

```bash
git add charts/studio/templates/studio/app/deployment.yaml charts/studio/templates/studio/app/configmap.yaml
git commit -m "$(cat <<'EOF'
feat(studio): wire unified app role, colocated Kafka, and SPA config mount

EOF
)"
```

---

### Task 5: Collapse Ingress; delete web-client runtime templates

**Files:**
- Modify: `charts/studio/templates/studio/app/ingress.yaml`
- Delete: `charts/studio/templates/studio/web-client/deployment.yaml`
- Delete: `charts/studio/templates/studio/web-client/service.yaml`
- Delete: `charts/studio/templates/studio/web-client/ingress.yaml`
- Delete: `charts/studio/templates/studio/web-client/serviceaccount.yaml`
- Modify: `charts/studio/templates/_helpers.tpl` — remove any remaining web-client workload helpers now unused
- Do **not** delete or merge Keycloak ingress (`templates/studio/keycloak/ingress.yaml` stays with `/auth`)

**Interfaces:**
- Consumes: app Service port (80 → targetPort 4000)
- Produces: One Studio app Ingress for `/api` + `/`; Keycloak Ingress remains separate

- [ ] **Step 1: Write failing assert — app Ingress should expose `/` (today only `/api`)**

```bash
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  | rg -n 'path: /$' 
```

Expected: FAIL or only web-client `/` until this task completes.

- [ ] **Step 2: Update app Ingress paths**

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

Keep YAML key `backend:` (K8s API). Do **not** add `/auth` to this Ingress — Keycloak template owns `/auth`.

- [ ] **Step 3: Delete web-client runtime manifests**

```bash
git rm charts/studio/templates/studio/web-client/deployment.yaml \
  charts/studio/templates/studio/web-client/service.yaml \
  charts/studio/templates/studio/web-client/ingress.yaml \
  charts/studio/templates/studio/web-client/serviceaccount.yaml
# remove empty web-client dir if empty
rmdir charts/studio/templates/studio/web-client 2>/dev/null || true
```

Grep and delete dead helpers referencing web-client image/SA/scheduling/ingress annotations.

- [ ] **Step 4: Render + assert**

```bash
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  | tee /tmp/studio-ingress.yaml

rg -n 'kind: Ingress' -A30 /tmp/studio-ingress.yaml
rg -q 'path: /api' /tmp/studio-ingress.yaml
rg -q 'path: /' /tmp/studio-ingress.yaml
rg -q '\-app$' /tmp/studio-ingress.yaml || rg -n 'name: .*app' /tmp/studio-ingress.yaml
! rg -q 'web-client' /tmp/studio-ingress.yaml
```

With Keycloak enabled separately:

```bash
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=true --set rasa.enabled=false \
  | rg -n 'path: /auth' -A8
```

Expected: `/auth` still targets Keycloak Service via **separate** Ingress; app Ingress has `/` + `/api` only.

- [ ] **Step 5: Commit**

```bash
git add -u charts/studio/templates
git commit -m "$(cat <<'EOF'
feat(studio): single-host app ingress and remove web-client Deployment

EOF
)"
```

---

### Task 6: Migration Job + separate ingestion Deployment (`mode` gating)

**Files:**
- Modify: `charts/studio/templates/studio/app/database-migration-job.yaml`
- Modify: `charts/studio/templates/studio/app/database-migration-serviceaccount.yaml` (name via helper)
- Modify: `charts/studio/templates/studio/event-ingestion/deployment.yaml`
- Modify: `charts/studio/templates/studio/event-ingestion/hpa.yaml`
- Modify: `charts/studio/templates/studio/event-ingestion/serviceaccount.yaml`

**Interfaces:**
- Consumes: `eventIngestion.mode`, `studio.eventIngestion.validate`, `app.migration.*`
- Produces: Migration Job `{release}-app-migration` with `STUDIO_ROLE=migration`; separate Deployment only when `mode=separate`, named `{release}-app-ingestion`, label `studio-app-ingestion`, `STUDIO_ROLE=ingestion`

- [ ] **Step 1: Write failing asserts for migration role + separate name**

```bash
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  --set eventIngestion.mode=separate \
  | tee /tmp/studio-sep-pre.yaml
rg -n 'STUDIO_ROLE|app-ingestion|app-migration|event-ingestion' /tmp/studio-sep-pre.yaml
```

Expected: FAIL on missing `STUDIO_ROLE=migration` / still `event-ingestion` name / wrong gate.

- [ ] **Step 2: Migration Job**

Ensure Job name is `{fullname}-app-migration`. Add env:

```yaml
- name: STUDIO_ROLE
  value: "migration"
```

Do **not** set `command`/`args` for the migration container unless the published image lacks entrypoint CMD. Keep existing `SKIP_KEYCLOAK` behavior when `keycloak.enabled=false`. Image via `studio.migration.image` / `app.migration.image.name: studio`.

- [ ] **Step 3: Event-ingestion templates — gate + rename + role**

Replace file header gate:

```yaml
{{- include "studio.eventIngestion.validate" . -}}
{{- if eq (include "studio.eventIngestion.mode" .) "separate" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "studio.fullname" . }}-app-ingestion
  labels:
    {{- include "studio.labels" . | nindent 4 }}
    app.kubernetes.io/component: studio-app-ingestion
```

Add:

```yaml
- name: STUDIO_ROLE
  value: "ingestion"
```

**Do not** add liveness/readiness probes.

Update HPA `scaleTargetRef.name` and SA default name to `*-app-ingestion`. Apply the same `if eq mode "separate"` gate to HPA and SA templates.

When mode is `colocated` or `disabled`, these files must render **nothing**.

- [ ] **Step 4: Mode matrix render asserts**

```bash
# colocated (default)
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  | tee /tmp/c.yaml
! rg -q 'app-ingestion' /tmp/c.yaml
rg -q 'app-migration' /tmp/c.yaml
rg -q 'STUDIO_ROLE' /tmp/c.yaml

# separate
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  --set eventIngestion.mode=separate \
  | tee /tmp/s.yaml
rg -q 'name: .*app-ingestion' /tmp/s.yaml
rg -q 'studio-app-ingestion' /tmp/s.yaml

# disabled
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  --set eventIngestion.mode=disabled \
  | tee /tmp/d.yaml
! rg -q 'app-ingestion' /tmp/d.yaml
# ENABLE_EVENT_INGESTION must be false on app — inspect app Deployment env block

# hard-fail: legacy enabled key
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  --set eventIngestion.enabled=true \
  >/tmp/bad.yaml 2>/tmp/bad.err; test $? -ne 0
rg -q 'eventIngestion.enabled was removed' /tmp/bad.err

# hard-fail: invalid mode
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  --set eventIngestion.mode=both \
  >/tmp/bad2.yaml 2>/tmp/bad2.err; test $? -ne 0
```

Expected: colocated/separate/disabled matrix holds; legacy `enabled` and invalid mode hard-fail.

- [ ] **Step 5: Commit**

```bash
git add charts/studio/templates/studio/app/database-migration-job.yaml \
  charts/studio/templates/studio/app/database-migration-serviceaccount.yaml \
  charts/studio/templates/studio/event-ingestion/
git commit -m "$(cat <<'EOF'
feat(studio): STUDIO_ROLE on migration/ingestion and mode-gated app-ingestion

EOF
)"
```

---

### Task 7: Network policies + test-connection

**Files:**
- Modify: `charts/studio/templates/network-policy/ingress-egress-from-kubelet.yaml`
- Modify: `charts/studio/templates/tests/test-connection.yaml`

**Interfaces:**
- Consumes: `.Values.app.service.port`, component labels `studio-app` / `studio-app-ingestion`
- Produces: NP targeting app (and ingestion if present); test hook hitting app Service

- [ ] **Step 1: Write failing grep**

```bash
rg -n 'studio-backend|studio-web-client|Values\.backend' \
  charts/studio/templates/network-policy charts/studio/templates/tests
```

Expected: matches exist (fail condition for “done”).

- [ ] **Step 2: Retarget network policies**

- Rename policy `ingress-egress-from-kubelet-to-studio-backend` → `...-studio-app`
- Selector `app.kubernetes.io/component: studio-app`
- Port from `.Values.app.service.port`
- **Delete** the web-client NetworkPolicy document entirely
- If an event-ingestion NP exists or should exist for kubelet probes, retarget to `studio-app-ingestion` / `*-app-ingestion`; if none exists today beyond backend/web-client, do not invent extra policies (YAGNI) unless kubelet NP was required for ingestion previously

- [ ] **Step 3: Fix test-connection**

```yaml
args: ['{{ include "studio.fullname" . }}-app:{{ .Values.app.service.port }}']
```

(Adjust if the old test intentionally hit a different service shape — match the app Service name `{fullname}-app`.)

- [ ] **Step 4: Verify**

```bash
rg -n 'studio-backend|studio-web-client|Values\.backend' \
  charts/studio/templates/network-policy charts/studio/templates/tests \
  && echo FAIL || echo OK
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=false --set rasa.enabled=false \
  | rg -n 'NetworkPolicy|test-connection' -A15
```

- [ ] **Step 5: Commit**

```bash
git add charts/studio/templates/network-policy/ingress-egress-from-kubelet.yaml \
  charts/studio/templates/tests/test-connection.yaml
git commit -m "$(cat <<'EOF'
fix(studio): retarget network policies and tests to app Service

EOF
)"
```

---

### Task 8: Schema, NOTES, README (helm-docs)

**Files:**
- Modify: `charts/studio/values.schema.json`
- Modify: `charts/studio/NOTES.txt`
- Modify: `charts/studio/README.md.gotmpl`
- Regenerated: `charts/studio/README.md`

**Interfaces:**
- Consumes: final values shape from Task 1
- Produces: `helm lint --strict` green; operator-facing breaking-change docs

- [ ] **Step 1: Write failing lint against new values (schema still old)**

```bash
helm lint --strict charts/studio
```

Expected: FAIL on schema mismatch (`app` vs `backend`, missing `webClient.replicaCount`, `eventIngestion.mode`, `databaseName`, etc.).

- [ ] **Step 2: Update `values.schema.json`**

- Rename property `backend` → `app` (keep nested shape: replicaCount, image, authSecret, migration, ingress, service, etc.).
- Rename `config.properties.database.properties.backendDatabaseName` → `databaseName` (same `secretRefOrString` ref via `#/definitions/secretRefOrString`).
- Slim `webClient` to:

```json
"webClient": {
  "type": "object",
  "properties": {
    "environmentVariables": {
      "type": "object",
      "additionalProperties": true
    }
  },
  "additionalProperties": false
}
```

(or `additionalProperties: true` if the chart historically allows extras — match existing chart style; do not require removed fields).

- Under `eventIngestion`:
  - Remove `enabled` (or reject it — prefer omit from schema so unknown keys depend on `additionalProperties`; validation helper still fails if present).
  - Add:

```json
"mode": {
  "type": "string",
  "enum": ["colocated", "separate", "disabled"]
}
```

- Ensure all `$ref` values use `#/definitions/...` only — **no** `$defs`.
- Defaults in `values.yaml` must satisfy the schema.

- [ ] **Step 3: Rewrite NOTES.txt access section**

Replace dual “Backend” + “Web Client” sections with a single Studio URL section using `app.ingress` / `config.ingressHost`. Add bullets:

- Breaking: values key `backend` → `app`; resources `*-backend` → `*-app`; migration `*-app-migration`; ingestion `*-app-ingestion`.
- Breaking images: `studio` unified image; chart 3.0.0 requires Studio ≥ 1.17.0.
- `eventIngestion.mode`: colocated (default) / separate / disabled; do not run dual consumers (chart hard-fails).
- Better Auth on app at `/api/auth/*`; Keycloak temporary at `/auth` while enabled.
- **Manual orphan cleanup after upgrade** (no auto-delete):

```text
kubectl delete deployment,svc,ingress,sa,hpa -l app.kubernetes.io/component=studio-backend -n <ns>
kubectl delete deployment,svc,ingress,sa -l app.kubernetes.io/component=studio-web-client -n <ns>
kubectl delete deployment,sa,hpa -l app.kubernetes.io/component=studio-event-ingestion -n <ns>
# also delete old jobs/sa named *-database-migration / *-db-migration if present
```

- [ ] **Step 4: Update README.md.gotmpl**

Add short sections (architecture blurb is fine): unified image; `backend`→`app` hard-break; default colocated topology; `eventIngestion.mode`; SPA config via `webClient.environmentVariables`; chart↔image pairing; Keycloak temporary + Better Auth path; upgrade orphan cleanup pointer.

Do **not** hand-edit `README.md` tables.

- [ ] **Step 5: helm-docs + lint**

```bash
pre-commit run helm-docs --all-files
helm lint --strict charts/studio
```

Expected: lint PASS; README lists `app.*` and `eventIngestion.mode`.

- [ ] **Step 6: Commit**

```bash
git add charts/studio/values.schema.json charts/studio/NOTES.txt \
  charts/studio/README.md.gotmpl charts/studio/README.md
git commit -m "$(cat <<'EOF'
docs(studio): schema and NOTES for app rename and ingestion modes

EOF
)"
```

---

### Task 9: Full verification matrix + leftover grep cleanup

**Files:** any leftovers under `charts/studio/` from `rg` cleanup (templates/docs only; do not edit generated README by hand)

- [ ] **Step 1: Grep for retired surfaces**

```bash
rg -n 'studio-backend|studio-web-client|studio-event-ingestion|studio-database-migration|/usr/share/nginx/html|\.Values\.backend|templates/studio/backend|backendDatabaseName' \
  charts/studio --glob '!README.md'

# Intentional "backend" mentions filter (K8s Ingress API field + historical docs + keycloak client id):
rg -n 'backend' charts/studio --glob '!README.md' | rg -v 'backend:|rasa-studio-backend|formerly|Former|Breaking|pathType|secretKeyRef'
```

Expected:
- No default `image.name` on old image strings
- No `.Values.backend` / `backendDatabaseName` / `templates/studio/backend`
- Ingress YAML may still contain K8s field `backend:`
- `rasa-studio-backend` client id may remain
- Historical NOTES mentions of the rename are OK

- [ ] **Step 2: Lint + mode matrix**

```bash
helm lint --strict charts/studio

render() {
  local out="$1"; shift
  helm template studio ./charts/studio --kube-version 1.29.0 \
    --set config.ingressHost=studio.example.com \
    --set config.database.host=pg --set config.database.databaseName=studio \
    --set config.database.username=u --set config.database.password=p \
    --set keycloak.enabled=false --set rasa.enabled=false \
    "$@" >"$out"
}

render /tmp/c.yaml
render /tmp/s.yaml --set eventIngestion.mode=separate
render /tmp/d.yaml --set eventIngestion.mode=disabled
```

Assert table:

| Check | colocated | separate | disabled |
| --- | --- | --- | --- |
| Image refs contain `/studio:` (not old names) | yes | yes | yes |
| Resources named `*-app` (not `*-backend`) | yes | yes | yes |
| `STUDIO_ROLE=app` on app Deployment | yes | yes | yes |
| `ENABLE_EVENT_INGESTION` | `true` | `false` | `false` |
| `*-app-ingestion` Deployment | absent | present + `STUDIO_ROLE=ingestion` | absent |
| web-client Deployment | absent | absent | absent |
| Ingress `/` + `/api` → `*-app` | yes | yes | yes |
| Keycloak `/auth` only when keycloak enabled (extra render) | separate Ingress | same | same |
| Migration Job `*-app-migration` + `STUDIO_ROLE=migration` | yes | yes | yes |
| `config.js` mount `/usr/src/app/spa/config.js` | yes | yes | yes |
| Kafka consumer env on app | present | absent (on app) | absent |

Extra Keycloak render:

```bash
helm template studio ./charts/studio --kube-version 1.29.0 \
  --set config.ingressHost=studio.example.com \
  --set config.database.host=pg --set config.database.databaseName=studio \
  --set config.database.username=u --set config.database.password=p \
  --set keycloak.enabled=true --set rasa.enabled=false \
  | rg -n 'path: /auth' -A6
```

Expected: Keycloak Service backend; **not** merged into app Ingress paths list.

- [ ] **Step 3: Confirm Chart.yaml still `3.0.0-rc.13`**

```bash
grep '^version:' charts/studio/Chart.yaml
```

Expected: `3.0.0-rc.13` — bump only if CI/`ct` demands another increment after this PR’s commits.

- [ ] **Step 4: Final tidy commit if needed**

```bash
git add -u charts/studio
git status
# only commit if there are leftover fixes:
git commit -m "$(cat <<'EOF'
chore(studio): finalize app-rename verification cleanups

EOF
)"
```

---

## Dependencies on Studio Phase 1

| Dependency | Why |
| --- | --- |
| Published image name `studio` (no aliases) | Chart defaults pull it |
| Entrypoint honors `STUDIO_ROLE` + `ENABLE_EVENT_INGESTION` | Deployment/Job env contract |
| `SPA_STATIC_ROOT=/usr/src/app/spa` + Express SPA serving | Ingress `/` + config mount path |
| Migration via `STUDIO_ROLE=migration` | Hook Job |
| Studio ≥ 1.17.0 (or first tag that publishes `studio`) | Chart↔image pairing |

If Phase 1 is not yet in the registry, implement/merge chart on the release branch but **do not** promote customer upgrades until the image exists.

---

## Self-review (spec coverage)

| Design requirement | Task(s) |
| --- | --- |
| Full-surface rename `backend` → `app` / `{release}-app` | 1, 2, 3, 7, 8, 9 |
| `{release}-app-migration` / `{release}-app-ingestion` | 3, 6 |
| Component label `studio-app` | 3, 7 |
| No nginx web-client; slim `webClient.environmentVariables` | 1, 4, 5 |
| `eventIngestion.mode` colocated/separate/disabled + hard-fail | 1, 2, 4, 6, 9 |
| `databaseName` rename | 1, 2, 8 |
| Single app Ingress `/` + `/api`; Keycloak `/auth` separate | 5, 9 |
| Unified `studio` image + roles | 1, 4, 6 |
| SPA mount `/usr/src/app/spa/config.js` | 4 |
| Manual orphan cleanup docs | 8 |
| Helm 4: never mutate `.Values` | Global + Tasks 2, 4 |
| Schema `#/definitions` | 8 |
| README via gotmpl + helm-docs | 8 |
| Chart version `3.0.0-rc.13` no re-bump | Starting state, Task 1, Task 9 |
| Leave `rasa-studio-backend` client id | Global |
| Ingress YAML field `backend:` unchanged | Task 5 note |
| No ingestion probes | Task 6 |
| Better Auth / Keycloak Phase 4 non-goals | Global, Task 5, 8 |

**Placeholder scan:** No TBD steps for Helm work. Image `tag` may remain unresolved until the unified image is published — called out under Ambiguities, not as an implementer “fill in later” code stub.

**Type/name consistency:** Helpers `studio.app.*`, `studio.eventIngestion.validate` / `mode`, `studio.appHost`, values `app` / `eventIngestion.mode` / `databaseName` are consistent across tasks.

---

## Ambiguities (resolved 2026-08-06)

1. **Default `tag`:** **LOCKED** → placeholder `2.0.0-latest` (Studio ≥ 2.0.0). Confirm published registry tag before customer promotion.
2. **SPA ConfigMap resource name:** **LOCKED** → keep `studio-web-client-configmap`.
3. **Working-tree Chart.yaml:** Already at `3.0.0-rc.13` — do not bump further unless CI requires. **No git commits** unless the user asks.

No ambiguity on values key (`app`), mode enum, DB field (`databaseName`), or Keycloak separate Ingress — those are locked.

---

## Execution handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-06-studio-helm-app-rename-implementation.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — Dispatch a fresh subagent per task, review between tasks, fast iteration. **REQUIRED SUB-SKILL:** `superpowers:subagent-driven-development`.

2. **Inline Execution** — Execute tasks in this session using `superpowers:executing-plans`, batch execution with checkpoints.

**Which approach?**
