# Studio Helm Chart — Customer Clarity Fixes (3.0.0-rc)

**Date:** 2026-08-07  
**Status:** Amended (awaiting re-approval) — customer-clarity items 1, 2, 7, 8 + webClient naming  
**Scope:** `charts/studio` docs/values clarity + small template cleanups; implementation follows a separate plan  
**Related:** `docs/superpowers/specs/2026-08-06-studio-helm-app-rename-design.md`

## Context

Chart 3.0 already renamed `backend` → `app` and removed the nginx web-client Deployment. Customers configuring Studio via Helm alone still hit four confusion points that internal Pulumi overlays obscure:

1. Web client overrides live under a top-level `webClient:` key that looks like a separate component (it is not).
2. Dead / misleading `MS_API_URL` guidance on the **app** container env — Studio API process does not read `MS_API_URL`; only the web client uses `window.MS_API_URL`.
7. `eventIngestion.*` values look uniformly applicable, but workload knobs only apply when `mode: separate`.
8. Stale `config.connectionType` `# --` comment claims it affects inter-service communication; README already correctly says external URL scheme only.

This doc locks the approved fixes so the implementation plan does not re-litigate them.

## Goals

- Make web client config obviously belong to the unified `app` component.
- Prefer **webClient** / **web client** / **web-client** naming everywhere we control identifiers or prose — avoid "SPA" / "spa" in values, docs, comments, and chart-owned K8s names.
- Remove dead app-container `MS_API_URL` default and stop documenting it as an app env override.
- Clarify (docs/comments only) which `eventIngestion` keys apply in colocated vs separate mode.
- Align `config.connectionType` values comment with README truth.

## Non-goals

- Keycloak default-on, image tag placeholder, orphan cleanup.
- AUTH_SECRET / SEED_USER docs beyond incidental mentions.
- Other customer-clarity items 3–6 / 9–13.
- Restructuring `eventIngestion` values keys or nesting Kafka under a sub-object.
- Implementing chart changes in this doc (plan + implement separately).
- Changing `charts/rasa` or `charts/op-kits`.
- Changing container filesystem paths that the Studio image hard-codes (see naming decision exception below).

## Locked decisions

### Naming: prefer `webClient` / web client — not SPA

| Layer | Convention |
| --- | --- |
| Customer-facing docs / README / `# --` comments | "web client" (prose); values paths `app.webClient` |
| Values key | `app.webClient` (camelCase; already the values key name) |
| Chart-owned Helm/K8s identifiers we control | Prefer `web-client` style (e.g. volume/volumeMount name `spa-config` → `web-client-config`) |
| Avoid | "SPA" / "spa" in prose, comments, and chart-owned resource/volume names |

**Exception (image-bound — do not rename):** The Studio unified container image expects the runtime config file at `/usr/src/app/spa/config.js`. That **mountPath stays unchanged** unless the Studio image is verified to support another path. The volume/volumeMount **name** is chart-owned and should become `web-client-config`; only the filesystem path under `/usr/src/app/spa/` is constrained by the image.

Historical note: older chart/docs used "SPA" for the browser UI; that term is retired in this chart's docs and identifiers.

### 1. Nest web client config: `webClient` → `app.webClient`

| Surface | From | To |
| --- | --- | --- |
| Values key | top-level `webClient:` | `app.webClient:` |
| ConfigMap template refs | `.Values.webClient.environmentVariables` | `.Values.app.webClient.environmentVariables` |
| Schema | root `webClient` property | nested under `app.properties.webClient` |
| README / `# --` / upgrade notes | `webClient.environmentVariables` | `app.webClient.environmentVariables` |
| Volume / volumeMount name (chart-owned) | `spa-config` | `web-client-config` |
| Mount path (image-bound) | `/usr/src/app/spa/config.js` | **unchanged** |

Rationale: there is no separate web-client workload; `config.js` is mounted on the app pod. Nesting under `app` matches the unified process and stops customers hunting for a removed component. Using webClient naming end-to-end avoids implying a separate SPA product surface.

**Upgrade:** Hard-break — no Helm alias from top-level `webClient:` → `app.webClient:`. Document values translation in README upgrade notes (alongside existing `backend` → `app` migration). Renaming the volume name is internal to the chart (no customer values change).

### 2. Drop dead app-container `MS_API_URL`; keep web client `MS_API_URL`

| Change | Detail |
| --- | --- |
| Remove | Hardcoded default merge in `templates/studio/app/deployment.yaml`: `dict "MS_API_URL" (dict "value" "http://rasapro")` |
| Remove | Commented / documented `app.environmentVariables.MS_API_URL` guidance in `values.yaml` and README examples that set app env `MS_API_URL` for Rasa Pro |
| Keep | Web client override key name `MS_API_URL` under `app.webClient.environmentVariables` — still writes `window.MS_API_URL` in the web-client ConfigMap |
| Keep | Default `window.MS_API_URL` derivation via `studio.modelServiceBaseUrl` when the web client override is unset |

**Evidence:** Studio API (`backend/config.ts` in the Studio product repo) does not read `MS_API_URL`; only the web client reads `window.MS_API_URL`.

Customers who need a custom model-service browser URL set:

```yaml
app:
  webClient:
    environmentVariables:
      MS_API_URL: "https://studio.example.com"
```

In-cluster app → Rasa Pro calls continue to use existing hardcoded / other env paths (not this dead key).

### 7. eventIngestion docs only — no values restructure

Clarify in `values.yaml` `# --` comments and README that:

| Applies when | Keys |
| --- | --- |
| **Both** `colocated` and `separate` | Kafka-related env under `eventIngestion.environmentVariables` (and colocated path that already injects those into the app Deployment) |
| **Only** `mode: separate` | `replicaCount`, `image`, `resources`, `serviceAccount`, HPA/`autoscaling`, scheduling (`nodeSelector` / `affinity` / `tolerations`), separate Deployment volumes/volumeMounts/additionalContainers, etc. |

Do **not** move Kafka env under a new nested object or split values schemas by mode. Comments + README wording only.

### 8. Fix stale `config.connectionType` comment

Update the `values.yaml` `# --` comment (and schema description if still wrong) to match README:

- `connectionType` is the scheme (`http` / `https`) for **externally derived** URLs (ingress-based `API_URL`, `WEB_CLIENT_URL`, web client `API_ENDPOINT`, model-service public URLs, `CORS_ORIGINS`, etc.).
- It does **not** change in-cluster `http://` service-to-service calls.

## Change surface (implementation)

| File | Change |
| --- | --- |
| `charts/studio/values.yaml` | Move `webClient:` under `app:`; replace SPA wording in `# --` with web client; document mount path constraint (`/usr/src/app/spa/config.js`) without calling the feature "SPA"; fix `connectionType` comment; remove app `MS_API_URL` docs; clarify eventIngestion applicability comments |
| `charts/studio/values.schema.json` | Nest `webClient` under `app`; fix `connectionType` description |
| `charts/studio/templates/studio/app/configmap.yaml` | `.Values.webClient.*` → `.Values.app.webClient.*` |
| `charts/studio/templates/studio/app/deployment.yaml` | Drop `MS_API_URL` default dict merge; range `app.environmentVariables` only; rename volume/volumeMount `spa-config` → `web-client-config`; **keep** `mountPath: /usr/src/app/spa/config.js` |
| `charts/studio/README.md.gotmpl` | Nest examples; remove app `MS_API_URL` guidance; web client override under `app.webClient`; replace SPA prose with web client; eventIngestion applicability; upgrade note `webClient` → `app.webClient` |
| `charts/studio/NOTES.txt` | Only if it mentions `webClient` / app `MS_API_URL` / SPA; touch only if needed for upgrade hints |
| Helpers | No new helpers expected; existing `studio.modelServiceBaseUrl` / `studio.webClientUrl` stay (names are URL helpers, not values keys) |

Generated `README.md` updates via helm-docs / pre-commit after values comment edits.

ConfigMap resource name `studio-web-client-configmap` already matches the preferred naming — leave as-is.

## Migration note (chart 3.0)

```yaml
# Before (top-level webClient bag)
webClient:
  environmentVariables:
    MS_API_URL: "https://studio.example.com"
    FEATURE_FLAG_FOO: "true"

# After
app:
  webClient:
    environmentVariables:
      MS_API_URL: "https://studio.example.com"
      FEATURE_FLAG_FOO: "true"
```

Also remove any `app.environmentVariables.MS_API_URL` (or former `backend.environmentVariables.MS_API_URL`) — it was never consumed by the Studio API process.

## Verification

- `helm lint --strict charts/studio`
- Template sanity: with/without `app.webClient.environmentVariables.MS_API_URL`, confirm ConfigMap emits `window.MS_API_URL` (override vs `studio.modelServiceBaseUrl` default)
- Confirm app Deployment env list has **no** default `MS_API_URL=http://rasapro`
- Confirm templates only read `app.webClient` (top-level `webClient` has no effect); schema declares `webClient` under `app` only
- Confirm volume/volumeMount name is `web-client-config` and mountPath remains `/usr/src/app/spa/config.js`
- Spot-check README/values comments: no customer-facing "SPA"/"spa" for this feature; connectionType and eventIngestion mode applicability correct

## Out-of-repo follow-up (document only)

`studio` repo Pulumi stack `infrastructure/studio-ci-app/Pulumi.yaml` must move `webClient:` → `app.webClient:` when consuming chart 3.0. Do **not** implement that change in this Helm repo.

## Success criteria

- Implementers treat nesting + webClient naming cleanup + MS_API_URL cleanup + comment fixes as one small clarity PR (or plan tasks), without reopening scope.
- Customer Helm values show web client config under `app.webClient` only.
- Chart-owned identifiers and docs prefer webClient / web-client / "web client"; image mount path under `/usr/src/app/spa/` remains as required by the container.
- No documented path suggests setting `MS_API_URL` on the app container.
- eventIngestion comment surface states colocated vs separate applicability without a values restructure.
- `connectionType` values comment matches README: external scheme only.
