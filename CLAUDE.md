# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Helm charts for deploying Rasa products on Kubernetes (chart versions live in each `Chart.yaml`, not here — they drift):
- **`charts/studio/`** - Rasa Studio (chart 3.x): unified `app` Deployment (API + web client in one `studio` image, Better Auth at `/api/auth/*`), event ingestion via `eventIngestion.mode` (`colocated` | `separate` | `disabled`), and optional `rasa` OCI subchart (`rasa.enabled`).
- **`charts/rasa/`** - Rasa Pro: main Rasa Pro server, action-server, duckling, rasa-pro-services
- **`charts/op-kits/`** - Operator Kits: thin CRD-wrapper chart that creates custom resources for PostgreSQL (CloudNativePG), Kafka (Strimzi), and Valkey. The operators themselves must be **pre-installed** in the cluster — this chart only emits CRs (`postgresql.cnpg.io/v1`, `kafka.strimzi.io/v1`, `hyperspike.io/v1`), gated by `<component>.enabled` flags.

## Commands

### Lint and Template

```bash
# Lint a specific chart (strict mode)
helm lint --strict charts/<CHART>

# Lint only changed charts (CI-style)
ct lint --config ct.yaml

# List changed charts
ct list-changed --config ct.yaml

# Generate templates (for debugging/inspection)
# Pass --kube-version to make output deterministic across Helm versions (CI uses 1.29.0)
helm template ./charts/<CHART> --output-dir ./output --kube-version 1.29.0
```

### Dependencies

```bash
# Build dependencies after modifying Chart.yaml
helm dependency build ./charts/studio
helm dependency build ./charts/rasa
helm dependency build ./charts/op-kits
```

### Documentation (pre-commit)

```bash
# Run all pre-commit hooks (fixes EOL, regenerates README.md files)
pre-commit run --all-files

# Regenerate README.md files only
pre-commit run helm-docs --all-files
```

## Before Every Commit

1. Increment `version` in `charts/<CHART>/Chart.yaml` (required by CI)
2. Run `helm lint --strict charts/<CHART>`
3. Run `pre-commit run --all-files`
4. Commit the auto-generated `README.md` alongside your changes

## Key Conventions

### Values Documentation
Use `# --` prefix for comments that should appear in the auto-generated README:
```yaml
# -- Enable or disable this component
enabled: false
```
Never manually edit `README.md` — always edit `README.md.gotmpl` and `values.yaml` comments instead.

### Values Schema (`values.schema.json`)
Both `charts/studio/` and `charts/rasa/` ship a `values.schema.json` that validates user-supplied values at `helm install`/`helm upgrade` time (op-kits has none). Key patterns validated:
- `config.connectionType`: enum `["http", "https"]`
- `imagePullPolicy`: enum `["Always", "IfNotPresent", "Never"]`
- Secret references: object with required `secretName` + `secretKey` (see `definitions.secretRef`) — includes Studio `app.authSecret`
- Dual-type fields (string or secret ref): use `definitions.secretRefOrString`
- Component toggles (`enabled`): boolean
- Studio `eventIngestion.mode`: `colocated` | `separate` | `disabled` (enforced in templates as well as schema)

Both schemas declare draft-07 and use the `definitions` keyword with `#/definitions/...` refs (NOT `$defs`, which is a draft-2019-09 keyword — Helm 4's stricter validator can silently skip `$defs` refs under a draft-07 declaration). Keep new `$ref`s pointing at `#/definitions/...`.

When adding new values to a chart that ships a schema, update `values.schema.json` accordingly. `helm lint --strict` validates the schema against default values, so defaults must satisfy the schema.

### Chart Version Bumps
- Patch (`1.3.2` → `1.3.3`): bug fixes
- Minor (`1.3.2` → `1.4.0`): new features
- Major (`1.3.2` → `2.0.0`): breaking changes

### Release Branch Versioning (`release/*`)
On `release/` branches, increment the version once and append `-rc.X`:
- Start: `2.0.2` → `2.0.3-rc.0`
- Each subsequent push: increment the rc counter (`-rc.1`, `-rc.2`, …)
- Before merging to `main`: remove the `-rc.X` suffix so the final version is `2.0.3`

CI blocks `-rc` suffixes on `main`.

### Secret References Pattern
```yaml
password:
  secretName: "my-secrets"
  secretKey: "SECRET_KEY"
```

### Component Enablement
Most components use `<component>.enabled` flags. Studio specifics:
- `rasa.enabled` — optional Rasa Pro OCI subchart
- `eventIngestion.mode` — `colocated` (default; consumers on the app pod), `separate` (sibling `{release}-app-ingestion` Deployment), or `disabled`. **`eventIngestion.enabled` was removed** — templates fail if it is set.

## Architecture Notes

- Each chart's `_helpers.tpl` defines naming helpers (`fullname`, `labels`, `selectorLabels`, `serviceAccountName`, `image`). Studio's is at `templates/_helpers.tpl`; rasa's is at `templates/helpers/_helpers.tpl`.
- Studio templates live under `templates/studio/{app,event-ingestion}/`. There is **no** separate web-client Deployment — browser config is `app.webClient.environmentVariables` → ConfigMap mounted at `/usr/src/app/webclient/config.js` on the app pod.
- Studio env helpers are in `templates/studio/_env.tpl`: `studio.app.env`. App auth uses `app.authSecret` → `AUTH_SECRET` / `BETTER_AUTH_BASE_URL` on the app Deployment.
- Top-level `repository` + `tag` feed the unified Studio image; `app.image.name` / `eventIngestion.image.name` default to `studio` (chart 3.0 requires Studio ≥ 2.0.0). Formerly `backend` / `studio-backend`.
- `templates/shared-env-configmap.yaml` emits shared `CORS_ORIGINS` and model-service URL for in-cluster consumers.
- Network policies follow a default-deny pattern: each chart includes `deny-all.yaml`, `allow-dns-access.yaml`, and `ingress-egress-from-kubelet.yaml` (rasa adds `allow-egress-http-https.yaml`). All hardcode `apiVersion: networking.k8s.io/v1`.
- `README.md` files are auto-generated by helm-docs using `README.md.gotmpl` + `values.yaml` `# --` comments
- Studio's `Chart.lock` locks its Rasa dependency to a specific OCI version — run `helm dependency build` after any dependency changes
- Studio and rasa ship `values.schema.json` for input validation — `helm lint` enforces it automatically; update the schema when adding new values (include `app.authSecret` / `eventIngestion.mode` patterns as needed)
- Studio's database migration runs as a `pre-install,pre-upgrade` Helm hook Job with `hook-delete-policy: before-hook-creation,hook-succeeded` — failed jobs persist for debugging and are cleaned up automatically before the next upgrade

## Helm 4 Compatibility

Charts must lint and render cleanly under **both Helm 3 and Helm 4**. CI enforces this: `lint.yml` runs a `lint` job (Helm 3.15.2 via `ct lint`) and a parallel `lint-helm4` job (Helm 4.2.0 via `helm lint --strict`) on every PR. When writing or editing templates:

- **Never mutate `.Values`.** Helm 4 makes `.Values` read-only at render time, so `{{- $_ := set .Values.foo ... }}` breaks. Build a local dict (`merge`/`deepCopy`) instead.
- **Don't branch on `.Capabilities.KubeVersion` for API versions.** All supported clusters are ≥1.19; ingress templates hardcode `networking.k8s.io/v1` with `pathType` and the `service:`/`port:` backend form. The old `extensions/v1beta1` / `networking.k8s.io/v1beta1` fallbacks were removed.
- **Prefer `deepCopy` over `toYaml | fromYaml`** for deep-copying a values map before `merge`.
- **`helm registry login` takes a domain only in Helm 4** (no `https://` prefix). The OCI release action (`.github/actions/release-helm-charts-oci`) still passes a full URL and is pinned to Helm 3.15.2 — it must be updated before that action moves to Helm 4.

## CI / Release Pipeline

- **`lint.yml`** (on PR): `lint` (ct lint, Helm 3), `lint-helm4` (helm lint --strict, Helm 4), and `snyk` (matrix over studio/rasa/op-kits; renders with `--kube-version 1.29.0` then scans with Snyk IaC). `ct.yaml` sets `check-version-increment: true`, so **every PR touching a chart must bump its `Chart.yaml` version** or CI fails. YAML lint rules live in `lintconf.yaml`.
- **`check-rc.yaml`** (on PR): detects changed charts and uses `.github/actions/check-chart-rc` to gate on the `-rc` suffix. CI **blocks `-rc` versions from merging to `main`** (see Release Branch Versioning above).
- **Release**: per-product `*-release-candidate.yml` and `*-chart-release.yml` workflows package and push charts to an OCI registry (Google Artifact Registry) via `.github/actions/release-helm-charts-oci`, and `chart-release-github-pages.yml` maintains the Helm repo index on the `ci/helm-index` branch. Release tags are prefixed per chart (`studio-`, `rasa-`, `op-kits-`).
