# Studio Helm Chart — Customer Clarity Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Studio Helm customer-facing values and docs clear: nest web client under `app.webClient`, drop dead app-container `MS_API_URL`, align mount path/volume naming with the unified image, and fix `connectionType` / `eventIngestion` comment accuracy.

**Architecture:** Hard-break values move (`webClient:` → `app.webClient:`) with matching schema and ConfigMap refs. Drop the unused Deployment `$defaults` merge for `MS_API_URL`. Rename chart-owned volume `spa-config` → `web-client-config` and mount at `/usr/src/app/webclient/config.js`. Docs/comments prefer webClient / web-client / "web client" over SPA. No values restructure for `eventIngestion` beyond comments.

**Tech Stack:** Helm 3/4, Kubernetes ConfigMap/Deployment, `values.schema.json` (draft-07 `#/definitions`), helm-docs / pre-commit.

## Global Constraints

- Locked design: `docs/superpowers/specs/2026-08-07-studio-helm-customer-clarity-design.md` (Approved) — do not reopen scope.
- Chart version starts at **`3.0.0-rc.13`** on `release/SWI-1605-studio-image-simplification`. Bump to **`3.0.0-rc.14`** once during implementation (release-branch `-rc.X` convention).
- Hard-break: **no** Helm alias from top-level `webClient:` → `app.webClient:`.
- Prefer **webClient** / **web-client** / **"web client"**; avoid **"SPA"** / **"spa"** in chart-owned prose, comments, volume names, and mount paths.
- Keep ConfigMap resource name **`studio-web-client-configmap`** unchanged.
- Keep helper names `studio.modelServiceBaseUrl` / `studio.webClientUrl` (URL helpers, not values keys).
- Keep web client env key name **`MS_API_URL`** under `app.webClient.environmentVariables` (writes `window.MS_API_URL`).
- **Never mutate `.Values`** at render time (Helm 4). Prefer local dicts / `deepCopy` / `mergeOverwrite` on copies only.
- Schema: draft-07 with `#/definitions/...` refs only (**not** `$defs`).
- `README.md` is auto-generated — edit `values.yaml` `# --` comments + `README.md.gotmpl`, then `pre-commit run helm-docs --all-files` (or `pre-commit run --all-files`). Never hand-edit generated README body.
- Do **not** change `charts/rasa/` or `charts/op-kits/`.
- Out of scope: Keycloak default-on, image tag placeholder, orphan cleanup, AUTH_SECRET / SEED_USER docs, customer-clarity items 3–6 / 9–13, restructuring `eventIngestion` keys.
- Out-of-repo follow-up (document only, do not implement here): Pulumi stack `infrastructure/studio-ci-app/Pulumi.yaml` in the Studio repo must move `webClient:` → `app.webClient:`.

## Cross-links

| Doc | Path |
| --- | --- |
| Locked customer-clarity design | `docs/superpowers/specs/2026-08-07-studio-helm-customer-clarity-design.md` |
| Prior `backend` → `app` rename plan | `docs/superpowers/plans/2026-08-06-studio-helm-app-rename-implementation.md` |
| Prior rename design | `docs/superpowers/specs/2026-08-06-studio-helm-app-rename-design.md` |

---

## File structure map

| Path | Responsibility |
| --- | --- |
| `charts/studio/Chart.yaml` | Bump `3.0.0-rc.13` → `3.0.0-rc.14` |
| `charts/studio/values.yaml` | Nest `webClient` under `app`; fix `# --` for connectionType, MS_API_URL, eventIngestion mode applicability, web-client naming + mount path |
| `charts/studio/values.schema.json` | Move root `webClient` under `app.properties`; fix `connectionType` description |
| `charts/studio/templates/studio/app/configmap.yaml` | Read `.Values.app.webClient.environmentVariables` |
| `charts/studio/templates/studio/app/deployment.yaml` | Drop `MS_API_URL` `$defaults`; rename volume/volumeMount; update `mountPath` |
| `charts/studio/README.md.gotmpl` | Nest examples; remove app `MS_API_URL` guidance; SPA→web client; eventIngestion applicability; upgrade note |
| `charts/studio/NOTES.txt` | Add `webClient` → `app.webClient` to breaking-changes list |
| `charts/studio/README.md` | Regenerated via helm-docs only |

---

## Shared render / assert helpers

**Minimal required values** (repeat in verification commands):

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
```

**Assert helper:**

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

**Baseline smoke (before Task 1):**

```bash
helm lint --strict charts/studio
```

Expected: PASS on current `3.0.0-rc.13` tree (top-level `webClient` still present).

---

## Locked decisions (do not re-litigate)

| # | Decision |
| --- | --- |
| 1 | Nest values: top-level `webClient:` → `app.webClient:` (hard-break, no alias). |
| 2 | Drop Deployment default merge `MS_API_URL=http://rasapro`; remove app-env docs that tell customers to set `app.environmentVariables.MS_API_URL`. |
| 3 | Keep `MS_API_URL` under `app.webClient.environmentVariables` → `window.MS_API_URL`; default still `studio.modelServiceBaseUrl` when unset. |
| 4 | Volume/volumeMount name `spa-config` → `web-client-config`. |
| 5 | Mount path `/usr/src/app/spa/config.js` → `/usr/src/app/webclient/config.js`. |
| 6 | Prefer webClient / web-client / "web client"; avoid SPA/spa in chart-owned surfaces. |
| 7 | `eventIngestion` applicability: comments/README only — no values key restructure. |
| 8 | `config.connectionType` is external URL scheme only (not in-cluster service calls). |
| 9 | Chart version bump `3.0.0-rc.13` → `3.0.0-rc.14`. |
| 10 | ConfigMap name `studio-web-client-configmap` stays. |
| 11 | Pulumi `webClient:` → `app.webClient:` is out-of-repo follow-up. |

---

### Task 1: Values surface — nest `webClient`, fix comments

**Files:**
- Modify: `charts/studio/values.yaml`
- Test: `helm lint --strict charts/studio` (may fail schema until Task 2 if schema still expects root `webClient` — see note below)

**Interfaces:**
- Consumes: locked design nesting + comment wording
- Produces: `app.webClient.environmentVariables` (object, default `{}`); no top-level `webClient`

**Note on lint order:** `values.schema.json` still declares root `webClient` until Task 2. After Task 1 alone, `helm lint --strict` may warn/fail on schema vs defaults. Prefer completing Task 1 + Task 2 before treating lint as green, or run Tasks 1–2 in one sitting and lint after Task 2.

- [ ] **Step 1: Fix `config.connectionType` comment**

Replace the stale comment at `connectionType` (currently claims inter-service communication):

```yaml
  # -- Define the URL scheme (`http` or `https`) for externally derived URLs
  # (ingress-based API_URL, WEB_CLIENT_URL, web client API_ENDPOINT, model-service
  # public URLs, CORS_ORIGINS, etc.). Valid values: "http" or "https".
  # Does not change in-cluster http:// service-to-service calls.
  connectionType: "http"
```

- [ ] **Step 2: Soften SPA wording on `app.image.name`**

Replace:

```yaml
    # -- app.image.name is the unified Studio container image (API + SPA + optional co-located ingestion).
```

with:

```yaml
    # -- app.image.name is the unified Studio container image (API + web client + optional co-located ingestion).
```

- [ ] **Step 3: Remove dead app `MS_API_URL` documentation from `app.environmentVariables`**

Delete the three commented lines that document `app.environmentVariables.MS_API_URL` (the `# -- app.environmentVariables.MS_API_URL...` block and the `# MS_API_URL:` / `#   value: "http://rasapro"` lines). Keep `DELETE_CONVERSATIONS_*` entries. Leave a short note that model-service **browser** URL overrides belong under `app.webClient.environmentVariables.MS_API_URL`:

```yaml
  environmentVariables:
    # NOTE: Do not set MS_API_URL here — the Studio API process does not read it.
    # Override the browser model-service URL via app.webClient.environmentVariables.MS_API_URL.
    # -- app.environmentVariables.DELETE_CONVERSATIONS_OLDER_THAN_HOURS is the conversation data retention period in hours.
    # Conversations older than this value will be deleted by the cleanup cron job.
    # Leave empty to disable automatic conversation cleanup.
    # Ref: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
    DELETE_CONVERSATIONS_OLDER_THAN_HOURS:
      value: ""
```

- [ ] **Step 4: Move top-level `webClient` under `app` (after `app.affinity`)**

Delete the top-level block:

```yaml
# Studio SPA runtime config (no separate Deployment — unified app serves the UI).
webClient:
  # -- webClient.environmentVariables feeds the SPA config.js ConfigMap mounted at
  # /usr/src/app/spa/config.js on the app pod. Values are not secrets (ConfigMap only).
  # Used for feature flags (FEATURE_FLAG_*), MS_API_URL, CURRENT_VERSION_NUMBER, etc.
  # Breaking: web-client Deployment/Service/Ingress/image removed in chart 3.0.0.
  environmentVariables: {}
```

Insert under `app:` (immediately after `affinity: {}`, still indented as an `app` child):

```yaml
  # -- app.webClient holds browser runtime config for the unified app (no separate web-client Deployment).
  # config.js is mounted into the app pod at /usr/src/app/webclient/config.js.
  webClient:
    # -- app.webClient.environmentVariables feeds the web-client config.js ConfigMap mounted at
    # /usr/src/app/webclient/config.js on the app pod. Values are not secrets (ConfigMap only).
    # Used for feature flags (FEATURE_FLAG_*), MS_API_URL (window.MS_API_URL), CURRENT_VERSION_NUMBER, etc.
    # Breaking: nest under app.webClient (was top-level webClient). Web-client Deployment removed in chart 3.0.0.
    environmentVariables: {}
```

- [ ] **Step 5: Clarify `eventIngestion` mode applicability in `# --` comments**

Update the `eventIngestion` section header / `mode` comment and annotate workload-only keys. Exact wording to apply:

1. Expand the `mode` block comment:

```yaml
eventIngestion:
  # -- eventIngestion.mode controls event-ingestion topology.
  # colocated (default): ENABLE_EVENT_INGESTION=true on the app pod; no sibling Deployment.
  # separate: deploy {release}-app-ingestion with STUDIO_ROLE=ingestion; app sets ENABLE_EVENT_INGESTION=false.
  # disabled: neither co-located nor separate consumers.
  # Breaking: replaces eventIngestion.enabled. Do not set both semantics.
  #
  # Applicability:
  # - Both colocated and separate: Kafka-related keys under eventIngestion.environmentVariables
  #   (colocated injects them into the app Deployment; separate injects them into the ingestion Deployment).
  # - Only mode: separate: replicaCount, image, resources, serviceAccount, autoscaling/HPA,
  #   scheduling (nodeSelector / affinity / tolerations) for the sibling Deployment.
  # - volumes / volumeMounts / envFrom / additionalContainers: applied to the app pod when
  #   colocated, and to the sibling Deployment when separate.
  mode: colocated
```

2. Prefix workload-only key comments with `(mode: separate only)` where they currently lack that hint — at minimum `replicaCount`, `image`, `serviceAccount`, and (if present as top comments) `resources` / `autoscaling` / `nodeSelector` / `affinity` / `tolerations`. Example:

```yaml
  # -- eventIngestion.replicaCount is the number of replicas for the Event Ingestion deployment.
  # Applies only when eventIngestion.mode is separate.
  replicaCount: 1
```

Do **not** nest Kafka env under a new object and do **not** split the schema by mode.

- [ ] **Step 6: Spot-check values file for leftover customer-facing SPA/spa on this feature**

```bash
rg -n 'SPA|/usr/src/app/spa|spa-config|^webClient:' charts/studio/values.yaml
```

Expected: no matches for those patterns on the web-client feature (image comment should say "web client"; nested `app.webClient` only).

- [ ] **Step 7: Commit**

```bash
git add charts/studio/values.yaml
git commit -m "$(cat <<'EOF'
refactor(studio)!: nest webClient under app and clarify values comments

EOF
)"
```

---

### Task 2: Schema — nest `webClient` under `app`; fix `connectionType`

**Files:**
- Modify: `charts/studio/values.schema.json`
- Test: `helm lint --strict charts/studio`

**Interfaces:**
- Consumes: `app.webClient` from Task 1 defaults
- Produces: schema validates nested `app.webClient`; root `webClient` removed

- [ ] **Step 1: Fix `config.connectionType` description**

Replace:

```json
        "connectionType": {
          "description": "URL scheme for internal service-to-service communication",
          "type": "string",
          "enum": ["http", "https"]
        },
```

with:

```json
        "connectionType": {
          "description": "URL scheme (http or https) for externally derived URLs; does not change in-cluster service-to-service calls",
          "type": "string",
          "enum": ["http", "https"]
        },
```

- [ ] **Step 2: Move `webClient` property under `app.properties`**

Inside the `"app"` object's `"properties"`, after `"tolerations"` (still inside `properties`), add:

```json
        "webClient": {
          "description": "Browser runtime configuration for the unified Studio app (config.js mounted on the app pod)",
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

Delete the root-level `"webClient": { ... }` property block that currently sits as a sibling of `"app"` / `"eventIngestion"`.

Keep draft-07 `#/definitions/...` style; do not introduce `$defs`.

- [ ] **Step 3: Lint**

```bash
helm lint --strict charts/studio
```

Expected: PASS (defaults satisfy nested schema).

- [ ] **Step 4: Commit**

```bash
git add charts/studio/values.schema.json
git commit -m "$(cat <<'EOF'
fix(studio): nest webClient in schema and fix connectionType description

EOF
)"
```

---

### Task 3: ConfigMap — read `app.webClient`

**Files:**
- Modify: `charts/studio/templates/studio/app/configmap.yaml`
- Test: `helm template` asserts below

**Interfaces:**
- Consumes: `.Values.app.webClient.environmentVariables`
- Produces: same `window.*` ConfigMap data; override path for `MS_API_URL` is nested

- [ ] **Step 1: Replace every `.Values.webClient` with `.Values.app.webClient`**

Final file content:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: studio-web-client-configmap
data:
  windowVariables: |
    window.API_ENDPOINT = "{{ .Values.config.connectionType }}://{{ include "studio.appHost" . }}/api";
    {{- with .Values.app.webClient.environmentVariables.MS_API_URL }}
    window.MS_API_URL = {{ . | quote }};
    {{- else }}
    window.MS_API_URL = "{{ include "studio.modelServiceBaseUrl" . }}";
    {{- end }}
    {{- range $key, $value := .Values.app.webClient.environmentVariables }}
    {{- if hasPrefix "FEATURE_FLAG_" $key }}
    window.{{ $key }} = {{ if kindIs "map" $value }}{{ ($value.value | default "false") | quote }}{{ else }}{{ $value | quote }}{{ end }};
    {{- end }}
    {{- end }}
    window.VOICE_INSPECTOR_ENABLED = {{ .Values.app.webClient.environmentVariables.VOICE_INSPECTOR_ENABLED | quote | default "false" }};
    window.SILENCE_TIMEOUT_ENABLED = {{ .Values.app.webClient.environmentVariables.SILENCE_TIMEOUT_ENABLED | quote | default "false" }};
    window.EDIT_SYSTEM_RESPONSES_ENABLED = {{ .Values.app.webClient.environmentVariables.EDIT_SYSTEM_RESPONSES_ENABLED | quote | default "false" }};
    {{- with .Values.app.webClient.environmentVariables.CURRENT_VERSION_NUMBER }}
    window.CURRENT_VERSION_NUMBER = {{ . | quote | trim }};
    {{- else }}
    window.CURRENT_VERSION_NUMBER = {{ .Values.tag | quote | trim }};
    {{- end }}
```

Keep resource name `studio-web-client-configmap`.

- [ ] **Step 2: Render without override — default `window.MS_API_URL`**

```bash
mkdir -p /tmp/studio-clarity
helm template clarity ./charts/studio "${RENDER_BASE[@]}" \
  --output-dir /tmp/studio-clarity/default
assert_render /tmp/studio-clarity/default/studio/templates/studio/app/configmap.yaml \
  'window.MS_API_URL' present
# Default uses studio.modelServiceBaseUrl helper output (http://… host), not a literal empty string
rg -n 'window.MS_API_URL' /tmp/studio-clarity/default/studio/templates/studio/app/configmap.yaml
```

Expected: `window.MS_API_URL` present and derived from connectionType + model service host (not from a customer override).

- [ ] **Step 3: Render with nested override**

```bash
helm template clarity ./charts/studio "${RENDER_BASE[@]}" \
  --set app.webClient.environmentVariables.MS_API_URL=https://studio.example.com \
  --output-dir /tmp/studio-clarity/override
assert_render /tmp/studio-clarity/override/studio/templates/studio/app/configmap.yaml \
  'window.MS_API_URL = "https://studio.example.com"' present
```

Expected: PASS (override present).

- [ ] **Step 4: Confirm top-level `webClient` has no effect**

```bash
helm template clarity ./charts/studio "${RENDER_BASE[@]}" \
  --set-string webClient.environmentVariables.MS_API_URL=https://should-not-appear.example.com \
  --output-dir /tmp/studio-clarity/toplevel 2>/dev/null || true
# If schema rejects unknown root webClient, that is also acceptable (hard-break).
# If render succeeds, assert the bogus URL is absent:
if [[ -f /tmp/studio-clarity/toplevel/studio/templates/studio/app/configmap.yaml ]]; then
  assert_render /tmp/studio-clarity/toplevel/studio/templates/studio/app/configmap.yaml \
    'should-not-appear' absent
fi
```

- [ ] **Step 5: Commit**

```bash
git add charts/studio/templates/studio/app/configmap.yaml
git commit -m "$(cat <<'EOF'
refactor(studio)!: read app.webClient in web-client ConfigMap

EOF
)"
```

---

### Task 4: Deployment — drop dead `MS_API_URL` default; rename volume + mount path

**Files:**
- Modify: `charts/studio/templates/studio/app/deployment.yaml`
- Test: `helm template` asserts below

**Interfaces:**
- Consumes: `.Values.app.environmentVariables` only (no `$defaults` merge for `MS_API_URL`)
- Produces: volume/volumeMount name `web-client-config`; `mountPath: /usr/src/app/webclient/config.js`

- [ ] **Step 1: Replace the `MS_API_URL` defaults merge with a direct range**

Replace:

```yaml
            {{- $defaults := dict "MS_API_URL" (dict "value" "http://rasapro") }}
            {{- $env := mergeOverwrite $defaults .Values.app.environmentVariables }}
            {{- range $key, $value := $env }}
            - name: {{ $key | upper }}
              {{- if $value.value }}
              value: {{ $value.value | quote }}
              {{- else if $value.secret }}
              valueFrom:
                secretKeyRef:
                  name: {{ $value.secret.name }}
                  key: {{ $value.secret.key }}
              {{- end }}
            {{- end }}
```

with:

```yaml
            {{- range $key, $value := .Values.app.environmentVariables }}
            - name: {{ $key | upper }}
              {{- if $value.value }}
              value: {{ $value.value | quote }}
              {{- else if $value.secret }}
              valueFrom:
                secretKeyRef:
                  name: {{ $value.secret.name }}
                  key: {{ $value.secret.key }}
              {{- end }}
            {{- end }}
```

Do **not** mutate `.Values`. Do **not** reintroduce a defaults dict for `MS_API_URL`.

- [ ] **Step 2: Rename volumeMount and volume; update mountPath**

Replace volumeMount:

```yaml
          volumeMounts:
            - name: web-client-config
              mountPath: /usr/src/app/webclient/config.js
              subPath: config.js
              readOnly: true
```

Replace volume:

```yaml
      volumes:
        - name: web-client-config
          configMap:
            name: studio-web-client-configmap
            items:
              - key: windowVariables
                path: config.js
```

- [ ] **Step 3: Render and assert Deployment env + mount**

```bash
helm template clarity ./charts/studio "${RENDER_BASE[@]}" \
  --output-dir /tmp/studio-clarity/deploy
DEP=/tmp/studio-clarity/deploy/studio/templates/studio/app/deployment.yaml

assert_render "$DEP" 'name: MS_API_URL' absent
assert_render "$DEP" 'http://rasapro' absent
assert_render "$DEP" 'name: spa-config' absent
assert_render "$DEP" '/usr/src/app/spa/config.js' absent
assert_render "$DEP" 'name: web-client-config' present
assert_render "$DEP" 'mountPath: /usr/src/app/webclient/config.js' present
assert_render "$DEP" 'name: studio-web-client-configmap' present
```

Expected: all asserts PASS.

- [ ] **Step 4: Commit**

```bash
git add charts/studio/templates/studio/app/deployment.yaml
git commit -m "$(cat <<'EOF'
fix(studio): drop app MS_API_URL default and rename web-client config mount

EOF
)"
```

---

### Task 5: Docs — README gotmpl + NOTES

**Files:**
- Modify: `charts/studio/README.md.gotmpl`
- Modify: `charts/studio/NOTES.txt`
- Test: visual/rg spot-check (helm-docs runs in Task 6)

**Interfaces:**
- Consumes: nested `app.webClient` examples; no app-container `MS_API_URL` guidance
- Produces: customer docs aligned with locked design

- [ ] **Step 1: Architecture intro — SPA → web client**

In `README.md.gotmpl`:

Replace:

```markdown
The Studio chart deploys a unified Studio image. The app serves both the API and SPA; all components share a single `ingressHost` and the `studio-secrets` Kubernetes Secret.
```

with:

```markdown
The Studio chart deploys a unified Studio image. The app serves both the API and the web client; all components share a single `ingressHost` and the `studio-secrets` Kubernetes Secret.
```

Replace the app row description `Studio API server and SPA` with `Studio API server and web client`.

- [ ] **Step 2: Remove app `MS_API_URL` example; nest web client override**

Replace the block under `When rasa.enabled: false`:

```yaml
When `rasa.enabled: false`, point Studio App at your own Rasa Pro instance:

```yaml
app:
  environmentVariables:
    MS_API_URL:
      value: "http://your-rasa-pro-service"
```

Override the web client model service URL when using an external instance or a custom ingress host:

```yaml
webClient:
  environmentVariables:
    MS_API_URL: "https://studio.example.com"
```
```

with:

```markdown
When `rasa.enabled: false`, override the **browser** model-service URL via the web client ConfigMap (the Studio API process does not read `MS_API_URL`):

```yaml
app:
  webClient:
    environmentVariables:
      MS_API_URL: "https://studio.example.com"
```
```

Keep the bullet that says the chart sets `window.MS_API_URL` on the web client from the model service external host.

- [ ] **Step 3: `connectionType` section — SPA → web client**

Replace:

```markdown
- the app-served SPA's `API_ENDPOINT`
```

with:

```markdown
- the app-served web client's `API_ENDPOINT`
```

(README body already correctly states external scheme only — leave that truth; values/schema were the stale surfaces fixed in Tasks 1–2.)

- [ ] **Step 4: Event Ingestion section — mode applicability**

After the mode paragraph (or expand it), add explicit applicability:

```markdown
Set `eventIngestion.mode` to `colocated` (default), `separate`, or `disabled`. `colocated` runs the consumer in the app pod; `separate` deploys a dedicated workload. Do not run dual consumers—the chart fails validation when configuration would do so. To disable event ingestion entirely, use `eventIngestion.mode: disabled`.

**Which keys apply when:**

| Applies when | Keys |
| --- | --- |
| Both `colocated` and `separate` | Kafka-related env under `eventIngestion.environmentVariables` |
| Only `mode: separate` | `replicaCount`, `image`, `resources`, `serviceAccount`, HPA/`autoscaling`, scheduling (`nodeSelector` / `affinity` / `tolerations`) |
| `colocated` (on app) and `separate` (on sibling) | `volumes`, `volumeMounts`, `envFrom`, `additionalContainers` |
```

- [ ] **Step 5: Upgrade notes for chart 3.0.0**

Replace the upgrade paragraph that mentions SPA / top-level `webClient` with:

```markdown
### Upgrading to chart 3.0.0

Chart 3.0.0 is a hard break: rename `backend` values to `app`; it uses the unified `studio` image and requires Studio ≥ 2.0.0. The default image tag is a placeholder until a published unified image is promoted. Configure web client runtime values under `app.webClient.environmentVariables` (was top-level `webClient.environmentVariables`). Do not set `MS_API_URL` on `app.environmentVariables` — only `app.webClient.environmentVariables.MS_API_URL` affects `window.MS_API_URL`.

```yaml
# Before
webClient:
  environmentVariables:
    MS_API_URL: "https://studio.example.com"

# After
app:
  webClient:
    environmentVariables:
      MS_API_URL: "https://studio.example.com"
```
```

Keep the existing Better Auth / Keycloak / `eventIngestion.mode` / orphan-cleanup sentences that follow.

- [ ] **Step 6: NOTES.txt — add breaking values move**

Under section `2. Breaking changes in chart 3.0.0:`, add a bullet:

```text
   - Values key `webClient` is now nested under `app.webClient`.
   - Do not set app container env `MS_API_URL`; use `app.webClient.environmentVariables.MS_API_URL`
     for the browser model-service URL (`window.MS_API_URL`).
```

- [ ] **Step 7: Spot-check gotmpl / NOTES for SPA / top-level webClient guidance**

```bash
rg -n 'SPA|webClient\.environmentVariables|app\.environmentVariables\.MS_API_URL|/usr/src/app/spa' \
  charts/studio/README.md.gotmpl charts/studio/NOTES.txt
```

Expected: no SPA; no top-level `webClient.environmentVariables` as the recommended path; no app-env `MS_API_URL` guidance. Nested `app.webClient` examples OK.

- [ ] **Step 8: Commit**

```bash
git add charts/studio/README.md.gotmpl charts/studio/NOTES.txt
git commit -m "$(cat <<'EOF'
docs(studio): nest webClient examples and clarify MS_API_URL / eventIngestion

EOF
)"
```

---

### Task 6: Version bump, helm-docs, lint, final verification

**Files:**
- Modify: `charts/studio/Chart.yaml`
- Modify: `charts/studio/README.md` (via helm-docs / pre-commit only)
- Test: full verification checklist below

**Interfaces:**
- Consumes: all prior task outputs
- Produces: releasable `3.0.0-rc.14` chart surface

- [ ] **Step 1: Bump chart version**

In `charts/studio/Chart.yaml`:

```yaml
version: 3.0.0-rc.14
```

- [ ] **Step 2: Regenerate README and run pre-commit**

```bash
pre-commit run helm-docs --all-files
# Prefer full hooks before finishing:
pre-commit run --all-files
```

Expected: `charts/studio/README.md` updates (version badge + values table reflecting `app.webClient.*` and fixed `config.connectionType` description). Commit any auto-fixed EOL / README churn with the version bump.

- [ ] **Step 3: Strict lint**

```bash
helm lint --strict charts/studio
```

Expected: PASS.

- [ ] **Step 4: Full template verification matrix**

```bash
rm -rf /tmp/studio-clarity-final
helm template clarity ./charts/studio "${RENDER_BASE[@]}" \
  --output-dir /tmp/studio-clarity-final/base

helm template clarity ./charts/studio "${RENDER_BASE[@]}" \
  --set app.webClient.environmentVariables.MS_API_URL=https://studio.example.com \
  --output-dir /tmp/studio-clarity-final/override

CM=/tmp/studio-clarity-final/base/studio/templates/studio/app/configmap.yaml
CMO=/tmp/studio-clarity-final/override/studio/templates/studio/app/configmap.yaml
DEP=/tmp/studio-clarity-final/base/studio/templates/studio/app/deployment.yaml

assert_render "$DEP" 'name: MS_API_URL' absent
assert_render "$DEP" 'name: web-client-config' present
assert_render "$DEP" 'mountPath: /usr/src/app/webclient/config.js' present
assert_render "$DEP" 'spa-config' absent
assert_render "$CM" 'window.MS_API_URL' present
assert_render "$CMO" 'window.MS_API_URL = "https://studio.example.com"' present

# Templates must not reference top-level .Values.webClient
rg -n '\.Values\.webClient' charts/studio/templates && echo 'FAIL: leftover .Values.webClient' && exit 1 || echo 'OK: no .Values.webClient'

# Customer-facing SPA/spa leftovers for this feature
rg -n 'SPA|/usr/src/app/spa|spa-config' charts/studio/values.yaml charts/studio/README.md.gotmpl \
  charts/studio/templates/studio/app/deployment.yaml charts/studio/NOTES.txt \
  && echo 'FAIL: SPA leftovers' && exit 1 || echo 'OK: no SPA leftovers'
```

Expected: all asserts OK.

- [ ] **Step 5: Commit**

```bash
git add charts/studio/Chart.yaml charts/studio/README.md
git commit -m "$(cat <<'EOF'
chore(studio): bump version to 3.0.0-rc.14

EOF
)"
```

If pre-commit modified other allowed files (EOL), include them in the same commit.

---

## Out-of-repo follow-up (do not implement in this repo)

When consumers adopt chart `3.0.0-rc.14+`, update Studio Pulumi stack:

- Repo: Studio product repo (not `helm-packaging`)
- File: `infrastructure/studio-ci-app/Pulumi.yaml`
- Change: `webClient:` → `app.webClient:` (and drop any `app.environmentVariables.MS_API_URL` if present)

Track as a separate PR in that repo.

---

## Self-review (plan author)

| Spec requirement | Task |
| --- | --- |
| Nest `webClient` → `app.webClient` (values/schema/templates/docs) | 1, 2, 3, 5 |
| Drop app Deployment `MS_API_URL` default + app-env docs | 1, 4, 5 |
| Keep web client `MS_API_URL` / `studio.modelServiceBaseUrl` | 3, 5 |
| eventIngestion applicability comments only | 1, 5 |
| Fix `connectionType` comment (+ schema) | 1, 2 |
| Prefer webClient naming over SPA | 1, 4, 5, 6 |
| Volume `spa-config` → `web-client-config` | 4 |
| Mount path → `/usr/src/app/webclient/config.js` | 4 |
| Chart version rc bump | 6 |
| Pulumi follow-up documented | Out-of-repo section |
| Helm 4: never mutate `.Values` | Global + Task 4 |

No placeholders remaining. Property path `app.webClient.environmentVariables` is consistent across tasks.

---

## Success criteria

- Customer values nest web client under `app.webClient` only.
- App Deployment has no default `MS_API_URL=http://rasapro`.
- Docs do not tell customers to set `app.environmentVariables.MS_API_URL`.
- Volume `web-client-config` mounts at `/usr/src/app/webclient/config.js`.
- Chart-owned prose prefers web client naming; no SPA path/volume leftovers for this feature.
- `connectionType` and `eventIngestion` comments match actual behavior.
- `helm lint --strict charts/studio` passes at `3.0.0-rc.14`.
