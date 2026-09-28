# studio

A Rasa Studio Helm chart for Kubernetes

![Version: 3.0.0-rc.33](https://img.shields.io/badge/Version-3.0.0--rc.33-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Architecture

The Studio chart deploys a unified Studio image. The app serves both the API and the web client; all components share a single host set via `global.ingressHost` and the `studio-secrets` Kubernetes Secret.

| Component | Description | Ingress path | Toggle |
|-----------|-------------|--------------|--------|
| **app** | Studio API server and web client — handles business logic and data persistence with Better Auth | `/api` and `/` | always on |
| **event-ingestion** | Kafka consumer that writes conversation events to the database | internal | `eventIngestion.mode` (`colocated`, `separate`, or `disabled`) |
| **rasa** | Rasa Pro model server (OCI subchart dependency) | `/modelservice` | `rasa.enabled` (default: `true`) |

## Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+
- A PostgreSQL instance (version 14+ recommended) accessible from the cluster
- A Kafka broker (unless `eventIngestion.mode: disabled`) accessible from the cluster
- A Rasa Pro license key

## Before You Install

### 1. Build chart dependencies

The Rasa Pro server is bundled as an OCI subchart. Before installing, fetch it:

```console
$ helm dependency build ./charts/studio
```

### 2. Create the `studio-secrets` Secret

All components read credentials from a single Kubernetes Secret named `studio-secrets` by default.
A ready-made template is included at the chart root:

```console
$ cp charts/studio/secrets.yaml my-studio-secrets.yaml
# Edit my-studio-secrets.yaml — base64-encode each value
$ kubectl apply -f my-studio-secrets.yaml
```

Or create it imperatively:

```console
$ kubectl create secret generic studio-secrets \
    --from-literal=DATABASE_PASSWORD="<db-password>" \
    --from-literal=AUTH_SECRET="<random-string-min-32-chars>" \
    --from-literal=RASA_PRO_LICENSE_SECRET_KEY="<rasa-pro-license>" \
    --from-literal=OPENAI_API_KEY_SECRET_KEY="<openai-api-key>" \
    --from-literal=KAFKA_SASL_PASSWORD="<kafka-sasl-password>"
```

> **Note:** `AUTH_SECRET` must be at least 32 characters long.

> **Note:** The secret name `studio-secrets` is the default referenced throughout `values.yaml`. If you use a different name, override every `secretName` field accordingly.

## Installing the Chart

You can install the chart from either the OCI registry or the GitHub Helm repository.

### Option 1: Install from OCI Registry

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 3.0.0-rc.33
```

### Option 2: Install from GitHub Helm Repository

First, add the Rasa Helm repository:

```console
$ helm repo add rasa https://helm.rasa.com/charts
$ helm repo update
```

Then install the chart:

```console
$ helm install my-release rasa/studio --version 3.0.0-rc.33
```

## Quick Start

Minimum `values.yaml` to get Studio running (assumes `studio-secrets` already created):

```yaml
global:
  ingressHost: studio.example.com
  ingressClassName: nginx

config:
  database:
    host: "postgres.example.com"
    username: "studio"
    databaseName: "studio"

# Disable event ingestion for a minimal setup — requires Kafka in colocated or separate mode.
# See the "Event Ingestion and Kafka" section to configure it once your broker is ready.
eventIngestion:
  mode: disabled
```

```console
$ helm dependency build ./charts/studio
$ helm install my-release rasa/studio -f values.yaml
```

After install, the app migration Job runs automatically as a pre-install hook. Monitor progress with:

```console
$ kubectl get jobs
$ kubectl logs job/my-release-studio-app-migration
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Pull the Chart

You can pull the chart from either source:

### From OCI Registry:

```console
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 3.0.0-rc.33
```

### From GitHub Helm Repository:

```console
$ helm pull rasa/studio --version 3.0.0-rc.33
```

## General Configuration

- **imagePullSecrets**: If you're using a private Docker registry, provide the necessary credentials in this section.

> **Note:** For application specific settings, please refer to our [documentation](https://rasa.com/docs/) and bellow you can find the full list of values.

## Ingress Host Configuration

**Single-host install (recommended):** set one value and the Studio app
and Rasa Pro model-service ingresses — plus every derived URL
(`window.MS_API_URL`, `RASA_MODEL_SERVER_BASE_URL`, `WEB_CLIENT_URL`) —
resolve from it:

```yaml
global:
  ingressHost: studio.example.com
```

**Split-host install** (model service on its own hostname): leave
`global.ingressHost` unset — it overrides per-host values when set — and
configure hosts individually:

```yaml
app:
  ingress:
    hostName: studio.example.com         # Studio app
rasa:
  rasa:
    ingress:
      hosts:
        - host: models.example.com       # model service
          paths:
            - path: /modelservice
              pathType: Prefix
```

Host resolution is two-level: `global.ingressHost` wins when set; otherwise
each ingress uses its own host (`app.ingress.hostName`,
`rasa.ingress.hosts[0].host`). No host value
is enforced by the schema — an install without any host renders empty
(match-all) ingress rules and relative browser URLs.

## Database Configuration

Studio requires a PostgreSQL database for the app services.

### Database Configuration

The `config.database` section defines the database connection settings used by the Studio app:

```yaml
config:
  database:
    host: "postgres.example.com"
    port: "5432"
    username: "studio_user"
    password:
      secretName: "studio-secrets"
      secretKey: "DATABASE_PASSWORD"
    databaseName: "studio"
```

### Using Secrets for Sensitive Values

Database credentials can be provided as plain values or secret references:

**Username from secret:**
```yaml
config:
  database:
    username:
      secretName: "my-db-secret"
      secretKey: "DB_USERNAME"
```

**App database name from secret:**
```yaml
config:
  database:
    databaseName:
      secretName: "my-db-secret"
      secretKey: "DB_NAME"
```

**Password (always from secret):**
```yaml
config:
  database:
    password:
      secretName: "studio-secrets"
      secretKey: "DATABASE_PASSWORD"
```

### AWS RDS IAM Authentication

For AWS RDS with IAM authentication, configure the following:

```yaml
config:
  database:
    host: "mydb.123456789012.us-east-1.rds.amazonaws.com"
    port: "5432"
    username: "studio_user"
    useAwsIamAuth: "true"
    awsRegion: "us-east-1"
    iamDbUsername: "iam_db_user"
    databaseName: "studio"
```

**Note:** When `useAwsIamAuth` is set to `"true"`, the password field is not required as authentication is handled via IAM.

## Chart Dependencies — Rasa Pro

Studio bundles the [Rasa Pro Helm chart](https://helm.rasa.com) as an optional OCI subchart:

```yaml
rasa:
  enabled: true  # set false to use an external Rasa Pro instance
```

When `rasa.enabled: true`, the bundled Rasa Pro is pre-configured to:
- Read the license and OpenAI API key from `studio-secrets`
- Expose the model server at `/modelservice` on the shared ingress host
- Use `/modelservice` for liveness and readiness probes on port `8000`
- Inject `RASA_MODEL_SERVER_BASE_URL` and `CORS_ORIGINS` via the `shared-environment` ConfigMap, derived from `config.connectionType`, the ingress host, and the model service ingress path
- Inject `STUDIO_AUTH_URL` (in-cluster Studio app service URL) via the same ConfigMap, so the model service can introspect Studio sessions for authentication
- Set `window.MS_API_URL` on the web client to the model service external host (without the ingress path prefix)
- Use a `Recreate` update strategy (no rolling updates — stateful model loading)
- Use service name `rasapro` (hardcoded via `fullnameOverride`) — this is the hostname the app uses internally

> **Note:** the subchart is `rasa` 3.0.0, which puts deployment settings at its own
> root rather than under a nested `rasa` key — so these are `rasa.image`,
> `rasa.resources`, `rasa.ingress`, and `rasa.rasa.*` holds only Rasa's own config
> (`port`, `mountDefaultConfigmap`). Old paths are ignored, not rejected. Upgrading an
> existing release also needs the Rasa Deployment deleted first, because its selector
> changed and Kubernetes treats that field as immutable:
> `kubectl delete deployment rasapro -n <namespace>`.

When `rasa.enabled: false`, override the **browser** model-service URL via the web client ConfigMap (the Studio API process does not read `MS_API_URL`):

```yaml
app:
  webClient:
    config:
      MS_API_URL: "https://models.example.com"
```

### Rasa Pro Model Service Environment Variables

The following environment variables can be configured on the Rasa Pro model server container via `rasa.overrideEnv`:

| Variable | Description | Default |
|----------|-------------|---------|
| `MAX_PARALLEL_TRAININGS` | Maximum number of parallel model trainings the model service will run simultaneously | `10` |
| `MAX_PARALLEL_BOT_RUNS` | Maximum number of parallel bot conversations the model service will handle simultaneously | `10` |
| `RASA_REMOTE_STORAGE` | Cloud storage backend where trained models are uploaded (e.g. `aws`, `gcs`, `azure`). Leave unset to disable remote storage. | `None` |

Example:

```yaml
rasa:
  enabled: true
  rasa:
    overrideEnv:
      - name: MAX_PARALLEL_TRAININGS
        value: "5"
      - name: MAX_PARALLEL_BOT_RUNS
        value: "20"
      - name: RASA_REMOTE_STORAGE
        value: "aws"
```

### Studio App Model Service Environment Variables

The following environment variables control how Studio App polls and manages the Rasa Pro model service, configurable via `app.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| `TRAINING_POLLING_INTERVAL_MS` | Interval (ms) at which Studio App polls the model service for training status updates | `1000` |
| `MODEL_POLLING_INTERVAL_MS` | Interval (ms) at which Studio App polls the model service for model status updates | `2000` |
| `MODEL_INACTIVE_AFTER_MS` | Time (ms) after which an unused model is marked as inactive | `3600000` (1 hour) |

Example:

```yaml
app:
  env:
    - name: TRAINING_POLLING_INTERVAL_MS
      value: "10000"
    - name: MODEL_POLLING_INTERVAL_MS
      value: "60000"
    - name: MODEL_INACTIVE_AFTER_MS
      value: "600000"
```

## URL Scheme (`connectionType`)

`config.connectionType` sets the URL **scheme** (`http` or `https`) for all externally visible URLs the chart derives from the ingress host:

- app `API_URL`, `BETTER_AUTH_BASE_URL`, and `WEB_CLIENT_URL`
- the app-served web client's `API_ENDPOINT`
- the model service `RASA_MODEL_SERVER_BASE_URL` and `window.MS_API_URL`
- `CORS_ORIGINS`

Set it to `"https"` when clients reach these hosts over TLS:

```yaml
config:
  connectionType: "https"  # default: "http"
```

It does **not** affect in-cluster service-to-service calls — those use hardcoded `http://` service names (e.g. app → Rasa Pro at `http://rasapro`). If your ingress terminates TLS externally while pods communicate over plain HTTP inside the cluster (the common setup), keep the default `"http"`.

## Event Ingestion and Kafka

The event-ingestion component consumes Rasa Pro conversation events from a Kafka broker. Configure the connection via environment variables:

```yaml
eventIngestion:
  env:
    - name: KAFKA_BROKER_ADDRESS
      value: "kafka-broker:9092"
    - name: KAFKA_TOPIC
      value: "rasa-events"
```

> **Note:** A user-supplied `env` list replaces the chart defaults wholesale — always carry over `KAFKA_TOPIC`, `KAFKA_DLQ_TOPIC`, `KAFKA_GROUP_ID`, `KAFKA_SASL_PASSWORD`.

### SASL Authentication

```yaml
eventIngestion:
  env:
    - name: KAFKA_BROKER_ADDRESS
      value: "kafka.example.com:9092"
    - name: KAFKA_SASL_MECHANISM
      value: "SCRAM-SHA-512"
    - name: KAFKA_SASL_USERNAME
      value: "studio"
    - name: KAFKA_SASL_PASSWORD
      valueFrom:
        secretKeyRef:
          name: studio-secrets
          key: KAFKA_SASL_PASSWORD
    - name: KAFKA_TOPIC
      value: "rasa-events"
    - name: KAFKA_DLQ_TOPIC
      value: "rasa-events-dlq"
    - name: KAFKA_GROUP_ID
      value: "studio"
```

> **Note:** A user-supplied `env` list replaces the chart defaults wholesale — always carry over `KAFKA_TOPIC`, `KAFKA_DLQ_TOPIC`, `KAFKA_GROUP_ID`, `KAFKA_SASL_PASSWORD`.

### SSL/TLS

```yaml
eventIngestion:
  env:
    - name: KAFKA_ENABLE_SSL
      value: "true"
    - name: KAFKA_CUSTOM_SSL
      value: "true"
    - name: KAFKA_REJECT_UNAUTHORIZED
      value: "true"
    # Mount custom certificates via eventIngestion.volumes / eventIngestion.volumeMounts
    # then reference the paths below:
    - name: KAFKA_CA_FILE
      value: "/etc/ssl/kafka/ca.crt"
    - name: KAFKA_CERT_FILE
      value: "/etc/ssl/kafka/tls.crt"
    - name: KAFKA_KEY_FILE
      value: "/etc/ssl/kafka/tls.key"
```

> **Note:** A user-supplied `env` list replaces the chart defaults wholesale — always carry over `KAFKA_TOPIC`, `KAFKA_DLQ_TOPIC`, `KAFKA_GROUP_ID`, `KAFKA_SASL_PASSWORD`.

Set `eventIngestion.mode` to `colocated` (default), `separate`, or `disabled`. `colocated` runs the consumer in the app pod; `separate` deploys a dedicated workload. Do not run dual consumers—the chart fails validation when configuration would do so. To disable event ingestion entirely, use `eventIngestion.mode: disabled`.

**Which keys apply when:**

| Applies when | Keys |
| --- | --- |
| Both `colocated` and `separate` | Kafka-related env under `eventIngestion.env` |
| Only `mode: separate` | `replicaCount`, `image`, `resources`, `serviceAccount`, HPA/`autoscaling`, scheduling (`nodeSelector` / `affinity` / `tolerations`) |
| `colocated` (on app) and `separate` (on sibling) | `volumes`, `volumeMounts`, `envFrom`, `additionalContainers` |

## Network Policies

The chart ships a default-deny network policy model. Enable it to restrict pod-to-pod traffic:

```yaml
networkPolicy:
  enabled: true
  denyAll: true
```

All policies are named after the release and select only its pods.

| policy | created when | effect |
|---|---|---|
| `deny-all` | `denyAll: true` | drops all ingress and egress |
| `allow-dns-access` | always | UDP/TCP 53 to `dnsNamespace` |
| `kubelet-access` | `nodeCIDR` set | probe traffic from the nodes to the app pods |
| `allow-egress` | `egressPorts` non-empty | outbound to the listed ports |
| `allow-ingress` | `allowIngressFrom` non-empty | inbound from the listed peers |

With `denyAll: true` you **must** set the last three, or Studio cannot reach its database and nothing can reach Studio:

```yaml
networkPolicy:
  enabled: true
  denyAll: true
  nodeCIDR:
    - ipBlock:
        cidr: 10.0.0.0/16        # your node CIDR, for kubelet probes
  egressPorts:
    - { port: 443, protocol: TCP }
    - { port: 80,  protocol: TCP }
    - { port: 5432, protocol: TCP }   # PostgreSQL
    - { port: 9092, protocol: TCP }   # Kafka
  allowIngressFrom:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
```

> **Note:** requires a CNI that enforces `NetworkPolicy` (Calico, Cilium, Antrea). Without one, enabling this has no effect.

> **Note:** these policies cover Studio's own pods. The bundled `rasa` subchart has its own `rasa.networkPolicy.*` settings and is not affected by enabling these.

## Database Migration

The app runs a `pre-install,pre-upgrade` Helm hook Job that applies database schema migrations before any pods start. On first install this job creates all tables; on upgrades it applies incremental migrations.

Monitor migration progress:

```console
$ kubectl get jobs
$ kubectl logs job/<release-name>-studio-app-migration
```

**If a migration fails**, the job is preserved for debugging — inspect the logs before retrying:

```console
$ kubectl logs job/<release-name>-studio-app-migration
```

Once you have identified and resolved the root cause, re-run `helm upgrade`. The failed job is automatically cleaned up before the next migration attempt.

Enable `app.migration.waitForIt: true` to make the migration job wait for PostgreSQL to be reachable before running. Useful when the database may not be immediately available at deploy time.

## Upgrading

When upgrading between chart versions, Helm runs the database migration hook automatically before updating the deployments. The `studio-secrets` Secret is not managed by the chart — it persists across upgrades.

To upgrade to a new version:

```console
$ helm dependency build ./charts/studio
$ helm upgrade my-release rasa/studio --version <new-version> -f values.yaml
```

Check the [chart changelog](https://github.com/RasaHQ/rasa-helm-charts/releases) for breaking changes before upgrading major versions.

### Upgrading to chart 3.0.0

Chart 3.0.0 is a hard break: rename `backend` values to `app`; it uses the unified `studio` image and requires Studio ≥ 2.0.0. The default image tag is a placeholder until a published unified image is promoted. Configure web client runtime values under `app.webClient.config` (was top-level `webClient.environmentVariables`). Do not set `MS_API_URL` on `app.env` — only `app.webClient.config.MS_API_URL` affects `window.MS_API_URL`.

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

Additional breaking changes in 3.0.0:

- Bundled Keycloak is **removed**. Authentication is Better Auth on the app at
  `/api/auth/*` only — there is no `/auth` ingress or Keycloak Deployment.
  Delete leftover `keycloak`, `config.keycloak`, and
  `config.database.keycloakDatabaseName` from values (they are ignored). After
  upgrade, Helm prunes Keycloak resources that belonged to the release; remove
  unused `KEYCLOAK_*` secret keys, and do not drop the Keycloak Postgres
  database until users exist in Better Auth. See `helm get notes <release>`.
- Environment variables use native Kubernetes `EnvVar` lists. `app.environmentVariables`,
  `app.migration.environmentVariables`, and `eventIngestion.environmentVariables`
  were removed — define entries under `app.env`, `app.migration.env`, and
  `eventIngestion.env` as `- name/value` or `- name/valueFrom.secretKeyRef`
  (was `KEY: {value: ...}` / `KEY: {secret: {name, key}}`).
  Keys are rendered verbatim (no more automatic upper-casing), and a user-supplied
  list replaces the chart defaults wholesale — copy the defaults you want to keep.
- `app.webClient.environmentVariables` is now `app.webClient.config` — a plain
  `KEY: "value"` map of browser `window.*` globals (not container env). Flag values
  always render as quoted strings in config.js.
- `config.database.host` must be set to a real host; empty values are rejected by the
  values schema at install time.
- `Chart.yaml` now declares `appVersion`; the `tag` value is empty by default and
  only overrides the appVersion-derived image tag. The migration Job is bounded by
  `app.migration.backoffLimit` / `app.migration.activeDeadlineSeconds`.
- The `&dns_hostname` YAML anchor and its `config.ingressHost` key were
  **removed** — a value still set there is silently ignored, so move it
  before upgrading. For a single-host install set
  **`global.ingressHost`** once — the app and Rasa Pro model-service
  ingresses and every derived URL (`window.MS_API_URL`,
  `RASA_MODEL_SERVER_BASE_URL`) follow it. For a split-host install (model
  service on its own hostname) leave `global.ingressHost` unset and set
  `app.ingress.hostName` and `rasa.ingress.hosts[0].host` (model service) —
  `global.ingressHost` overrides the per-host values when set, so the two
  are mutually exclusive by design.

Better Auth is served by the app at `/api/auth/*`. Choose exactly one ingestion topology with `eventIngestion.mode`: `colocated` (default), `separate`, or `disabled`.

Helm does not delete resources that disappeared from the previous topology. After upgrade, remove the old backend, web-client, and event-ingestion resources as described in the chart release notes (`helm get notes <release-name>`).

## Values

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| app.additionalContainers | list | Additional containers to run alongside the main Studio App container. These containers will be part of the same pod and share the pod's network namespace. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] Ref: https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers | `[]` |
| app.affinity | object | Affinity rules for the app pods. This controls where the pods can be scheduled. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| app.annotations | object | Annotations to add to all Studio App resources. These annotations will be merged with deploymentAnnotations (deploymentAnnotations take precedence if keys conflict). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| app.authSecret | object | Secret used by the app to sign sessions and tokens. Must be at least 32 characters long. Stored in a Kubernetes secret. Required. | `{"secretKey":"AUTH_SECRET","secretName":"studio-secrets"}` |
| app.automountServiceAccountToken | bool | Whether the app pod is given a Kubernetes API token at /var/run/secrets/kubernetes.io/serviceaccount. Studio never calls the Kubernetes API, so the token is left out; set it to true if you add a sidecar that needs one. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ | `false` |
| app.autoscaling | object | Horizontal Pod Autoscaling configuration. This enables automatic scaling of the app deployment based on metrics. Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/ | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` |
| app.autoscaling.enabled | bool | Whether to enable horizontal pod autoscaling. | `false` |
| app.autoscaling.maxReplicas | int | Maximum number of replicas. | `100` |
| app.autoscaling.minReplicas | int | Minimum number of replicas. | `1` |
| app.autoscaling.targetCPUUtilizationPercentage | int | Target CPU utilization percentage. The HPA will scale the deployment to maintain this CPU utilization. Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details | `80` |
| app.env | list | Extra environment variables for the Studio App container, in native Kubernetes EnvVar format (name + value or valueFrom). NOTE: a user-supplied list REPLACES this default list wholesale (Helm does not merge lists) — copy the default entries you want to keep. NOTE: Do not set MS_API_URL here — the Studio API process does not read it. Override the browser model-service URL via app.webClient.config.MS_API_URL. Example:   - name: MY_VAR     value: "my-value"   - name: MY_SECRET_VAR     valueFrom:       secretKeyRef:         name: my-secret         key: MY_SECRET_KEY | `[{"name":"DELETE_CONVERSATIONS_CRON_EXPRESSION","value":"0 * * * *"}]` |
| app.envFrom | list | Additional environment variables from ConfigMap or Secret. These will be mounted as environment variables in the container. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables | `[]` |
| app.image | object | Container image settings for the app service. This section defines the container image settings for the app service. Ref: https://kubernetes.io/docs/concepts/containers/images/ | `{"name":"studio","pullPolicy":"IfNotPresent"}` |
| app.image.name | string | Unified Studio container image (API + web client + optional co-located ingestion). Chart 3.0.0 requires this image (Studio ≥ 2.0.0). Formerly studio-backend. | `"studio"` |
| app.image.pullPolicy | string | Container image pull policy. Valid values: Always, IfNotPresent, Never Always: Always pull the image IfNotPresent: Only pull if not present locally Never: Never pull the image Ref: https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy | `"IfNotPresent"` |
| app.ingress | object | How the app service is exposed externally. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/ | `{"additionalAnnotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` |
| app.ingress.additionalAnnotations | object | Additional annotations for the ingress resource. Example:   kubernetes.io/ingress.class: nginx   cert-manager.io/cluster-issuer: letsencrypt-prod Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| app.ingress.className | string | Ingress class name. This should match your cluster's ingress controller. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class | `""` |
| app.ingress.enabled | bool | Whether to create an ingress resource. | `true` |
| app.ingress.labels | object | Labels to add to the ingress resource. Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ | `{}` |
| app.ingress.tls | list | TLS configuration for the ingress. Example: - secretName: chart-example-tls   hosts:     - chart-example.local | `[]` |
| app.livenessProbe | object | Liveness probe configuration. This determines if the container is alive and functioning. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| app.livenessProbe.enabled | bool | Whether to enable the liveness probe. | `true` |
| app.livenessProbe.failureThreshold | int | Number of failures before the container is considered unhealthy. | `6` |
| app.livenessProbe.httpGet | object | HTTP GET probe configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command | `{"path":"/api/health","port":4000,"scheme":"HTTP"}` |
| app.livenessProbe.httpGet.path | string | Path to check for liveness. | `"/api/health"` |
| app.livenessProbe.httpGet.port | int | Port to check for liveness. | `4000` |
| app.livenessProbe.httpGet.scheme | string | Protocol to use for the check. | `"HTTP"` |
| app.livenessProbe.initialDelaySeconds | int | Number of seconds to wait before starting probe. | `15` |
| app.livenessProbe.periodSeconds | int | How often to perform the probe. | `15` |
| app.livenessProbe.successThreshold | int | Minimum consecutive successes for the probe to be considered successful. | `1` |
| app.livenessProbe.timeoutSeconds | int | Number of seconds after which the probe times out. | `5` |
| app.migration | object | Database migration job configuration. This section controls the database schema migration process. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/job/ | `{"activeDeadlineSeconds":900,"affinity":{},"annotations":{},"automountServiceAccountToken":false,"backoffLimit":3,"enabled":true,"env":[],"image":{"name":"studio","pullPolicy":"IfNotPresent"},"nodeSelector":{},"podAnnotations":{},"podSecurityContext":{"enabled":true},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}},"serviceAccount":{"annotations":{},"create":false,"name":""},"tolerations":[],"waitForIt":false,"waitForItContainer":{"image":"postgres:18.6","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true,"runAsUser":999,"seccompProfile":{"type":"RuntimeDefault"}}}}` |
| app.migration.activeDeadlineSeconds | int | Hard wall-clock bound for the migration Job; size it to your worst-case migration duration. | `900` |
| app.migration.affinity | object | Affinity rules for the migration job. This controls where the job can be scheduled. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| app.migration.annotations | object | Annotations to add to the migration job resource. These annotations will be merged with deploymentAnnotations and helm hook annotations (helm hooks take precedence). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| app.migration.automountServiceAccountToken | bool | Whether the migration Job pod is given a Kubernetes API token. The migration only talks to PostgreSQL. | `false` |
| app.migration.backoffLimit | int | Number of retries before the migration Job is marked failed. | `3` |
| app.migration.enabled | bool | Whether to enable the database migration job. Set to false if you want to handle migrations manually. | `true` |
| app.migration.env | list | Extra environment variables for the migration job container, in native Kubernetes EnvVar format (name + value or valueFrom). NOTE: a user-supplied list REPLACES this default list wholesale (Helm does not merge lists) — copy the default entries you want to keep. | `[]` |
| app.migration.image | object | Image configuration for the migration job. | `{"name":"studio","pullPolicy":"IfNotPresent"}` |
| app.migration.image.name | string | Uses the same unified studio image with STUDIO_ROLE=migration. | `"studio"` |
| app.migration.image.pullPolicy | string | Container image pull policy. | `"IfNotPresent"` |
| app.migration.nodeSelector | object | Which nodes the migration job can run on. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector | `{}` |
| app.migration.podAnnotations | object | Annotations to add to the migration job pod. Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| app.migration.podSecurityContext | object | Security settings for the entire migration job pod. The restricted Pod Security Standard is already satisfied by the container-level contexts, so the pod-level equivalents are left commented out, matching the other Studio components. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ | `{"enabled":true}` |
| app.migration.podSecurityContext.enabled | bool | Whether to enable the pod security context. | `true` |
| app.migration.securityContext | object | Security settings for the migration container. The waitForIt init container has its own context under app.migration.waitForItContainer.securityContext. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` |
| app.migration.securityContext.allowPrivilegeEscalation | bool | Whether to allow privilege escalation. Should be false for security best practices. | `false` |
| app.migration.securityContext.capabilities | object | Linux capabilities configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container | `{"drop":["ALL"]}` |
| app.migration.securityContext.capabilities.drop | list | Capabilities to drop from the container. ALL drops all capabilities for maximum security. | `["ALL"]` |
| app.migration.securityContext.enabled | bool | Whether to enable the security context. | `true` |
| app.migration.securityContext.runAsNonRoot | bool | Whether to run the container as a non-root user. Should be true for security best practices. | `true` |
| app.migration.securityContext.seccompProfile | object | Seccomp profile configuration. Kept active because the restricted Pod Security Standard requires a seccomp profile, and the pod-level one above is commented out. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-seccomp-profile-for-a-container | `{"type":"RuntimeDefault"}` |
| app.migration.securityContext.seccompProfile.type | string | Seccomp profile type. | `"RuntimeDefault"` |
| app.migration.serviceAccount | object | Kubernetes service account used by the migration job pod. | `{"annotations":{},"create":false,"name":""}` |
| app.migration.serviceAccount.annotations | object | Annotations to add to the service account. | `{}` |
| app.migration.serviceAccount.create | bool | Whether to create a new service account. | `false` |
| app.migration.serviceAccount.name | string | Name of the service account to use. If not set and create is true, a name is generated using the fullname + "-db-migration" suffix. | `""` |
| app.migration.tolerations | list | Tolerations for the migration job. This allows the job to run on nodes with matching taints. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ | `[]` |
| app.migration.waitForIt | bool | Whether to wait for the database to be ready before running migrations. | `false` |
| app.migration.waitForItContainer | object | Configuration for the wait-for-it container. | `{"image":"postgres:18.6","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true,"runAsUser":999,"seccompProfile":{"type":"RuntimeDefault"}}}` |
| app.migration.waitForItContainer.image | string | Image used by the waitForIt init container. Only `pg_isready` is invoked from it, so this version does not need to match the database server version. | `"postgres:18.6"` |
| app.migration.waitForItContainer.securityContext | object | Security settings for the waitForIt init container. Defaults satisfy the restricted Pod Security Standard. NOTE: `runAsUser` is required because this image is configured to run as root; 999 is its built-in `postgres` user. Adjust it if you point `image` at a different waitForIt image. Ref: https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true,"runAsUser":999,"seccompProfile":{"type":"RuntimeDefault"}}` |
| app.migration.waitForItContainer.securityContext.allowPrivilegeEscalation | bool | Whether to allow privilege escalation. | `false` |
| app.migration.waitForItContainer.securityContext.capabilities | object | Linux capabilities configuration. | `{"drop":["ALL"]}` |
| app.migration.waitForItContainer.securityContext.capabilities.drop | list | Capabilities to drop from the container. | `["ALL"]` |
| app.migration.waitForItContainer.securityContext.enabled | bool | Whether to enable the security context. | `true` |
| app.migration.waitForItContainer.securityContext.runAsNonRoot | bool | Whether to run the container as a non-root user. | `true` |
| app.migration.waitForItContainer.securityContext.runAsUser | int | User ID to run the container as. | `999` |
| app.migration.waitForItContainer.securityContext.seccompProfile | object | Seccomp profile configuration. | `{"type":"RuntimeDefault"}` |
| app.migration.waitForItContainer.securityContext.seccompProfile.type | string | Seccomp profile type. | `"RuntimeDefault"` |
| app.nodeSelector | object | Which nodes the app pods can run on. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector | `{}` |
| app.podAnnotations | object | Annotations to add to the app pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-app: runtime/default Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| app.podSecurityContext | object | Security settings for the entire pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ | `{"enabled":true}` |
| app.podSecurityContext.enabled | bool | Whether to enable the pod security context. | `true` |
| app.readinessProbe | object | Readiness probe configuration. This determines if the container is ready to receive traffic. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| app.readinessProbe.enabled | bool | Whether to enable the readiness probe. | `true` |
| app.readinessProbe.failureThreshold | int | Number of failures before the container is considered not ready. | `6` |
| app.readinessProbe.httpGet | object | HTTP GET probe configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-readiness-probe | `{"path":"/api/health","port":4000,"scheme":"HTTP"}` |
| app.readinessProbe.httpGet.path | string | Path to check for readiness. | `"/api/health"` |
| app.readinessProbe.httpGet.port | int | Port to check for readiness. | `4000` |
| app.readinessProbe.httpGet.scheme | string | Protocol to use for the check. | `"HTTP"` |
| app.readinessProbe.initialDelaySeconds | int | Number of seconds to wait before starting probe. | `15` |
| app.readinessProbe.periodSeconds | int | How often to perform the probe. | `15` |
| app.readinessProbe.successThreshold | int | Minimum consecutive successes for the probe to be considered successful. | `1` |
| app.readinessProbe.timeoutSeconds | int | Number of seconds after which the probe times out. | `5` |
| app.replicaCount | int | Number of replicas for the Studio App deployment. Increase this value for high availability and better load distribution. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#replicas | `1` |
| app.resources | object | Resource limits and requests for Studio App. This controls the compute resources allocated to the app container. Ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ | `{}` |
| app.securityContext | object | Security settings for the app container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` |
| app.securityContext.allowPrivilegeEscalation | bool | Whether to allow privilege escalation. Should be false for security best practices. | `false` |
| app.securityContext.capabilities | object | Linux capabilities configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container | `{"drop":["ALL"]}` |
| app.securityContext.capabilities.drop | list | Capabilities to drop from the container. ALL drops all capabilities for maximum security. | `["ALL"]` |
| app.securityContext.enabled | bool | Whether to enable the security context. | `true` |
| app.securityContext.runAsNonRoot | bool | Whether to run the container as a non-root user. Should be true for security best practices. | `true` |
| app.securityContext.seccompProfile | object | Seccomp profile configuration. Kept active because the restricted Pod Security Standard requires a seccomp profile, and the pod-level one above is commented out. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-seccomp-profile-for-a-container | `{"type":"RuntimeDefault"}` |
| app.securityContext.seccompProfile.type | string | Seccomp profile type. | `"RuntimeDefault"` |
| app.service | object | How the app service is exposed within the cluster. Ref: https://kubernetes.io/docs/concepts/services-networking/service/ | `{"port":80,"targetPort":4000,"type":"ClusterIP"}` |
| app.service.port | int | Port number for the service. | `80` |
| app.service.targetPort | int | Target port in the container. This should match the port your application listens on. | `4000` |
| app.service.type | string | Type of Kubernetes service. Valid values: ClusterIP, NodePort, LoadBalancer, ExternalName Ref: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types | `"ClusterIP"` |
| app.serviceAccount | object | Kubernetes service account used by the app pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ | `{"annotations":{},"create":false,"name":""}` |
| app.serviceAccount.annotations | object | Annotations to add to the service account. Useful for cloud provider specific configurations. | `{}` |
| app.serviceAccount.create | bool | Whether to create a new service account. | `false` |
| app.serviceAccount.name | string | Name of the service account to use. If not set and create is true, a name is generated using the fullname template. | `""` |
| app.tolerations | list | Tolerations for the app pods. This allows the pods to run on nodes with matching taints. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ | `[]` |
| app.webClient | object | Browser runtime config for the unified app (no separate web-client Deployment). config.js is mounted into the app pod at /usr/src/app/webclient/config.js. | `{"config":{}}` |
| app.webClient.config | object | Feeds browser window.* globals rendered into the config.js ConfigMap mounted at /usr/src/app/webclient/config.js on the app pod. Plain scalar map (KEY: "value") — these are NOT container environment variables and cannot reference secrets (ConfigMap only). Used for feature flags (FEATURE_FLAG_*), MS_API_URL (window.MS_API_URL), CURRENT_VERSION_NUMBER, etc. | `{}` |
| config.affinity | object | Pod affinity and anti-affinity rules for all deployments. These settings can be overridden by component-specific configurations. | `{}` |
| config.connectionType | string | Define the URL scheme (`http` or `https`) for externally derived URLs (ingress-based API_URL, WEB_CLIENT_URL, web client API_ENDPOINT, model-service public URLs, CORS_ORIGINS, etc.). Valid values: "http" or "https". Does not change in-cluster http:// service-to-service calls. | `"http"` |
| config.database | object | The postgres database instance details for Studio to connect to. This section configures the database connection parameters for Studio. | `{"awsRegion":"","databaseName":"studio","host":"DATABASE.HOST.NAME","iamDbUsername":"","password":{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"},"port":"5432","preferSSL":"true","queryParams":"","rejectUnauthorized":"","useAwsIamAuth":"","username":""}` |
| config.database.awsRegion | string | The AWS region for the database. Needed if you want to use AWS IAM authentication for the database. | `""` |
| config.database.databaseName | string | The database name for Studio app services. This is used by Studio to store its data. Can be specified as a plain string value or as a secret reference. Plain value example: databaseName: "studio" Secret reference example: databaseName:   secretName: "my-secret"   secretKey: "DB_NAME" | `"studio"` |
| config.database.host | string | The database host name or IP address where PostgreSQL is running. Example: "postgres.example.com" or "10.0.0.1" Placeholder value — you MUST set this; an empty value is rejected by the schema. | `"DATABASE.HOST.NAME"` |
| config.database.iamDbUsername | string | The IAM database username for the database. Needed if you want to use AWS IAM authentication for the database. | `""` |
| config.database.password | object | The database password configuration. This references a Kubernetes secret containing the database password. | `{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"}` |
| config.database.port | string | The database port number for PostgreSQL. Default PostgreSQL port is 5432 | `"5432"` |
| config.database.preferSSL | string | Set to true if you want to use SSL for database connection. When enabled, Studio will attempt to establish an encrypted connection to the database. | `"true"` |
| config.database.queryParams | string | The database connection URL query parameters. These parameters are used to configure the database connection. Example: "sslmode=require&connect_timeout=30" | `""` |
| config.database.rejectUnauthorized | string | If true, the server will reject database connections which are not present in the list of supplied CAs. This provides additional security by ensuring only trusted certificates are accepted. | `""` |
| config.database.useAwsIamAuth | string | Set to true if you want to use AWS IAM authentication for the database. | `""` |
| config.database.username | string | The database username for Studio to connect with. This user should have appropriate permissions on the database. Can be specified as a plain string value or as a secret reference. Plain value example: username: "studio" Secret reference example: username:   secretName: "my-secret"   secretKey: "DB_USERNAME" | `""` |
| config.nodeSelector | object | Common pod scheduling configuration for all deployments. These settings can be overridden by component-specific configurations. Not possible to combine with component-specific configurations for each scheduling option. | `{}` |
| config.tolerations | list | Pod tolerations for all deployments. These settings can be overridden by component-specific configurations. | `[]` |
| deploymentAnnotations | object | Annotations to add to all Studio resources. These annotations are applied globally to all resources (Deployments, Services, Ingresses, Jobs, HPAs, ConfigMaps, ServiceAccounts). Component-specific annotations can override these values if keys conflict. Example:   key: "value" Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| deploymentLabels | object | Labels to add to all Studio deployment. | `{}` |
| dnsConfig | object | Pod's DNS config # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config | `{}` |
| dnsPolicy | string | Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy | `""` |
| eventIngestion.additionalContainers | list | Additional containers to run alongside the main Event Ingestion container. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] | `[]` |
| eventIngestion.affinity | object | Affinity rules for the event ingestion pods. Applies only when eventIngestion.mode is separate. | `{}` |
| eventIngestion.annotations | object | Annotations to add to all Studio Event Ingestion resources. These annotations will be merged with deploymentAnnotations (deploymentAnnotations take precedence if keys conflict). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| eventIngestion.automountServiceAccountToken | bool | Whether the event ingestion pod is given a Kubernetes API token. Ingestion only talks to Kafka and PostgreSQL. Applies only when eventIngestion.mode is separate. | `false` |
| eventIngestion.autoscaling | object | Horizontal Pod Autoscaling configuration. Applies only when eventIngestion.mode is separate. | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` |
| eventIngestion.autoscaling.enabled | bool | Whether to enable horizontal pod autoscaling. Applies only when eventIngestion.mode is separate. | `false` |
| eventIngestion.autoscaling.maxReplicas | int | Maximum number of replicas. Applies only when eventIngestion.mode is separate. | `100` |
| eventIngestion.autoscaling.minReplicas | int | Minimum number of replicas. Applies only when eventIngestion.mode is separate. | `1` |
| eventIngestion.autoscaling.targetCPUUtilizationPercentage | int | Target CPU utilization percentage. Applies only when eventIngestion.mode is separate. | `80` |
| eventIngestion.env | list | Extra environment variables for the event ingestion consumers, in native Kubernetes EnvVar format (name + value or valueFrom). Injected into the app container when mode is colocated, and into the sibling ingestion Deployment when mode is separate. NOTE: a user-supplied list REPLACES this default list wholesale (Helm does not merge lists) — copy the default entries you want to keep (KAFKA_TOPIC, KAFKA_DLQ_TOPIC, KAFKA_GROUP_ID, KAFKA_SASL_PASSWORD). Optional Kafka settings (add as needed):   - name: KAFKA_BROKER_ADDRESS      # address of the Kafka broker (required for ingestion)     value: "kafka.example.com:9092"   - name: KAFKA_ENABLE_SSL          # enable SSL for Kafka connections     value: "true"   - name: KAFKA_CUSTOM_SSL          # use custom SSL certificates for Kafka     value: "true"   - name: KAFKA_CA_FILE             # path to the CA certificate file     value: "/certs/ca.pem"   - name: KAFKA_KEY_FILE            # path to the client key file     value: "/certs/key.pem"   - name: KAFKA_CERT_FILE           # path to the client certificate file     value: "/certs/cert.pem"   - name: KAFKA_REJECT_UNAUTHORIZED # verify server certificates     value: "true"   - name: NODE_TLS_REJECT_UNAUTHORIZED  # allow untrusted certificates ("0" allows)     value: "0"   - name: KAFKA_SASL_MECHANISM      # plain, SCRAM-SHA-256 or SCRAM-SHA-512     value: "plain"   - name: KAFKA_SASL_USERNAME     value: "kafka-user" | `[{"name":"KAFKA_TOPIC","value":"rasa-events"},{"name":"KAFKA_DLQ_TOPIC","value":"rasa-events-dlq"},{"name":"KAFKA_GROUP_ID","value":"studio"},{"name":"KAFKA_SASL_PASSWORD","valueFrom":{"secretKeyRef":{"key":"KAFKA_SASL_PASSWORD","name":"studio-secrets"}}}]` |
| eventIngestion.envFrom | list | Additional environment variables from ConfigMap or Secret. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret | `[]` |
| eventIngestion.image | object | Container image settings for the event ingestion service. Applies only when eventIngestion.mode is separate. | `{"name":"studio","pullPolicy":"IfNotPresent"}` |
| eventIngestion.image.name | string | Unified studio image for the separate ingestion Deployment. Applies only when eventIngestion.mode is separate. | `"studio"` |
| eventIngestion.image.pullPolicy | string | Container image pull policy. Applies only when eventIngestion.mode is separate. | `"IfNotPresent"` |
| eventIngestion.mode | string | Event-ingestion topology. colocated (default): ENABLE_EVENT_INGESTION=true on the app pod; no sibling Deployment. separate: deploy {release}-app-ingestion with STUDIO_ROLE=ingestion; app sets ENABLE_EVENT_INGESTION=false. disabled: neither co-located nor separate consumers. Breaking: replaces eventIngestion.enabled. Do not set both semantics.  Applicability: - Both colocated and separate: Kafka-related keys under eventIngestion.env   (colocated injects them into the app Deployment; separate injects them into the ingestion Deployment). - Only mode: separate: replicaCount, image, resources, serviceAccount, autoscaling/HPA,   scheduling (nodeSelector / affinity / tolerations) for the sibling Deployment. - volumes / volumeMounts / envFrom / additionalContainers: applied to the app pod when   colocated, and to the sibling Deployment when separate. | `"colocated"` |
| eventIngestion.nodeSelector | object | Which nodes the event ingestion pods can run on. Applies only when eventIngestion.mode is separate. | `{}` |
| eventIngestion.podAnnotations | object | Annotations to add to the event ingestion pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-app-ingestion: runtime/default | `{}` |
| eventIngestion.podSecurityContext | object | Security settings for the entire pod. | `{"enabled":true}` |
| eventIngestion.podSecurityContext.enabled | bool | Whether to enable the pod security context. | `true` |
| eventIngestion.replicaCount | int | Number of replicas for the Event Ingestion deployment. Applies only when eventIngestion.mode is separate. | `1` |
| eventIngestion.resources | object | Resource limits and requests for the event ingestion service. Applies only when eventIngestion.mode is separate. | `{}` |
| eventIngestion.securityContext | object | Security settings for the event ingestion container. | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` |
| eventIngestion.securityContext.allowPrivilegeEscalation | bool | Whether to allow privilege escalation. | `false` |
| eventIngestion.securityContext.capabilities | object | Linux capabilities configuration. | `{"drop":["ALL"]}` |
| eventIngestion.securityContext.capabilities.drop | list | Capabilities to drop from the container. | `["ALL"]` |
| eventIngestion.securityContext.enabled | bool | Whether to enable the security context. | `true` |
| eventIngestion.securityContext.runAsNonRoot | bool | Whether to run the container as a non-root user. | `true` |
| eventIngestion.securityContext.seccompProfile | object | Seccomp profile configuration. Kept active because the restricted Pod Security Standard requires a seccomp profile, and the pod-level one above is commented out. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-seccomp-profile-for-a-container | `{"type":"RuntimeDefault"}` |
| eventIngestion.securityContext.seccompProfile.type | string | Seccomp profile type. | `"RuntimeDefault"` |
| eventIngestion.serviceAccount | object | Kubernetes service account used by the event ingestion pod. Applies only when eventIngestion.mode is separate. | `{"annotations":{},"create":false,"name":""}` |
| eventIngestion.serviceAccount.annotations | object | Annotations to add to the service account. Applies only when eventIngestion.mode is separate. | `{}` |
| eventIngestion.serviceAccount.create | bool | Whether to create a new service account. Applies only when eventIngestion.mode is separate. | `false` |
| eventIngestion.serviceAccount.name | string | Name of the service account to use. Applies only when eventIngestion.mode is separate. | `""` |
| eventIngestion.tolerations | list | Tolerations for the event ingestion pods. Applies only when eventIngestion.mode is separate. | `[]` |
| eventIngestion.volumeMounts | list | Where to mount the volumes in the Event Ingestion container. Example: - name: config-volume   mountPath: /etc/config   readOnly: true | `[]` |
| eventIngestion.volumes | list | Additional volumes for the Event Ingestion container. Example: - name: config-volume   configMap:     name: special-config | `[]` |
| fullnameOverride | string | Override the full qualified app name. | `""` |
| global.additionalDeploymentLabels | object | Map organizational structures onto system objects. https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ | `{}` |
| global.ingressAnnotations | object | Annotations added to the Studio app ingress and the Rasa Pro model-service ingress. Merged with per-ingress annotations (app.ingress.additionalAnnotations, rasa.ingress.annotations), which win on key conflicts. Example:   cert-manager.io/cluster-issuer: letsencrypt-prod | `{}` |
| global.ingressClassName | string | Ingress class for the Studio app ingress and the Rasa Pro model-service ingress. Acts as a fallback: a per-ingress className (app.ingress.className, rasa.ingress.className) wins when set. | `""` |
| global.ingressHost | string | Single-host knob: set it once and the Studio app ingress and Rasa Pro model-service ingress and every derived URL (window.MS_API_URL, RASA_MODEL_SERVER_BASE_URL, WEB_CLIENT_URL, CORS) resolve from it. WARNING: when set it silently overrides per-component hosts, including rasa.ingress.hosts[0].host — leave it UNSET for split-host installs and use the per-ingress hosts (app.ingress.hostName, rasa.ingress.hosts[0].host) instead. | `nil` |
| hostNetwork | bool | Whether the pod may use the node network namespace. | `false` |
| imagePullSecrets | list | Repository pull secrets. | `[]` |
| nameOverride | string | Override name of app. | `""` |
| networkPolicy.allowIngressFrom | list | Peers allowed to reach the Studio app port. Required with denyAll; nodeCIDR only covers kubelet probes. | `[]` |
| networkPolicy.denyAll | bool | Whether to default-deny all ingress and egress before more specific rules apply. | `false` |
| networkPolicy.dnsNamespace | string | Namespace running cluster DNS, matched on kubernetes.io/metadata.name. | `"kube-system"` |
| networkPolicy.egressPorts | list | Destination ports Studio may reach. Defaults cover HTTP and HTTPS only — add your database, Kafka and object-storage ports. | `[{"port":443,"protocol":"TCP"},{"port":80,"protocol":"TCP"}]` |
| networkPolicy.enabled | bool | Whether to enable network policies. Only explicitly allowed traffic is permitted. | `false` |
| networkPolicy.nodeCIDR | list | Node IP ranges allowed to reach pods. Required for kubelet probes when enabled. | `[]` |
| podLabels | object | Labels to add to all Studio pod(s) | `{}` |
| rasa.args | list | `args: []` replaces the chart-generated arguments entirely, so the container runs `command` alone. This is what settings.useDefaultArgs: false used to do. | `[]` |
| rasa.command[0] | string |  | `"python"` |
| rasa.command[1] | string |  | `"-m"` |
| rasa.command[2] | string |  | `"rasa.model_service"` |
| rasa.enabled | bool | Deploy the Rasa Pro model server subchart. To run Studio without the model service set this to false. WARNING: never disable with `rasa: null` — deleting the key breaks the subchart condition and re-enables the subchart with its default values (the chart fails the render if it detects this). | `true` |
| rasa.envFrom[0].configMapRef.name | string |  | `"shared-environment"` |
| rasa.fullnameOverride | string |  | `"rasapro"` |
| rasa.image.repository | string |  | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` |
| rasa.image.tag | string |  | `"3.17.11-latest"` |
| rasa.ingress.annotations | object |  | `{}` |
| rasa.ingress.enabled | bool |  | `true` |
| rasa.ingress.hosts[0].host | string |  | `""` |
| rasa.ingress.hosts[0].paths[0].path | string |  | `"/modelservice"` |
| rasa.ingress.hosts[0].paths[0].pathType | string |  | `"Prefix"` |
| rasa.livenessProbe.enabled | bool |  | `true` |
| rasa.livenessProbe.failureThreshold | int |  | `6` |
| rasa.livenessProbe.httpGet.path | string |  | `"/modelservice/health"` |
| rasa.livenessProbe.httpGet.port | int |  | `8000` |
| rasa.livenessProbe.httpGet.scheme | string |  | `"HTTP"` |
| rasa.livenessProbe.initialDelaySeconds | int |  | `30` |
| rasa.livenessProbe.periodSeconds | int |  | `15` |
| rasa.livenessProbe.successThreshold | int |  | `1` |
| rasa.livenessProbe.timeoutSeconds | int |  | `5` |
| rasa.mountModelsVolume | bool | The model service ships its own models; no chart-managed volume. | `false` |
| rasa.overrideEnv[0].name | string |  | `"RASA_LICENSE"` |
| rasa.overrideEnv[0].valueFrom.secretKeyRef.key | string |  | `"RASA_PRO_LICENSE_SECRET_KEY"` |
| rasa.overrideEnv[0].valueFrom.secretKeyRef.name | string |  | `"studio-secrets"` |
| rasa.overrideEnv[1].name | string |  | `"OPENAI_API_KEY"` |
| rasa.overrideEnv[1].valueFrom.secretKeyRef.key | string |  | `"OPENAI_API_KEY_SECRET_KEY"` |
| rasa.overrideEnv[1].valueFrom.secretKeyRef.name | string |  | `"studio-secrets"` |
| rasa.persistence.create | bool |  | `true` |
| rasa.persistence.hostPath.enabled | bool |  | `false` |
| rasa.persistence.storageCapacity | string |  | `"1Gi"` |
| rasa.persistence.storageClassName | string | Make sure to set the correct storage class name based on your cluster configuration. | `nil` |
| rasa.persistence.storageRequests | string |  | `"1Gi"` |
| rasa.podSecurityContext.fsGroup | int | User ID of the container to access the mounted volume. | `1001` |
| rasa.rasa.mountDefaultConfigmap | bool | Studio supplies no endpoints or integrations, so render no ConfigMap. | `false` |
| rasa.rasa.port | int | The model service listens on 8000, not the chart default 5005. | `8000` |
| rasa.readinessProbe.enabled | bool |  | `true` |
| rasa.readinessProbe.failureThreshold | int |  | `6` |
| rasa.readinessProbe.httpGet.path | string |  | `"/modelservice/health"` |
| rasa.readinessProbe.httpGet.port | int |  | `8000` |
| rasa.readinessProbe.httpGet.scheme | string |  | `"HTTP"` |
| rasa.readinessProbe.initialDelaySeconds | int |  | `30` |
| rasa.readinessProbe.periodSeconds | int |  | `15` |
| rasa.readinessProbe.successThreshold | int |  | `1` |
| rasa.readinessProbe.timeoutSeconds | int |  | `5` |
| rasa.replicaCount | int |  | `1` |
| rasa.resources | object | Resources limits and requests. | `{}` |
| rasa.service.port | int |  | `80` |
| rasa.service.targetPort | int |  | `8000` |
| rasa.strategy.type | string |  | `"Recreate"` |
| repository | string | Image repository for Studio. | `"europe-west3-docker.pkg.dev/rasa-releases/studio/"` |
| tag | string | Overrides the image tag for all Studio images (unified studio image; Studio ≥ 2.0.0). Empty (default) uses the chart's appVersion. Set an exact, immutable tag to pin deployments independently of chart upgrades. | `""` |
