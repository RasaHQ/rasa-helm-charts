# rasa

A Rasa Pro Helm chart for Kubernetes

![Version: 3.0.0-rc.17](https://img.shields.io/badge/Version-3.0.0--rc.17-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.20.0-latest](https://img.shields.io/badge/AppVersion-3.20.0--latest-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+
- A valid Rasa Pro license key

## Creating Secrets

The chart reads credentials exclusively from Kubernetes Secrets. Only the **license secret is required** to install — all other secrets are optional and only referenced when you enable the corresponding feature.

### License Secret (required)

Create a secret containing your Rasa Pro license key before installing:

```console
kubectl create secret generic rasa-secrets \
  --from-literal=RASA_LICENSE="<YOUR_LICENSE_KEY>"
```

The chart defaults to `secretName: rasa-secrets` and `secretKey: RASA_LICENSE`. Secret keys are upper snake case, matching the environment variables they populate and the `studio` chart. Override both in your values if you use a different name or key:

```yaml
rasa:
  license:
    secretName: my-custom-secret
    secretKey: MY_LICENSE_KEY
```

### Optional Secrets

Add optional keys to the same secret (or separate secrets) as you enable features. You can extend the secret you created above:

```console
kubectl patch secret rasa-secrets -p \
  '{"stringData":{"AUTH_TOKEN":"<YOUR_TOKEN>","JWT_SECRET":"<YOUR_JWT_SECRET>"}}'
```

The table below lists all secret-backed fields:

| Secret key | Feature | values.yaml field |
|---|---|---|
| `AUTH_TOKEN` | Token-based API authentication | `rasa.authToken` |
| `JWT_SECRET` | JWT API authentication | `rasa.jwtSecret` |

Both are unset by default, so adding the key to the Secret is not enough on its own — point the values field at it as well:

```yaml
rasa:
  authToken:
    secretName: rasa-secrets
    secretKey: AUTH_TOKEN
```

Alternatively, create all credentials upfront from a manifest. The chart ships a `secrets.yaml` example that you can use as a starting point — **use `stringData` so Kubernetes base64-encodes the values automatically**:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rasa-secrets
type: Opaque
stringData:
  RASA_LICENSE: "<YOUR_LICENSE_KEY>"      # required for all deployments
  AUTH_TOKEN: "<YOUR_AUTH_TOKEN>"         # optional: token-based API auth
  JWT_SECRET: "<YOUR_JWT_SECRET>"         # optional: JWT auth
```

## Installing the Chart

Before installing, make sure you have created the license secret as described in [Creating Secrets](#creating-secrets) above.

You can install the chart from either the OCI registry or the GitHub Helm repository.

### Option 1: Install from OCI Registry

To install the chart with the release name `my-release`:

```console
helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version 3.0.0-rc.17
```

### Option 2: Install from GitHub Helm Repository

First, add the Rasa Helm repository:

```console
helm repo add rasa https://helm.rasa.com/charts
helm repo update
```

Then install the chart:

```console
helm install my-release rasa/rasa --version 3.0.0-rc.17
```

## Upgrading the Chart

To upgrade to a new chart version, update the repository index and run:

```console
helm repo update
helm upgrade my-release rasa/rasa --version <new-version> -f values.yaml
```

Or from OCI:

```console
helm upgrade my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version <new-version> -f values.yaml
```

> **Note:** Always check the [release notes](https://github.com/RasaHQ/rasa-helm-charts/releases) for breaking changes before upgrading across major versions.

### Upgrading to 3.0.0

3.0.0 is a breaking release: the chart deploys the Rasa Pro server only, the
values are flattened, and the licence key moved. Three changes need work
outside your values file.

**See [MIGRATION.md](MIGRATION.md) for the full guide.**

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## General Configuration

- **imagePullSecrets**: If you're pulling from a private registry, provide your pull secret name(s) here.
- **rasa.license**: All Rasa Pro deployments require a valid license. Provide `secretName` and `secretKey` pointing to the Kubernetes Secret that holds your license value.

> **Note:** For application-specific settings, refer to the [Rasa documentation](https://rasa.com/docs/). The full list of configurable values is at the bottom of this page.

### Minimal Working Configuration

The following is the smallest `values.yaml` needed to get Rasa Pro running. It assumes the license secret was created as shown in [Creating Secrets](#creating-secrets):

```yaml
image:
  tag: "3.x.x"  # pin to a specific Rasa Pro version

rasa:
  license:
    secretName: rasa-secrets
    secretKey: RASA_LICENSE
```

Install with:

```console
helm install my-release rasa/rasa -f values.yaml
```

From there, add sections from the rest of this guide as your deployment grows.

### Use MinIO instead of S3

> **Warning:** MinIO is end-of-life and no longer receives updates. The chart still supports connecting to a MinIO instance, but we recommend migrating to S3 or another actively maintained object storage provider.

To use MinIO instead of S3, set `AWS_ENDPOINT_URL` to the URL of the MinIO server and provide `AWS_REGION` and `BUCKET_NAME`. Store your MinIO credentials in a Kubernetes Secret:

```console
kubectl create secret generic minio-credentials \
  --from-literal=accessKey="<YOUR_MINIO_ACCESS_KEY>" \
  --from-literal=secretKey="<YOUR_MINIO_SECRET_KEY>"
```

```yaml
extraEnv:
  - name: AWS_ENDPOINT_URL
    value: "http://minio.example.com"
  - name: AWS_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: minio-credentials
        key: accessKey
  - name: AWS_SECRET_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: minio-credentials
        key: secretKey
  - name: AWS_REGION
    value: "us-east-1"
  - name: BUCKET_NAME
    value: "rasa-models"
```

### Mount Configuration Options

**mountDefaultConfigmap:**

By default, the chart renders a ConfigMap from `rasa.integrations` and `rasa.endpoints` and mounts it at `/app/integrations.yml` and `/app/endpoints.yml` — which is where `rasa run` looks for them, since the image sets `WORKDIR /app`. If you would rather supply those files from somewhere else, disable it:

```yaml
rasa:
  mountDefaultConfigmap: false
```

When disabled, supply the files yourself — baked into the image, or mounted at `/app/integrations.yml` and `/app/endpoints.yml` through `rasa.extraVolumes` and `rasa.extraVolumeMounts`.

**mountModelsVolume:**

By default, the chart mounts a models volume to the Rasa deployment at `/app/models`. If you prefer to mount models from a different source or bake them into the image, you can disable this behavior:

```yaml
mountModelsVolume: false
```

When disabled, it is expected that the models are mounted to the `/app/models` directory or baked into the image.

### Configuring API Authentication

The Rasa HTTP API supports two authentication methods. Configure one or both via Kubernetes Secrets.

**Token-based authentication:**

```console
kubectl create secret generic rasa-secrets \
  --from-literal=AUTH_TOKEN="<YOUR_STATIC_TOKEN>"
```

```yaml
rasa:
  authToken:
    secretName: rasa-secrets
    secretKey: AUTH_TOKEN
```

**JWT authentication:**

```console
kubectl create secret generic rasa-secrets \
  --from-literal=JWT_SECRET="<YOUR_JWT_SECRET>"
```

```yaml
rasa:
  jwtSecret:
    secretName: rasa-secrets
    secretKey: JWT_SECRET
  jwtMethod: HS256
```

See the [Rasa documentation](https://rasa.com/docs/reference/api/pro/rasa-pro-rest-api/) for details on API authentication.

### Immutable Root Filesystem

`rasa.containerSecurityContext.readOnlyRootFilesystem` is commented out by default. Enabling it makes the chart mount the three paths Rasa needs to write, so you do not have to find them yourself:

```yaml
containerSecurityContext:
  readOnlyRootFilesystem: true
```

| path | why |
|---|---|
| `/tmp` | the image declares it as a Dockerfile `VOLUME`, which Kubernetes ignores |
| `/app/.config` | `HOME=/app`, so the global config lands here |
| `/app/.cache` | matplotlib's cache |

The project directory itself stays read-only — no `emptyDir` is mounted over `/app`, so a model or project baked into the image is not masked. Verified on Kubernetes 1.37 with `rasa-pro:3.20.0-latest`: the pod reaches `ready=true` with no `errno 30` in its logs and `helm test` passes.

### Configuring the Readiness Probe

The default readiness probe hits the `/` endpoint, which returns a success code as soon as the HTTP server is up — before any model has been loaded. For production, use the `/status` endpoint instead, which only returns a success code once Rasa has loaded a model and is ready to process conversations.

Measured against `rasa-pro:3.20.0-latest`, which is what makes the two cases below necessary:

| endpoint | no credential | `AUTH_TOKEN` set |
|---|---|---|
| `/` | `200` immediately | `200` — not authenticated |
| `/version` | `200` immediately | `200` — not authenticated |
| `/status` | `409` until a model is loaded | `401` without a token |

So `/` and `/version` stay usable as probes whatever your auth configuration, and `/status` needs the token once one is set.

**Without authentication:**

```yaml
readinessProbe:
  httpGet:
    path: /status
    port: 5005          # keep in step with rasa.port
    scheme: HTTP
```

**With `authToken` configured:**

When `AUTH_TOKEN` is set, the `/status` endpoint requires authentication. Use an `exec` probe that reads the token from the environment variable:

```yaml
readinessProbe:
  httpGet: null
  exec:
    command:
      - /bin/sh
      - -c
      - "curl -f http://localhost:5005/status?token=${AUTH_TOKEN}"
  initialDelaySeconds: 15
  periodSeconds: 15
  successThreshold: 1
  timeoutSeconds: 5
  failureThreshold: 6
```

**With only `jwtSecret` configured:**

`/status` returns `401` and there is no way to satisfy it from a probe — a JWT would have to be minted and signed per request. Leave readiness on `/` (or `/version`) and rely on liveness plus your own monitoring for model readiness.

> **Note:** The `AUTH_TOKEN` environment variable is automatically injected by the chart from the secret referenced in `rasa.authToken`. Setting `httpGet: null` removes the default value set by the chart — this is required when switching from an `httpGet` probe to an `exec` probe, otherwise both will be rendered and Kubernetes will reject the manifest. Update the port in the `curl` command if you have changed `rasa.port` from its default.

### Graceful Shutdown and Lifecycle Hooks

The `rasa` component accepts a pod-level `terminationGracePeriodSeconds` and a container-level `lifecycle` block. Both are unset by default, so the rendered manifests are unchanged unless you opt in.

When Kubernetes deletes a pod it removes the pod from Service endpoints and sends `SIGTERM` at the same time, so in-flight requests can still arrive for a short window. A `preStop` sleep holds the container open long enough for the endpoint removal to propagate:

```yaml
lifecycle:
  preStop:
    sleep:
      seconds: 10
terminationGracePeriodSeconds: 60
```

The native `sleep` handler needs no shell or `sleep` binary in the image, which matters for images you do not build yourself. It has been enabled by default since Kubernetes 1.30, the minimum this chart supports, so no feature gate is required. The equivalent `exec` form remains available if you would rather run a real drain command than simply wait:

```yaml
lifecycle:
  preStop:
    exec:
      command: ["/bin/sh", "-c", "sleep 10"]
```

Two rules of thumb when picking values:

- Make the `preStop` sleep at least as long as `readinessProbe.periodSeconds` so load balancers have a full probe cycle to notice the pod is going away.
- Keep `terminationGracePeriodSeconds` larger than the `preStop` duration plus the time your application needs to finish in-flight work. The `preStop` hook runs *inside* the grace period, so a hook longer than the grace period gets cut short by `SIGKILL`.

Leaving `terminationGracePeriodSeconds` unset falls back to the Kubernetes default of 30 seconds.

The `lifecycle` block is passed through verbatim, so any hook handler Kubernetes supports (`exec`, `httpGet`, `sleep`) works. `postStart` is available as well:

```yaml
lifecycle:
  postStart:
    exec:
      command: ["/bin/sh", "-c", "echo rasa pro starting"]
```

> **Note:** The hook applies to the component's main container only. Containers you supply through `initContainers` or `extraContainers` can carry their own `lifecycle` block directly.

### Configuring Integrations and Endpoints via ConfigMap

With `rasa.mountDefaultConfigmap: true` (the default), the chart renders a ConfigMap and mounts it at `/app/integrations.yml` and `/app/endpoints.yml`.

#### Configuring Integrations

`rasa.integrations` renders `/app/integrations.yml` — the LLM, its model groups, channels, MCP servers and tracing. Mantle reads channels from here and ignores `credentials.yml` entirely.

```yaml
rasa:
  integrations:
    llm:
      model_group: main
    model_groups:
      - id: main
        models:
          - provider: openai
            model: gpt-4o
    channels:
      - name: rest
```

> **Warning:** this mount **replaces** the `integrations.yml` inside your trained project. Supply the whole file, `llm.model_group` included, or the server fails validation at startup.

> **Note:** a project counts as Mantle only when `integrations.yml` **and** at least one `skills/*/skill.md` exist under the project root. The skills come from the trained artifact, so this key alone does not switch a project to Mantle — and if the artifact unpacks its skills elsewhere, channels fall back to `credentials.yml`, which the chart no longer provides.

See the [integrations.yml reference](https://mantle.rasa.com/reference/integrations-yml).

#### Sourcing Files from Raw YAML

`rasa.integrationsRaw` and `rasa.endpointsRaw` take the **raw contents** of an `integrations.yml` / `endpoints.yml` file, so the file a developer already uses locally flows straight into the ConfigMap. Each is deep-merged with its structured counterpart, and **the structured value wins on key conflicts** — so infrastructure-owned blocks like `tracker_store` stay authoritative. Malformed YAML fails the render. `${VAR}` placeholders pass through verbatim.

```console
helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa \
  --version 3.0.0-rc.17 \
  --set-file rasa.integrationsRaw=./integrations.yml \
  --set-file rasa.endpointsRaw=./endpoints.yml
```

ArgoCD multi-source `Application`:

```yaml
spec:
  sources:
    - repoURL: https://github.com/RasaHQ/rasa-helm-charts
      chart: rasa
      targetRevision: 3.0.0-rc.17
      helm:
        fileParameters:
          - name: rasa.integrationsRaw
            path: $values/integrations.yml
          - name: rasa.endpointsRaw
            path: $values/endpoints.yml
    - repoURL: https://github.com/your-org/your-app-repo
      targetRevision: main
      ref: values
```

#### Configuring Endpoints

The `rasa.endpoints` section allows you to configure various endpoints and integrations. These endpoints are written to the `endpoints.yml` file in the ConfigMap.

**Action Server Endpoint:**

This chart does not deploy an action server. Run one yourself and point `action_endpoint.url` at it as a full HTTP URL:

```yaml
rasa:
  endpoints:
    action_endpoint:
      url: "http://my-action-server.actions.svc.cluster.local:5055/webhook"
```

Alternatively, run your actions in-process by setting `actions_module` instead of `url`.

**Model Storage:**

```yaml
rasa:
  endpoints:
    models:
      url: http://my-server.com/models/default_core@latest
      wait_time_between_pulls: 10
```

**Tracker Store (Redis example):**

```yaml
rasa:
  endpoints:
    tracker_store:
      type: redis
      url: <host of the redis instance>
      port: 6379
      db: 0
      password: <password>
      use_ssl: false
```

**Tracker Store (PostgreSQL example):**

```yaml
rasa:
  endpoints:
    tracker_store:
      type: sql
      dialect: postgresql
      url: <hostname>
      db: <database>
      username: <username>
      password: <password>
      port: 5432
```

**Event Broker (Kafka example):**

```yaml
rasa:
  endpoints:
    event_broker:
      type: kafka
      url: localhost:9095
      sasl_mechanism: SCRAM-SHA-512
      security_protocol: SASL_PLAINTEXT
      sasl_username: testuser
      sasl_password: testpass123
      partition_by_sender: true
      client_id: rasa-broker
```

**Model Groups:**

Model groups require an LLM provider API key. Inject it as an environment variable from a Kubernetes Secret:

```console
kubectl create secret generic openai-secret \
  --from-literal=apiKey="<YOUR_OPENAI_API_KEY>"
```

```yaml
extraEnv:
  - name: OPENAI_API_KEY
    valueFrom:
      secretKeyRef:
        name: openai-secret
        key: apiKey
rasa:
  endpoints:
    model_groups:
      - id: openai-gpt-4o
        models:
          - provider: openai
            model: gpt-4o-2024-11-20
            request_timeout: 7
            max_tokens: 256
```

See the [Rasa endpoints documentation](https://rasa.com/docs/pro/build/configuring-assistant#endpoints) for complete endpoint configuration options.

### Environment Variables

Use `extraEnv` to inject extra environment variables into any component without replacing the chart-managed ones. Both plain values and Secret/ConfigMap references are supported:

```yaml
extraEnv:
  - name: MY_VAR
    value: "my-value"
  - name: MY_SECRET_VAR
    valueFrom:
      secretKeyRef:
        name: my-secret
        key: my-key
  - name: MY_CONFIGMAP_VAR
    valueFrom:
      configMapKeyRef:
        name: my-configmap
        key: my-key
```

Use `envFrom` to inject all keys from a ConfigMap or Secret as environment variables at once:

```yaml
envFrom:
  - configMapRef:
      name: my-configmap
  - secretRef:
      name: my-secret
```

### Loading Initial Models

Use `initContainers` to download a model before the Rasa server starts. The init container shares the `/app/models` volume with the main container:

```yaml
initContainers:
  - name: load-initial-model
    image: alpine
    command: ["/bin/sh", "-c"]
    args:
      - wget https://my-model-server.example.com/models/model.tar.gz -O /app/models/model.tar.gz
    volumeMounts:
      - mountPath: /app/models
        name: models
```

### Ingress

To expose the Rasa API externally, enable the ingress resource. The example below uses nginx with TLS managed by cert-manager:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: rasa.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: rasa-tls
      hosts:
        - rasa.example.com
```

#### Shared ingress settings

The `global` block carries three ingress settings so an ingress class, a set of annotations and a host can be declared once instead of being repeated:

```yaml
global:
  ingressClassName: nginx
  ingressAnnotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  ingressHost: rasa.example.com
```

`global.ingressClassName` and `global.ingressAnnotations` are defaults that `rasa.ingress` overrides. A non-empty `rasa.ingress.className` wins outright, and `rasa.ingress.annotations` wins per key while non-conflicting global annotations still merge in.

> **Note:** `global.ingressHost` behaves differently. It overrides `rasa.ingress.hosts[*].host` instead of falling back to it, so leave it unset if you need per-host values.

`global.ingressHost` sets the ingress rule host and nothing else. TLS is a separate list that the chart does not derive from it, so a single-host deployment repeats the hostname under `rasa.ingress.tls`:

```yaml
global:
  ingressHost: rasa.example.com
ingress:
  tls:
    - secretName: rasa-tls
      hosts:
        - rasa.example.com
```

Keep the two in sync. If `global.ingressHost` changes and `rasa.ingress.tls[*].hosts` is left behind, the chart still renders and applies without complaint: the ingress serves the new host while the TLS section claims the old one, so the controller finds no certificate matching the host it serves and falls back to its default. The symptom is a browser certificate warning rather than a Helm error, which makes it easy to miss.

Because Helm propagates `global` down the dependency tree after user overrides are merged, a parent chart that bundles this one can set these under its own `global` block and have them reach this chart. That is how Rasa Studio drives the host of the model-service ingress.

### Resources and Autoscaling

No resource requests or limits are set by default. For production, always set these explicitly:

```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2
    memory: 4Gi
```

Enable Horizontal Pod Autoscaling (HPA) to scale replicas based on CPU or memory:

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  # targetMemoryUtilizationPercentage: 80
```

### Pod Topology Spread Constraints

Once a component runs more than one replica, spread its pods across failure domains so a single zone or node outage cannot take all of them down:

```yaml
replicaCount: 3
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: ScheduleAnyway
```

A constraint needs a `labelSelector` to decide which pods to count, and one that selects nothing is silently ignored rather than rejected. The chart therefore fills in the component's own selector labels whenever an entry omits `labelSelector`, so the example above means "spread the Rasa Pro server pods across zones" without further configuration. Set `labelSelector` yourself when you want to count a broader set of pods than the one component.

Choose `whenUnsatisfiable` to match the replica count: `DoNotSchedule` gives the Rasa Pro server a hard spread guarantee at three or more replicas, but at one or two it leaves pods `Pending` when a zone has no room. Prefer `ScheduleAnyway` there, or leave the list empty, since a spread constraint over a single replica does nothing.

#### Setting labelSelector explicitly

A `labelSelector` selects pods, so it can only match labels the pod template actually carries. The chart labels its pods with `app.kubernetes.io/name` and `app.kubernetes.io/instance` (the release name), plus anything added through the chart-level `podLabels`. The selector injected by default is exactly that first pair, which is also what the Deployment uses in `spec.selector.matchLabels` to own its pods.

Labels set through `deploymentLabels` or `global.extraDeploymentLabels` are attached to the Deployment object rather than to the pods, as are `helm.sh/chart` and `app.kubernetes.io/managed-by`. A selector referring to any of those matches no pods, and the constraint is then quietly ignored.

Writing the selector out explicitly is the same as the default, and is worth doing when you need several constraints with different scopes:

```yaml
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: my-release-rasa
        app.kubernetes.io/instance: my-release
```

To spread the Rasa Pro server together with a workload this chart does not manage — your own action server, for instance — as a single pool rather than each on its own, give both sets of pods a shared label and select on it. `podLabels` applies to the pods this chart creates; label the other workload the same way in its own chart:

```yaml
podLabels:
  rasa.com/spread-group: rasa-stack

topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        rasa.com/spread-group: rasa-stack
```

A shared `podLabels` key is preferable to selecting on `app.kubernetes.io/instance` for this. The selector cannot be templated, so the release name would have to be spelled out, and when this chart is deployed as a Rasa Studio subchart the Studio components share the same `app.kubernetes.io/instance` value and would be drawn into the same spread group.

`matchExpressions` is also available, which is the shorter route to pooling a named subset without introducing a new label:

```yaml
      labelSelector:
        matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
              - my-release-rasa
              - my-action-server
```

### Network Policies

Network policies are disabled by default. Every policy the chart emits selects **only this release's pods**, so enabling them in a shared namespace does not affect anything else.

`denyAll` drops all traffic first; everything the pod needs must then be allowed back explicitly. A working configuration needs four things, and omitting any of them leaves the pod running but unreachable or unable to connect:

```yaml
networkPolicy:
  enabled: true
  denyAll: true

  # 1. kubelet liveness and readiness probes
  nodeCIDR:
    - ipBlock:
        cidr: 10.0.0.0/8          # adjust to your node CIDR

  # 2. cluster DNS, matched on the API-server-managed namespace label
  dnsNamespace: kube-system

  # 3. everything the pod dials out to. The defaults cover 443 and 80 ONLY,
  #    so a tracker store, event broker or model storage on any other port
  #    is denied until you add it here.
  egressPorts:
    - port: 443
    - port: 80
    - port: 5432                  # PostgreSQL tracker store
    - port: 9092                  # Kafka event broker

  # 4. whoever reaches the service. nodeCIDR covers the kubelet only, not an
  #    ingress controller, which connects from its own pod IP.
  allowIngressFrom:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
```

> **Warning:** `denyAll` without `egressPorts` entries for your database and broker will start the pod and then fail every connection to them. `denyAll` without `allowIngressFrom` black-holes your ingress while the pod reports healthy.

## Configuration Reference

The following table lists all configurable parameters for this chart and their default values.

## Values

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| affinity | object | Affinity rules. | `{}` |
| args | string | Replaces the generated container arguments. Unset builds them from rasa.port, rasa.cors, rasa.enableApi, rasa.debugMode. [] means no arguments. | `nil` |
| automountServiceAccountToken | bool | Mount a Kubernetes API token. Off: Rasa never calls the API and the chart grants no RBAC. Turn on for a sidecar that needs one. | `false` |
| autoscaling | object | HorizontalPodAutoscaler. | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` |
| autoscaling.enabled | bool | Enable the HorizontalPodAutoscaler. | `false` |
| autoscaling.maxReplicas | int | Maximum replicas. | `100` |
| autoscaling.minReplicas | int | Minimum replicas. | `1` |
| autoscaling.targetCPUUtilizationPercentage | int | Target CPU utilisation percentage. | `80` |
| command | list | Overrides the container entrypoint. | `[]` |
| containerSecurityContext | object | Container security context. Defaults satisfy the restricted Pod Security Standard. | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` |
| containerSecurityContext.allowPrivilegeEscalation | bool | Allow privilege escalation. | `false` |
| containerSecurityContext.capabilities | object | Linux capabilities. | `{"drop":["ALL"]}` |
| containerSecurityContext.capabilities.drop | list | Capabilities to drop. | `["ALL"]` |
| containerSecurityContext.runAsNonRoot | bool | Run as a non-root user. Requires an image whose USER is a numeric non-root uid; the stock image is 1001. | `true` |
| containerSecurityContext.seccompProfile | object | Seccomp profile. | `{"type":"RuntimeDefault"}` |
| containerSecurityContext.seccompProfile.type | string | Seccomp profile type. | `"RuntimeDefault"` |
| deploymentAnnotations | object | Annotations on all Rasa deployments. | `{}` |
| deploymentLabels | object | Labels on all Rasa deployments. | `{}` |
| dnsConfig | object | Pod DNS config. | `{}` |
| dnsPolicy | string | Pod DNS policy. | `""` |
| envFrom | list | Environment from ConfigMaps or Secrets. | `[]` |
| extraArgs | list | Arguments appended to the generated ones. Ignored when args is set. | `[]` |
| extraContainers | list | Sidecar containers. | `[]` |
| extraEnv | list | Environment variables added to the generated ones. | `[]` |
| extraVolumeMounts | list | Additional volume mounts. | `[]` |
| extraVolumes | list | Additional volumes. | `[]` |
| fullnameOverride | string | Overrides the full name prefix for all chart resources. | `""` |
| global.extraDeploymentLabels | object |  | `{}` |
| global.ingressAnnotations | object | Annotations added to the ingress. Merged with rasa.ingress.annotations, which wins. | `{}` |
| global.ingressClassName | string | Ingress class. Used only when rasa.ingress.className is empty. | `""` |
| global.ingressHost | string | Sets the host of every ingress rule. Overrides rasa.ingress.hosts[*].host rather than acting as a fallback. | `nil` |
| hostAliases | list | Pod-level hostname resolution overrides. | `[]` |
| hostNetwork | bool | Let the pod use the node network namespace. | `false` |
| image.pullPolicy | string | Image pull policy. | `"IfNotPresent"` |
| image.repository | string | Image repository. | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` |
| image.tag | string | Image tag. Empty uses the chart appVersion. Set an exact tag to pin independently of chart upgrades. | `""` |
| imagePullSecrets | list | Secrets for pulling images from private registries. | `[]` |
| ingress | object | Ingress for the Rasa Pro server. | `{"annotations":{},"className":"","enabled":false,"hosts":[],"labels":{},"tls":[]}` |
| ingress.annotations | object | Ingress annotations. | `{}` |
| ingress.className | string | Ingress class name. | `""` |
| ingress.enabled | bool | Create an Ingress. | `false` |
| ingress.hosts | list | Hosts and paths. Empty by default, so an ingress you enable is one you fully describe. global.ingressHost overrides each host but cannot create one. | `[]` |
| ingress.labels | object | Ingress labels. | `{}` |
| ingress.tls | list | TLS configuration. Keep the hosts in sync with ingress.hosts; not derived from global.ingressHost. | `[]` |
| initContainers | list | Init containers. | `[]` |
| lifecycle | object | Container lifecycle hooks (postStart / preStop). | `{}` |
| livenessProbe | object | Liveness probe. | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":null,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"terminationGracePeriodSeconds":30,"timeoutSeconds":5}` |
| livenessProbe.enabled | bool | Enable the liveness probe. | `true` |
| livenessProbe.failureThreshold | int | Failures before the container is restarted. | `6` |
| livenessProbe.httpGet | object | Liveness probe HTTP request. | `{"path":"/","port":null,"scheme":"HTTP"}` |
| livenessProbe.httpGet.port | string | Probed container port. Empty follows port. | `nil` |
| livenessProbe.initialDelaySeconds | int | Delay before the first liveness probe. | `15` |
| livenessProbe.periodSeconds | int | Liveness probe interval, seconds. | `15` |
| livenessProbe.successThreshold | int | Consecutive successes needed after a failure. | `1` |
| livenessProbe.terminationGracePeriodSeconds | int | Grace period after a liveness probe failure. | `30` |
| livenessProbe.timeoutSeconds | int | Liveness probe timeout, seconds. | `5` |
| mountModelsVolume | bool | Mount an emptyDir for models at /app/models. | `true` |
| nameOverride | string | Overrides the chart name used in resource names. | `""` |
| networkPolicy.allowIngressFrom | list | Peers allowed to reach the server port. Required with denyAll; nodeCIDR only covers kubelet probes. | `[]` |
| networkPolicy.denyAll | bool | Default-deny all ingress and egress before more specific rules apply. | `false` |
| networkPolicy.dnsNamespace | string | Namespace running cluster DNS, matched on kubernetes.io/metadata.name. | `"kube-system"` |
| networkPolicy.egressPorts | list | Destination ports the server may reach. Defaults cover HTTP and HTTPS only — add your tracker store, broker and model storage ports. | `[{"port":443,"protocol":"TCP"},{"port":80,"protocol":"TCP"}]` |
| networkPolicy.enabled | bool | Create NetworkPolicy resources. Only explicitly allowed traffic is permitted. | `false` |
| networkPolicy.nodeCIDR | list | Node IP ranges allowed to reach pods. Required for kubelet probes when enabled. | `[]` |
| nodeSelector | object | Node selector. | `{}` |
| overrideEnv | list | Replaces the generated environment wholesale, including RASA_LICENSE. Empty keeps it. Use extraEnv to add. | `[]` |
| persistence | object | PersistentVolumeClaim for model data at /app/working-data. | `{"create":false,"hostPath":{"enabled":false},"storageCapacity":"1Gi","storageClassName":null,"storageRequests":"1Gi"}` |
| podAnnotations | object | Pod annotations. | `{}` |
| podLabels | object | Labels on all Rasa pods. | `{}` |
| podSecurityContext | object | Pod-level security context. | `{"enabled":true}` |
| rasa.allowUnauthenticatedApi | bool | Accept an unauthenticated API: silences the install warning and the render refusal. | `false` |
| rasa.authToken | string | Secret holding the static bearer token for API requests. Unset by default. | `nil` |
| rasa.cors | string | Allowed CORS origin. Restrict to specific domains in production. | `"*"` |
| rasa.debugMode | bool |  | `false` |
| rasa.enableApi | bool | Serve the Rasa HTTP API. On by default because rasa run exits when it has neither a model nor the API. The API is unauthenticated until you set authToken or jwtSecret. | `true` |
| rasa.endpoints | object | DEPRECATED. Rendered to /app/endpoints.yml: tracker store, event broker, lock store, action endpoint, NLG server. | `{}` |
| rasa.endpointsRaw | string | DEPRECATED. Raw endpoints.yml as a string, deep-merged with endpoints, which wins. Malformed YAML fails the render. | `""` |
| rasa.environment | string | Rasa runtime environment. 'production' disables development-only defaults. | `"development"` |
| rasa.integrations | object | Rendered to /app/integrations.yml (Mantle: LLM, model groups, channels, MCP servers, tracing). Replaces the file in your trained project, so supply all of it. | `{}` |
| rasa.integrationsRaw | string |  | `""` |
| rasa.jwtMethod | string | JWT algorithm. | `"HS256"` |
| rasa.jwtSecret | string | Secret holding the JWT signing secret for API requests. Unset by default; pair with jwtMethod. | `nil` |
| rasa.license | object | Secret holding the Rasa Pro licence. Required. Passed to the container as RASA_LICENSE. | `{"secretKey":"RASA_LICENSE","secretName":"rasa-secrets"}` |
| rasa.logging | object | Logging settings. | `{"logLevel":"info"}` |
| rasa.logging.logLevel | string | Rasa log level. | `"info"` |
| rasa.mountDefaultConfigmap | bool | Render integrations and endpoints into a ConfigMap mounted at /app/integrations.yml and /app/endpoints.yml. Set false to supply them yourself. | `true` |
| rasa.port | int | Port Rasa binds. The container port, Service targetPort and probes all follow it. | `5005` |
| rasa.telemetry | object | Telemetry settings. | `{"debug":false,"enabled":true}` |
| rasa.telemetry.debug | bool | Print telemetry payloads to stdout. | `false` |
| rasa.telemetry.enabled | bool | Send anonymous usage data to Rasa. | `true` |
| readinessProbe | object | Readiness probe. | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":null,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| readinessProbe.enabled | bool | Enable the readiness probe. | `true` |
| readinessProbe.failureThreshold | int | Failures before the pod is marked unready. | `6` |
| readinessProbe.httpGet | object | Readiness probe HTTP request. | `{"path":"/","port":null,"scheme":"HTTP"}` |
| readinessProbe.httpGet.port | string | Probed container port. Empty follows port. | `nil` |
| readinessProbe.initialDelaySeconds | int | Delay before the first readiness probe. | `15` |
| readinessProbe.periodSeconds | int | Readiness probe interval, seconds. | `15` |
| readinessProbe.successThreshold | int | Consecutive successes needed after a failure. | `1` |
| readinessProbe.timeoutSeconds | int | Readiness probe timeout, seconds. | `5` |
| replicaCount | int | Number of Rasa Pro replicas. | `1` |
| resources | object | Resource requests and limits. | `{}` |
| service | object | Service exposing the Rasa Pro server. | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":5005,"targetPort":null,"type":"ClusterIP"}` |
| service.annotations | object | Service annotations. | `{}` |
| service.port | int | Service port. | `5005` |
| service.targetPort | string | Container port traffic is forwarded to. Empty follows port. | `nil` |
| service.type | string | Service type. | `"ClusterIP"` |
| serviceAccount | object | Service account for the Rasa pod. | `{"annotations":{},"create":true,"name":""}` |
| serviceAccount.annotations | object | Service account annotations. | `{}` |
| serviceAccount.create | bool | Create the service account. | `true` |
| serviceAccount.name | string | Service account name. Empty generates one. | `""` |
| strategy | object | Deployment strategy. | `{}` |
| terminationGracePeriodSeconds | int | Grace period after SIGTERM before SIGKILL. Unset uses the Kubernetes default of 30. | `nil` |
| tolerations | list | Tolerations. | `[]` |
| topologySpreadConstraints | list | Pod spread across zones or nodes. An entry without labelSelector defaults to this component's pods. | `[]` |
