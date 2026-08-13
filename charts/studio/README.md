# studio

A Rasa Studio Helm chart for Kubernetes

![Version: 3.0.0-rc.16](https://img.shields.io/badge/Version-3.0.0--rc.16-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Architecture

The Studio chart deploys a unified Studio image. The app serves both the API and the web client; all components share a single `ingressHost` and the `studio-secrets` Kubernetes Secret.

| Component | Description | Ingress path | Toggle |
|-----------|-------------|--------------|--------|
| **app** | Studio API server and web client — handles business logic and data persistence | `/api` and `/` | always on |
| **keycloak** | Temporary legacy identity provider, retained while migrating existing users to Better Auth | `/auth` | `keycloak.enabled` (default: `true`) |
| **event-ingestion** | Kafka consumer that writes conversation events to the database | internal | `eventIngestion.mode` (`colocated`, `separate`, or `disabled`) |
| **rasa** | Rasa Pro model server (OCI subchart dependency) | `/modelservice` | `rasa.enabled` (default: `true`) |

> **Note:** `rasaProServices` is always disabled in this chart — it requires a separate analytics database that must be provisioned externally.

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
    --from-literal=KEYCLOAK_ADMIN_PASSWORD="<keycloak-admin-pw>" \
    --from-literal=KEYCLOAK_API_PASSWORD="<keycloak-api-pw>" \
    --from-literal=RASA_PRO_LICENSE_SECRET_KEY="<rasa-pro-license>" \
    --from-literal=OPENAI_API_KEY_SECRET_KEY="<openai-api-key>" \
    --from-literal=KAFKA_SASL_PASSWORD="<kafka-sasl-password>"
```

> **Note:** `AUTH_SECRET` must be at least 32 characters long.

> **Note:** `KEYCLOAK_ADMIN_PASSWORD` and `KEYCLOAK_API_PASSWORD` are only required while the bundled Keycloak (`keycloak.enabled: true`) is deployed for migration. Once you disable Keycloak, they can be removed.

> **Note:** The secret name `studio-secrets` is the default referenced throughout `values.yaml`. If you use a different name, override every `secretName` field accordingly.

## Installing the Chart

You can install the chart from either the OCI registry or the GitHub Helm repository.

### Option 1: Install from OCI Registry

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 3.0.0-rc.16
```

### Option 2: Install from GitHub Helm Repository

First, add the Rasa Helm repository:

```console
$ helm repo add rasa https://helm.rasa.com/charts
$ helm repo update
```

Then install the chart:

```console
$ helm install my-release rasa/studio --version 3.0.0-rc.16
```

## Quick Start

Minimum `values.yaml` to get Studio running (assumes `studio-secrets` already created):

```yaml
config:
  ingressHost: &dns_hostname studio.example.com
  ingressClassName: nginx
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
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 3.0.0-rc.16
```

### From GitHub Helm Repository:

```console
$ helm pull rasa/studio --version 3.0.0-rc.16
```

## General Configuration

- **imagePullSecrets**: If you're using a private Docker registry, provide the necessary credentials in this section.

> **Note:** For application specific settings, please refer to our [documentation](https://rasa.com/docs/) and bellow you can find the full list of values.

## Important Notes on `ingressHost` Anchor

The `config.ingressHost` field in the `values.yaml` file is defined with an **anchor** (`&dns_hostname`) to ensure consistency and reusability across the Helm chart.

### Example:
```yaml
# values.yaml
config:
  ingressHost: &dns_hostname INGRESS.HOST.NAME
```

### Guidelines:
Do *NOT* delete or modify the anchor (`&dns_hostname`).
If you need to change the ingress host, only modify the value (e.g., `INGRESS.HOST.NAME`) while keeping the anchor intact.

## Database Configuration

Studio requires a PostgreSQL database for the app services. While the bundled Keycloak is deployed for migration (`keycloak.enabled: true`), it additionally uses the database named by `config.database.keycloakDatabaseName`.

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
- Set `window.MS_API_URL` on the web client to the model service external host (without the ingress path prefix)
- Use a `Recreate` update strategy (no rolling updates — stateful model loading)
- Use service name `rasapro` (hardcoded via `fullnameOverride`) — this is the hostname the app uses internally

When `rasa.enabled: false`, override the **browser** model-service URL via the web client ConfigMap (the Studio API process does not read `MS_API_URL`):

```yaml
app:
  webClient:
    config:
      MS_API_URL: "https://models.example.com"
```

> **Note:** `rasaProServices` is always disabled. It requires a dedicated analytics database and must be enabled and configured separately if needed.

### Rasa Pro Model Service Environment Variables

The following environment variables can be configured on the Rasa Pro model server container via `rasa.rasa.overrideEnv`:

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

When enabled, three policies are created:
- **deny-all** — drops all ingress/egress by default (namespace-scoped)
- **allow-dns-access** — permits UDP/TCP port 53 for DNS resolution
- **ingress-egress-from-kubelet** — allows Kubernetes health-check traffic from the kubelet

> **Note:** Requires a CNI plugin that enforces `NetworkPolicy` (e.g. Calico, Cilium, Antrea). Enabling network policies without a compatible CNI has no effect.

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

- Environment variables use native Kubernetes `EnvVar` lists. `app.environmentVariables`,
  `app.migration.environmentVariables`, `eventIngestion.environmentVariables` and
  `keycloak.environmentVariables` were removed — define entries under `app.env`,
  `app.migration.env`, `eventIngestion.env`, `keycloak.env` as `- name/value` or
  `- name/valueFrom.secretKeyRef` (was `KEY: {value: ...}` / `KEY: {secret: {name, key}}`).
  Keys are rendered verbatim (no more automatic upper-casing), and a user-supplied
  list replaces the chart defaults wholesale — copy the defaults you want to keep.
- `app.webClient.environmentVariables` is now `app.webClient.config` — a plain
  `KEY: "value"` map of browser `window.*` globals (not container env). Flag values
  always render as quoted strings in config.js.
- `SKIP_KEYCLOAK` on the migration Job is derived from `keycloak.enabled`
  (`"false"` when enabled, `"true"` when disabled). Add a `SKIP_KEYCLOAK` entry to
  `app.migration.env` only to override the derived value (e.g. the Keycloak
  database was created manually).
- `config.database.host` must be set to a real host; empty values are rejected by the
  values schema at install time.
- `Chart.yaml` now declares `appVersion`; the `tag` value is empty by default and
  only overrides the appVersion-derived image tag. The migration Job is bounded by
  `app.migration.backoffLimit` / `app.migration.activeDeadlineSeconds`.

Better Auth is served by the app at `/api/auth/*`. Keycloak is temporary and remains available at `/auth` while enabled. Choose exactly one ingestion topology with `eventIngestion.mode`: `colocated` (default), `separate`, or `disabled`.

Helm does not delete resources that disappeared from the previous topology. After upgrade, remove the old backend, web-client, and event-ingestion resources as described in the chart release notes (`helm get notes <release-name>`).

## Values

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| app.additionalContainers | list | app.additionalContainers defines additional containers to run alongside the main Studio App container. These containers will be part of the same pod and share the pod's network namespace. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] Ref: https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers | `[]` |
| app.affinity | object | app.affinity defines affinity rules for the app pods. This controls where the pods can be scheduled. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| app.annotations | object | app.annotations defines annotations to add to all Studio App resources. These annotations will be merged with deploymentAnnotations (deploymentAnnotations take precedence if keys conflict). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| app.authSecret | object | app.authSecret is the secret used by the app to sign sessions and tokens. Must be at least 32 characters long. Stored in a Kubernetes secret. Required. | `{"secretKey":"AUTH_SECRET","secretName":"studio-secrets"}` |
| app.autoscaling | object | app.autoscaling defines the Horizontal Pod Autoscaling configuration. This enables automatic scaling of the app deployment based on metrics. Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/ | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` |
| app.autoscaling.enabled | bool | app.autoscaling.enabled determines whether to enable horizontal pod autoscaling. | `false` |
| app.autoscaling.maxReplicas | int | app.autoscaling.maxReplicas is the maximum number of replicas. | `100` |
| app.autoscaling.minReplicas | int | app.autoscaling.minReplicas is the minimum number of replicas. | `1` |
| app.autoscaling.targetCPUUtilizationPercentage | int | app.autoscaling.targetCPUUtilizationPercentage is the target CPU utilization percentage. The HPA will scale the deployment to maintain this CPU utilization. Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details | `80` |
| app.env | list | app.env defines extra environment variables for the Studio App container, in native Kubernetes EnvVar format (name + value or valueFrom). NOTE: a user-supplied list REPLACES this default list wholesale (Helm does not merge lists) — copy the default entries you want to keep. NOTE: Do not set MS_API_URL here — the Studio API process does not read it. Override the browser model-service URL via app.webClient.config.MS_API_URL. Example:   - name: MY_VAR     value: "my-value"   - name: MY_SECRET_VAR     valueFrom:       secretKeyRef:         name: my-secret         key: MY_SECRET_KEY | `[{"name":"DELETE_CONVERSATIONS_CRON_EXPRESSION","value":"0 * * * *"}]` |
| app.envFrom | list | app.envFrom defines additional environment variables from ConfigMap or Secret. These will be mounted as environment variables in the container. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables | `[]` |
| app.image | object | app.image defines the container image settings for the app service. This section defines the container image settings for the app service. Ref: https://kubernetes.io/docs/concepts/containers/images/ | `{"name":"studio","pullPolicy":"IfNotPresent"}` |
| app.image.name | string | app.image.name is the unified Studio container image (API + web client + optional co-located ingestion). Chart 3.0.0 requires this image (Studio ≥ 2.0.0). Formerly studio-backend. | `"studio"` |
| app.image.pullPolicy | string | app.image.pullPolicy is the container image pull policy. Valid values: Always, IfNotPresent, Never Always: Always pull the image IfNotPresent: Only pull if not present locally Never: Never pull the image Ref: https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy | `"IfNotPresent"` |
| app.ingress | object | app.ingress defines how the app service is exposed externally. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/ | `{"additionalAnnotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` |
| app.ingress.additionalAnnotations | object | app.ingress.additionalAnnotations defines additional annotations for the ingress resource. Example:   kubernetes.io/ingress.class: nginx   cert-manager.io/cluster-issuer: letsencrypt-prod Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| app.ingress.className | string | app.ingress.className is the ingress class name. This should match your cluster's ingress controller. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class | `""` |
| app.ingress.enabled | bool | app.ingress.enabled determines whether to create an ingress resource. | `true` |
| app.ingress.labels | object | app.ingress.labels defines labels to add to the ingress resource. Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ | `{}` |
| app.ingress.tls | list | app.ingress.tls defines the TLS configuration for the ingress. Example: - secretName: chart-example-tls   hosts:     - chart-example.local | `[]` |
| app.livenessProbe | object | app.livenessProbe defines the liveness probe configuration. This determines if the container is alive and functioning. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| app.livenessProbe.enabled | bool | app.livenessProbe.enabled determines whether to enable the liveness probe. | `true` |
| app.livenessProbe.failureThreshold | int | app.livenessProbe.failureThreshold is the number of failures before the container is considered unhealthy. | `6` |
| app.livenessProbe.httpGet | object | app.livenessProbe.httpGet defines the HTTP GET probe configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command | `{"path":"/api/health","port":4000,"scheme":"HTTP"}` |
| app.livenessProbe.httpGet.path | string | app.livenessProbe.httpGet.path is the path to check for liveness. | `"/api/health"` |
| app.livenessProbe.httpGet.port | int | app.livenessProbe.httpGet.port is the port to check for liveness. | `4000` |
| app.livenessProbe.httpGet.scheme | string | app.livenessProbe.httpGet.scheme is the protocol to use for the check. | `"HTTP"` |
| app.livenessProbe.initialDelaySeconds | int | app.livenessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. | `15` |
| app.livenessProbe.periodSeconds | int | app.livenessProbe.periodSeconds is how often to perform the probe. | `15` |
| app.livenessProbe.successThreshold | int | app.livenessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. | `1` |
| app.livenessProbe.timeoutSeconds | int | app.livenessProbe.timeoutSeconds is the number of seconds after which the probe times out. | `5` |
| app.migration | object | app.migration defines the database migration job configuration. This section controls the database schema migration process. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/job/ | `{"activeDeadlineSeconds":900,"affinity":{},"annotations":{},"backoffLimit":3,"enabled":true,"env":[{"name":"KC_DEFAULT_DATABASE_CONNECTION_NAME","value":"postgres"}],"image":{"name":"studio","pullPolicy":"IfNotPresent"},"nodeSelector":{},"podAnnotations":{},"serviceAccount":{"annotations":{},"create":false,"name":""},"tolerations":[],"waitForIt":false,"waitForItContainer":{"image":"postgres:17.2"}}` |
| app.migration.activeDeadlineSeconds | int | app.migration.activeDeadlineSeconds is the hard wall-clock bound for the migration Job; size it to your worst-case migration duration. | `900` |
| app.migration.affinity | object | app.migration.affinity defines affinity rules for the migration job. This controls where the job can be scheduled. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| app.migration.annotations | object | app.migration.annotations defines annotations to add to the migration job resource. These annotations will be merged with deploymentAnnotations and helm hook annotations (helm hooks take precedence). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| app.migration.backoffLimit | int | app.migration.backoffLimit is the number of retries before the migration Job is marked failed. | `3` |
| app.migration.enabled | bool | app.migration.enabled determines whether to enable the database migration job. Set to false if you want to handle migrations manually. | `true` |
| app.migration.env | list | app.migration.env defines extra environment variables for the migration job container, in native Kubernetes EnvVar format (name + value or valueFrom). NOTE: a user-supplied list REPLACES this default list wholesale (Helm does not merge lists) — copy the default entries you want to keep. NOTE: SKIP_KEYCLOAK is derived from keycloak.enabled automatically ("false" when enabled, "true" when disabled). Add a SKIP_KEYCLOAK entry to this list only to override that behavior (e.g. the Keycloak database was created manually). | `[{"name":"KC_DEFAULT_DATABASE_CONNECTION_NAME","value":"postgres"}]` |
| app.migration.image | object | app.migration.image defines the image configuration for the migration job. | `{"name":"studio","pullPolicy":"IfNotPresent"}` |
| app.migration.image.name | string | app.migration.image.name uses the same unified studio image with STUDIO_ROLE=migration. | `"studio"` |
| app.migration.image.pullPolicy | string | app.migration.image.pullPolicy is the container image pull policy. | `"IfNotPresent"` |
| app.migration.nodeSelector | object | app.migration.nodeSelector defines which nodes the migration job can run on. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector | `{}` |
| app.migration.podAnnotations | object | app.migration.podAnnotations defines annotations to add to the migration job pod. Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| app.migration.serviceAccount | object | app.migration.serviceAccount defines the Kubernetes service account used by the migration job pod. | `{"annotations":{},"create":false,"name":""}` |
| app.migration.serviceAccount.annotations | object | app.migration.serviceAccount.annotations defines annotations to add to the service account. | `{}` |
| app.migration.serviceAccount.create | bool | app.migration.serviceAccount.create determines whether to create a new service account. | `false` |
| app.migration.serviceAccount.name | string | app.migration.serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname + "-db-migration" suffix. | `""` |
| app.migration.tolerations | list | app.migration.tolerations defines tolerations for the migration job. This allows the job to run on nodes with matching taints. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ | `[]` |
| app.migration.waitForIt | bool | app.migration.waitForIt determines whether to wait for the database to be ready before running migrations. | `false` |
| app.migration.waitForItContainer | object | app.migration.waitForItContainer defines the configuration for the wait-for-it container. | `{"image":"postgres:17.2"}` |
| app.nodeSelector | object | app.nodeSelector defines which nodes the app pods can run on. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector | `{}` |
| app.podAnnotations | object | app.podAnnotations defines annotations to add to the app pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-app: runtime/default Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| app.podSecurityContext | object | app.podSecurityContext defines the security settings for the entire pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ | `{"enabled":true}` |
| app.podSecurityContext.enabled | bool | app.podSecurityContext.enabled determines whether to enable the pod security context. | `true` |
| app.readinessProbe | object | app.readinessProbe defines the readiness probe configuration. This determines if the container is ready to receive traffic. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| app.readinessProbe.enabled | bool | app.readinessProbe.enabled determines whether to enable the readiness probe. | `true` |
| app.readinessProbe.failureThreshold | int | app.readinessProbe.failureThreshold is the number of failures before the container is considered not ready. | `6` |
| app.readinessProbe.httpGet | object | app.readinessProbe.httpGet defines the HTTP GET probe configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-readiness-probe | `{"path":"/api/health","port":4000,"scheme":"HTTP"}` |
| app.readinessProbe.httpGet.path | string | app.readinessProbe.httpGet.path is the path to check for readiness. | `"/api/health"` |
| app.readinessProbe.httpGet.port | int | app.readinessProbe.httpGet.port is the port to check for readiness. | `4000` |
| app.readinessProbe.httpGet.scheme | string | app.readinessProbe.httpGet.scheme is the protocol to use for the check. | `"HTTP"` |
| app.readinessProbe.initialDelaySeconds | int | app.readinessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. | `15` |
| app.readinessProbe.periodSeconds | int | app.readinessProbe.periodSeconds is how often to perform the probe. | `15` |
| app.readinessProbe.successThreshold | int | app.readinessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. | `1` |
| app.readinessProbe.timeoutSeconds | int | app.readinessProbe.timeoutSeconds is the number of seconds after which the probe times out. | `5` |
| app.replicaCount | int | app.replicaCount is the number of replicas for the Studio App deployment. Increase this value for high availability and better load distribution. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#replicas | `1` |
| app.resources | object | app.resources defines the resource limits and requests for Studio App. This controls the compute resources allocated to the app container. Ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ | `{}` |
| app.securityContext | object | app.securityContext defines the security settings for the app container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` |
| app.securityContext.allowPrivilegeEscalation | bool | app.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. Should be false for security best practices. | `false` |
| app.securityContext.capabilities | object | app.securityContext.capabilities defines the Linux capabilities configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container | `{"drop":["ALL"]}` |
| app.securityContext.capabilities.drop | list | app.securityContext.capabilities.drop defines capabilities to drop from the container. ALL drops all capabilities for maximum security. | `["ALL"]` |
| app.securityContext.enabled | bool | app.securityContext.enabled determines whether to enable the security context. | `true` |
| app.securityContext.runAsNonRoot | bool | app.securityContext.runAsNonRoot determines whether to run the container as a non-root user. Should be true for security best practices. | `true` |
| app.service | object | app.service defines how the app service is exposed within the cluster. Ref: https://kubernetes.io/docs/concepts/services-networking/service/ | `{"port":80,"targetPort":4000,"type":"ClusterIP"}` |
| app.service.port | int | app.service.port is the port number for the service. | `80` |
| app.service.targetPort | int | app.service.targetPort is the target port in the container. This should match the port your application listens on. | `4000` |
| app.service.type | string | app.service.type is the type of Kubernetes service. Valid values: ClusterIP, NodePort, LoadBalancer, ExternalName Ref: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types | `"ClusterIP"` |
| app.serviceAccount | object | app.serviceAccount defines the Kubernetes service account used by the app pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ | `{"annotations":{},"create":false,"name":""}` |
| app.serviceAccount.annotations | object | app.serviceAccount.annotations defines annotations to add to the service account. Useful for cloud provider specific configurations. | `{}` |
| app.serviceAccount.create | bool | app.serviceAccount.create determines whether to create a new service account. | `false` |
| app.serviceAccount.name | string | app.serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template. | `""` |
| app.tolerations | list | app.tolerations defines tolerations for the app pods. This allows the pods to run on nodes with matching taints. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ | `[]` |
| app.webClient | object | app.webClient holds browser runtime config for the unified app (no separate web-client Deployment). config.js is mounted into the app pod at /usr/src/app/webclient/config.js. | `{"config":{}}` |
| app.webClient.config | object | app.webClient.config feeds browser window.* globals rendered into the config.js ConfigMap mounted at /usr/src/app/webclient/config.js on the app pod. Plain scalar map (KEY: "value") — these are NOT container environment variables and cannot reference secrets (ConfigMap only). Used for feature flags (FEATURE_FLAG_*), MS_API_URL (window.MS_API_URL), CURRENT_VERSION_NUMBER, etc. | `{}` |
| config.affinity | object | Pod affinity and anti-affinity rules for all deployments. These settings can be overridden by component-specific configurations. | `{}` |
| config.connectionType | string | Define the URL scheme (`http` or `https`) for externally derived URLs (ingress-based API_URL, WEB_CLIENT_URL, web client API_ENDPOINT, model-service public URLs, CORS_ORIGINS, etc.). Valid values: "http" or "https". Does not change in-cluster http:// service-to-service calls. | `"http"` |
| config.database | object | The postgres database instance details for Studio to connect to. This section configures the database connection parameters for Studio. | `{"awsRegion":"","databaseName":"studio","host":"DATABASE.HOST.NAME","iamDbUsername":"","keycloakDatabaseName":"keycloak","password":{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"},"port":"5432","preferSSL":"true","queryParams":"","rejectUnauthorized":"","useAwsIamAuth":"","username":""}` |
| config.database.awsRegion | string | The AWS region for the database. Needed if you want to use AWS IAM authentication for the database. | `""` |
| config.database.databaseName | string | The database name for Studio app services. This is used by Studio to store its data. Can be specified as a plain string value or as a secret reference. Plain value example: databaseName: "studio" Secret reference example: databaseName:   secretName: "my-secret"   secretKey: "DB_NAME" | `"studio"` |
| config.database.host | string | The database host name or IP address where PostgreSQL is running. Example: "postgres.example.com" or "10.0.0.1" Placeholder value — you MUST set this; an empty value is rejected by the schema. | `"DATABASE.HOST.NAME"` |
| config.database.iamDbUsername | string | The IAM database username for the database. Needed if you want to use AWS IAM authentication for the database. | `""` |
| config.database.keycloakDatabaseName | string | The database name for Keycloak user management service. This is used by Keycloak to store its user management data. Note: This must be a plain string value (not a secret reference) as it's used in JDBC URL construction. | `"keycloak"` |
| config.database.password | object | The database password configuration. This references a Kubernetes secret containing the database password. | `{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"}` |
| config.database.port | string | The database port number for PostgreSQL. Default PostgreSQL port is 5432 | `"5432"` |
| config.database.preferSSL | string | Set to true if you want to use SSL for database connection. When enabled, Studio will attempt to establish an encrypted connection to the database. | `"true"` |
| config.database.queryParams | string | The database connection URL query parameters. These parameters are used to configure the database connection. Example: "sslmode=require&connect_timeout=30" | `""` |
| config.database.rejectUnauthorized | string | If true, the server will reject database connections which are not present in the list of supplied CAs. This provides additional security by ensuring only trusted certificates are accepted. | `""` |
| config.database.useAwsIamAuth | string | Set to true if you want to use AWS IAM authentication for the database. | `""` |
| config.database.username | string | The database username for Studio to connect with. This user should have appropriate permissions on the database. Can be specified as a plain string value or as a secret reference. Plain value example: username: "studio" Secret reference example: username:   secretName: "my-secret"   secretKey: "DB_USERNAME" | `""` |
| config.ingressAnnotations | object | Define the ingress annotations to be used for ALL the ingress resources. These annotations will be applied to all ingress resources created by this chart. Example:   kubernetes.io/ingress.class: nginx   cert-manager.io/cluster-issuer: letsencrypt-prod | `{}` |
| config.ingressClassName | string | Define the ingress class name to be used for ALL the ingress resources. This value will be applied to all ingress resources created by this chart. Example: "nginx", "istio", "traefik" Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class | `""` |
| config.ingressHost | string | Defines the host name for all Studio ingress resources. This value is used as an anchor (&dns_hostname) for referencing the host name across multiple places in the Helm chart. WARNING: Do NOT delete or modify the anchor (&dns_hostname) as it is critical for the proper functioning of the chart. If you need to update the host name, only change the value (INGRESS.HOST.NAME), keeping the anchor intact. | `"INGRESS.HOST.NAME"` |
| config.keycloak | object | config.keycloak defines the Keycloak configuration settings. This section configures the authentication and authorization service. Note: Keycloak is retained to support migration of existing data to the new app's internal authentication. | `{"adminPassword":{"secretKey":"KEYCLOAK_ADMIN_PASSWORD","secretName":"studio-secrets"},"adminUsername":"kcadmin","apiClientId":"admin-cli","apiPassword":{"secretKey":"KEYCLOAK_API_PASSWORD","secretName":"studio-secrets"},"apiUsername":"realmadmin","clientId":"rasa-studio-backend","realm":"rasa-studio","url":""}` |
| config.keycloak.adminPassword | object | config.keycloak.adminPassword defines the admin password for Keycloak. This password is used to login to the Keycloak admin console. The password is stored in a Kubernetes secret. | `{"secretKey":"KEYCLOAK_ADMIN_PASSWORD","secretName":"studio-secrets"}` |
| config.keycloak.adminUsername | string | config.keycloak.adminUsername is the admin username for Keycloak. This username is used to login to the Keycloak admin console. | `"kcadmin"` |
| config.keycloak.apiClientId | string | config.keycloak.apiClientId is the client ID for Keycloak API. This client is used by Studio App to authenticate with Keycloak. | `"admin-cli"` |
| config.keycloak.apiPassword | object | config.keycloak.apiPassword is the password for Keycloak API. This password is used by Studio App to authenticate with Keycloak. | `{"secretKey":"KEYCLOAK_API_PASSWORD","secretName":"studio-secrets"}` |
| config.keycloak.apiUsername | string | config.keycloak.apiUsername is the username for Keycloak API. This username is used by Studio App to authenticate with Keycloak. | `"realmadmin"` |
| config.keycloak.clientId | string | config.keycloak.clientId is the client ID for Keycloak. This client is used by Studio to authenticate with Keycloak. | `"rasa-studio-backend"` |
| config.keycloak.realm | string | config.keycloak.realm is the realm name for Keycloak. This realm is used by Studio to manage users and clients. | `"rasa-studio"` |
| config.keycloak.url | string | config.keycloak.url overrides the default service endpoint for Keycloak. Format is `http(s)://<ingressHost>/auth`. Required only if your cluster redirects internal HTTP traffic to HTTPS. | `""` |
| config.nodeSelector | object | Common pod scheduling configuration for all deployments. These settings can be overridden by component-specific configurations. Not possible to combine with component-specific configurations for each scheduling option. | `{}` |
| config.tolerations | list | Pod tolerations for all deployments. These settings can be overridden by component-specific configurations. | `[]` |
| deploymentAnnotations | object | deploymentAnnotations defines annotations to add to all Studio resources. These annotations are applied globally to all resources (Deployments, Services, Ingresses, Jobs, HPAs, ConfigMaps, ServiceAccounts). Component-specific annotations can override these values if keys conflict. Example:   key: "value" Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| deploymentLabels | object | deploymentLabels defines labels to add to all Studio deployment | `{}` |
| dnsConfig | object | dnsConfig specifies Pod's DNS config # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config | `{}` |
| dnsPolicy | string | dnsPolicy specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy | `""` |
| eventIngestion.additionalContainers | list | eventIngestion.additionalContainers defines additional containers to run alongside the main Event Ingestion container. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] | `[]` |
| eventIngestion.affinity | object | eventIngestion.affinity defines affinity rules for the event ingestion pods. Applies only when eventIngestion.mode is separate. | `{}` |
| eventIngestion.annotations | object | eventIngestion.annotations defines annotations to add to all Studio Event Ingestion resources. These annotations will be merged with deploymentAnnotations (deploymentAnnotations take precedence if keys conflict). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| eventIngestion.autoscaling | object | eventIngestion.autoscaling defines the Horizontal Pod Autoscaling configuration. Applies only when eventIngestion.mode is separate. | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` |
| eventIngestion.autoscaling.enabled | bool | eventIngestion.autoscaling.enabled determines whether to enable horizontal pod autoscaling. Applies only when eventIngestion.mode is separate. | `false` |
| eventIngestion.autoscaling.maxReplicas | int | eventIngestion.autoscaling.maxReplicas is the maximum number of replicas. Applies only when eventIngestion.mode is separate. | `100` |
| eventIngestion.autoscaling.minReplicas | int | eventIngestion.autoscaling.minReplicas is the minimum number of replicas. Applies only when eventIngestion.mode is separate. | `1` |
| eventIngestion.autoscaling.targetCPUUtilizationPercentage | int | eventIngestion.autoscaling.targetCPUUtilizationPercentage is the target CPU utilization percentage. Applies only when eventIngestion.mode is separate. | `80` |
| eventIngestion.env | list | eventIngestion.env defines extra environment variables for the event ingestion consumers, in native Kubernetes EnvVar format (name + value or valueFrom). Injected into the app container when mode is colocated, and into the sibling ingestion Deployment when mode is separate. NOTE: a user-supplied list REPLACES this default list wholesale (Helm does not merge lists) — copy the default entries you want to keep (KAFKA_TOPIC, KAFKA_DLQ_TOPIC, KAFKA_GROUP_ID, KAFKA_SASL_PASSWORD). Optional Kafka settings (add as needed):   - name: KAFKA_BROKER_ADDRESS      # address of the Kafka broker (required for ingestion)     value: "kafka.example.com:9092"   - name: KAFKA_ENABLE_SSL          # enable SSL for Kafka connections     value: "true"   - name: KAFKA_CUSTOM_SSL          # use custom SSL certificates for Kafka     value: "true"   - name: KAFKA_CA_FILE             # path to the CA certificate file     value: "/certs/ca.pem"   - name: KAFKA_KEY_FILE            # path to the client key file     value: "/certs/key.pem"   - name: KAFKA_CERT_FILE           # path to the client certificate file     value: "/certs/cert.pem"   - name: KAFKA_REJECT_UNAUTHORIZED # verify server certificates     value: "true"   - name: NODE_TLS_REJECT_UNAUTHORIZED  # allow untrusted certificates ("0" allows)     value: "0"   - name: KAFKA_SASL_MECHANISM      # plain, SCRAM-SHA-256 or SCRAM-SHA-512     value: "plain"   - name: KAFKA_SASL_USERNAME     value: "kafka-user" | `[{"name":"KAFKA_TOPIC","value":"rasa-events"},{"name":"KAFKA_DLQ_TOPIC","value":"rasa-events-dlq"},{"name":"KAFKA_GROUP_ID","value":"studio"},{"name":"KAFKA_SASL_PASSWORD","valueFrom":{"secretKeyRef":{"key":"KAFKA_SASL_PASSWORD","name":"studio-secrets"}}}]` |
| eventIngestion.envFrom | list | eventIngestion.envFrom defines additional environment variables from ConfigMap or Secret. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret | `[]` |
| eventIngestion.image | object | eventIngestion.image defines the container image settings for the event ingestion service. Applies only when eventIngestion.mode is separate. | `{"name":"studio","pullPolicy":"IfNotPresent"}` |
| eventIngestion.image.name | string | eventIngestion.image.name is the unified studio image for the separate ingestion Deployment. Applies only when eventIngestion.mode is separate. | `"studio"` |
| eventIngestion.image.pullPolicy | string | eventIngestion.image.pullPolicy is the container image pull policy. Applies only when eventIngestion.mode is separate. | `"IfNotPresent"` |
| eventIngestion.mode | string | eventIngestion.mode controls event-ingestion topology. colocated (default): ENABLE_EVENT_INGESTION=true on the app pod; no sibling Deployment. separate: deploy {release}-app-ingestion with STUDIO_ROLE=ingestion; app sets ENABLE_EVENT_INGESTION=false. disabled: neither co-located nor separate consumers. Breaking: replaces eventIngestion.enabled. Do not set both semantics.  Applicability: - Both colocated and separate: Kafka-related keys under eventIngestion.env   (colocated injects them into the app Deployment; separate injects them into the ingestion Deployment). - Only mode: separate: replicaCount, image, resources, serviceAccount, autoscaling/HPA,   scheduling (nodeSelector / affinity / tolerations) for the sibling Deployment. - volumes / volumeMounts / envFrom / additionalContainers: applied to the app pod when   colocated, and to the sibling Deployment when separate. | `"colocated"` |
| eventIngestion.nodeSelector | object | eventIngestion.nodeSelector defines which nodes the event ingestion pods can run on. Applies only when eventIngestion.mode is separate. | `{}` |
| eventIngestion.podAnnotations | object | eventIngestion.podAnnotations defines annotations to add to the event ingestion pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-app-ingestion: runtime/default | `{}` |
| eventIngestion.podSecurityContext | object | eventIngestion.podSecurityContext defines the security settings for the entire pod. | `{"enabled":true}` |
| eventIngestion.podSecurityContext.enabled | bool | eventIngestion.podSecurityContext.enabled determines whether to enable the pod security context. | `true` |
| eventIngestion.replicaCount | int | eventIngestion.replicaCount is the number of replicas for the Event Ingestion deployment. Applies only when eventIngestion.mode is separate. | `1` |
| eventIngestion.resources | object | eventIngestion.resources defines the resource limits and requests for the event ingestion service. Applies only when eventIngestion.mode is separate. | `{}` |
| eventIngestion.securityContext | object | eventIngestion.securityContext defines the security settings for the event ingestion container. | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` |
| eventIngestion.securityContext.allowPrivilegeEscalation | bool | eventIngestion.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. | `false` |
| eventIngestion.securityContext.capabilities | object | eventIngestion.securityContext.capabilities defines the Linux capabilities configuration. | `{"drop":["ALL"]}` |
| eventIngestion.securityContext.capabilities.drop | list | eventIngestion.securityContext.capabilities.drop defines capabilities to drop from the container. | `["ALL"]` |
| eventIngestion.securityContext.enabled | bool | eventIngestion.securityContext.enabled determines whether to enable the security context. | `true` |
| eventIngestion.securityContext.runAsNonRoot | bool | eventIngestion.securityContext.runAsNonRoot determines whether to run the container as a non-root user. | `true` |
| eventIngestion.serviceAccount | object | eventIngestion.serviceAccount defines the Kubernetes service account used by the event ingestion pod. Applies only when eventIngestion.mode is separate. | `{"annotations":{},"create":false,"name":""}` |
| eventIngestion.serviceAccount.annotations | object | eventIngestion.serviceAccount.annotations defines annotations to add to the service account. Applies only when eventIngestion.mode is separate. | `{}` |
| eventIngestion.serviceAccount.create | bool | eventIngestion.serviceAccount.create determines whether to create a new service account. Applies only when eventIngestion.mode is separate. | `false` |
| eventIngestion.serviceAccount.name | string | eventIngestion.serviceAccount.name is the name of the service account to use. Applies only when eventIngestion.mode is separate. | `""` |
| eventIngestion.tolerations | list | eventIngestion.tolerations defines tolerations for the event ingestion pods. Applies only when eventIngestion.mode is separate. | `[]` |
| eventIngestion.volumeMounts | list | eventIngestion.volumeMounts defines where to mount the volumes in the Event Ingestion container. Example: - name: config-volume   mountPath: /etc/config   readOnly: true | `[]` |
| eventIngestion.volumes | list | eventIngestion.volumes defines additional volumes for the Event Ingestion container. Example: - name: config-volume   configMap:     name: special-config | `[]` |
| fullnameOverride | string | Override the full qualified app name | `""` |
| global.additionalDeploymentLabels | object | global.additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ | `{}` |
| global.ingressHost | string |  | `nil` |
| hostNetwork | bool | Controls whether the pod may use the node network namespace | `false` |
| imagePullSecrets | list | imagePullSecret defines repository pull secrets | `[]` |
| keycloak.additionalContainers | list | keycloak.additionalContainers defines additional containers to run alongside the main Keycloak container. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] | `[]` |
| keycloak.affinity | object | keycloak.affinity defines affinity rules for the Keycloak pods. | `{}` |
| keycloak.annotations | object | keycloak.annotations defines annotations to add to all Studio Keycloak resources. These annotations will be merged with deploymentAnnotations (deploymentAnnotations take precedence if keys conflict). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| keycloak.database | object | The postgres database instance details for Keycloak to connect to. This section configures the database connection parameters for Keycloak. If not all fields are provided, the same values in the database section will be used, including the keycloakDatabaseName for the database name. | `{}` |
| keycloak.enabled | bool | keycloak.enabled determines whether to deploy the Keycloak authentication service. | `true` |
| keycloak.env | list | keycloak.env defines extra environment variables for the Keycloak container, in native Kubernetes EnvVar format (name + value or valueFrom). NOTE: a user-supplied list REPLACES this default list wholesale (Helm does not merge lists) — copy the default entries you want to keep. | `[{"name":"KC_HTTP_ENABLED","value":"true"},{"name":"KC_PROXY_HEADERS","value":"xforwarded"},{"name":"KC_PROXY","value":"edge"}]` |
| keycloak.envFrom | list | keycloak.envFrom defines additional environment variables from ConfigMap or Secret. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret | `[]` |
| keycloak.image | object | keycloak.image defines the container image settings for the Keycloak service. | `{"name":"studio-keycloak","pullPolicy":"IfNotPresent"}` |
| keycloak.image.name | string | keycloak.image.name is the name of the Keycloak container image. | `"studio-keycloak"` |
| keycloak.image.pullPolicy | string | keycloak.image.pullPolicy is the container image pull policy. | `"IfNotPresent"` |
| keycloak.ingress | object | keycloak.ingress defines how the Keycloak service is exposed externally. | `{"additionalAnnotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` |
| keycloak.ingress.additionalAnnotations | object | keycloak.ingress.additionalAnnotations defines additional annotations for the ingress resource. | `{}` |
| keycloak.ingress.className | string | keycloak.ingress.className is the ingress class name. | `""` |
| keycloak.ingress.enabled | bool | keycloak.ingress.enabled determines whether to create an ingress resource. | `true` |
| keycloak.ingress.labels | object | keycloak.ingress.labels defines labels to add to the ingress resource. | `{}` |
| keycloak.ingress.tls | list | keycloak.ingress.tls defines the TLS configuration for the ingress. | `[]` |
| keycloak.livenessProbe | object | keycloak.livenessProbe defines the liveness probe configuration. | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/auth","port":8080,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| keycloak.livenessProbe.enabled | bool | keycloak.livenessProbe.enabled determines whether to enable the liveness probe. | `true` |
| keycloak.livenessProbe.failureThreshold | int | keycloak.livenessProbe.failureThreshold is the number of failures before the container is considered unhealthy. | `6` |
| keycloak.livenessProbe.httpGet | object | keycloak.livenessProbe.httpGet defines the HTTP GET probe configuration. | `{"path":"/auth","port":8080,"scheme":"HTTP"}` |
| keycloak.livenessProbe.httpGet.path | string | keycloak.livenessProbe.httpGet.path is the path to check for liveness. | `"/auth"` |
| keycloak.livenessProbe.httpGet.port | int | keycloak.livenessProbe.httpGet.port is the port to check for liveness. | `8080` |
| keycloak.livenessProbe.httpGet.scheme | string | keycloak.livenessProbe.httpGet.scheme is the protocol to use for the check. | `"HTTP"` |
| keycloak.livenessProbe.initialDelaySeconds | int | keycloak.livenessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. | `30` |
| keycloak.livenessProbe.periodSeconds | int | keycloak.livenessProbe.periodSeconds is how often to perform the probe. | `15` |
| keycloak.livenessProbe.successThreshold | int | keycloak.livenessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. | `1` |
| keycloak.livenessProbe.timeoutSeconds | int | keycloak.livenessProbe.timeoutSeconds is the number of seconds after which the probe times out. | `5` |
| keycloak.nodeSelector | object | keycloak.nodeSelector defines which nodes the Keycloak pods can run on. | `{}` |
| keycloak.podAnnotations | object | keycloak.podAnnotations defines annotations to add to the Keycloak pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-keycloak: runtime/default | `{}` |
| keycloak.podSecurityContext | object | keycloak.podSecurityContext defines the security settings for the entire pod. | `{"enabled":true}` |
| keycloak.podSecurityContext.enabled | bool | keycloak.podSecurityContext.enabled determines whether to enable the pod security context. | `true` |
| keycloak.readinessProbe | object | keycloak.readinessProbe defines the readiness probe configuration. | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/auth","port":8080,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| keycloak.readinessProbe.enabled | bool | keycloak.readinessProbe.enabled determines whether to enable the readiness probe. | `true` |
| keycloak.readinessProbe.failureThreshold | int | keycloak.readinessProbe.failureThreshold is the number of failures before the container is considered not ready. | `6` |
| keycloak.readinessProbe.httpGet | object | keycloak.readinessProbe.httpGet defines the HTTP GET probe configuration. | `{"path":"/auth","port":8080,"scheme":"HTTP"}` |
| keycloak.readinessProbe.httpGet.path | string | keycloak.readinessProbe.httpGet.path is the path to check for readiness. | `"/auth"` |
| keycloak.readinessProbe.httpGet.port | int | keycloak.readinessProbe.httpGet.port is the port to check for readiness. | `8080` |
| keycloak.readinessProbe.httpGet.scheme | string | keycloak.readinessProbe.httpGet.scheme is the protocol to use for the check. | `"HTTP"` |
| keycloak.readinessProbe.initialDelaySeconds | int | keycloak.readinessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. | `30` |
| keycloak.readinessProbe.periodSeconds | int | keycloak.readinessProbe.periodSeconds is how often to perform the probe. | `15` |
| keycloak.readinessProbe.successThreshold | int | keycloak.readinessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. | `1` |
| keycloak.readinessProbe.timeoutSeconds | int | keycloak.readinessProbe.timeoutSeconds is the number of seconds after which the probe times out. | `5` |
| keycloak.replicaCount | int | keycloak.replicaCount is the number of replicas for the Keycloak deployment. | `1` |
| keycloak.resources | object | keycloak.resources defines the resource limits and requests for the Keycloak service. | `{}` |
| keycloak.securityContext | object | keycloak.securityContext defines the security settings for the Keycloak container. | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` |
| keycloak.securityContext.allowPrivilegeEscalation | bool | keycloak.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. | `false` |
| keycloak.securityContext.capabilities | object | keycloak.securityContext.capabilities defines the Linux capabilities configuration. | `{"drop":["ALL"]}` |
| keycloak.securityContext.capabilities.drop | list | keycloak.securityContext.capabilities.drop defines capabilities to drop from the container. | `["ALL"]` |
| keycloak.securityContext.enabled | bool | keycloak.securityContext.enabled determines whether to enable the security context. | `true` |
| keycloak.securityContext.runAsNonRoot | bool | keycloak.securityContext.runAsNonRoot determines whether to run the container as a non-root user. | `true` |
| keycloak.service | object | keycloak.service defines how the Keycloak service is exposed within the cluster. | `{"port":80,"targetPort":8080,"type":"ClusterIP"}` |
| keycloak.service.port | int | keycloak.service.port is the port number for the service. | `80` |
| keycloak.service.targetPort | int | keycloak.service.targetPort is the target port in the container. | `8080` |
| keycloak.service.type | string | keycloak.service.type is the type of Kubernetes service. | `"ClusterIP"` |
| keycloak.serviceAccount | object | keycloak.serviceAccount defines the Kubernetes service account used by the Keycloak pod. | `{"annotations":{},"create":false,"name":""}` |
| keycloak.serviceAccount.annotations | object | keycloak.serviceAccount.annotations defines annotations to add to the service account. | `{}` |
| keycloak.serviceAccount.create | bool | keycloak.serviceAccount.create determines whether to create a new service account. | `false` |
| keycloak.serviceAccount.name | string | keycloak.serviceAccount.name is the name of the service account to use. | `""` |
| keycloak.tolerations | list | keycloak.tolerations defines tolerations for the Keycloak pods. | `[]` |
| nameOverride | string | Override name of app | `""` |
| networkPolicy.denyAll | bool | networkPolicy.denyAll defines whether to apply denyAll network policy | `false` |
| networkPolicy.enabled | bool | networkPolicy.enabled specifies whether to enable network policies | `false` |
| networkPolicy.nodeCIDR | list | networkPolicy.nodeCIDR allows for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes | `[]` |
| podLabels | object | podLabels defines labels to add to all Studio pod(s) | `{}` |
| rasa.enabled | bool | rasa.enabled deploys the Rasa Pro model server subchart. To run Studio without the model service set this to false. WARNING: never disable with `rasa: null` — deleting the key breaks the subchart condition and re-enables the subchart with its default values (the chart fails the render if it detects this). | `true` |
| rasa.fullnameOverride | string |  | `"rasapro"` |
| rasa.rasa.command[0] | string |  | `"python"` |
| rasa.rasa.command[1] | string |  | `"-m"` |
| rasa.rasa.command[2] | string |  | `"rasa.model_service"` |
| rasa.rasa.envFrom[0].configMapRef.name | string |  | `"shared-environment"` |
| rasa.rasa.image.repository | string |  | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` |
| rasa.rasa.image.tag | string |  | `"3.16.2-latest"` |
| rasa.rasa.ingress.annotations | object |  | `{}` |
| rasa.rasa.ingress.enabled | bool |  | `true` |
| rasa.rasa.ingress.hosts[0] | object | Please update the below URL with the correct host name of the Studio deployment | `{"host":"INGRESS.HOST.NAME","paths":[{"path":"/modelservice","pathType":"Prefix"}]}` |
| rasa.rasa.livenessProbe.enabled | bool |  | `true` |
| rasa.rasa.livenessProbe.failureThreshold | int |  | `6` |
| rasa.rasa.livenessProbe.httpGet.path | string |  | `"/modelservice/health"` |
| rasa.rasa.livenessProbe.httpGet.port | int |  | `8000` |
| rasa.rasa.livenessProbe.httpGet.scheme | string |  | `"HTTP"` |
| rasa.rasa.livenessProbe.initialDelaySeconds | int |  | `30` |
| rasa.rasa.livenessProbe.periodSeconds | int |  | `15` |
| rasa.rasa.livenessProbe.successThreshold | int |  | `1` |
| rasa.rasa.livenessProbe.timeoutSeconds | int |  | `5` |
| rasa.rasa.overrideEnv[0].name | string |  | `"RASA_PRO_LICENSE"` |
| rasa.rasa.overrideEnv[0].valueFrom.secretKeyRef.key | string |  | `"RASA_PRO_LICENSE_SECRET_KEY"` |
| rasa.rasa.overrideEnv[0].valueFrom.secretKeyRef.name | string |  | `"studio-secrets"` |
| rasa.rasa.overrideEnv[1].name | string |  | `"OPENAI_API_KEY"` |
| rasa.rasa.overrideEnv[1].valueFrom.secretKeyRef.key | string |  | `"OPENAI_API_KEY_SECRET_KEY"` |
| rasa.rasa.overrideEnv[1].valueFrom.secretKeyRef.name | string |  | `"studio-secrets"` |
| rasa.rasa.persistence.create | bool |  | `true` |
| rasa.rasa.persistence.hostPath.enabled | bool |  | `false` |
| rasa.rasa.persistence.storageCapacity | string |  | `"1Gi"` |
| rasa.rasa.persistence.storageClassName | string | Make sure to set the correct storage class name based on your cluster configuration | `nil` |
| rasa.rasa.persistence.storageRequests | string |  | `"1Gi"` |
| rasa.rasa.podSecurityContext.fsGroup | int | User ID of the container to access the mounted volume | `1001` |
| rasa.rasa.readinessProbe.enabled | bool |  | `true` |
| rasa.rasa.readinessProbe.failureThreshold | int |  | `6` |
| rasa.rasa.readinessProbe.httpGet.path | string |  | `"/modelservice/health"` |
| rasa.rasa.readinessProbe.httpGet.port | int |  | `8000` |
| rasa.rasa.readinessProbe.httpGet.scheme | string |  | `"HTTP"` |
| rasa.rasa.readinessProbe.initialDelaySeconds | int |  | `30` |
| rasa.rasa.readinessProbe.periodSeconds | int |  | `15` |
| rasa.rasa.readinessProbe.successThreshold | int |  | `1` |
| rasa.rasa.readinessProbe.timeoutSeconds | int |  | `5` |
| rasa.rasa.replicaCount | int |  | `1` |
| rasa.rasa.resources | object | rasa.resources specifies the resources limits and requests | `{}` |
| rasa.rasa.service.port | int |  | `80` |
| rasa.rasa.service.targetPort | int |  | `8000` |
| rasa.rasa.settings.mountDefaultConfigmap | bool |  | `false` |
| rasa.rasa.settings.mountModelsVolume | bool |  | `false` |
| rasa.rasa.settings.useDefaultArgs | bool |  | `false` |
| rasa.rasa.strategy.type | string |  | `"Recreate"` |
| rasa.rasaProServices.enabled | bool |  | `false` |
| repository | string | repository specifies image repository for Studio | `"europe-west3-docker.pkg.dev/rasa-releases/studio/"` |
| tag | string | tag overrides the image tag for all Studio images (unified studio image; Studio ≥ 2.0.0). Empty (default) uses the chart's appVersion. Set an exact, immutable tag to pin deployments independently of chart upgrades. | `""` |
