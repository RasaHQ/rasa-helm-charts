# Migration guide — Rasa Studio Helm chart

Upgrade notes for breaking chart releases. For everything else see
[README.md](README.md).

## Upgrading to 3.0.0

Chart 3.0.0 is a hard break. It collapses the three-Deployment topology
(`backend`, `web-client`, `event-ingestion`) into a single `app` Deployment
running the unified `studio` image, replaces bundled Keycloak with Better Auth
served at `/api/auth/*`, and moves the bundled Rasa Pro subchart to its own
3.0.0. It **requires Studio ≥ 2.0.0**.

**Check your cluster version first.** 3.0.0 raises the chart's floor to
Kubernetes **1.31**, up from the 1.23 that 2.x enforced. The bundled Rasa Pro
subchart sets `unhealthyPodEvictionPolicy` on its PodDisruptionBudget, which is
stable only from 1.31, and Helm does not enforce a subchart's own floor — so
this chart declares it. On an older cluster `helm upgrade` refuses to run and
nothing below this line applies: upgrade the cluster, or stay on 2.x.

This chart needs the Studio release that contains SWI-2173
([RasaHQ/studio#5353](https://github.com/RasaHQ/studio/pull/5353)). With an
older Studio image, the agent preview cannot reach the model service.

Eight things need work **outside** your values file. Everything else is a values
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
- at '/persistence/storageClassName': got null, want string
```

(The Rasa Pro chart used on its own reports `missing property 'storageClassName'`
instead. Helm drops a null that comes from a chart's own `values.yaml`, but this
chart declares `rasa.persistence.storageClassName` explicitly, and a null set by
the parent survives the merge into the subchart. Same cause, different wording —
worth knowing if you are grepping logs.)

```yaml
rasa:
  persistence:
    storageClassName: gp3   # kubectl get storageclass
```

Leaving it unset installed fine and broke on the next deploy. The chart rendered
the key with a null value, and a field the chart renders is a field Helm manages.
At install the `DefaultStorageClass` admission plugin substituted the cluster
default; every later `helm upgrade` reconciled that drift back towards null, and
a PersistentVolumeClaim spec is immutable:

```
spec: Forbidden: spec is immutable after creation
```

On a cluster with no default StorageClass there was nothing to substitute, so the
claim simply stayed `Pending` with nothing explaining why.

**If you already have a claim**, set the value to the class it is bound to — that
single edit also unblocks your upgrades:

```console
$ kubectl get pvc rasa-pro-data-pvc-<namespace> -n <namespace> \
    -o jsonpath='{.spec.storageClassName}'
```

Full detail in the Rasa Pro chart's [migration guide](../rasa/MIGRATION.md).

### 6. Add `STUDIO_ENCRYPTION_KEY` to the Secret before you upgrade

The app container reads `STUDIO_ENCRYPTION_KEY` from `app.encryptionKey`
(default: the `STUDIO_ENCRYPTION_KEY` key of `studio-secrets`) through a
non-optional `secretKeyRef`. If the key is missing, the new pod does not start.
Add it before `helm upgrade`:

```console
$ kubectl patch secret studio-secrets -n <namespace> --type merge \
    -p "{\"stringData\":{\"STUDIO_ENCRYPTION_KEY\":\"$(openssl rand -base64 32 | tr '+/' '-_' | tr -d =)\"}}"
```

Keep a backup of the key outside the cluster. Do not change it later: Studio
stores its fingerprint and cannot read its stored secrets with a different key.
See step 2 of [Before You Install](README.md#2-create-the-studio-secrets-secret).

### 7. Give each Rasa Pro HTTP event broker a credential

From this release Studio refuses event batches on `/api/events` that do not
carry a valid token. There is no grace period and no flag to turn this off.
This needs the Studio release with
[RasaHQ/studio#5369](https://github.com/RasaHQ/studio/pull/5369) and a Rasa Pro
with [RasaHQ/rasa-private#8223](https://github.com/RasaHQ/rasa-private/pull/8223).

Each Rasa Pro (Mantle agent) that uses the `http` event broker needs a Pro
credential from Studio. Put it in the `event_broker:` section of
`integrations.yml`, with the values read from environment variables:

```yaml
event_broker:
  type: http
  url: https://studio.example.com/api/events
  client_id: ${STUDIO_EVENTS_CLIENT_ID}
  client_secret: ${STUDIO_EVENTS_CLIENT_SECRET}
```

Replace a secret in this order, so that no batch goes out without a valid
token:

1. Create a new credential in Studio.
2. Deploy Rasa Pro with the new credential.
3. Revoke the old credential.

Kafka (CALM) users are not affected.

Studio limits token requests to 20 a minute for each client address. Behind a
load balancer, set `app.trustedProxies` to every hop in front of Studio: the
cloud load balancer range and the ingress controller pod CIDR. Without it,
Studio can count all Rasa Pro instances as one address.

### 8. GitOps installs: set `app.previewEventsSecret.existingSecret`

Preview bots send their events to Studio with the secret
`STUDIO_EVENTS_CLIENT_SECRET`, which the app and the model service both read.
This needs the Studio release with
[RasaHQ/studio#5381](https://github.com/RasaHQ/studio/pull/5381) and a Rasa Pro
with [RasaHQ/rasa-private#8250](https://github.com/RasaHQ/rasa-private/pull/8250).

With `helm install` and `helm upgrade` there is nothing to do. The chart
generates the secret in the Secret `studio-preview-events` and keeps it on
upgrade.

With `helm template` or Argo CD, the chart cannot read that Secret and makes a
new value on each render. Studio then accepts the new value only after it
restarts, and the model service keeps the old value until it restarts too. Set
your own secret instead:

1. Add `STUDIO_EVENTS_CLIENT_SECRET` to `studio-secrets`. The value is `rsc_`
   followed by at least 32 characters:

   ```console
   $ kubectl patch secret studio-secrets -n <namespace> --type merge \
       -p "{\"stringData\":{\"STUDIO_EVENTS_CLIENT_SECRET\":\"rsc_$(openssl rand -base64 32 | tr '+/' '-_' | tr -d =)\"}}"
   ```

2. Set `app.previewEventsSecret.existingSecret` to that key.
3. Point the `STUDIO_EVENTS_CLIENT_SECRET` entry of `rasa.overrideEnv` at the
   same key. See [Preview Event Secret](README.md#preview-event-secret).

If you replace `rasa.overrideEnv`, add the two new default entries,
`STUDIO_EVENTS_CLIENT_ID` and `STUDIO_EVENTS_CLIENT_SECRET`. The chart refuses
to render without them.

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
    FEATURE_FLAG_EXAMPLE: "true"

# After
app:
  webClient:
    config:
      FEATURE_FLAG_EXAMPLE: "true"
```

`config.js` no longer carries `MS_API_URL`. The browser reaches the model
service only through Studio at `/api/rasa/model-service/`, and the chart sets
`MS_API_URL` on the app container. The render fails if
`app.webClient.config.MS_API_URL` is set. With `rasa.enabled: false`, move the
value to `app.env` (see [Chart Dependencies — Rasa Pro](README.md#chart-dependencies--rasa-pro)).
A non-empty `MS_API_URL` in `app.env` also sets `window.MODEL_SERVICE_ENABLED`
to `"true"`.

The preview socket now goes through the Studio app ingress, not the Rasa Pro
ingress. Move any socket timeout or body-size annotations from
`rasa.ingress.annotations` to `app.ingress.extraAnnotations`.

### Ingress host configuration

The `&dns_hostname` YAML anchor and `config.ingressHost` are removed, and a
value left there is silently ignored — move it before upgrading.

- **Single host:** set `global.ingressHost` once. The app ingress, the Rasa Pro
  model-service ingress, and every derived URL
  (`RASA_MODEL_SERVER_BASE_URL`, `WEB_CLIENT_URL`, `CORS_ORIGINS`) follow it.
- **Split host:** leave `global.ingressHost` **unset** and set
  `app.ingress.hostName` and `rasa.ingress.hosts[0].host`.

An app host is required: without `global.ingressHost` or `app.ingress.hostName`
the render fails. Both take a bare hostname, without a scheme or a path.

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
| Event ingestion topology is explicit | Pick one `eventIngestion.mode`: `disabled` (default, no consumer; Mantle agents send events over HTTP), `colocated` (consumers on the app pod), or `separate` (a sibling `{release}-app-ingestion` Deployment). A Kafka install must set `colocated` or `separate`, or Studio stops reading the topic without any error. In `separate` the app pod gets `ENABLE_EVENT_INGESTION=false` and no `KAFKA_*` variables at all, so the two can never double-consume. |
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
