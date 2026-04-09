# rasa

A Rasa Pro Helm chart for Kubernetes

![Version: 2.1.0-rc.0](https://img.shields.io/badge/Version-2.1.0--rc.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
  --from-literal=rasaProLicense="<YOUR_LICENSE_KEY>"
```

The chart defaults to `secretName: rasa-secrets` and `secretKey: rasaProLicense`. Override both in your values if you use a different name or key:

```yaml
rasaProLicense:
  secretName: my-custom-secret
  secretKey: myLicenseKey
```

### Optional Secrets

Add optional keys to the same secret (or separate secrets) as you enable features. You can extend the secret you created above:

```console
kubectl patch secret rasa-secrets -p \
  '{"stringData":{"authToken":"<YOUR_TOKEN>","jwtSecret":"<YOUR_JWT_SECRET>"}}'
```

The table below lists all secret-backed fields:

| Secret key | Feature | values.yaml field |
|---|---|---|
| `authToken` | Token-based API authentication | `rasa.settings.authToken` |
| `jwtSecret` | JWT API authentication | `rasa.settings.jwtSecret` |
| `kafkaSslPassword` | Kafka SASL password (non-IAM) | `rasaProServices.kafka.saslPassword` |
| `analyticsDbUrl` | Analytics database URL (non-IAM) | `rasaProServices.database.urlExistingSecretName` |

Alternatively, create all credentials upfront from a manifest. The chart ships a `secrets.yaml` example that you can use as a starting point — **use `stringData` so Kubernetes base64-encodes the values automatically**:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rasa-secrets
type: Opaque
stringData:
  rasaProLicense: "<YOUR_LICENSE_KEY>"    # required for all deployments
  authToken: "<YOUR_AUTH_TOKEN>"          # optional: token-based API auth
  jwtSecret: "<YOUR_JWT_SECRET>"          # optional: JWT auth
  kafkaSslPassword: "<KAFKA_PASSWORD>"    # optional: Kafka SASL (non-IAM)
```

## Installing the Chart

Before installing, make sure you have created the license secret as described in [Creating Secrets](#creating-secrets) above.

You can install the chart from either the OCI registry or the GitHub Helm repository.

### Option 1: Install from OCI Registry

To install the chart with the release name `my-release`:

```console
helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version 2.1.0-rc.0
```

### Option 2: Install from GitHub Helm Repository

First, add the Rasa Helm repository:

```console
helm repo add rasa https://helm.rasa.com/charts
helm repo update
```

Then install the chart:

```console
helm install my-release rasa/rasa --version 2.1.0-rc.0
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

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## General Configuration

- **imagePullSecrets**: If you're pulling from a private registry, provide your pull secret name(s) here. This applies to all components unless overridden at the component level.
- **rasaProLicense**: All Rasa Pro deployments require a valid license. Provide `secretName` and `secretKey` pointing to the Kubernetes Secret that holds your license value.

> **Note:** For application-specific settings, refer to the [Rasa documentation](https://rasa.com/docs/). The full list of configurable values is at the bottom of this page.

### Deployment Modes

#### Rasa Pro with Analytics (full stack)

Deploys the Rasa Pro server together with the Rasa Pro Services analytics pipeline. Requires a PostgreSQL-compatible analytics database.

```yaml
rasa:
  enabled: true
rasaProServices:
  enabled: true
  database:
    url: "postgresql://user:password@host:5432/dbname"
```

#### Rasa Pro only (no analytics)

Deploys only the Rasa Pro server. Use this when you do not need the analytics pipeline.

```yaml
rasa:
  enabled: true
rasaProServices:
  enabled: false
```

### Minimal Working Configuration

The following is the smallest `values.yaml` needed to get Rasa Pro running. It assumes the license secret was created as shown in [Creating Secrets](#creating-secrets):

```yaml
rasaProLicense:
  secretName: rasa-secrets
  secretKey: rasaProLicense

rasa:
  enabled: true
  image:
    tag: "3.x.x"  # pin to a specific Rasa Pro version

rasaProServices:
  enabled: false
```

Install with:

```console
helm install my-release rasa/rasa -f values.yaml
```

From there, add sections from the rest of this guide as your deployment grows.

### Rasa Pro Services Database Configuration

The `rasaProServices.database` section configures the analytics data lake connection. There are two ways to provide the database URL.

**Plain value:**

```yaml
rasaProServices:
  database:
    url: "postgresql://user:password@host:5432/dbname"
```

**From an existing secret** (recommended for production):

Create a Kubernetes secret containing the database URL:

```console
kubectl create secret generic my-db-secret \
  --from-literal=analyticsDbUrl="postgresql://user:password@host:5432/dbname"
```

Then reference it in your values:

```yaml
rasaProServices:
  database:
    urlExistingSecretName: my-db-secret
    urlExistingSecretKey: analyticsDbUrl
```

When `urlExistingSecretName` is set it takes precedence over `url`.

**AWS RDS IAM authentication:**

For IAM-based authentication (passwordless, using an IAM role bound to the pod's service account), use `database.enableAwsRdsIam: true` and provide individual connection fields instead of a URL:

```yaml
rasaProServices:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/rasa-pro-services-role"
  database:
    enableAwsRdsIam: true
    hostname: "my-cluster.cluster-xxxxx.us-east-1.rds.amazonaws.com"
    port: "5432"
    username: "rasa_user"
    databaseName: "rasa_analytics"
    sslMode: "verify-full"
    sslCaLocation: "/path/to/rds-ca.pem"
```

### Use MinIO instead of S3

> **Warning:** MinIO is end-of-life and no longer receives updates. The chart still supports connecting to a MinIO instance, but we recommend migrating to S3 or another actively maintained object storage provider.

To use MinIO instead of S3, set `AWS_ENDPOINT_URL` to the URL of the MinIO server and provide `AWS_REGION` and `BUCKET_NAME`. Store your MinIO credentials in a Kubernetes Secret:

```console
kubectl create secret generic minio-credentials \
  --from-literal=accessKey="<YOUR_MINIO_ACCESS_KEY>" \
  --from-literal=secretKey="<YOUR_MINIO_SECRET_KEY>"
```

```yaml
rasa:
  additionalEnv:
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

By default, the chart mounts `credentials.yml` and `endpoints.yml` files from a ConfigMap to the Rasa deployment. If you prefer to mount these files from a different source (e.g., from the `/.config` directory or baked into the image), you can disable this behavior:

```yaml
rasa:
  settings:
    mountDefaultConfigmap: false
```

When disabled, it is expected that the credentials and endpoints are mounted to the `/.config` directory or baked into the image.

**mountModelsVolume:**

By default, the chart mounts a models volume to the Rasa deployment at `/app/models`. If you prefer to mount models from a different source or bake them into the image, you can disable this behavior:

```yaml
rasa:
  settings:
    mountModelsVolume: false
```

When disabled, it is expected that the models are mounted to the `/app/models` directory or baked into the image.

### Configuring API Authentication

The Rasa HTTP API supports two authentication methods. Configure one or both via Kubernetes Secrets.

**Token-based authentication:**

```console
kubectl create secret generic rasa-secrets \
  --from-literal=authToken="<YOUR_STATIC_TOKEN>"
```

```yaml
rasa:
  settings:
    authToken:
      secretName: rasa-secrets
      secretKey: authToken
```

**JWT authentication:**

```console
kubectl create secret generic rasa-secrets \
  --from-literal=jwtSecret="<YOUR_JWT_SECRET>"
```

```yaml
rasa:
  settings:
    jwtSecret:
      secretName: rasa-secrets
      secretKey: jwtSecret
    jwtMethod: HS256
```

See the [Rasa documentation](https://rasa.com/docs/reference/api/pro/rasa-pro-rest-api/) for details on API authentication.

### Configuring the Readiness Probe

The default readiness probe hits the `/` endpoint, which returns a success code as soon as the HTTP server is up — before any model has been loaded. For production, use the `/status` endpoint instead, which only returns a success code once Rasa has loaded a model and is ready to process conversations.

**Without authentication:**

```yaml
rasa:
  readinessProbe:
    httpGet:
      path: /status
      port: 5005
      scheme: HTTP
```

**With `authToken` configured:**

When `AUTH_TOKEN` is set, the `/status` endpoint requires authentication. Use an `exec` probe that reads the token from the environment variable:

```yaml
rasa:
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

> **Note:** The `AUTH_TOKEN` environment variable is automatically injected by the chart from the secret referenced in `rasa.settings.authToken`. Setting `httpGet: null` removes the default value set by the chart — this is required when switching from an `httpGet` probe to an `exec` probe, otherwise both will be rendered and Kubernetes will reject the manifest. Update the URL scheme and port in the `curl` command if you have changed `rasa.settings.scheme` or `rasa.settings.port` from their defaults.

### Configuring Credentials and Endpoints via ConfigMap

The chart can automatically create a ConfigMap containing `credentials.yml` and `endpoints.yml` files that are mounted to the Rasa deployment. This is enabled by default via `rasa.settings.mountDefaultConfigmap: true`.

#### Configuring Credentials

The `rasa.settings.credentials` section allows you to configure channel connectors for messaging and voice channels. These credentials are written to the `credentials.yml` file in the ConfigMap.

For example, to configure Facebook Messenger:

```yaml
rasa:
  settings:
    credentials:
      facebook:
        verify: "rasa"
        secret: "<SECRET>"
        page-access-token: "<PAGE-ACCESS-TOKEN>"
```

For REST channel:

```yaml
rasa:
  settings:
    credentials:
      rest:
```

See the [Rasa channel documentation](https://rasa.com/docs/reference/channels/messaging-and-voice-channels) for all available channel configurations.

#### Configuring Endpoints

The `rasa.settings.endpoints` section allows you to configure various endpoints and integrations. These endpoints are written to the `endpoints.yml` file in the ConfigMap.

**Action Server Endpoint:**

The action endpoint URL must be a full HTTP URL. When using the bundled Action Server component, the service name follows the pattern `<fullname>-action-server`:

```yaml
rasa:
  settings:
    endpoints:
      action_endpoint:
        url: "http://my-release-action-server:5055/webhook"
```

**Model Storage:**

```yaml
rasa:
  settings:
    endpoints:
      models:
        url: http://my-server.com/models/default_core@latest
        wait_time_between_pulls: 10
```

**Tracker Store (Redis example):**

```yaml
rasa:
  settings:
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
  settings:
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
  settings:
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
rasa:
  additionalEnv:
    - name: OPENAI_API_KEY
      valueFrom:
        secretKeyRef:
          name: openai-secret
          key: apiKey
  settings:
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

### Action Server

The chart can optionally deploy a [Rasa SDK](https://rasa.com/docs/action-server) Action Server alongside Rasa Pro. You must build and publish your own container image from your actions code — there is no default image provided.

```yaml
actionServer:
  enabled: true
  image:
    repository: "your-registry/your-actions-image"
    tag: "latest"
```

When enabled, configure Rasa Pro to use it via `rasa.settings.endpoints`. The Action Server service name follows the pattern `<release-name>-action-server`:

```yaml
rasa:
  settings:
    endpoints:
      action_endpoint:
        url: "http://my-release-action-server:5055/webhook"
```

### Duckling

[Duckling](https://github.com/facebook/duckling) is a structured entity extraction service. Enable it when your NLU pipeline requires it:

```yaml
duckling:
  enabled: true
```

When `duckling.enabled: true`, the chart automatically sets `RASA_DUCKLING_HTTP_URL` to the in-cluster service URL — no additional configuration is required.

To connect to an **external** Duckling instance instead, leave `duckling.enabled: false` and set the URL explicitly:

```yaml
duckling:
  enabled: false
rasa:
  settings:
    ducklingHttpUrl: "http://my-external-duckling:8000"
```

### Environment Variables

Use `additionalEnv` to inject extra environment variables into any component without replacing the chart-managed ones. Both plain values and Secret/ConfigMap references are supported:

```yaml
rasa:
  additionalEnv:
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
rasa:
  envFrom:
    - configMapRef:
        name: my-configmap
    - secretRef:
        name: my-secret
```

Both `additionalEnv` and `envFrom` are available on all components (`rasa`, `rasaProServices`, `actionServer`, `duckling`).

### Loading Initial Models

Use `initContainers` to download a model before the Rasa server starts. The init container shares the `/app/models` volume with the main container:

```yaml
rasa:
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
rasa:
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

The Action Server and Duckling components each have their own `ingress` block with the same structure under `actionServer.ingress` and `duckling.ingress`.

### Resources and Autoscaling

No resource requests or limits are set by default. For production, always set these explicitly:

```yaml
rasa:
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
rasa:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    # targetMemoryUtilizationPercentage: 80
```

The same `resources` and `autoscaling` blocks are available for `rasaProServices`, `actionServer`, and `duckling`.

### Rasa Pro Services Kafka Configuration

Rasa Pro Services consumes conversation events from Kafka for the analytics pipeline. Configure the Kafka connection under `rasaProServices.kafka`:

**SASL_SSL (recommended for production):**

```yaml
rasaProServices:
  kafka:
    brokerAddress: "kafka-bootstrap.example.com:9092"
    topic: "rasa-core-events"
    dlqTopic: "rasa-analytics-dlq"
    consumerId: "rasa-analytics-group"
    securityProtocol: "SASL_SSL"
    saslMechanism: "SCRAM-SHA-512"
    saslUsername: "rasa-analytics"
    saslPassword:
      secretName: kafka-credentials
      secretKey: password
    sslCaLocation: "/path/to/ca.pem"
```

**AWS MSK with IAM authentication:**

```yaml
rasaProServices:
  kafka:
    enableAwsMskIam: true
    brokerAddress: "b-1.my-cluster.xxxxx.c1.kafka.us-east-1.amazonaws.com:9098"
    topic: "rasa-core-events"
    dlqTopic: "rasa-analytics-dlq"
  useCloudProviderIam:
    enabled: true
    provider: "aws"
    region: "us-east-1"
```

### Network Policies

Network policies are disabled by default. Enable them to restrict traffic between components:

```yaml
networkPolicy:
  enabled: true
  denyAll: true
  nodeCIDR:
    - ipBlock:
        cidr: 10.0.0.0/8  # adjust to your node CIDR
```

> **Note:** When `networkPolicy.denyAll` is true, you must supply `nodeCIDR` so that the kubelet can reach pods for liveness and readiness probes.

> **Warning:** The built-in kubelet allowlist only covers the `rasa` and `rasa-pro-services` pods. If you enable `duckling` or `actionServer` alongside `denyAll: true`, their liveness and readiness probes will silently fail — the pods will start but Kubernetes will never mark them as ready. You must add NetworkPolicy rules manually to allow kubelet access to those pods before enabling `denyAll`.

## Configuration Reference

The following table lists all configurable parameters for this chart and their default values.

## Values

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| actionServer.additionalContainers | list | actionServer.additionalContainers allows to specify additional containers for the Action Server Deployment | `[]` |
| actionServer.additionalEnv | list | actionServer.additionalEnv adds additional environment variables | `[]` |
| actionServer.affinity | object | actionServer.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| actionServer.args | list | actionServer.args overrides the default arguments for the container | `[]` |
| actionServer.autoscaling.enabled | bool | autoscaling.enabled specifies whether autoscaling should be enabled | `false` |
| actionServer.autoscaling.maxReplicas | int | autoscaling.maxReplicas specifies the maximum number of replicas | `100` |
| actionServer.autoscaling.minReplicas | int | autoscaling.minReplicas specifies the minimum number of replicas | `1` |
| actionServer.autoscaling.targetCPUUtilizationPercentage | int | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage | `80` |
| actionServer.command | list | actionServer.command overrides the default command for the container | `[]` |
| actionServer.containerSecurityContext | object | actionServer.containerSecurityContext defines security context that allows you to overwrite the container-level security context | `{"enabled":true}` |
| actionServer.enabled | bool | actionServer.enabled enables Action Server deployment | `false` |
| actionServer.envFrom | list | actionServer.envFrom is used to add environment variables from ConfigMap or Secret | `[]` |
| actionServer.image.pullPolicy | string | image.pullPolicy specifies image pull policy | `"IfNotPresent"` |
| actionServer.image.repository | string | image.repository specifies image repository | `"rasa/rasa-sdk"` |
| actionServer.image.tag | string | image.tag specifies image tag | `"3.16.0-latest"` |
| actionServer.ingress.annotations | object | ingress.annotations defines annotations to add to the ingress | `{}` |
| actionServer.ingress.className | string | ingress.className specifies the ingress className to be used | `""` |
| actionServer.ingress.enabled | bool | ingress.enabled specifies whether an ingress service should be created | `false` |
| actionServer.ingress.hosts | list | ingress.hosts specifies the hosts for this ingress | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}]` |
| actionServer.ingress.labels | object | ingress.labels defines labels to add to the ingress | `{}` |
| actionServer.ingress.tls | list | ingress.tls specifies the TLS configuration for ingress | `[]` |
| actionServer.initContainers | list | actionServer.initContainers allows to specify init containers for the Action Server deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ | `[]` |
| actionServer.livenessProbe.enabled | bool | livenessProbe.enabled is used to enable or disable liveness probe | `true` |
| actionServer.livenessProbe.failureThreshold | int | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| actionServer.livenessProbe.httpGet | object | livenessProbe.httpGet is used to define HTTP request | `{"path":"/health","port":5055,"scheme":"HTTP"}` |
| actionServer.livenessProbe.initialDelaySeconds | int | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| actionServer.livenessProbe.periodSeconds | int | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| actionServer.livenessProbe.successThreshold | int | livenessProbe.successThreshold is the minimum consecutive successes required before the probe is considered successful after a failure | `1` |
| actionServer.livenessProbe.terminationGracePeriodSeconds | int | livenessProbe.terminationGracePeriodSeconds is an optional duration in seconds the pod needs to terminate gracefully after a liveness probe failure | `30` |
| actionServer.livenessProbe.timeoutSeconds | int | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| actionServer.nodeSelector | object | actionServer.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| actionServer.podAnnotations | object | actionServer.podAnnotations defines annotations to add to the pod | `{}` |
| actionServer.podSecurityContext | object | actionServer.podSecurityContext defines pod security context | `{"enabled":true}` |
| actionServer.readinessProbe.enabled | bool | readinessProbe.enabled is used to enable or disable readinessProbe | `true` |
| actionServer.readinessProbe.failureThreshold | int | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| actionServer.readinessProbe.httpGet | object | readinessProbe.httpGet is used to define HTTP request | `{"path":"/health","port":5055,"scheme":"HTTP"}` |
| actionServer.readinessProbe.initialDelaySeconds | int | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| actionServer.readinessProbe.periodSeconds | int | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| actionServer.readinessProbe.successThreshold | int | readinessProbe.successThreshold is the minimum consecutive successes required before the probe is considered successful after a failure | `1` |
| actionServer.readinessProbe.timeoutSeconds | int | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| actionServer.replicaCount | int | actionServer.replicaCount specifies number of replicas | `1` |
| actionServer.resources | object | actionServer.resources specifies the resources limits and requests | `{}` |
| actionServer.service | object | actionServer.service define service for Action Server | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":5055,"targetPort":5055,"type":"ClusterIP"}` |
| actionServer.service.annotations | object | service.annotations defines annotations to add to the service | `{}` |
| actionServer.service.externalTrafficPolicy | string | service.externalTrafficPolicy enables client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip | `"Cluster"` |
| actionServer.service.loadBalancerIP | string | service.loadBalancerIP exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer | `nil` |
| actionServer.service.nodePort | string | service.nodePort is used to specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport | `nil` |
| actionServer.service.port | int | service.port is used to specify service port | `5055` |
| actionServer.service.targetPort | int | service.targetPort is the container port that Service traffic is forwarded to. Should match settings.port. | `5055` |
| actionServer.service.type | string | service.type is used to specify service type | `"ClusterIP"` |
| actionServer.serviceAccount | object | actionServer.serviceAccount defines service account | `{"annotations":{},"create":true,"name":""}` |
| actionServer.serviceAccount.annotations | object | serviceAccount.annotations defines annotations to add to the service account | `{}` |
| actionServer.serviceAccount.create | bool | serviceAccount.create specifies whether a service account should be created | `true` |
| actionServer.serviceAccount.name | string | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""` |
| actionServer.settings.port | int | settings.port defines port on which Action Server runs | `5055` |
| actionServer.settings.scheme | string | settings.scheme is the HTTP scheme (http or https) used to construct internal service URLs | `"http"` |
| actionServer.strategy | object | actionServer.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy | `{}` |
| actionServer.tolerations | list | actionServer.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| actionServer.volumeMounts | list | actionServer.volumeMounts specifies additional volumes to mount in the Action Server container | `[]` |
| actionServer.volumes | list | actionServer.volumes specify additional volumes to mount in the Action Server container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ | `[]` |
| deploymentAnnotations | object | deploymentAnnotations defines annotations to add to all Rasa deployments | `{}` |
| deploymentLabels | object | deploymentLabels defines labels to add to all Rasa deployment | `{}` |
| dnsConfig | object | dnsConfig specifies Pod's DNS config # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config | `{}` |
| dnsPolicy | string | dnsPolicy specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy | `""` |
| duckling.additionalContainers | list | duckling.additionalContainers allows to specify additional containers for the Duckling Deployment | `[]` |
| duckling.additionalEnv | list | duckling.additionalEnv adds additional environment variables | `[]` |
| duckling.affinity | object | duckling.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| duckling.args | list | duckling.args overrides the default arguments for the container | `[]` |
| duckling.autoscaling.enabled | bool | autoscaling.enabled specifies whether autoscaling should be enabled | `false` |
| duckling.autoscaling.maxReplicas | int | autoscaling.maxReplicas specifies the maximum number of replicas | `100` |
| duckling.autoscaling.minReplicas | int | autoscaling.minReplicas specifies the minimum number of replicas | `1` |
| duckling.autoscaling.targetCPUUtilizationPercentage | int | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage | `80` |
| duckling.command | list | duckling.command overrides the default command for the container | `[]` |
| duckling.containerSecurityContext | object | duckling.containerSecurityContext defines security context that allows you to overwrite the container-level security context | `{"enabled":true}` |
| duckling.enabled | bool | duckling.enabled enables Duckling deployment | `false` |
| duckling.envFrom | list | duckling.envFrom is used to add environment variables from ConfigMap or Secret | `[]` |
| duckling.image.pullPolicy | string | image.pullPolicy specifies image pull policy | `"IfNotPresent"` |
| duckling.image.repository | string | image.repository specifies image repository | `"rasa/duckling"` |
| duckling.image.tag | string | image.tag specifies image tag | `"0.2.0.2-r4"` |
| duckling.ingress.annotations | object | ingress.annotations defines annotations to add to the ingress | `{}` |
| duckling.ingress.className | string | ingress.className specifies the ingress className to be used | `""` |
| duckling.ingress.enabled | bool | ingress.enabled specifies whether an ingress service should be created | `false` |
| duckling.ingress.hosts | list | ingress.hosts specifies the hosts for this ingress | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}]` |
| duckling.ingress.labels | object | ingress.labels defines labels to add to the ingress | `{}` |
| duckling.ingress.tls | list | ingress.tls specifies the TLS configuration for ingress | `[]` |
| duckling.initContainers | list | duckling.initContainers allows to specify init containers for the Duckling deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ | `[]` |
| duckling.livenessProbe.enabled | bool | livenessProbe.enabled is used to enable or disable liveness probe | `true` |
| duckling.livenessProbe.failureThreshold | int | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| duckling.livenessProbe.httpGet | object | livenessProbe.httpGet is used to define HTTP request | `{"path":"/","port":8000,"scheme":"HTTP"}` |
| duckling.livenessProbe.initialDelaySeconds | int | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| duckling.livenessProbe.periodSeconds | int | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| duckling.livenessProbe.successThreshold | int | livenessProbe.successThreshold is the minimum consecutive successes required before the probe is considered successful after a failure | `1` |
| duckling.livenessProbe.terminationGracePeriodSeconds | int | livenessProbe.terminationGracePeriodSeconds is an optional duration in seconds the pod needs to terminate gracefully after a liveness probe failure | `30` |
| duckling.livenessProbe.timeoutSeconds | int | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| duckling.nodeSelector | object | duckling.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| duckling.podAnnotations | object | duckling.podAnnotations defines annotations to add to the pod | `{}` |
| duckling.podSecurityContext | object | duckling.podSecurityContext defines pod security context | `{"enabled":true}` |
| duckling.readinessProbe.enabled | bool | readinessProbe.enabled is used to enable or disable readinessProbe | `true` |
| duckling.readinessProbe.failureThreshold | int | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| duckling.readinessProbe.httpGet | object | readinessProbe.httpGet is used to define HTTP request | `{"path":"/","port":8000,"scheme":"HTTP"}` |
| duckling.readinessProbe.initialDelaySeconds | int | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| duckling.readinessProbe.periodSeconds | int | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| duckling.readinessProbe.successThreshold | int | readinessProbe.successThreshold is the minimum consecutive successes required before the probe is considered successful after a failure | `1` |
| duckling.readinessProbe.timeoutSeconds | int | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| duckling.replicaCount | int | duckling.replicaCount specifies number of replicas | `1` |
| duckling.resources | object | duckling.resources specifies the resources limits and requests | `{}` |
| duckling.service | object | duckling.service define service for Duckling | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":8000,"targetPort":8000,"type":"ClusterIP"}` |
| duckling.service.annotations | object | service.annotations defines annotations to add to the service | `{}` |
| duckling.service.externalTrafficPolicy | string | service.externalTrafficPolicy enables client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip | `"Cluster"` |
| duckling.service.loadBalancerIP | string | service.loadBalancerIP exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer | `nil` |
| duckling.service.nodePort | string | service.nodePort is used to specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport | `nil` |
| duckling.service.port | int | service.port is used to specify service port | `8000` |
| duckling.service.targetPort | int | service.targetPort is the container port that Service traffic is forwarded to. Should match settings.port. | `8000` |
| duckling.service.type | string | service.type is used to specify service type | `"ClusterIP"` |
| duckling.serviceAccount | object | duckling.serviceAccount defines service account | `{"annotations":{},"create":true,"name":""}` |
| duckling.serviceAccount.annotations | object | serviceAccount.annotations defines annotations to add to the service account | `{}` |
| duckling.serviceAccount.create | bool | serviceAccount.create specifies whether a service account should be created | `true` |
| duckling.serviceAccount.name | string | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""` |
| duckling.settings.port | int | settings.port defines port on which Duckling runs | `8000` |
| duckling.settings.scheme | string | settings.scheme is the HTTP scheme (http or https) used to construct internal service URLs | `"http"` |
| duckling.strategy | object | duckling.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy | `{}` |
| duckling.tolerations | list | duckling.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| duckling.volumeMounts | list | duckling.volumeMounts specifies additional volumes to mount in the Duckling container | `[]` |
| duckling.volumes | list | duckling.volumes specify additional volumes to mount in the Duckling container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ | `[]` |
| fullnameOverride | string | fullnameOverride overrides the fully-qualified name prefix used for all chart resources. | `""` |
| global.additionalDeploymentLabels | object | global.additionalDeploymentLabels adds extra labels to all Deployment resources. Useful for mapping organizational structures onto Kubernetes objects. See: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ | `{}` |
| global.ingressHost | string |  | `nil` |
| hostAliases | list | hostAliases specifies pod-level override of hostname resolution when DNS and other options are not applicable | `[]` |
| hostNetwork | bool | hostNetwork controls whether the pod may use the node network namespace | `false` |
| imagePullSecrets | list | imagePullSecrets contains references to Secrets for pulling images from private registries. Applied to all components unless overridden at the component level. | `[]` |
| nameOverride | string | nameOverride overrides the name used for chart resources. Defaults to the chart name. | `""` |
| networkPolicy.denyAll | bool | networkPolicy.denyAll applies a default-deny NetworkPolicy that blocks all ingress and egress traffic before more specific rules are applied. | `false` |
| networkPolicy.enabled | bool | networkPolicy.enabled enables Kubernetes NetworkPolicy resources for all components. When true, only explicitly allowed traffic is permitted. | `false` |
| networkPolicy.nodeCIDR | list | networkPolicy.nodeCIDR specifies node IP ranges allowed to reach pods. Required to allow kubelet liveness and readiness probes when networkPolicy.enabled is true. | `[]` |
| podLabels | object | podLabels defines labels to add to all Rasa pod(s) | `{}` |
| rasa.additionalArgs | list | rasa.additionalArgs adds additional arguments to the default args | `[]` |
| rasa.additionalContainers | list | rasa.additionalContainers allows to specify additional containers for the Rasa Deployment | `[]` |
| rasa.additionalEnv | list | rasa.additionalEnv adds additional environment variables | `[]` |
| rasa.affinity | object | rasa.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| rasa.args | list | rasa.args overrides the default arguments for the container | `[]` |
| rasa.autoscaling.enabled | bool | autoscaling.enabled specifies whether autoscaling should be enabled | `false` |
| rasa.autoscaling.maxReplicas | int | autoscaling.maxReplicas specifies the maximum number of replicas | `100` |
| rasa.autoscaling.minReplicas | int | autoscaling.minReplicas specifies the minimum number of replicas | `1` |
| rasa.autoscaling.targetCPUUtilizationPercentage | int | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage | `80` |
| rasa.command | list | rasa.command overrides the default command for the container | `[]` |
| rasa.containerSecurityContext | object | rasa.containerSecurityContext defines security context that allows you to overwrite the container-level security context | `{"enabled":true}` |
| rasa.enabled | bool | rasa.enabled enables the Rasa Pro server deployment. Set to false to deploy only Rasa Pro Services (analytics pipeline). | `true` |
| rasa.envFrom | list | rasa.envFrom is used to add environment variables from ConfigMap or Secret | `[]` |
| rasa.image.pullPolicy | string | image.pullPolicy specifies image pull policy | `"IfNotPresent"` |
| rasa.image.repository | string | image.repository specifies image repository | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` |
| rasa.image.tag | string | image.tag specifies image tag | `"3.16.2-latest"` |
| rasa.ingress.annotations | object | ingress.annotations defines annotations to add to the ingress | `{}` |
| rasa.ingress.className | string | ingress.className specifies the ingress className to be used | `""` |
| rasa.ingress.enabled | bool | ingress.enabled specifies whether an ingress service should be created | `false` |
| rasa.ingress.hosts | list | ingress.hosts specifies the hosts for this ingress | `[{"extraPaths":[],"host":"INGRESS.HOST.NAME","paths":[{"path":"/api","pathType":"Prefix"}]}]` |
| rasa.ingress.labels | object | ingress.labels defines labels to add to the ingress | `{}` |
| rasa.ingress.tls | list | ingress.tls specifies the TLS configuration for ingress | `[]` |
| rasa.initContainers | list | rasa.initContainers allows to specify init containers for the Rasa deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ # <PATH_TO_INITIAL_MODEL> has to be a URL (without auth) that points to a tar.gz file | `[]` |
| rasa.livenessProbe.enabled | bool | livenessProbe.enabled is used to enable or disable liveness probe | `true` |
| rasa.livenessProbe.failureThreshold | int | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| rasa.livenessProbe.httpGet | object | livenessProbe.httpGet is used to define HTTP request | `{"path":"/","port":5005,"scheme":"HTTP"}` |
| rasa.livenessProbe.initialDelaySeconds | int | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| rasa.livenessProbe.periodSeconds | int | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| rasa.livenessProbe.successThreshold | int | livenessProbe.successThreshold is the minimum consecutive successes required before the probe is considered successful after a failure | `1` |
| rasa.livenessProbe.terminationGracePeriodSeconds | int | livenessProbe.terminationGracePeriodSeconds is an optional duration in seconds the pod needs to terminate gracefully after a liveness probe failure | `30` |
| rasa.livenessProbe.timeoutSeconds | int | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| rasa.nodeSelector | object | rasa.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| rasa.overrideEnv | list | rasa.overrideEnv overrides all default environment variables | `[]` |
| rasa.persistence.create | bool |  | `false` |
| rasa.persistence.hostPath.enabled | bool |  | `false` |
| rasa.persistence.storageCapacity | string |  | `"1Gi"` |
| rasa.persistence.storageClassName | string |  | `nil` |
| rasa.persistence.storageRequests | string |  | `"1Gi"` |
| rasa.podAnnotations | object | rasa.podAnnotations defines annotations to add to the pod | `{}` |
| rasa.podSecurityContext | object | rasa.podSecurityContext defines pod security context | `{"enabled":true}` |
| rasa.readinessProbe.enabled | bool | readinessProbe.enabled is used to enable or disable readinessProbe | `true` |
| rasa.readinessProbe.failureThreshold | int | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| rasa.readinessProbe.httpGet | object | readinessProbe.httpGet is used to define HTTP request | `{"path":"/","port":5005,"scheme":"HTTP"}` |
| rasa.readinessProbe.initialDelaySeconds | int | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| rasa.readinessProbe.periodSeconds | int | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| rasa.readinessProbe.successThreshold | int | readinessProbe.successThreshold is the minimum consecutive successes required before the probe is considered successful after a failure | `1` |
| rasa.readinessProbe.timeoutSeconds | int | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| rasa.replicaCount | int | rasa.replicaCount specifies number of replicas | `1` |
| rasa.resources | object | rasa.resources specifies the resources limits and requests | `{}` |
| rasa.service | object | rasa.service configures the Kubernetes Service exposing the Rasa Pro server. | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":5005,"targetPort":5005,"type":"ClusterIP"}` |
| rasa.service.annotations | object | service.annotations defines annotations to add to the service | `{}` |
| rasa.service.externalTrafficPolicy | string | service.externalTrafficPolicy enables client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip | `"Cluster"` |
| rasa.service.loadBalancerIP | string | service.loadBalancerIP exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer | `nil` |
| rasa.service.nodePort | string | service.nodePort is used to specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport | `nil` |
| rasa.service.port | int | service.port is used to specify service port | `5005` |
| rasa.service.targetPort | int | service.targetPort is the container port that Service traffic is forwarded to. Should match settings.port. | `5005` |
| rasa.service.type | string | service.type is used to specify service type | `"ClusterIP"` |
| rasa.serviceAccount | object | rasa.serviceAccount defines service account | `{"annotations":{},"create":true,"name":""}` |
| rasa.serviceAccount.annotations | object | serviceAccount.annotations defines annotations to add to the service account | `{}` |
| rasa.serviceAccount.create | bool | serviceAccount.create specifies whether a service account should be created | `true` |
| rasa.serviceAccount.name | string | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""` |
| rasa.settings.authToken | object | settings.authToken references the Kubernetes Secret containing the static bearer token used to authenticate API requests. | `{"secretKey":"authToken","secretName":"rasa-secrets"}` |
| rasa.settings.cors | string | settings.cors sets the allowed CORS origin for the Rasa API. Defaults to '*' (all origins). Restrict to specific domains in production. | `"*"` |
| rasa.settings.credentials | object | settings.credentials enables credentials configuration for channel connectors # See: https://rasa.com/docs/reference/channels/messaging-and-voice-channels | `{}` |
| rasa.settings.debugMode | bool | settings.debugMode enables debug mode | `false` |
| rasa.settings.ducklingHttpUrl | string | settings.ducklingHttpUrl is the HTTP URL of the Duckling entity extraction service. Required when using Duckling for entity extraction. | `nil` |
| rasa.settings.enableApi | bool | settings.enableApi enables the Rasa HTTP API in addition to the configured input channel. Required for most integrations. Supports token-based auth (authToken) or JWT auth (jwtSecret + jwtMethod). | `true` |
| rasa.settings.endpoints | object | settings.endpoints enables endpoints configuration for the Rasa deployment. See: https://rasa.com/docs/pro/build/configuring-assistant#endpoints | `{}` |
| rasa.settings.environment | string | settings.environment sets the Rasa runtime environment. Use 'production' to disable certain development-only defaults. | `"development"` |
| rasa.settings.jwtMethod | string | settings.jwtMethod is JWT algorithm to be used | `"HS256"` |
| rasa.settings.jwtSecret | object | settings.jwtSecret references the Kubernetes Secret containing the JWT secret used to verify signed tokens for API authentication. | `{"secretKey":"jwtSecret","secretName":"rasa-secrets"}` |
| rasa.settings.logging.logLevel | string | logging.logLevel is Rasa Log Level | `"info"` |
| rasa.settings.mountDefaultConfigmap | bool | settings.mountDefaultConfigmap controls whether the chart mounts a ConfigMap containing credentials.yml and endpoints.yml into the Rasa container. When false, credentials and endpoints must be available at /.config or baked into the image. | `true` |
| rasa.settings.mountModelsVolume | bool | settings.mountModelsVolume controls whether the chart mounts a volume for Rasa models at /app/models. When false, models must be available at /app/models or baked into the image. | `true` |
| rasa.settings.port | int | settings.port defines port on which Rasa runs | `5005` |
| rasa.settings.scheme | string | settings.scheme defines scheme by which the service are accessible | `"http"` |
| rasa.settings.telemetry.debug | bool | telemetry.debug prints telemetry data to stdout | `false` |
| rasa.settings.telemetry.enabled | bool | telemetry.enabled allow Rasa to collect anonymous usage details | `true` |
| rasa.settings.useDefaultArgs | bool | settings.useDefaultArgs controls whether the chart injects default Rasa startup arguments. Keep true for standalone Rasa Pro deployments. Only disable when deploying as part of Rasa Studio. | `true` |
| rasa.strategy | object | rasa.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy | `{}` |
| rasa.tolerations | list | rasa.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| rasa.volumeMounts | list | rasa.volumeMounts specifies additional volumes to mount in the Rasa container | `[]` |
| rasa.volumes | list | rasa.volumes specify additional volumes to mount in the Rasa container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ | `[]` |
| rasaProLicense | object | rasaProLicense references the Kubernetes Secret that holds your Rasa Pro license key. Required for all Rasa Pro deployments. | `{"secretKey":"rasaProLicense","secretName":"rasa-secrets"}` |
| rasaProServices.additionalContainers | list | rasaProServices.additionalContainers allows to specify additional containers for the Rasa Pro Services Deployment | `[]` |
| rasaProServices.additionalEnv | list | rasaProServices.additionalEnv allows you to specify additional environment variables for the Rasa Pro Services container These are rendered as-is using toYaml, providing maximum flexibility for environment variable configuration Example:   additionalEnv:     - name: MY_CUSTOM_VAR       value: "some-value"     - name: SECRET_VAR       valueFrom:         secretKeyRef:           name: my-secret           key: secret-key     - name: CONFIGMAP_VAR       valueFrom:         configMapKeyRef:           name: my-configmap           key: config-key | `[]` |
| rasaProServices.affinity | object | rasaProServices.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| rasaProServices.autoscaling.enabled | bool | autoscaling.enabled specifies whether autoscaling should be enabled | `false` |
| rasaProServices.autoscaling.maxReplicas | int | autoscaling.maxReplicas specifies the maximum number of replicas | `100` |
| rasaProServices.autoscaling.minReplicas | int | autoscaling.minReplicas specifies the minimum number of replicas | `1` |
| rasaProServices.autoscaling.targetCPUUtilizationPercentage | int | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage | `80` |
| rasaProServices.containerSecurityContext | object | rasaProServices.containerSecurityContext defines security context that allows you to overwrite the container-level security context | `{"enabled":true}` |
| rasaProServices.database.databaseName | string | database.databaseName specifies the database name for the data lake to store analytics data in. Required if enableAwsRdsIam is true. To pass the database name from an existing secret instead, leave this empty and set databaseNameExistingSecretName and databaseNameExistingSecretKey:   databaseNameExistingSecretName: my-secret   databaseNameExistingSecretKey: analyticsDbName | `""` |
| rasaProServices.database.enableAwsRdsIam | bool | database.enableAwsRdsIam specifies whether to use AWS RDS IAM authentication for the Rasa Pro Services container. | `false` |
| rasaProServices.database.hostname | string | database.hostname specifies the hostname of the data lake to store analytics data in. Required if enableAwsRdsIam is true. | `""` |
| rasaProServices.database.port | string | database.port specifies the port for the data lake to store analytics data in. Required if enableAwsRdsIam is true. | `"5432"` |
| rasaProServices.database.sslCaLocation | string | database.sslCaLocation specifies the SSL CA location for the data lake to store analytics data in. Required if sslMode is verify-full. | `""` |
| rasaProServices.database.sslMode | string | database.sslMode specifies the SSL mode for the data lake to store analytics data in. Required if enableAwsRdsIam is true. | `""` |
| rasaProServices.database.url | string | database.url specifies the URL of the data lake to store analytics data in. Use `hostname` if you use IAM authentication. To pass the URL from an existing secret instead, leave this empty and set urlExistingSecretName and urlExistingSecretKey:   urlExistingSecretName: my-secret   urlExistingSecretKey: analyticsDbUrl | `""` |
| rasaProServices.database.username | string | database.username specifies the username for the data lake to store analytics data in. Required if enableAwsRdsIam is true. To pass the username from an existing secret instead, leave this empty and set usernameExistingSecretName and usernameExistingSecretKey:   usernameExistingSecretName: my-secret   usernameExistingSecretKey: analyticsDbUsername | `""` |
| rasaProServices.enabled | bool | rasaProServices.enabled enables the Rasa Pro Services deployment (analytics pipeline). Requires a connected analytics database. | `true` |
| rasaProServices.envFrom | list | rasaProServices.envFrom is used to add environment variables from ConfigMap or Secret | `[]` |
| rasaProServices.image.pullPolicy | string | image.pullPolicy specifies image pull policy | `"IfNotPresent"` |
| rasaProServices.image.repository | string | image.repository specifies image repository | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro-services"` |
| rasaProServices.image.tag | string | image.tag specifies image tag | `"3.8.0-latest"` |
| rasaProServices.imagePullSecrets | list | imagePullSecrets contains references to Secrets for pulling the Rasa Pro Services image from a private registry. Takes priority over the global imagePullSecrets when set. | `[]` |
| rasaProServices.kafka.brokerAddress | string | kafka.brokerAddress specifies the broker address for the Rasa Pro Services container. Required if enableAwsMskIam is true. | `""` |
| rasaProServices.kafka.consumerId | string | kafka.consumerId specifies the consumer ID for the Rasa Pro Services container. | `"rasa-analytics-group"` |
| rasaProServices.kafka.dlqTopic | string | kafka.dlqTopic specifies the DLQ topic fused to publish events that resulted in a processing failure. | `"rasa-analytics-dlq"` |
| rasaProServices.kafka.enableAwsMskIam | bool | kafka.enableAwsMskIam specifies whether to use AWS MSK IAM authentication for the Rasa Pro Services container. | `false` |
| rasaProServices.kafka.saslMechanism | string | kafka.saslMechanism specifies the SASL mechanism for the Rasa Pro Services container. Leave empty if you are using SSL. | `""` |
| rasaProServices.kafka.saslPassword | object | kafka.saslPassword specifies the SASL password for the Rasa Pro Services container. Do not set if enableAwsMskIam is true. | `{"secretKey":"kafkaSslPassword","secretName":"rasa-secrets"}` |
| rasaProServices.kafka.saslUsername | string | kafka.saslUsername specifies the SASL username for the Rasa Pro Services container. Do not set if enableAwsMskIam is true. | `""` |
| rasaProServices.kafka.securityProtocol | string | kafka.securityProtocol specifies the security protocol for the Rasa Pro Services container. Supported mechanisms are PLAINTEXT, SASL_PLAINTEXT, SASL_SSL and SSL | `""` |
| rasaProServices.kafka.sslCaLocation | string | kafka.sslCaLocation specifies the SSL CA location for the Rasa Pro Services container. | `""` |
| rasaProServices.kafka.sslCertFileLocation | string | kafka.sslCertFileLocation specifies the filepath for SSL client Certificate that will be used to connect with Kafka. Required if securityProtocol is SSL. | `""` |
| rasaProServices.kafka.sslKeyFileLocation | string | kafka.sslKeyFileLocation specifies the filepath for SSL Keyfile that will be used to connect with Kafka. Required if securityProtocol is SSL. | `""` |
| rasaProServices.kafka.topic | string | kafka.topic specifies the topic for the Rasa Pro Services container. | `"rasa-core-events"` |
| rasaProServices.livenessProbe.enabled | bool | livenessProbe.enabled is used to enable or disable liveness probe | `true` |
| rasaProServices.livenessProbe.failureThreshold | int | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| rasaProServices.livenessProbe.httpGet | object | livenessProbe.httpGet is used to define HTTP request | `{"path":"/healthcheck","port":8732,"scheme":"HTTP"}` |
| rasaProServices.livenessProbe.initialDelaySeconds | int | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| rasaProServices.livenessProbe.periodSeconds | int | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| rasaProServices.livenessProbe.successThreshold | int | livenessProbe.successThreshold is the minimum consecutive successes required before the probe is considered successful after a failure | `1` |
| rasaProServices.livenessProbe.terminationGracePeriodSeconds | int | livenessProbe.terminationGracePeriodSeconds is an optional duration in seconds the pod needs to terminate gracefully after a liveness probe failure | `30` |
| rasaProServices.livenessProbe.timeoutSeconds | int | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| rasaProServices.loggingLevel | string | rasaProServices.loggingLevel specifies the logging level for the Rasa Pro Services container. Valid levels are DEBUG, INFO, WARNING, ERROR, CRITICAL. | `"INFO"` |
| rasaProServices.nodeSelector | object | rasaProServices.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| rasaProServices.podAnnotations | object | rasaProServices.podAnnotations defines annotations to add to the pod | `{}` |
| rasaProServices.podSecurityContext | object | rasaProServices.podSecurityContext defines pod security context | `{"enabled":true}` |
| rasaProServices.readinessProbe.enabled | bool | readinessProbe.enabled is used to enable or disable readinessProbe | `true` |
| rasaProServices.readinessProbe.failureThreshold | int | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| rasaProServices.readinessProbe.httpGet | object | readinessProbe.httpGet is used to define HTTP request | `{"path":"/healthcheck","port":8732,"scheme":"HTTP"}` |
| rasaProServices.readinessProbe.initialDelaySeconds | int | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| rasaProServices.readinessProbe.periodSeconds | int | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| rasaProServices.readinessProbe.successThreshold | int | readinessProbe.successThreshold is the minimum consecutive successes required before the probe is considered successful after a failure | `1` |
| rasaProServices.readinessProbe.timeoutSeconds | int | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| rasaProServices.replicaCount | int | rasaProServices.replicaCount specifies number of replicas | `1` |
| rasaProServices.resources | object | rasaProServices.resources specifies the resources limits and requests | `{}` |
| rasaProServices.service | object | rasaProServices.service configures the Kubernetes Service exposing Rasa Pro Services. | `{"annotations":{},"port":8732,"targetPort":8732,"type":"ClusterIP"}` |
| rasaProServices.service.annotations | object | service.annotations defines annotations to add to the service | `{}` |
| rasaProServices.service.port | int | service.port is used to specify service port | `8732` |
| rasaProServices.service.targetPort | int | service.targetPort is the container port that Service traffic is forwarded to. Should match settings.port. | `8732` |
| rasaProServices.service.type | string | service.type is used to specify service type | `"ClusterIP"` |
| rasaProServices.serviceAccount | object | rasaProServices.serviceAccount defines service account | `{"annotations":{},"create":true,"name":""}` |
| rasaProServices.serviceAccount.annotations | object | serviceAccount.annotations defines annotations to add to the service account | `{}` |
| rasaProServices.serviceAccount.create | bool | serviceAccount.create specifies whether a service account should be created | `true` |
| rasaProServices.serviceAccount.name | string | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""` |
| rasaProServices.strategy | object | rasaProServices.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy | `{}` |
| rasaProServices.tolerations | list | rasaProServices.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| rasaProServices.useCloudProviderIam.enabled | bool | useCloudProviderIam.enabled specifies whether to use cloud provider IAM for the Rasa Pro Services container. | `false` |
| rasaProServices.useCloudProviderIam.provider | string | useCloudProviderIam.provider specifies the cloud provider for the Rasa Pro Services container. Supported value is aws | `"aws"` |
| rasaProServices.useCloudProviderIam.region | string | useCloudProviderIam.region specifies the region for IAM authentication. Required if IAM_CLOUD_PROVIDER is set to aws. | `"us-east-1"` |
| rasaProServices.volumeMounts | list | rasaProServices.volumeMounts specifies additional volumes to mount in the Rasa Pro Services container | `[]` |
| rasaProServices.volumes | list | rasaProServices.volumes specify additional volumes for the Rasa Pro Services container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ | `[]` |
