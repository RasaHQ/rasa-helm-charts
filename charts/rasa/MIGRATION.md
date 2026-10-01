# Migration guide — Rasa Pro Helm chart

Upgrade notes for breaking chart releases. For everything else see
[README.md](README.md).

## Upgrading to 3.0.0

Three changes need work **outside** your values file. Everything else is a values edit or a changed default.

### 1. Delete the Deployment first — the selector is immutable

`app.kubernetes.io/name` is now the chart name (`rasa`), not the release fullname. It is part of `Deployment.spec.selector`, which Kubernetes will not let you change, so `helm upgrade` **fails** on an existing release.

```console
kubectl delete deployment my-release-rasa -n my-namespace
helm upgrade my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa -n my-namespace
```

> **Warning:** do **not** use `--cascade=orphan` to dodge the downtime. The orphaned ReplicaSet keeps the old label, so the new selector can never adopt it — the old pods outlive the release, survive `helm uninstall`, and are never garbage collected. They also leave the Service the moment its selector flips, so you get the stranded workload *without* the continuity.

To avoid downtime, install alongside under a second release name and cut traffic over yourself.

### 2. Rename the licence key inside your Secret

The values key `rasaProLicense` is now `rasa.license`, and the default Secret keys are upper snake case (`RASA_LICENSE`, `AUTH_TOKEN`, `JWT_SECRET`) to match the variables they populate. A chart cannot rename a key inside your Secret, so the pod fails with `CreateContainerConfigError` until you either rename it there or pin the old name:

```yaml
rasa:
  license:
    secretName: rasa-secrets
    secretKey: rasaProLicense   # your existing key
```

The licence now reaches the container as `RASA_LICENSE`; `RASA_PRO_LICENSE` is deprecated upstream and no longer set.

### 3. The HTTP API is unauthenticated unless you give it a credential

`rasa.enableApi` stays `true` and `rasa.authToken`/`rasa.jwtSecret` are unset. The chart cannot default the API off: `rasa run` exits when it has neither a model nor the API to load one through.

| state | behaviour |
|---|---|
| no credential, ClusterIP only | install-time warning |
| no credential **and** `ingress.enabled`, `service.type` ≠ `ClusterIP`, or `hostNetwork` | **render fails** |
| `rasa.allowUnauthenticatedApi: true` | both suppressed |

A ClusterIP Service is not a security boundary, and a route added outside this chart is invisible to it — the refusal covers what the chart can prove it is doing, the warning covers the rest. Satisfy it with `rasa.authToken`, `rasa.jwtSecret`, or an `AUTH_TOKEN`/`JWT_SECRET` entry via the root-level `overrideEnv`, `extraEnv` or `envFrom`.

### 4. `persistence.storageClassName` is required when `persistence.create` is true

Previously this could be left unset, and the PersistentVolumeClaim silently inherited whatever StorageClass the cluster defaults to. The schema now rejects an unset value:

```
rasa:
- at '/persistence': missing property 'storageClassName'
```

Two reasons. On a cluster with no default StorageClass the claim stayed `Pending` forever with nothing pointing at the cause. And on a cluster that has one, the install succeeded and the next upgrade failed. The chart rendered the key with a null value, and a field the chart renders is a field Helm manages; the `DefaultStorageClass` admission plugin substituted the cluster default at install, so every later upgrade reconciled that drift back towards null against an immutable PersistentVolumeClaim spec:

```
PersistentVolumeClaim "rasa-pro-data-pvc-<namespace>" is invalid:
spec: Forbidden: spec is immutable after creation
```

**If you already have a claim from an earlier install**, set the value to the class it is already bound to — the same edit fixes the upgrade:

```console
$ kubectl get pvc rasa-pro-data-pvc-<namespace> -n <namespace> \
    -o jsonpath='{.spec.storageClassName}'
```

```yaml
persistence:
  create: true
  storageClassName: gp3   # whatever the command above printed
```

Set it to `""` to bind a classless PersistentVolume instead — that is what you want alongside `persistence.hostPath.enabled: true`, which creates exactly such a volume. `""` is an explicit empty string, not the same as leaving the key unset, and admission leaves it alone.

### Deployment settings moved to the chart root

`rasa.*` now holds **only Rasa's own configuration** — `port`, `enableApi`, `cors`, `authToken`, `jwtSecret`, `license`, `endpoints`, `integrations`, `telemetry`, `logging`, `environment`, `debugMode`, `mountDefaultConfigmap`. Everything that describes the Kubernetes workload moved to the root.

The old split was arbitrary: `podLabels` was at the root while `podAnnotations` sat under `rasa`, `imagePullSecrets` at the root while `image` was nested, `networkPolicy` at the root while `service` and `ingress` were nested.

```text
before                    after
──────────────────────    ──────────────────────
rasa:                     replicaCount: 2
  replicaCount: 2         image:
  image:                    tag: "3.20.0"
    tag: "3.20.0"         resources: {}
  resources: {}           rasa:
  port: 5005                port: 5005
```

### Renamed and removed keys

Old keys are **ignored, not rejected**, so anything left behind is silently dropped.

| old | new |
|---|---|
| `rasa.settings.*` | `rasa.*` |
| `rasaProLicense` | `rasa.license` |
| `rasa.image`, `rasa.replicaCount`, `rasa.strategy`, `rasa.resources`, `rasa.autoscaling` | root: `image`, `replicaCount`, … |
| `rasa.service`, `rasa.ingress`, `rasa.persistence`, `rasa.livenessProbe`, `rasa.readinessProbe`, `rasa.lifecycle` | root |
| `rasa.nodeSelector`, `rasa.tolerations`, `rasa.affinity`, `rasa.topologySpreadConstraints` | root |
| `rasa.podAnnotations`, `rasa.podSecurityContext`, `rasa.containerSecurityContext`, `rasa.serviceAccount`, `rasa.automountServiceAccountToken`, `rasa.terminationGracePeriodSeconds` | root |
| `rasa.command`, `rasa.args`, `rasa.extraArgs`, `rasa.overrideEnv`, `rasa.extraEnv`, `rasa.envFrom` | root |
| `rasa.initContainers`, `rasa.extraContainers`, `rasa.extraVolumes`, `rasa.extraVolumeMounts`, `rasa.mountModelsVolume` | root |
| `additionalArgs` / `additionalEnv` / `additionalContainers` | `extraArgs` / `extraEnv` / `extraContainers` |
| `volumes` / `volumeMounts` | `extraVolumes` / `extraVolumeMounts` |
| `global.additionalDeploymentLabels` | `global.extraDeploymentLabels` |
| `rasa.credentials` / `rasa.credentialsRaw` | `rasa.integrations` / `rasa.integrationsRaw` |
| `useDefaultArgs: false` | `args: []` |
| `rasa.enabled`, `rasa.scheme`, `rasa.ducklingHttpUrl` | removed |
| `actionServer`, `duckling`, `rasaProServices` | removed |

`args` now has three states: unset builds the arguments and appends `extraArgs`; a list replaces them; `[]` means no arguments at all, for when `command` runs something other than the Rasa server.

Nulling a block to blank it is now rejected up front. 2.6.0 shipped no
`required` list, so `networkPolicy: null` either crashed the render with
`nil pointer evaluating interface {}.enabled` or was silently ignored,
depending on the block. 3.0.0 declares fourteen top-level blocks required —
`rasa`, `image`, `serviceAccount`, `podSecurityContext`,
`containerSecurityContext`, `service`, `livenessProbe`, `readinessProbe`,
`ingress`, `autoscaling`, `persistence`, `networkPolicy`, `podDisruptionBudget`,
`global` — plus `license`, `telemetry` and `logging` under `rasa`. Helm rejects
a missing one before rendering starts:

```text
values don't meet the specifications of the schema(s):
- at '': missing property 'service'
```

Use the block's own toggle instead — `networkPolicy.enabled: false`,
`autoscaling.enabled: false`, `persistence.create: false` — or leave the block
at its default.

### Changed defaults and behaviour

| change | what to do |
|---|---|
| Action servers are bring-your-own | Deploy one, point `rasa.endpoints.action_endpoint.url` at it — **before** upgrading. The pod starts either way; the break surfaces on the first custom-action call. |
| `RASA_DUCKLING_HTTP_URL` no longer emitted | Set it through `extraEnv` if you run Duckling. |
| NetworkPolicies are release-scoped | They previously selected *every* pod in the namespace. Set `dnsNamespace`, `egressPorts` and `allowIngressFrom` — see [Network Policies](README.md#network-policies). |
| `ingress.hosts` is empty | Supply hosts, or enabling the ingress is refused at render time. |
| Restricted Pod Security Standard by default | `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`, `runAsNonRoot: true`, `seccompProfile: RuntimeDefault`. No `runAsUser`, so volume ownership is unchanged. |
| `automountServiceAccountToken: false` | Set `true` for a sidecar that calls the Kubernetes API. |
| `appVersion` drives the image tag | `image.tag` defaults to `""` and follows `appVersion`, so **a chart upgrade moves the image**. Set an exact tag to pin. |
| Ports follow `rasa.port`, not `service.port` | `service.targetPort` is empty by default and follows `rasa.port`. Set it only for a different or named port. |
| `rasa.cors` is a plain string | The secret-reference form was never read and rendered `map[...]` into `--cors`. Remove it. |
| `rasa.endpoints` is deprecated but works | `rasa run` still reads `/app/endpoints.yml`. Move `model_groups`, `mcp_servers` and `tracing` into `rasa.integrations`. |

> **Custom images:** `runAsNonRoot: true` needs a numeric non-root `USER` (the stock image is `USER 1001`). An image running as root, or declaring `USER` by name, fails with `CreateContainerConfigError`. Check with `docker image inspect --format '{{.Config.User}}' <your-image>`, or opt out via `containerSecurityContext.runAsNonRoot: false`.
