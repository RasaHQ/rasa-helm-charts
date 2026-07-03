# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Helm charts for deploying Rasa products on Kubernetes (chart versions live in each `Chart.yaml`, not here — they drift):
- **`charts/studio/`** - Rasa Studio: multi-component app with backend, web-client, keycloak, event-ingestion. Optionally bundles the `rasa` chart as an OCI subchart (toggled by `rasa.enabled`).
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

### YAML Formatting (`lintconf.yaml`)
- No `---` document start markers
- Unix line endings, spaces (no tabs)
- Max 2 consecutive empty lines, none at file start/end
- Comments require a leading space, at least 2 spaces from content

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
- Secret references: object with required `secretName` + `secretKey` (see `definitions.secretRef`)
- Dual-type fields (string or secret ref): use `definitions.secretRefOrString`
- Component toggles (`enabled`): boolean

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
Components are toggled via `<component>.enabled` flags in values. Studio conditionally deploys Rasa Pro via `rasa.enabled`.

## Architecture Notes

- Each chart's `_helpers.tpl` defines naming helpers (`fullname`, `labels`, `selectorLabels`, `serviceAccountName`, `image`). Studio's is at `templates/_helpers.tpl`; rasa's is at `templates/helpers/_helpers.tpl`.
- Studio defines shared environment-variable blocks as named templates in `templates/studio/_env.tpl` (e.g. `studio.shared.env`, `studio.backend.env`, `studio.keycloak.env`) — these centralize the secret-ref vs plain-string branching for DB and Keycloak credentials.
- Network policies follow a default-deny pattern: each chart includes `deny-all.yaml`, `allow-dns-access.yaml`, and `ingress-egress-from-kubelet.yaml` (rasa adds `allow-egress-http-https.yaml`). All hardcode `apiVersion: networking.k8s.io/v1`.
- `README.md` files are auto-generated by helm-docs using `README.md.gotmpl` + `values.yaml` `# --` comments
- Studio's `Chart.lock` locks its Rasa dependency to a specific OCI version — run `helm dependency build` after any dependency changes
- Studio ships `values.schema.json` for input validation — `helm lint` enforces it automatically; update the schema when adding new values
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

# context-mode — MANDATORY routing rules

You have context-mode MCP tools available. These rules are NOT optional — they protect your context window from flooding. A single unrouted command can dump 56 KB into context and waste the entire session.

## BLOCKED commands — do NOT attempt these

### curl / wget — BLOCKED
Any Bash command containing `curl` or `wget` is intercepted and replaced with an error message. Do NOT retry.
Instead use:
- `ctx_fetch_and_index(url, source)` to fetch and index web pages
- `ctx_execute(language: "javascript", code: "const r = await fetch(...)")` to run HTTP calls in sandbox

### Inline HTTP — BLOCKED
Any Bash command containing `fetch('http`, `requests.get(`, `requests.post(`, `http.get(`, or `http.request(` is intercepted and replaced with an error message. Do NOT retry with Bash.
Instead use:
- `ctx_execute(language, code)` to run HTTP calls in sandbox — only stdout enters context

### WebFetch — BLOCKED
WebFetch calls are denied entirely. The URL is extracted and you are told to use `ctx_fetch_and_index` instead.
Instead use:
- `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` to query the indexed content

## REDIRECTED tools — use sandbox equivalents

### Bash (>20 lines output)
Bash is ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`, and other short-output commands.
For everything else, use:
- `ctx_batch_execute(commands, queries)` — run multiple commands + search in ONE call
- `ctx_execute(language: "shell", code: "...")` — run in sandbox, only stdout enters context

### Read (for analysis)
If you are reading a file to **Edit** it → Read is correct (Edit needs content in context).
If you are reading to **analyze, explore, or summarize** → use `ctx_execute_file(path, language, code)` instead. Only your printed summary enters context. The raw file content stays in the sandbox.

### Grep (large results)
Grep results can flood context. Use `ctx_execute(language: "shell", code: "grep ...")` to run searches in sandbox. Only your printed summary enters context.

## Tool selection hierarchy

1. **GATHER**: `ctx_batch_execute(commands, queries)` — Primary tool. Runs all commands, auto-indexes output, returns search results. ONE call replaces 30+ individual calls.
2. **FOLLOW-UP**: `ctx_search(queries: ["q1", "q2", ...])` — Query indexed content. Pass ALL questions as array in ONE call.
3. **PROCESSING**: `ctx_execute(language, code)` | `ctx_execute_file(path, language, code)` — Sandbox execution. Only stdout enters context.
4. **WEB**: `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` — Fetch, chunk, index, query. Raw HTML never enters context.
5. **INDEX**: `ctx_index(content, source)` — Store content in FTS5 knowledge base for later search.

## Subagent routing

When spawning subagents (Agent/Task tool), the routing block is automatically injected into their prompt. Bash-type subagents are upgraded to general-purpose so they have access to MCP tools. You do NOT need to manually instruct subagents about context-mode.

## Output constraints

- Keep responses under 500 words.
- Write artifacts (code, configs, PRDs) to FILES — never return them as inline text. Return only: file path + 1-line description.
- When indexing content, use descriptive source labels so others can `ctx_search(source: "label")` later.

## ctx commands

| Command | Action |
|---------|--------|
| `ctx stats` | Call the `ctx_stats` MCP tool and display the full output verbatim |
| `ctx doctor` | Call the `ctx_doctor` MCP tool, run the returned shell command, display as checklist |
| `ctx upgrade` | Call the `ctx_upgrade` MCP tool, run the returned shell command, display as checklist |
