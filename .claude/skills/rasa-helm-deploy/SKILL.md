---
name: rasa-helm-deploy
description: Guided configuration and deployment of the Rasa Pro (charts/rasa) and Rasa Studio (charts/studio) Helm charts to Kubernetes. Generates the required Secret, a schema-valid values.yaml (or --set flags), ingress config for the detected controller, and can provision Postgres/Kafka via op-kits and auto-wire them. Use when installing, upgrading, or generating values/secrets for the rasa or studio charts, or when a user asks how to deploy Rasa or Studio to Kubernetes.
---

# rasa-helm-deploy

Guide a user — including someone with little Helm or Rasa knowledge — from
nothing to a working `helm install` of **Rasa Pro** (`charts/rasa/`) or
**Rasa Studio** (`charts/studio/`), with the fewest steps that still produce a
correct deployment.

## Operating principles (read first)

1. **Read chart files live — never hardcode chart contents.** Chart versions,
   defaults, required fields, and secret keys drift with every release. At
   runtime, read the actual files of the chart you are configuring:
   - `charts/<chart>/values.schema.json` — the source of truth for **required**
     fields and enums. Validate your generated values against it mentally
     before writing them.
   - `charts/<chart>/values.yaml` — the authoritative shape to copy from.
     **Do not** treat `charts/rasa/values.example.yaml` as authoritative — it
     drifts from `values.yaml`. Use it only as an illustration and cross-check
     every key against `values.yaml`.
   - `charts/<chart>/secrets.yaml` — the *default* secret key inventory.
   - `charts/<chart>/Chart.yaml` — the `version:` to pin the install to, and
     (for studio) the `rasa` OCI dependency version.
   If the repo is not present locally (an external user installing from a
   registry), `helm show values <ref>` / `helm show chart <ref>` against the
   OCI ref or `helm repo` give you the same data — see Phase 8 for refs.

2. **Never write secret values into a values file or any committed file.**
   Secrets go only into a `kubectl create secret` command (run by the user) or
   a placeholder manifest the user fills in. Values files reference secrets by
   name/key, never by value.

3. **Mutating commands require explicit confirmation.** Generating files is
   safe. `helm install/upgrade`, `kubectl create/apply`, and op-kits CR
   application are mutating: emit the command, **state the target kube-context
   and namespace**, and run it only after the user explicitly says to.

4. **Pin versions.** Always pin the chart version (from `Chart.yaml`) in the
   final install command. Never `latest`.

5. **Ask only what is needed.** Derive the required questions from
   `values.schema.json`; offer sensible defaults; don't interrogate the user
   for fields that have working defaults.

6. **Rasa images and Helm charts are public.** Do **not** assume a private
   registry or ask for image-pull credentials by default. `imagePullSecrets`
   are optional — only relevant when a customer mirrors the images to their own
   private registry. Offer to wire them only if the user says they pull from a
   private registry.

## Reference files

Consult these for product knowledge (they hold stable concepts, not
drifting values):

- `references/secrets.md` — the credential-injection idioms, the per-chart
  secret-key inventory, and the **beyond-default env-var catalog** (features
  needing secrets/env vars not in the chart's `secrets.yaml`).
- `references/rasa-endpoints-credentials.md` — what `settings.endpoints` and
  `settings.credentials` are and how to fill them.
- `references/studio-datastores.md` — Postgres, Kafka, and Keycloak
  connectivity for Studio.
- `references/op-kits-provisioning.md` — provisioning Postgres/Kafka via
  op-kits and the auto-wire mapping into the app chart.
- `references/ingress.md` — ingress-controller detection and per-controller
  annotation snippets, plus two ingress gotchas.

## Workflow

Run these phases in order. Announce each phase briefly so the user can follow.

### Phase 1 — Detect chart & read live config

- Determine the chart (`rasa` or `studio`) from the command args or by asking.
- Read `values.schema.json`, `values.yaml`, `secrets.yaml`, `Chart.yaml` for
  that chart. Note the required fields, the default secret name/keys, and the
  chart version.

### Phase 2 — Cluster preflight (read-only)

Run and summarize (do not dump raw output):

- `kubectl config current-context` — **always report the target context**;
  confirm it is the intended cluster before anything mutating later.
- `kubectl get ingressclass` — detect the ingress controller
  (nginx / traefik / alb / none). Drives Phase 6 annotations
  (see `references/ingress.md`).
- Target namespace: ask or default; `kubectl get ns <ns>` to check existence.
- Existing secret: `kubectl -n <ns> get secret <default-secret-name>` to see if
  one already exists (avoid clobbering).
- For a possible op-kits path: check operator CRDs exist —
  `kubectl get crd clusters.postgresql.cnpg.io kafkas.kafka.strimzi.io`
  (present = operator installed).

### Phase 3 — Interview

Ask only what the schema marks required plus the feature toggles the user
wants. Offer defaults from `values.yaml`.

- **rasa**: Rasa Pro license (required); ingress host + class; optional endpoints
  (`tracker_store`, `event_broker`, `action_endpoint`, `models`, `model_groups`
  / OpenAI — see `references/rasa-endpoints-credentials.md`); optional
  components (`actionServer`, `duckling`, `rasaProServices`).
- **studio**: `config.ingressHost` (**required** — preserve the `&dns_hostname`
  YAML anchor; only change the value); `config.database.host` and `username`
  (**required**) + password; Keycloak admin/api passwords; OpenAI key; license;
  Kafka settings (only if `eventIngestion.enabled`, default true). Offer
  `eventIngestion.enabled: false` for a minimal first deploy if no broker is
  ready.
- **Both**: if the user enables a feature needing an env var/secret **outside**
  the default `secrets.yaml` (non-OpenAI LLM provider, Vault/`SECRET_MANAGER`,
  RabbitMQ SSL, SQL-tracker tuning, analytics DB URL, …), consult the catalog
  in `references/secrets.md` and collect those too, noting which are secrets vs
  plain env.

### Phase 4 — Datastore decision (op-kits auto-wire)

Ask: bring-your-own external Postgres/Kafka, or provision in-cluster via
op-kits?

- **Bring-your-own**: collect host/port/db/creds and move on.
- **Provision via op-kits**: verify the required operators are installed
  (Phase 2). Generate an `op-kits-values.yaml` enabling CloudNativePG and/or
  Strimzi, then **auto-wire** the emitted connection details into the app
  chart's values and secret keys using the mapping table in
  `references/op-kits-provisioning.md` (e.g. `<cluster>-rw.<ns>.svc:5432` →
  `config.database.host`; `<kafka>-kafka-bootstrap.<ns>.svc:9092` +
  `SCRAM-SHA-512` → `eventIngestion.KAFKA_*`). Note that op-kits only emits CRs
  — the operators themselves must be pre-installed.

### Phase 5 — Secrets artifact

Compute the needed secret keys = the default `secrets.yaml` keys the chart
references **plus** any extra keys from Phase 3 features
(`references/secrets.md`).

**Auto-generate, don't ask, for chart-required non-user secrets.** For rasa,
`authToken` and `jwtSecret` are wired by the chart's default values, so the
secret must contain them — generate each as a **12-char alphanumeric** string
(no special characters) rather than prompting the user. Only credentials the
user alone can provide (license keys, external DB/broker passwords, provider API
keys) are asked for. Then, per the user's choice:

- **Values provided** → emit a ready-to-run command:
  ```
  kubectl -n <ns> create secret generic <secret-name> \
    --from-literal=<KEY>=<VALUE> [ --from-literal=... ]
  ```
  (Recommend `--dry-run=client -o yaml | kubectl apply -f -` for idempotency.)
- **No values provided** → write a placeholder `secrets.yaml` (based on the
  chart's template, extended with the extra keys, using `stringData:` so
  Kubernetes base64-encodes automatically) and explain how to fill and apply
  it. Never invent secret values.

For any extra key **not** natively wired by the chart, also add the matching
`additionalEnv` / component-env `valueFrom.secretKeyRef` entry in the values
artifact (Phase 6) so the container actually receives it.

### Phase 6 — Values artifact

Two output modes — ask the user's preference:

- **values file** → write `<chart>-values.yaml`: minimal, derived from the live
  `values.yaml`, containing only what differs from defaults + the user's
  answers. Preserve the `&dns_hostname` anchor for studio. Wire rasa endpoint
  DB/broker passwords with the `${VAR}` + `additionalEnv` idiom
  (`references/rasa-endpoints-credentials.md`). Inject ingress annotations
  tailored to the detected controller (`references/ingress.md`).
- **`--set` flags** → for users who don't want a file, emit the equivalent
  `--set key=value` / `--set-file` flags for the install command instead.

### Phase 7 — Validate

- `helm lint --strict charts/<chart> -f <chart>-values.yaml` (this runs
  `values.schema.json` validation — fix any errors before proceeding).
- `helm template charts/<chart> -f <chart>-values.yaml --kube-version 1.29.0
  --output-dir /tmp/rasa-helm-render` and spot-check the rendered ingress
  hosts, env vars, and secret refs. Summarize — don't dump the full render.

### Phase 8 — Install / upgrade command (mutating — confirm first)

Emit the final command, version pinned from `Chart.yaml`, using whichever
source the user prefers:

- **OCI**: `helm install <release> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/<chart> --version <v> -n <ns> [--create-namespace] -f <chart>-values.yaml`
- **Helm repo**: `helm repo add rasa https://helm.rasa.com/charts && helm repo update && helm install <release> rasa/<chart> --version <v> -n <ns> -f <chart>-values.yaml`

State the target kube-context + namespace. For `configure`, stop here (emit
only). For `install`/`upgrade`, run only after explicit confirmation. Offer a
post-install check: `kubectl -n <ns> get pods` and surfacing the chart's
`NOTES.txt`. For upgrades, offer `helm diff upgrade …` first if the plugin is
installed.

## Out of scope (for now)

ExternalSecrets Operator / GitOps secret output (AWS Secrets Manager,
1Password) is a natural future extension but not implemented here — if a user
asks, point them to their platform's ESO setup rather than generating raw
Secrets.
