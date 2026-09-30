# Migration guide — Rasa Studio Helm chart

Upgrade notes for breaking chart releases. For everything else see
[README.md](README.md).

## Upgrading to 3.0.0

Chart 3.0.0 is a hard break. It collapses the three-Deployment topology
(`backend`, `web-client`, `event-ingestion`) into a single `app` Deployment
running the unified `studio` image, replaces bundled Keycloak with Better Auth
served at `/api/auth/*`, and moves the bundled Rasa Pro subchart to its own
3.0.0. It **requires Studio ≥ 2.0.0**.

Four things need work **outside** your values file. Everything else is a values
edit or a changed default.

### 1. Delete the old topology — Helm will not

Helm only removes resources it still renders. The `backend`, `web-client` and
standalone `event-ingestion` objects are gone from the chart, so they survive
the upgrade and keep serving traffic from the old image.

```console
kubectl delete deployment,svc,ingress,sa,hpa -l app.kubernetes.io/component=studio-backend -n my-namespace
kubectl delete deployment,svc,ingress,sa -l app.kubernetes.io/component=studio-web-client -n my-namespace
kubectl delete deployment,sa,hpa -l app.kubernetes.io/component=studio-event-ingestion -n my-namespace
```

Also remove old Jobs and ServiceAccounts named `*-database-migration` or
`*-db-migration`.

### 2. Delete the Rasa Deployment first — the selector is immutable

Applies with `rasa.enabled: true`, which is the default. The Rasa Pro subchart
changed `app.kubernetes.io/name` from the release fullname to the chart name.
That label is part of `Deployment.spec.selector`, which Kubernetes will not let
you change, so `helm upgrade` **fails** on an existing release.

```console
kubectl delete deployment rasapro -n my-namespace
helm upgrade my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio -n my-namespace
```

The name is whatever `rasa.fullnameOverride` is set to — `rasapro` by default.

> **Warning:** do **not** use `--cascade=orphan` to dodge the downtime. The
> orphaned ReplicaSet keeps the old label, so the new selector can never adopt
> it — the old pods outlive the release, survive `helm uninstall`, and are never
> garbage collected. They also leave the Service the moment its selector flips,
> so you get the stranded workload *without* the continuity.

### 3. Keycloak is gone — check Better Auth before dropping its database

Authentication is Better Auth on the app at `/api/auth/*`. There is no `/auth`
ingress and no Keycloak Deployment. Helm prunes the Keycloak resources that
belonged to the release; if any survive:

```console
kubectl delete deployment,svc,ingress,sa,networkpolicy -l app.kubernetes.io/component=studio-keycloak -n my-namespace
```

Confirm your users exist in Better Auth **before** dropping the Keycloak
Postgres database, then remove the unused `KEYCLOAK_*` keys from
`studio-secrets`. The values keys `keycloak`, `config.keycloak` and
`config.database.keycloakDatabaseName` are ignored, not rejected — delete them.

### 4. `networkPolicy.denyAll` now needs three more keys

Policies are scoped to the release's own pods instead of every pod in the
namespace, and the DNS policy matches `kubernetes.io/metadata.name` rather than
a `name: kube-system` label that neither EKS nor GKE applies. If you relied on
this chart imposing a namespace-wide default-deny, it no longer does.

With `denyAll` set you must also supply `dnsNamespace`, `egressPorts` and
`allowIngressFrom`, or Studio cannot reach its database and nothing can reach
Studio. `egressPorts` defaults to 443 and 80 only — add your database, Kafka and
object-storage ports. See [Network Policies](README.md#network-policies).

### 5. `rasa.persistence.storageClassName` is now required

Only when the Rasa Pro model service is enabled, which is the default:
`rasa.persistence.create` is `true`, and the subchart's schema now rejects an
unset class. A fresh install refuses to render:

```
rasa:
- at '/persistence': missing property 'storageClassName'
```

```yaml
rasa:
  persistence:
    storageClassName: gp3   # kubectl get storageclass
```

Leaving it unset used to work by accident: the cluster's default StorageClass was
substituted at admission, and Kubernetes then treats the field as immutable, so
every later `helm upgrade` was rejected with `spec: Forbidden: spec is immutable
after creation`. On a cluster with no default StorageClass the claim simply stayed
`Pending` with nothing explaining why.

**If you already have a claim**, set the value to the class it is bound to — that
single edit also unblocks your upgrades:

```console
$ kubectl get pvc rasa-pro-data-pvc-<namespace> -n <namespace> \
    -o jsonpath='{.spec.storageClassName}'
```

Full detail in the Rasa Pro chart's [migration guide](../rasa/MIGRATION.md).

### Renamed and removed keys

Old keys are **ignored, not rejected**, so anything left behind is silently
dropped. The one exception is `eventIngestion.enabled`, which fails the render.

| old | new |
|---|---|
| `backend.*` | `app.*` |
| `webClient.environmentVariables`, `app.webClient.environmentVariables` | `app.webClient.config` |
| `backend.environmentVariables`, `app.environmentVariables` | `app.env` |
| `backend.migration.environmentVariables`, `app.migration.environmentVariables` | `app.migration.env` |
| `eventIngestion.environmentVariables` | `eventIngestion.env` |
| `eventIngestion.enabled` | `eventIngestion.mode` — **rejected at render time** |
| `config.ingressHost` (and the `&dns_hostname` anchor) | `global.ingressHost` |
| `config.ingressClassName` | `global.ingressClassName` |
| `config.ingressAnnotations` | `global.ingressAnnotations` |
| `global.additionalDeploymentLabels` | `global.extraDeploymentLabels` |
| `app.additionalContainers` | `app.extraContainers` |
| `eventIngestion.additionalContainers` | `eventIngestion.extraContainers` |
| `app.ingress.additionalAnnotations` | `app.ingress.extraAnnotations` |
| `rasa.rasa.<deployment key>` | `rasa.<key>` — see below |
| `keycloak`, `config.keycloak`, `config.database.keycloakDatabaseName` | removed |

Nulling a top-level block to disable it no longer works: `config`, `app`,
`global`, `networkPolicy` and `eventIngestion` are `required` in
`values.schema.json`, so `networkPolicy: null` is rejected at install time
rather than producing a nil-pointer render error.

### Environment variables are native `EnvVar` lists

`app.env`, `app.migration.env` and `eventIngestion.env` take the Kubernetes
shape — `- name` with `value` or `valueFrom` — replacing the old
`KEY: {value: ...}` / `KEY: {secret: {name, key}}` maps.

```yaml
# Before
backend:
  environmentVariables:
    LOG_LEVEL: {value: "debug"}
    API_KEY: {secret: {name: "studio-secrets", key: "API_KEY"}}

# After
app:
  env:
    - name: LOG_LEVEL
      value: "debug"
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: studio-secrets
          key: API_KEY
```

Two behaviour changes come with it. Keys render **verbatim** — there is no
automatic upper-casing. And a user-supplied list **replaces the chart defaults
wholesale**, so copy across any default you still want.

### Web client configuration

`app.webClient.config` is a plain `KEY: "value"` map of browser `window.*`
globals mounted into `config.js`. It is not container environment, and flag
values always render as quoted strings.

```yaml
# Before
webClient:
  environmentVariables:
    MS_API_URL: "https://studio.example.com"

# After
app:
  webClient:
    config:
      MS_API_URL: "https://studio.example.com"
```

Setting `MS_API_URL` on `app.env` has no effect on `window.MS_API_URL` — only
`app.webClient.config.MS_API_URL` does.

### Ingress host configuration

The `&dns_hostname` YAML anchor and `config.ingressHost` are removed, and a
value left there is silently ignored — move it before upgrading.

- **Single host:** set `global.ingressHost` once. The app ingress, the Rasa Pro
  model-service ingress, and every derived URL (`window.MS_API_URL`,
  `RASA_MODEL_SERVER_BASE_URL`, `WEB_CLIENT_URL`, `CORS_ORIGINS`) follow it.
- **Split host:** leave `global.ingressHost` **unset** and set
  `app.ingress.hostName` and `rasa.ingress.hosts[0].host`.

The two are mutually exclusive by design: `global.ingressHost` overrides the
per-component hosts whenever it is set.

Class and annotations moved to `global` for a different reason — Helm
propagates only the `global.*` namespace into subcharts, so the old `config.*`
keys could never reach the Rasa Pro subchart and operators had to set the same
values twice.

> **Precedence flipped.** `global.ingressClassName` and
> `global.ingressAnnotations` are now a *baseline*: a per-ingress
> `className` or `extraAnnotations` entry **wins** on a key conflict, where
> `config.ingressAnnotations` previously won. This matches the Rasa Pro
> subchart. If you relied on the global value overriding a per-ingress one,
> that annotation now resolves the other way.

### Changed defaults and behaviour

| change | what to do |
|---|---|
| Event ingestion topology is explicit | Pick one `eventIngestion.mode`: `colocated` (default, consumers on the app pod), `separate` (a sibling `{release}-app-ingestion` Deployment), or `disabled`. In `separate` the app pod gets `ENABLE_EVENT_INGESTION=false` and no `KAFKA_*` variables at all, so the two can never double-consume. |
| `rasa.overrideEnv` must keep the model-service credentials | It replaces the chart's default list wholesale, and that default is the only thing wiring the licence and `OPENAI_API_KEY` into the model service. A partial list used to install cleanly and leave the model service dead; it is now refused at install time. Either licence env name counts: `RASA_LICENSE` or the legacy `RASA_PRO_LICENSE`. |
| `config.database.host` must be a real host | There is no default. The schema rejects an unset or empty value at install time with `at '/config/database': missing property 'host'`. |
| `Chart.yaml` declares `appVersion`, which drives the image tag | `tag` is empty by default and follows `appVersion`, so **a chart upgrade moves the image**. Set an exact tag to pin. |
| Restricted Pod Security Standard by default | `seccompProfile: RuntimeDefault` is on for the app and ingestion containers, so existing installs inherit it. The chart installs into a namespace labelled `pod-security.kubernetes.io/enforce=restricted` unmodified. |
| `automountServiceAccountToken: false` on all four pod specs | App, migration Job, separate ingestion and the test hook lose the API token. No Studio component calls the Kubernetes API; set `app.automountServiceAccountToken: true` (or the `app.migration.*` / `eventIngestion.*` equivalent) for a sidecar that does. |
| The migration Job is bounded | `app.migration.backoffLimit` and `app.migration.activeDeadlineSeconds` cap it. A failed Job persists for debugging and is deleted before the next attempt by `hook-delete-policy: before-hook-creation,hook-succeeded`. |

### The bundled Rasa Pro subchart is also a 3.0.0

`rasa.*` keys are flattened the same way the standalone chart is: everything
describing the Kubernetes workload sits at the subchart root, and `rasa.rasa.*`
holds only Rasa's own configuration (`port`, `mountDefaultConfigmap`, and the
rest).

```text
before                              after
────────────────────────────────    ────────────────────────────────
rasa:                               rasa:
  rasa:                               replicaCount: 1
    replicaCount: 1                   image:
    image:                              tag: "3.17.11-latest"
      tag: "3.17.11-latest"           mountModelsVolume: false
    settings:                         args: []
      useDefaultArgs: false           rasa:
      mountModelsVolume: false          port: 8000
```

Three of these were previously nested twice over and are easy to miss:

| old | new |
|---|---|
| `rasa.rasa.settings.useDefaultArgs: false` | `rasa.args: []` |
| `rasa.rasa.settings.mountModelsVolume` | `rasa.mountModelsVolume` |
| `rasa.rasa.settings.mountDefaultConfigmap` | `rasa.rasa.mountDefaultConfigmap` |
| `rasa.rasaProServices.enabled` | removed — the component is gone |

Left behind, `useDefaultArgs` means the container runs
`python -m rasa.model_service run --port 5005 --cors '*'` instead of the model
service, and `mountModelsVolume` defaults back to `true`, resurrecting the
`models` emptyDir and `/app/models` mount that Studio suppresses.

> **You are not affected by the Rasa Pro licence Secret rename.** The standalone
> chart renamed `rasaProLicense` to `rasa.license` with upper-snake-case Secret
> keys. Studio does not use that wiring — it injects `RASA_LICENSE` directly
> through `rasa.overrideEnv` from `studio-secrets`, so your existing Secret keys
> are untouched.

For anything else under `rasa.*`, see the
[Rasa Pro chart migration guide](https://github.com/RasaHQ/rasa-helm-charts/blob/main/charts/rasa/MIGRATION.md).
Its action-server, Duckling and `rasa-pro-services` removals do not apply to
Studio, which never enabled them.
